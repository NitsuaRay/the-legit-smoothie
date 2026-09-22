import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_legit_smoothie/features/auth/services/auth_service.dart';
import 'package:the_legit_smoothie/features/orders/screens/order_tracking_screen.dart';
import 'package:the_legit_smoothie/features/seller/screens/seller_order_detail_screen.dart';
import 'package:the_legit_smoothie/main.dart';

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  // ============================================================
  // SERVICES
  // ============================================================

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final SupabaseClient _supabase = Supabase.instance.client;

  final AuthService _authService = AuthService();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // ============================================================
  // SUBSCRIPTIONS
  // ============================================================

  StreamSubscription<String>? _tokenRefreshSubscription;

  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;

  StreamSubscription<RemoteMessage>? _notificationTapSubscription;

  // ============================================================
  // STATE
  // ============================================================

  bool _localNotificationsInitialized = false;

  String? _pendingOrderId;
  String? _pendingNotificationType;

  // ============================================================
  // PENDING NOTIFICATION DATA
  // ============================================================

  String? get pendingOrderId => _pendingOrderId;

  String? get pendingNotificationType => _pendingNotificationType;

  bool get hasPendingOrder =>
      _pendingOrderId != null && _pendingOrderId!.isNotEmpty;

  void clearPendingNotification() {
    _pendingOrderId = null;
    _pendingNotificationType = null;
  }

  // ============================================================
  // ANDROID NOTIFICATION CHANNEL
  // ============================================================

  static const AndroidNotificationChannel _notificationChannel =
      AndroidNotificationChannel(
        'the_legit_smoothie_notifications',
        'The Legit Smoothie Notifications',
        description:
            'Order updates and other notifications '
            'from The Legit Smoothie.',
        importance: Importance.high,
      );

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize() async {
    try {
      // --------------------------------------------------------
      // REQUEST FCM NOTIFICATION PERMISSION
      // --------------------------------------------------------

      await _messaging.requestPermission(alert: true, badge: true, sound: true);

      // --------------------------------------------------------
      // INITIALIZE LOCAL NOTIFICATIONS
      // --------------------------------------------------------

      await _initializeLocalNotifications();

      // --------------------------------------------------------
      // LISTEN FOR FOREGROUND FCM MESSAGES
      // --------------------------------------------------------

      await _foregroundMessageSubscription?.cancel();

      _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(
        _handleForegroundMessage,
        onError: (Object error) {},
      );

      // --------------------------------------------------------
      // LISTEN FOR BACKGROUND FCM NOTIFICATION TAPS
      // --------------------------------------------------------

      await _notificationTapSubscription?.cancel();

      _notificationTapSubscription = FirebaseMessaging.onMessageOpenedApp
          .listen(_handleRemoteNotificationTap, onError: (Object error) {});

      // --------------------------------------------------------
      // CHECK IF APP WAS OPENED FROM TERMINATED STATE
      // --------------------------------------------------------

      final RemoteMessage? initialMessage = await _messaging
          .getInitialMessage();

      if (initialMessage != null) {
        await _handleRemoteNotificationTap(initialMessage);
      }
      // --------------------------------------------------------
      // GET CURRENT FCM TOKEN
      // --------------------------------------------------------

      final String? token = await _messaging.getToken();

      if (token == null || token.isEmpty) {
        return;
      }

      // --------------------------------------------------------
      // SAVE CURRENT TOKEN
      // --------------------------------------------------------

      await _saveToken(token);

      // --------------------------------------------------------
      // LISTEN FOR TOKEN REFRESH
      // --------------------------------------------------------

      await _tokenRefreshSubscription?.cancel();

      _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((
        String newToken,
      ) async {
        try {
          await _saveToken(newToken);
        } catch (error) {
          debugPrint(
            'Unable to save refreshed FCM token: '
            '$error',
          );
        }
      }, onError: (Object error) {});
    } catch (error, stackTrace) {
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // ============================================================
  // INITIALIZE LOCAL NOTIFICATIONS
  // ============================================================

  Future<void> _initializeLocalNotifications() async {
    if (_localNotificationsInitialized) {
      return;
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      settings: initializationSettings,

      // --------------------------------------------------------
      // FOREGROUND LOCAL NOTIFICATION TAP
      // --------------------------------------------------------
      onDidReceiveNotificationResponse: _handleLocalNotificationTap,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidPlugin?.createNotificationChannel(_notificationChannel);

    _localNotificationsInitialized = true;
  }

  // ============================================================
  // FOREGROUND FCM MESSAGE
  // ============================================================

  Future<void> _handleForegroundMessage(RemoteMessage remoteMessage) async {
    try {
      final RemoteNotification? notification = remoteMessage.notification;

      if (notification == null) {
        return;
      }

      final String title = notification.title ?? 'The Legit Smoothie';

      final String body = notification.body ?? '';

      if (body.isEmpty) {
        return;
      }

      final int notificationId =
          remoteMessage.messageId?.hashCode ??
          DateTime.now().millisecondsSinceEpoch.remainder(2147483647);

      await _localNotifications.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _notificationChannel.id,
            _notificationChannel.name,
            channelDescription: _notificationChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: _buildNotificationPayload(remoteMessage),
      );
    } catch (error, stackTrace) {
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // ============================================================
  // BACKGROUND / TERMINATED FCM TAP
  // ============================================================

  Future<void> _handleRemoteNotificationTap(RemoteMessage message) async {
    final String? orderId = message.data['order_id'];

    final String? type = message.data['type'];

    _storePendingNotification(orderId: orderId, type: type);

    await _navigateToPendingOrder();
  }

  // ============================================================
  // FOREGROUND LOCAL NOTIFICATION TAP
  // ============================================================

  Future<void> _handleLocalNotificationTap(
    NotificationResponse response,
  ) async {
    final String? payload = response.payload;

    if (payload == null || payload.isEmpty) {
      return;
    }

    final Uri uri = Uri.parse('push://notification?$payload');

    final String? orderId = uri.queryParameters['order_id'];

    final String? type = uri.queryParameters['type'];

    _storePendingNotification(orderId: orderId, type: type);

    await _navigateToPendingOrder();
  }

  // ============================================================
  // STORE PENDING NOTIFICATION
  // ============================================================

  void _storePendingNotification({
    required String? orderId,
    required String? type,
  }) {
    if (orderId == null || orderId.isEmpty) {
      return;
    }

    _pendingOrderId = orderId;
    _pendingNotificationType = type;
  }

  Future<void> _navigateToPendingOrder() async {
    final String? orderId = _pendingOrderId;

    if (orderId == null || orderId.isEmpty) {
      return;
    }

    // ============================================================
    // CHECK WHETHER NAVIGATION IS READY
    // ============================================================

    final NavigatorState? navigator = navigatorKey.currentState;

    if (navigator == null) {
      return;
    }

    // ============================================================
    // CHECK AUTHENTICATION
    // ============================================================

    if (_supabase.auth.currentSession == null) {
      return;
    }

    try {
      // ==========================================================
      // GET CURRENT ROLE
      // ==========================================================

      final String? role = await _authService.getCurrentUserRole();

      if (role == null) {
        return;
      }

      // The pending notification could theoretically have changed
      // while awaiting the profile query.
      if (_pendingOrderId != orderId) {
        return;
      }

      // ==========================================================
      // SELLER
      // ==========================================================

      if (role == 'seller') {
        clearPendingNotification();

        navigator.push(
          MaterialPageRoute(
            builder: (_) => SellerOrderDetailScreen(orderId: orderId),
          ),
        );

        return;
      }

      // ==========================================================
      // CUSTOMER
      // ==========================================================

      if (role == 'customer') {
        clearPendingNotification();

        navigator.push(
          MaterialPageRoute(
            builder: (_) => OrderTrackingScreen(orderId: orderId),
          ),
        );
        return;
      }
    } catch (error) {
      // Keep the pending notification so SplashScreen or another
      // navigation attempt can still consume it.
      debugPrint(
        'Unable to navigate from push '
        'notification: $error',
      );
    }
  }

  // ============================================================
  // BUILD LOCAL NOTIFICATION PAYLOAD
  // ============================================================

  String? _buildNotificationPayload(RemoteMessage message) {
    final String? orderId = message.data['order_id'];

    final String? type = message.data['type'];

    if ((orderId == null || orderId.isEmpty) &&
        (type == null || type.isEmpty)) {
      return null;
    }

    return Uri(
      queryParameters: {
        if (orderId != null && orderId.isNotEmpty) 'order_id': orderId,
        if (type != null && type.isNotEmpty) 'type': type,
      },
    ).query;
  }

  // ============================================================
  // REMOVE CURRENT DEVICE TOKEN
  // ============================================================

  Future<void> removeCurrentDeviceToken() async {
    try {
      final User? user = _supabase.auth.currentUser;

      if (user == null) {
        return;
      }

      final String? token = await _messaging.getToken();

      if (token == null || token.isEmpty) {
        return;
      }

      await _supabase
          .from('device_tokens')
          .delete()
          .eq('user_id', user.id)
          .eq('token', token);

      clearPendingNotification();
    } catch (error, stackTrace) {
      debugPrintStack(stackTrace: stackTrace);

      rethrow;
    }
  }

  // ============================================================
  // REGISTER CURRENT DEVICE TOKEN
  // ============================================================

  Future<void> registerCurrentDeviceToken() async {
    try {
      final User? user = _supabase.auth.currentUser;

      if (user == null) {
        debugPrint(
          'FCM token registration skipped: '
          'no authenticated user.',
        );

        return;
      }

      final String? token = await _messaging.getToken();

      if (token == null || token.isEmpty) {
        debugPrint(
          'FCM token registration skipped: '
          'token unavailable.',
        );

        return;
      }

      await _saveToken(token);

      debugPrint(
        'FCM token registered for '
        'user ${user.id}.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Unable to register FCM token: '
        '$error',
      );

      debugPrintStack(stackTrace: stackTrace);

      rethrow;
    }
  }

  // ============================================================
  // SAVE TOKEN TO SUPABASE
  // ============================================================

  Future<void> _saveToken(String token) async {
    final User? user = _supabase.auth.currentUser;

    if (user == null) {
      return;
    }

    await _supabase.from('device_tokens').upsert({
      'user_id': user.id,
      'token': token,
      'platform': 'android',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'token');
  }
}
