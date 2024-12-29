import 'package:cloud_firestore/cloud_firestore.dart';

class DynamicPricingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<double> calculateDynamicPrice(String itemId, String restaurantId) async {
    DocumentSnapshot item = await _firestore
        .collection('items')
        .doc(itemId)
        .get();

    double basePrice = item.get('basePrice');
    double finalPrice = basePrice;

    // Factor 1: Time of day
    int currentHour = DateTime.now().hour;
    if (currentHour >= 11 && currentHour <= 14) { // Lunch rush
      finalPrice *= 1.1; // 10% increase
    }

    // Factor 2: Day of week
    if (DateTime.now().weekday >= 5) { // Weekend
      finalPrice *= 1.15; // 15% increase
    }

    // Factor 3: Current demand
    int activeOrders = await getActiveOrders(restaurantId);
    if (activeOrders > 10) {
      finalPrice *= 1.2; // 20% increase during high demand
    }

    return finalPrice;
  }

  Future<int> getActiveOrders(String restaurantId) async {
    QuerySnapshot activeOrders = await _firestore
        .collection('orders')
        .where('restaurantId', isEqualTo: restaurantId)
        .where('status', whereIn: ['preparing', 'delivering'])
        .get();

    return activeOrders.docs.length;
  }
}