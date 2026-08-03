import 'package:flutter/material.dart';

class JoinFamilyScreen extends StatelessWidget {
  const JoinFamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Family'),
      ),
      body: const Center(
        child: Text(
          'Join Family Screen',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}