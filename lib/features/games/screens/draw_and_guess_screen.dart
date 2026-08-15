import 'package:flutter/material.dart';

class DrawAndGuessScreen extends StatelessWidget {
  const DrawAndGuessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw & Guess'),
      ),
      body: const Center(
        child: Text(
          'Draw & Guess setup coming next.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}