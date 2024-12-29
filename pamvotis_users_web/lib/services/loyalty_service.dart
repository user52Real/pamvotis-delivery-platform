import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/loyalty.dart';

class LoyaltyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addPoints(String userId, double orderAmount) async {
    // Add 1 point per $1 spent
    int pointsToAdd = orderAmount.floor();

    await _firestore.collection('loyalty').doc(userId).update({
      'points': FieldValue.increment(pointsToAdd),
    });

    // Check and update tier if necessary
    await updateTier(userId);
  }

  Future<void> updateTier(String userId) async {
    DocumentSnapshot userLoyalty = await _firestore
        .collection('loyalty')
        .doc(userId)
        .get();

    int points = userLoyalty.get('points');
    LoyaltyTier newTier;

    if (points >= 1000) newTier = LoyaltyTier.platinum;
    else if (points >= 500) newTier = LoyaltyTier.gold;
    else if (points >= 200) newTier = LoyaltyTier.silver;
    else newTier = LoyaltyTier.bronze;

    await _firestore.collection('loyalty').doc(userId).update({
      'tier': newTier.index,
    });
  }
}