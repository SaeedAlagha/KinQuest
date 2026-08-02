import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
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
                child: const Icon(
                  Icons.family_restroom,
                  size: 64,
                  color: Color(0xFF6750A4),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'KinQuest',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF241A35),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Play Together. Learn Together. Grow Together.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.5,
                  color: Color(0xFF625B71),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6750A4),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6750A4),
                    side: const BorderSide(
                      color: Color(0xFF6750A4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
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