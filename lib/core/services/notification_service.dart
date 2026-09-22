import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_notification.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================
  // CURRENT USER
  // ============================================================

  User? get currentUser => _supabase.auth.currentUser;

  String? get currentUserId => currentUser?.id;

  // ============================================================
  // GET NOTIFICATIONS
  // ============================================================

  Future<List<AppNotification>> getNotifications({
    int limit = 50,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      return [];
    }

    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map(
            (json) => AppNotification.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    } catch (e) {
      throw Exception(
        'Failed to load notifications: $e',
      );
    }
  }

  // ============================================================
  // GET UNREAD COUNT
  // ============================================================

  Future<int> getUnreadCount() async {
    final userId = currentUserId;

    if (userId == null) {
      return 0;
    }

    try {
      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      throw Exception(
        'Failed to get unread notification count: $e',
      );
    }
  }

  // ============================================================
  // MARK ONE NOTIFICATION AS READ
  // ============================================================

  Future<void> markAsRead(String notificationId) async {
    final userId = currentUserId;

    if (userId == null) {
      return;
    }

    try {
      await _supabase
          .from('notifications')
          .update({
            'is_read': true,
          })
          .eq('id', notificationId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception(
        'Failed to mark notification as read: $e',
      );
    }
  }

  // ============================================================
  // MARK ALL NOTIFICATIONS AS READ
  // ============================================================

  Future<void> markAllAsRead() async {
    final userId = currentUserId;

    if (userId == null) {
      return;
    }

    try {
      await _supabase
          .from('notifications')
          .update({
            'is_read': true,
          })
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception(
        'Failed to mark all notifications as read: $e',
      );
    }
  }

  // ============================================================
  // REALTIME NOTIFICATION LISTENER
  //
  // Whenever a notification is INSERTED for the currently
  // authenticated user, this stream emits the new notification.
  // ============================================================

  Stream<AppNotification> watchNewNotifications() {
    final userId = currentUserId;

    if (userId == null) {
      return const Stream.empty();
    }

    final controller = StreamController<AppNotification>();

    late final RealtimeChannel channel;

    channel = _supabase.channel(
      'notifications:$userId:${DateTime.now().microsecondsSinceEpoch}',
    );

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            try {
              final notification = AppNotification.fromJson(
                Map<String, dynamic>.from(payload.newRecord),
              );

              if (!controller.isClosed) {
                controller.add(notification);
              }
            } catch (e, stackTrace) {
              if (!controller.isClosed) {
                controller.addError(e, stackTrace);
              }
            }
          },
        )
        .subscribe();

    controller.onCancel = () async {
      await _supabase.removeChannel(channel);

      if (!controller.isClosed) {
        await controller.close();
      }
    };

    return controller.stream;
  }
}