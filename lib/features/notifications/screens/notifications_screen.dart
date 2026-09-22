import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/app_notification.dart';
import '../../../core/services/notification_service.dart';

// Adjust only these 2 import paths if your actual folders differ.
import '../../orders/screens/order_tracking_screen.dart';
import '../../seller/screens/seller_order_detail_screen.dart';

// =================================================================
// VIEWER TYPE
// =================================================================

enum NotificationViewer {
  customer,
  seller,
}

// =================================================================
// NOTIFICATIONS SCREEN
// =================================================================

class NotificationsScreen extends StatefulWidget {
  final NotificationViewer viewer;

  const NotificationsScreen({
    super.key,
    required this.viewer,
  });

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService =
      NotificationService.instance;

  List<AppNotification> _notifications = [];

  StreamSubscription<AppNotification>? _notificationSubscription;

  bool _isLoading = true;
  bool _isMarkingAllRead = false;

  // =============================================================
  // LIFECYCLE
  // =============================================================

  @override
  void initState() {
    super.initState();

    _loadNotifications();
    _listenForNotifications();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();

    super.dispose();
  }

  // =============================================================
  // LOAD NOTIFICATIONS
  // =============================================================

  Future<void> _loadNotifications() async {
    try {
      final notifications =
          await _notificationService.getNotifications();

      if (!mounted) {
        return;
      }

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (error) {


      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Unable to load notifications.',
      );
    }
  }

  // =============================================================
  // REALTIME
  // =============================================================

  void _listenForNotifications() {
    _notificationSubscription =
        _notificationService.watchNewNotifications().listen(
      (notification) {
        if (!mounted) {
          return;
        }

        setState(() {
          final alreadyExists = _notifications.any(
            (item) => item.id == notification.id,
          );

          if (!alreadyExists) {
            _notifications.insert(
              0,
              notification,
            );
          }
        });
      },
      onError: (Object error) {
      },
    );
  }

  // =============================================================
  // MARK ONE AS READ
  // =============================================================

