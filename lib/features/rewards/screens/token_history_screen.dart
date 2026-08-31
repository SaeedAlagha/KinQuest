import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/mascot/sila_mascot.dart';
import '../../../l10n/app_localizations.dart';
import '../../mascot/widgets/sila_companion_callout.dart';
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
              return _TokenHistoryState(
                userId: user.uid,
                title: strings.tokenHistory,
                message: strings.tokenHistoryLoadFailed,
                pose: SilaMascotPose.oops,
              );
            }

            final transactions =
                snapshot.data?.docs
                    .map(TokenTransaction.fromDocument)
                    .toList() ??
                [];

            if (transactions.isEmpty) {
              return _TokenHistoryState(
                userId: user.uid,
                title: strings.noTokenActivity,
                message: strings.tokenActivityDescription,
                pose: SilaMascotPose.encouraging,
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

class _TokenHistoryState extends StatelessWidget {
  const _TokenHistoryState({
    required this.userId,
    required this.title,
    required this.message,
    required this.pose,
  });

  final String userId;
  final String title;
  final String message;
  final SilaMascotPose pose;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SilaCompanionCallout(
            key: const ValueKey('token-history-sila-state'),
            userId: userId,
            title: title,
            message: message,
            pose: pose,
          ),
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
