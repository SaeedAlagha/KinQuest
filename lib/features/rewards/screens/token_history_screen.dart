import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/token_transaction.dart';

class TokenHistoryScreen extends StatelessWidget {
  const TokenHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: SafeArea(child: Center(child: Text('No user is signed in.'))),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Token History')),
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
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Could not load Token history.',
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
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 52),
                      SizedBox(height: 14),
                      Text(
                        'No Token activity yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Token earnings and spending will appear here.',
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
    final amountText = '${isPositive ? '+' : ''}${transaction.amount} Tokens';

    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(_iconForType(transaction.type))),
        title: Text(
          transaction.reason.isEmpty
              ? _labelForType(transaction.type)
              : transaction.reason,
        ),
        subtitle: transaction.createdAt == null
            ? Text(_labelForType(transaction.type))
            : Text(
                '${_labelForType(transaction.type)} • '
                '${_formatDate(transaction.createdAt!)}',
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

  String _labelForType(TokenTransactionType type) {
    switch (type) {
      case TokenTransactionType.earned:
        return 'Earned';
      case TokenTransactionType.spent:
        return 'Spent';
      case TokenTransactionType.refunded:
        return 'Refunded';
      case TokenTransactionType.adjusted:
        return 'Adjusted';
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}
