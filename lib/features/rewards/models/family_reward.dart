import 'package:cloud_firestore/cloud_firestore.dart';

enum FamilyRewardType { family, digital }

enum RewardAvailability { unlimited, daily, weekly, monthly, oneTime }

class FamilyReward {
  const FamilyReward({
    required this.id,
    required this.title,
    required this.description,
    required this.tokenCost,
    required this.type,
    required this.approvalRequired,
    required this.availability,
    required this.active,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final int tokenCost;
  final FamilyRewardType type;
  final bool approvalRequired;
  final RewardAvailability availability;
  final bool active;
  final String createdBy;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  factory FamilyReward.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};

    return FamilyReward(
      id: document.id,
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      tokenCost: (data['tokenCost'] as num?)?.toInt() ?? 0,
      type: _rewardTypeFromString(data['type']?.toString()),
      approvalRequired: data['approvalRequired'] as bool? ?? true,
      availability: _availabilityFromString(data['availability']?.toString()),
      active: data['active'] as bool? ?? true,
      createdBy: data['createdBy']?.toString() ?? '',
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title.trim(),
      'description': description.trim(),
      'tokenCost': tokenCost,
      'type': type.name,
      'approvalRequired': approvalRequired,
      'availability': availability.name,
      'active': active,
      'createdBy': createdBy,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static FamilyRewardType _rewardTypeFromString(String? value) {
    return FamilyRewardType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => FamilyRewardType.family,
    );
  }

  static RewardAvailability _availabilityFromString(String? value) {
    return RewardAvailability.values.firstWhere(
      (availability) => availability.name == value,
      orElse: () => RewardAvailability.unlimited,
    );
  }
}
