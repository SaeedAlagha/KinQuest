import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8DEFF),
                  shape: BoxShape.circle,
                ),
                child:  Icon(
                  Icons.family_restroom,
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'KinQuest',
                style: Theme.of(context).textTheme.displaySmall,
              ),

              const SizedBox(height: 12),

              Text(
                'Play Together. Learn Together. Grow Together.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      height: 1.5,
                    ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                onPressed: () {},
                child: const Text('Log In'),
                ),
            ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                onPressed: () {},
                child: const Text('Create Account'),
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