import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/validation/form_validators.dart';
import '../../../l10n/app_localizations.dart';
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
      final strings = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.joinFamilyLoginRequired)));
      return;
    }

    setState(() {
      _isJoiningFamily = true;
    });

    try {
      final code = _codeController.text.trim().toUpperCase();

      final familyReference = FirebaseFirestore.instance
          .collection('families')
          .doc(code);

      final familySnapshot = await familyReference.get();

      if (!familySnapshot.exists) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.invitationCodeNotFound),
          ),
        );

        return;
      }

      await familyReference.update({
        'members': FieldValue.arrayUnion([user.uid]),
      });
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'familyId': code,
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        (route) => false,
      );
    } on FirebaseException {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.couldNotJoinFamily),
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
    final strings = AppLocalizations.of(context)!;
    final validators = LocalizedFormValidators(strings);

    return Scaffold(
      appBar: AppBar(title: Text(strings.joinFamily)),
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
                    const SizedBox(height: 20),

                    Text(
                      strings.joinYourFamily,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      strings.joinFamilyDescription,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    const SizedBox(height: 36),

                    TextFormField(
                      controller: _codeController,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.done,
                      maxLength: 6,
                      validator: validators.validateInvitationCode,
                      onFieldSubmitted: (_) => _joinFamily(),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[A-Za-z0-9]'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: strings.invitationCode,
                        hintText: strings.invitationCodeHint,
                        prefixIcon: const Icon(Icons.key_outlined),
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
                          _isJoiningFamily
                              ? strings.joiningFamily
                              : strings.joinFamily,
                        ),
                      ),
                    ),
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
