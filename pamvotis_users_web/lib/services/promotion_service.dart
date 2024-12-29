import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/promotion.dart';

class PromotionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<double> calculateDiscount(String orderId, items, double subtotal) async {
    double discount = 0;

    // Get applicable promotions
    QuerySnapshot promoSnapshot = await _firestore
        .collection('promotions')
        .where('isActive', isEqualTo: true)
        .where('validUntil', isGreaterThan: DateTime.now())
        .get();

    for (var promo in promoSnapshot.docs) {
      Map<String, dynamic> promoData = promo.data() as Map<String, dynamic>;

      if (subtotal >= promoData['minimumOrderAmount']) {
        switch (PromotionType.values[promoData['type']]) {
          case PromotionType.percentageDiscount:
            discount = subtotal * (promoData['discountPercentage'] / 100);
            break;
          case PromotionType.freeDelivery:
            discount = 5.0; // Assuming fixed delivery fee
            break;
        // Add other promotion types
          case PromotionType.buyOneGetOne:
            // TODO: Handle this case.
          case PromotionType.firstOrder:
            // TODO: Handle this case.
          case PromotionType.bulkDiscount:
            // TODO: Handle this case.
        }
      }
    }
    return discount;
  }
}