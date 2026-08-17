import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'create_family_screen.dart';
import 'join_family_screen.dart';

class FamilyChoiceScreen extends StatelessWidget {
  const FamilyChoiceScreen({super.key});

  void _openCreateFamily(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateFamilyScreen()),
    );
  }

  void _openJoinFamily(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JoinFamilyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.familySetup)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                children: [
                  const Spacer(),

                  Icon(
                    Icons.family_restroom,
                    size: 90,
                    color: Theme.of(context).colorScheme.primary,
                  ),

                  const SizedBox(height: 28),

                  Text(
                    strings.connectWithFamily,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    strings.createOrJoinFamily,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _openCreateFamily(context),
                      icon: const Icon(Icons.add_home_outlined),
                      label: Text(strings.createFamily),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openJoinFamily(context),
                      icon: const Icon(Icons.group_add_outlined),
                      label: Text(strings.joinFamily),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
