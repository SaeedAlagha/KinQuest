import 'package:flutter/material.dart';

import 'create_family_screen.dart';
import 'join_family_screen.dart';

class FamilyChoiceScreen extends StatelessWidget {
  const FamilyChoiceScreen({super.key});

  void _openCreateFamily(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateFamilyScreen(),
      ),
    );
  }

  void _openJoinFamily(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const JoinFamilyScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Setup'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                'Connect with your family',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 12),

              Text(
                'Create a new family group or join an existing one.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _openCreateFamily(context),
                  icon: const Icon(Icons.add_home_outlined),
                  label: const Text('Create a Family'),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openJoinFamily(context),
                  icon: const Icon(Icons.group_add_outlined),
                  label: const Text('Join a Family'),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}