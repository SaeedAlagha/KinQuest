import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SafeArea(
        child: Center(child: Text('No user is currently signed in.')),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, userSnapshot) {
        final userData = userSnapshot.data?.data();

        final name = userData?['name'] as String? ?? 'KinQuest User';
        final tokens = userData?['tokens'] ?? 0;
        final familyId = userData?['familyId'] as String?;

        if (familyId == null || familyId.isEmpty) {
          return _buildHomeContent(
            context,
            name: name,
            familyName: 'No family joined',
            memberCount: 0,
            tokens: tokens.toString(),
          );
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('families')
              .doc(familyId)
              .snapshots(),
          builder: (context, familySnapshot) {
            final familyData = familySnapshot.data?.data();

            final familyName = familyData?['name'] as String? ?? 'Your Family';

            final members = List<String>.from(
              familyData?['members'] ?? const [],
            );

            return _buildHomeContent(
              context,
              name: name,
              familyName: familyName,
              memberCount: members.length,
              tokens: tokens.toString(),
            );
          },
        );
      },
    );
  }

  Widget _buildHomeContent(
    BuildContext context, {
    required String name,
    required String familyName,
    required int memberCount,
    required String tokens,
  }) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $name',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(familyName, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 28),

            _HomeCard(
              icon: Icons.family_restroom,
              title: familyName,
              subtitle: '$memberCount family members',
              buttonText: 'Family Overview',
              onPressed: () {},
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _SmallHomeCard(
                    icon: Icons.groups_outlined,
                    title: 'Family Members',
                    value: memberCount.toString(),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _SmallHomeCard(
                    icon: Icons.stars_outlined,
                    title: 'Family Tokens',
                    value: tokens,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Text(
              'Quick actions',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontSize: 22),
            ),

            const SizedBox(height: 14),

            _QuickAction(
              icon: Icons.add_photo_alternate_outlined,
              title: 'Add a Memory',
              subtitle: 'Upload family photos and videos.',
              onTap: () {},
            ),

            const SizedBox(height: 12),

            _QuickAction(
              icon: Icons.sports_esports_outlined,
              title: 'Challenge a Family Member',
              subtitle: 'Start a friendly family match.',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(subtitle),
          const SizedBox(height: 18),
          FilledButton(onPressed: onPressed, child: Text(buttonText)),
        ],
      ),
    );
  }
}

class _SmallHomeCard extends StatelessWidget {
  const _SmallHomeCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
