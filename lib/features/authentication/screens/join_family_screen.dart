import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/validation/form_validators.dart';

class JoinFamilyScreen extends StatefulWidget {
  const JoinFamilyScreen({super.key});

  @override
  State<JoinFamilyScreen> createState() => _JoinFamilyScreenState();
}

class _JoinFamilyScreenState extends State<JoinFamilyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
void dispose() {
  _codeController.dispose();
  super.dispose();
}

void _joinFamily() {
  FocusScope.of(context).unfocus();

  final isValid = _formKey.currentState?.validate() ?? false;

  if (!isValid) {
    return;
  }

  final invitationCode = _codeController.text.trim().toUpperCase();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Code $invitationCode is valid. Firebase verification will be added later.',
      ),
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Family'),
      ),
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
              FilteringTextInputFormatter.allow(
                RegExp(r'[A-Za-z0-9]'),
              ),
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
              onPressed: _joinFamily,
              icon: const Icon(Icons.group_add_outlined),
              label: const Text('Join Family'),
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