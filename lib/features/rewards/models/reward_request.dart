import 'package:cloud_firestore/cloud_firestore.dart';

enum RewardRequestStatus {
  pending,
  approved,
  declined,
  cancelled,
  completed,
  expired,
}

class RewardRequest {
  const RewardRequest({
    required this.id,
    required this.familyId,
    required this.userId,
    required this.rewardId,
    required this.rewardTitle,
    required this.tokenCost,
    required this.status,
    this.approverId,
    this.requesterNote,
    this.approverNote,
    this.createdAt,
    this.updatedAt,
    this.approvedAt,
    this.completedAt,
  });

  final String id;
  final String familyId;
  final String userId;
  final String rewardId;
  final String rewardTitle;
  final int tokenCost;
  final RewardRequestStatus status;

  final String? approverId;
  final String? requesterNote;
  final String? approverNote;

  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final Timestamp? approvedAt;
  final Timestamp? completedAt;

  factory RewardRequest.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};

    return RewardRequest(
      id: document.id,
      familyId: data['familyId']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      rewardId: data['rewardId']?.toString() ?? '',
      rewardTitle: data['rewardTitle']?.toString() ?? '',
      tokenCost: (data['tokenCost'] as num?)?.toInt() ?? 0,
      status: _statusFromString(data['status']?.toString()),
      approverId: data['approverId']?.toString(),
      requesterNote: data['requesterNote']?.toString(),
      approverNote: data['approverNote']?.toString(),
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
      approvedAt: data['approvedAt'] as Timestamp?,
      completedAt: data['completedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'familyId': familyId,
      'userId': userId,
      'rewardId': rewardId,
      'rewardTitle': rewardTitle.trim(),
      'tokenCost': tokenCost,
      'status': status.name,
      'approverId': approverId,
      'requesterNote': requesterNote?.trim(),
      'approverNote': approverNote?.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static RewardRequestStatus _statusFromString(String? value) {
    return RewardRequestStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => RewardRequestStatus.pending,
    );
  }
}
