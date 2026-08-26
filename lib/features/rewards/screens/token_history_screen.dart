import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../models/token_transaction.dart';

class TokenHistoryScreen extends StatelessWidget {
  const TokenHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final strings = AppLocalizations.of(context)!;

    if (user == null) {
      return Scaffold(
        body: SafeArea(child: Center(child: Text(strings.noUserSignedIn))),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.tokenHistory)),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('tokenTransactions')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    strings.tokenHistoryLoadFailed,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final transactions =
                snapshot.data?.docs
                    .map(TokenTransaction.fromDocument)
                    .toList() ??
                [];

            if (transactions.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.receipt_long_outlined, size: 52),
                      const SizedBox(height: 14),
                      Text(
                        strings.noTokenActivity,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        strings.tokenActivityDescription,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: transactions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final transaction = transactions[index];

                return _TokenTransactionCard(transaction: transaction);
              },
            );
          },
        ),
      ),
    );
  }
}

class _TokenTransactionCard extends StatelessWidget {
  const _TokenTransactionCard({required this.transaction});

  final TokenTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.amount > 0;
    final strings = AppLocalizations.of(context)!;
    final localizedAmount = strings.tokensAmount(transaction.amount.abs());
    final prefix = transaction.amount == 0 ? '' : (isPositive ? '+' : '-');
    final amountText = '$prefix$localizedAmount';
    final typeLabel = _labelForType(strings, transaction.type);

    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(_iconForType(transaction.type))),
        title: Text(
          transaction.reason.isEmpty ? typeLabel : transaction.reason,
        ),
        subtitle: transaction.createdAt == null
            ? Text(typeLabel)
            : Text(
                '$typeLabel • ${_formatDate(context, transaction.createdAt!)}',
              ),
        trailing: Text(
          amountText,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  IconData _iconForType(TokenTransactionType type) {
    switch (type) {
      case TokenTransactionType.earned:
        return Icons.add_circle_outline_rounded;
      case TokenTransactionType.spent:
        return Icons.remove_circle_outline_rounded;
      case TokenTransactionType.refunded:
        return Icons.replay_rounded;
      case TokenTransactionType.adjusted:
        return Icons.tune_rounded;
    }
  }

  String _labelForType(AppLocalizations strings, TokenTransactionType type) {
    switch (type) {
      case TokenTransactionType.earned:
        return strings.tokenEarned;
      case TokenTransactionType.spent:
        return strings.tokenSpent;
      case TokenTransactionType.refunded:
        return strings.tokenRefunded;
      case TokenTransactionType.adjusted:
        return strings.tokenAdjusted;
    }
  }

  String _formatDate(BuildContext context, Timestamp timestamp) {
    final date = timestamp.toDate();
    final material = MaterialLocalizations.of(context);
    return '${material.formatCompactDate(date)} ${material.formatTimeOfDay(TimeOfDay.fromDateTime(date))}';
  }
}
