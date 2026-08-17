import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/validation/form_validators.dart';
import '../../../l10n/app_localizations.dart';
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
      final strings = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.createFamilyLoginRequired)),
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
        'inviteCode': invitationCode,
        'description': _descriptionController.text.trim(),
        'invitationCode': invitationCode,
        'ownerId': user.uid,
        'members': [user.uid],
        'createdAt': FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
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
        SnackBar(content: Text(AppLocalizations.of(context)!.familyCreated)),
      );
    } on FirebaseException catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.couldNotCreateFamily),
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
    final strings = AppLocalizations.of(context)!;
    final validators = LocalizedFormValidators(strings);

    return Scaffold(
      appBar: AppBar(title: Text(strings.createFamily)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.createFamilyGroup,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      strings.createFamilyDescription,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    const SizedBox(height: 28),

                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            child: Icon(
                              Icons.family_restroom,
                              size: 56,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          PositionedDirectional(
                            end: 0,
                            bottom: 0,
                            child: IconButton.filled(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(strings.familyImageComing),
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
                      validator: validators.validateFamilyName,
                      decoration: InputDecoration(
                        labelText: strings.familyName,
                        hintText: strings.familyNameHint,
                        prefixIcon: const Icon(Icons.home_outlined),
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextFormField(
                      controller: _descriptionController,
                      maxLength: 120,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: strings.familyDescriptionOptional,
                        hintText: strings.familyDescriptionHint,
                        prefixIcon: const Icon(Icons.edit_note_outlined),
                        alignLabelWithHint: true,
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isCreatingFamily ? null : _createFamily,
                        child: Text(
                          _isCreatingFamily
                              ? strings.creatingFamily
                              : strings.createFamily,
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
                            Text(
                              strings.yourInvitationCode,
                              style: const TextStyle(
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

                            Text(
                              strings.shareInvitationCode,
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 14),

                            OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(strings.copyingComing),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy_outlined),
                              label: Text(strings.copyCode),
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
                                child: Text(strings.continueToHome),
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
        ),
      ),
    );
  }
}
