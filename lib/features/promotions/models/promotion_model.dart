class PromotionModel {
  final String id;
  final String title;
  final String description;
  final String bannerUrl;
  final String discountTag;
  final String? targetProductId;
  final DateTime? validUntil;

  PromotionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.bannerUrl,
    required this.discountTag,
    this.targetProductId,
    this.validUntil,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      bannerUrl: json['banner_url'] ?? '',
      discountTag: json['discount_tag'] ?? 'SPECIAL OFFER',
      targetProductId: json['target_product_id'],
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'])
          : null,
    );
  }
}