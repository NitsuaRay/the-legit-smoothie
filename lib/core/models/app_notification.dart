class AppNotification {
  final String id;
  final String userId;
  final String? orderId;

  final String type;
  final String title;
  final String message;

  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    this.orderId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  // ============================================================
  // FROM SUPABASE JSON
  // ============================================================

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      orderId: json['order_id'] as String?,
      type: json['type'] as String? ?? 'notification',
      title: json['title'] as String? ?? 'Notification',
      message: json['message'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(
        json['created_at'] as String,
      ).toLocal(),
    );
  }

  // ============================================================
  // COPY WITH
  // Useful when marking a notification as read locally.
  // ============================================================

  AppNotification copyWith({
    String? id,
    String? userId,
    String? orderId,
    String? type,
    String? title,
    String? message,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderId: orderId ?? this.orderId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool get hasOrder => orderId != null && orderId!.isNotEmpty;

  bool get isOrderNotification {
    return type == 'new_order' ||
        type == 'order_accepted' ||
        type == 'order_preparing' ||
        type == 'ready_for_pickup' ||
        type == 'out_for_delivery' ||
        type == 'order_completed' ||
        type == 'order_cancelled';
  }

  @override
  String toString() {
    return 'AppNotification('
        'id: $id, '
        'type: $type, '
        'title: $title, '
        'isRead: $isRead, '
        'orderId: $orderId'
        ')';
  }
}