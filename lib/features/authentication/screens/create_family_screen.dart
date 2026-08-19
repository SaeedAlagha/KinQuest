import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      final firestore = FirebaseFirestore.instance;
      String? invitationCode;

      for (var attempt = 0; attempt < 8 && invitationCode == null; attempt++) {
        final candidate = _generateInvitationCode();
        final familyReference = firestore.collection('families').doc(candidate);
        final userReference = firestore.collection('users').doc(user.uid);

        final created = await firestore.runTransaction<bool>((
          transaction,
        ) async {
          final familySnapshot = await transaction.get(familyReference);
          final userSnapshot = await transaction.get(userReference);

          if (familySnapshot.exists) return false;

          final currentFamilyId = userSnapshot.data()?['familyId']?.toString();

          if (currentFamilyId?.isNotEmpty == true) {
            throw const _AlreadyInFamilyException();
          }

          transaction.set(familyReference, {
            'name': _familyNameController.text.trim(),
            'inviteCode': candidate,
            'description': _descriptionController.text.trim(),
            'invitationCode': candidate,
            'ownerId': user.uid,
            'members': [user.uid],
            'createdAt': FieldValue.serverTimestamp(),
          });
          transaction.set(userReference, {
            'familyId': candidate,
            'email': user.email,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          return true;
        });

        if (created) invitationCode = candidate;
      }

      if (invitationCode == null) {
        throw const _InvitationCodeAllocationException();
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _invitationCode = invitationCode;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.familyCreated)),
      );
    } on _AlreadyInFamilyException {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.alreadyInFamily)),
      );
    } catch (_) {
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
                      child: CircleAvatar(
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
                    ),

                    const SizedBox(height: 30),

                    TextFormField(
                      controller: _familyNameController,
                      enabled: !_isCreatingFamily && _invitationCode == null,
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
                      enabled: !_isCreatingFamily && _invitationCode == null,
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
                        onPressed: _isCreatingFamily || _invitationCode != null
                            ? null
                            : _createFamily,
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
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: _invitationCode!),
                                );

                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      strings.familyInviteCodeCopied,
                                    ),
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

class _AlreadyInFamilyException implements Exception {
  const _AlreadyInFamilyException();
}

class _InvitationCodeAllocationException implements Exception {
  const _InvitationCodeAllocationException();
}
