class Promotion {
  final String id;
  final String title;
  final String description;
  final double discountPercentage;
  final double minimumOrderAmount;
  final DateTime validFrom;
  final DateTime validUntil;
  final String? couponCode;
  final bool isActive;
  final List<String> applicableItems;
  final PromotionType type;

  Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.minimumOrderAmount,
    required this.validFrom,
    required this.validUntil,
    this.couponCode,
    this.isActive = true,
    required this.applicableItems,
    required this.type,
  });
}

enum PromotionType {
  percentageDiscount,
  freeDelivery,
  buyOneGetOne,
  firstOrder,
  bulkDiscount
}