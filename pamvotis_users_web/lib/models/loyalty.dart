class LoyaltyProgram {
  final String userId;
  int points;
  LoyaltyTier tier;
  List<LoyaltyReward> availableRewards;

  LoyaltyProgram({
    required this.userId,
    this.points = 0,
    this.tier = LoyaltyTier.bronze,
    required this.availableRewards,
  });
}

enum LoyaltyTier { bronze, silver, gold, platinum }

class LoyaltyReward {
  final String id;
  final String title;
  final int pointsCost;
  final RewardType type;
  final double value;

  LoyaltyReward({
    required this.id,
    required this.title,
    required this.pointsCost,
    required this.type,
    required this.value,
  });
}

enum RewardType { discount, freeDelivery, freeItem }