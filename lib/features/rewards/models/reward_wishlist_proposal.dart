import 'package:cloud_firestore/cloud_firestore.dart';

enum RewardWishlistStatus {
  requested,
  offered,
  accepted,
  declined,
  rejected,
  readyToRedeem,
  redemptionRequested,
  completed,
  cancelled,
}

class RewardWishlistProposal {
  const RewardWishlistProposal({
    required this.id,
    required this.familyId,
    required this.requesterId,
    required this.requesterName,
    required this.recipientId,
    required this.recipientName,
    required this.title,
    required this.description,
    required this.status,
    required this.tokenRequirement,
    required this.dailyWinsRequired,
    required this.weeklyWinsRequired,
    required this.monthlyWinsRequired,
    required this.missionsRequired,
    this.createdAt,
    this.offeredAt,
    this.acceptedAt,
    this.completedAt,
  });

  final String id;
  final String familyId;

  final String requesterId;
  final String requesterName;

  final String recipientId;
  final String recipientName;

  final String title;
  final String description;

  final RewardWishlistStatus status;

  final int tokenRequirement;
  final int dailyWinsRequired;
  final int weeklyWinsRequired;
  final int monthlyWinsRequired;
  final int missionsRequired;

  final Timestamp? createdAt;
  final Timestamp? offeredAt;
  final Timestamp? acceptedAt;
  final Timestamp? completedAt;

  factory RewardWishlistProposal.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};

    return RewardWishlistProposal(
      id: document.id,
      familyId: data['familyId']?.toString() ?? '',
      requesterId: data['requesterId']?.toString() ?? '',
      requesterName: data['requesterName']?.toString() ?? 'Family Member',
      recipientId: data['recipientId']?.toString() ?? '',
      recipientName: data['recipientName']?.toString() ?? 'Family Member',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      status: _statusFromString(data['status']?.toString()),
      tokenRequirement: (data['tokenRequirement'] as num?)?.toInt() ?? 0,
      dailyWinsRequired: (data['dailyWinsRequired'] as num?)?.toInt() ?? 0,
      weeklyWinsRequired: (data['weeklyWinsRequired'] as num?)?.toInt() ?? 0,
      monthlyWinsRequired: (data['monthlyWinsRequired'] as num?)?.toInt() ?? 0,
      missionsRequired: (data['missionsRequired'] as num?)?.toInt() ?? 0,
      createdAt: data['createdAt'] as Timestamp?,
      offeredAt: data['offeredAt'] as Timestamp?,
      acceptedAt: data['acceptedAt'] as Timestamp?,
      completedAt: data['completedAt'] as Timestamp?,
    );
  }

  static RewardWishlistStatus _statusFromString(String? value) {
    return RewardWishlistStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => RewardWishlistStatus.requested,
    );
  }
}