  Future<void> _markAsRead(
    AppNotification notification,
  ) async {
    if (notification.isRead) {
      return;
    }

    try {
      await _notificationService.markAsRead(
        notification.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        final index = _notifications.indexWhere(
          (item) => item.id == notification.id,
        );

        if (index != -1) {
          _notifications[index] =
              _notifications[index].copyWith(
            isRead: true,
          );
        }
      });
    } catch (error) {
      debugPrint(
        'Failed to mark notification as read: $error',
      );
    }
  }

  // =============================================================
  // MARK ALL AS READ
  // =============================================================

  Future<void> _markAllAsRead() async {
    if (_isMarkingAllRead || _unreadCount == 0) {
      return;
    }

    setState(() {
      _isMarkingAllRead = true;
    });

    try {
      await _notificationService.markAllAsRead();

      if (!mounted) {
        return;
      }

      setState(() {
        _notifications = _notifications
            .map(
              (notification) => notification.copyWith(
                isRead: true,
              ),
            )
            .toList();
      });
    } catch (error) {

      if (mounted) {
        _showMessage(
          'Unable to mark notifications as read.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isMarkingAllRead = false;
        });
      }
    }
  }

  // =============================================================
  // NOTIFICATION TAP
  // =============================================================

  Future<void> _onNotificationTap(
    AppNotification notification,
  ) async {
    // Mark this notification as read first.
    await _markAsRead(notification);

    if (!mounted) {
      return;
    }

    final String? orderId = notification.orderId;

    // Some future notification types may not belong to an order.
    if (orderId == null || orderId.trim().isEmpty) {
      return;
    }

    // ===========================================================
    // SELLER
    // ===========================================================

    if (widget.viewer == NotificationViewer.seller) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SellerOrderDetailScreen(
            orderId: orderId,
          ),
        ),
      );

      return;
    }

    // ===========================================================
    // CUSTOMER
    // ===========================================================

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderTrackingScreen(
          orderId: orderId,
        ),
      ),
    );
  }

  // =============================================================
  // HELPERS
  // =============================================================

  int get _unreadCount {
    return _notifications.where(
      (notification) => !notification.isRead,
    ).length;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(
            18,
            0,
            18,
            18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _notifications.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: AppColors.textPrimary,
                          onRefresh: _loadNotifications,
                          child: ListView.separated(
                            physics:
                                const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.fromLTRB(
                              18,
                              8,
                              18,
                              30,
                            ),
                            itemCount: _notifications.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final notification =
                                  _notifications[index];

                              return _NotificationCard(
                                notification: notification,
                                onTap: () {
                                  _onNotificationTap(
                                    notification,
                                  );
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // HEADER
  // =============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        14,
        18,
        16,
      ),
      child: Row(
        children: [
          _HeaderButton(
            icon: Icons.arrow_back_rounded,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'NOTIFICATIONS',
                  style: TextStyle(
                    fontSize: 7.5,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: AppColors.textSecondary
                        .withValues(alpha: 0.55),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Updates for you',
                  style: TextStyle(
                    fontSize: 20,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.55,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          if (_unreadCount > 0)
            TextButton(
              onPressed: _isMarkingAllRead
                  ? null
                  : _markAllAsRead,
              style: TextButton.styleFrom(
                foregroundColor:
                    AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
              child: _isMarkingAllRead
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                            AppColors.textPrimary,
                      ),
                    )
                  : const Text(
                      'Mark all read',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  // =============================================================
  // LOADING
  // =============================================================

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: AppColors.textPrimary,
      ),
    );
  }

  // =============================================================
  // EMPTY
  // =============================================================

  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: AppColors.textPrimary,
      onRefresh: _loadNotifications,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        children: [
          SizedBox(
            height:
                MediaQuery.sizeOf(context).height *
                    0.18,
          ),

          Center(
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.border
                      .withValues(alpha: 0.30),
                ),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 28,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'No notifications yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.45,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Order updates and other important '
            'activity will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary
                  .withValues(alpha: 0.70),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// NOTIFICATION CARD
// =================================================================

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool unread = !notification.isRead;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: unread
                ? AppColors.surface
                : AppColors.surface
                    .withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: unread
                  ? AppColors.textPrimary
                      .withValues(alpha: 0.13)
                  : AppColors.border
                      .withValues(alpha: 0.25),
            ),
            boxShadow: unread
                ? [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: 0.035),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _NotificationIcon(
                type: notification.type,
                unread: unread,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.2,
                              fontWeight: unread
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              color:
                                  AppColors.textPrimary,
                            ),
                          ),
                        ),

                        if (unread) ...[
                          const SizedBox(width: 8),

                          Container(
                            width: 7,
                            height: 7,
                            decoration:
                                const BoxDecoration(
                              color:
                                  AppColors.textPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary
                            .withValues(alpha: 0.78),
                      ),
                    ),

                    const SizedBox(height: 9),

                    Text(
                      _formatTime(
                        notification.createdAt,
                      ),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary
                            .withValues(alpha: 0.50),
                      ),
                    ),
                  ],
                ),
              ),

              if (notification.hasOrder) ...[
                const SizedBox(width: 8),

                Padding(
                  padding:
                      const EdgeInsets.only(top: 13),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: AppColors.textSecondary
                        .withValues(alpha: 0.45),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================
  // TIME
  // =============================================================

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative) {
      return 'Just now';
    }

    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;

      return '$minutes '
          '${minutes == 1 ? 'minute' : 'minutes'} ago';
    }

    if (difference.inHours < 24) {
      final hours = difference.inHours;

      return '$hours '
          '${hours == 1 ? 'hour' : 'hours'} ago';
    }

    if (difference.inDays < 7) {
      final days = difference.inDays;

      return '$days '
          '${days == 1 ? 'day' : 'days'} ago';
    }

    return '${_monthName(dateTime.month)} '
        '${dateTime.day}, ${dateTime.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }
}

// =================================================================
// NOTIFICATION ICON
// =================================================================

class _NotificationIcon extends StatelessWidget {
  final String type;
  final bool unread;

  const _NotificationIcon({
    required this.type,
    required this.unread,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: unread
            ? AppColors.textPrimary
            : AppColors.background,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: unread
              ? AppColors.textPrimary
              : AppColors.border
                  .withValues(alpha: 0.30),
        ),
      ),
      child: Icon(
        _icon,
        size: 19,
        color: unread
            ? Colors.white
            : AppColors.textPrimary,
      ),
    );
  }

  IconData get _icon {
    switch (type) {
      case 'new_order':
        return Icons.shopping_bag_outlined;

      case 'order_accepted':
        return Icons.check_circle_outline_rounded;

      case 'order_preparing':
        return Icons.blender_outlined;

      case 'ready_for_pickup':
        return Icons.shopping_bag_rounded;

      case 'out_for_delivery':
        return Icons.delivery_dining_outlined;

      case 'order_completed':
        return Icons.task_alt_rounded;

      case 'order_cancelled':
        return Icons.cancel_outlined;

      default:
        return Icons.notifications_none_rounded;
    }
  }
}

// =================================================================
// HEADER BUTTON
// =================================================================

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border
                  .withValues(alpha: 0.35),
            ),
          ),
          child: Icon(
            icon,
            size: 19,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}