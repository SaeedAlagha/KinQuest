import 'package:flutter/material.dart';

import 'features/authentication/screens/welcome_screen.dart';

void main() {
  runApp(const KinQuestApp());
}

class KinQuestApp extends StatelessWidget {
  const KinQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KinQuest',
      home: const WelcomeScreen(),
    );
  }
}