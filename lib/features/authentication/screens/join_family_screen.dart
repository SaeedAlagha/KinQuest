import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/validation/form_validators.dart';
import '../../home/screens/main_navigation_screen.dart';

class JoinFamilyScreen extends StatefulWidget {
  const JoinFamilyScreen({super.key});

  @override
  State<JoinFamilyScreen> createState() => _JoinFamilyScreenState();
}

class _JoinFamilyScreenState extends State<JoinFamilyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isJoiningFamily = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinFamily() async {
  FocusScope.of(context).unfocus();

  final isValid = _formKey.currentState?.validate() ?? false;

  if (!isValid) {
    return;
  }

  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You must be logged in to join a family.'),
      ),
    );
    return;
  }

  setState(() {
    _isJoiningFamily = true;
  });

  try {
    final code = _codeController.text.trim().toUpperCase();

    final familyReference =
        FirebaseFirestore.instance.collection('families').doc(code);

    final familySnapshot = await familyReference.get();

    if (!familySnapshot.exists) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invitation code not found.'),
        ),
      );

      return;
    }

    await familyReference.update({
      'members': FieldValue.arrayUnion([user.uid]),
    });

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const MainNavigationScreen(),
      ),
      (route) => false,
    );
  } on FirebaseException {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Could not join the family. Please try again.',
        ),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isJoiningFamily = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Family')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                Text(
                  'Join your family',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 8),

                Text(
                  'Enter the six-character invitation code shared by your family.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 36),

                TextFormField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.done,
                  maxLength: 6,
                  validator: FormValidators.validateInvitationCode,
                  onFieldSubmitted: (_) => _joinFamily(),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Invitation code',
                    hintText: 'A7K9Q2',
                    prefixIcon: Icon(Icons.key_outlined),
                    counterText: '',
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isJoiningFamily ? null : _joinFamily,
                    icon: const Icon(Icons.group_add_outlined),
                    label: Text(
                      _isJoiningFamily ? 'Joining Family...' : 'Join Family',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
