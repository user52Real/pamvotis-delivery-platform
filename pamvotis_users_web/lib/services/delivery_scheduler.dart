import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryScheduler {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DateTime>> getAvailableTimeSlots(String restaurantId, DateTime date) async {
    List<DateTime> availableSlots = [];

    // Get restaurant operating hours
    DocumentSnapshot restaurant = await _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .get();

    Map<String, dynamic> operatingHours = restaurant.get('operatingHours');

    // Generate time slots
    DateTime startTime = DateTime(date.year, date.month, date.day,
        operatingHours['openTime']);
    DateTime endTime = DateTime(date.year, date.month, date.day,
        operatingHours['closeTime']);

    // Add slots every 30 minutes
    DateTime currentSlot = startTime;
    while (currentSlot.isBefore(endTime)) {
      availableSlots.add(currentSlot);
      currentSlot = currentSlot.add(const Duration(minutes: 30));
    }

    return availableSlots;
  }

  Future<bool> scheduleDelivery(String orderId, DateTime selectedTime) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'scheduledDeliveryTime': selectedTime,
        'isScheduledDelivery': true,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}