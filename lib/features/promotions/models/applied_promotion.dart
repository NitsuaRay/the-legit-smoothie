class AppliedPromotion {
  final String id;
  final String title;
  final String promotionType;
  final String discountType;

  final double discountValue;
  final double discountAmount;
  final double eligibleSubtotal;
  final double cartSubtotal;
  final double finalSubtotal;

  final Map<String, dynamic> snapshot;

  const AppliedPromotion({
    required this.id,
    required this.title,
    required this.promotionType,
    required this.discountType,
    required this.discountValue,
    required this.discountAmount,
    required this.eligibleSubtotal,
    required this.cartSubtotal,
    required this.finalSubtotal,
    required this.snapshot,
  });

  factory AppliedPromotion.fromMap(
    Map<String, dynamic> map,
  ) {
    return AppliedPromotion(
      id: map['promotion_id']?.toString() ?? '',
      title: map['promotion_title']?.toString() ?? '',
      promotionType:
          map['promotion_type']?.toString() ?? '',
      discountType:
          map['discount_type']?.toString() ?? '',
      discountValue:
          _toDouble(map['discount_value']),
      discountAmount:
          _toDouble(map['discount_amount']),
      eligibleSubtotal:
          _toDouble(map['eligible_subtotal']),
      cartSubtotal:
          _toDouble(map['cart_subtotal']),
      finalSubtotal:
          _toDouble(map['final_subtotal']),
      snapshot: _toMap(
        map['promotion_snapshot'],
      ),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static Map<String, dynamic> _toMap(
    dynamic value,
  ) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  int get applications {
    final dynamic value = snapshot['applications'];

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  bool get isMixAndMatch =>
      promotionType == 'mix_and_match';

  bool get hasDiscount =>
      discountAmount > 0;

  String get savingsLabel =>
      '₱${discountAmount.toStringAsFixed(2)}';
}