import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/validation/form_validators.dart';
import '../../home/screens/main_navigation_screen.dart';

class CreateFamilyScreen extends StatefulWidget {
  const CreateFamilyScreen({super.key});

  @override
  State<CreateFamilyScreen> createState() => _CreateFamilyScreenState();
}

class _CreateFamilyScreenState extends State<CreateFamilyScreen> {
  final _formKey = GlobalKey<FormState>();

  final _familyNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _invitationCode;
  bool _isCreatingFamily = false;

  @override
  void dispose() {
    _familyNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _generateInvitationCode() {
    const characters = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();

    return List.generate(
      6,
      (_) => characters[random.nextInt(characters.length)],
    ).join();
  }

  Future<void> _createFamily() async {
  FocusScope.of(context).unfocus();

  final isValid = _formKey.currentState?.validate() ?? false;

  if (!isValid) {
    return;
  }

  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You must be logged in to create a family.'),
      ),
    );
    return;
  }

  setState(() {
    _isCreatingFamily = true;
  });

  try {
    String invitationCode;
    DocumentReference<Map<String, dynamic>> familyReference;

    do {
      invitationCode = _generateInvitationCode();

      familyReference = FirebaseFirestore.instance
          .collection('families')
          .doc(invitationCode);
    } while ((await familyReference.get()).exists);

    await familyReference.set({
      'name': _familyNameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'invitationCode': invitationCode,
      'ownerId': user.uid,
      'members': [user.uid],
      'createdAt': FieldValue.serverTimestamp(),
    });
    await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .set({
  'familyId': invitationCode,
  'email': user.email,
  'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

    if (!mounted) {
      return;
    }

    setState(() {
      _invitationCode = invitationCode;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Family created successfully.'),
      ),
    );
  } on FirebaseException catch (_) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Could not create the family. Please try again.',
        ),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isCreatingFamily = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Family'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create your family group',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 8),

                Text(
                  'Give your family a name and invite relatives to join.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 28),

                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.family_restroom,
                          size: 56,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: IconButton.filled(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Family image upload will be added later.',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.camera_alt_outlined),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                TextFormField(
                  controller: _familyNameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: FormValidators.validateFamilyName,
                  decoration: const InputDecoration(
                    labelText: 'Family name',
                    hintText: 'Alagha Family',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                ),

                const SizedBox(height: 18),

                TextFormField(
                  controller: _descriptionController,
                  maxLength: 120,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Family description (optional)',
                    hintText: 'A short message about your family',
                    prefixIcon: Icon(Icons.edit_note_outlined),
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isCreatingFamily ? null : _createFamily,
                    child: Text(
                      _isCreatingFamily ? 'Creating Family...' : 'Create Family',
                    ),
                  ),
                ),

                if (_invitationCode != null) ...[
                  const SizedBox(height: 30),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Your invitation code',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 10),

                        SelectableText(
                          _invitationCode!,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 5,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Share this code with relatives so they can join your family.',
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 14),

                        OutlinedButton.icon(
  onPressed: () {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Copying will be connected next.',
        ),
      ),
    );
  },
  icon: const Icon(Icons.copy_outlined),
  label: const Text('Copy Code'),
),

const SizedBox(height: 12),

SizedBox(
  width: double.infinity,
  child: FilledButton(
    onPressed: () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const MainNavigationScreen(),
        ),
        (route) => false,
      );
    },
    child: const Text('Continue to Home'),
  ),
),
                        
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}