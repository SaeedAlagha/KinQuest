import 'package:flutter/material.dart';

class DontSayItScreen extends StatelessWidget {
  const DontSayItScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Don\'t Say It'),
      ),
      body: const Center(
        child: Text(
          'Don\'t Say It setup coming next.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}