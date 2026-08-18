import 'package:cloud_firestore/cloud_firestore.dart';

enum TokenTransactionType { earned, spent, refunded, adjusted }

class TokenTransaction {
  const TokenTransaction({
    required this.id,
    required this.userId,
    required this.familyId,
    required this.amount,
    required this.type,
    required this.reason,
    this.relatedRewardId,
    this.relatedRequestId,
    this.relatedCompetitionId,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String familyId;
  final int amount;
  final TokenTransactionType type;
  final String reason;

  final String? relatedRewardId;
  final String? relatedRequestId;
  final String? relatedCompetitionId;

  final Timestamp? createdAt;

  factory TokenTransaction.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};

    return TokenTransaction(
      id: document.id,
      userId: data['userId']?.toString() ?? '',
      familyId: data['familyId']?.toString() ?? '',
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      type: _typeFromString(data['type']?.toString()),
      reason: data['reason']?.toString() ?? '',
      relatedRewardId: data['relatedRewardId']?.toString(),
      relatedRequestId: data['relatedRequestId']?.toString(),
      relatedCompetitionId: data['relatedCompetitionId']?.toString(),
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'familyId': familyId,
      'amount': amount,
      'type': type.name,
      'reason': reason.trim(),
      'relatedRewardId': relatedRewardId,
      'relatedRequestId': relatedRequestId,
      'relatedCompetitionId': relatedCompetitionId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static TokenTransactionType _typeFromString(String? value) {
    return TokenTransactionType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => TokenTransactionType.adjusted,
    );
  }
}
