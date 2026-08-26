import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/validation/form_validators.dart';
import '../../../core/widgets/sila_brand_mark.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/screens/main_navigation_screen.dart';
import 'signup_screen.dart';

typedef PasswordResetSender = Future<void> Function(String email);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.sendPasswordReset});

  final PasswordResetSender? sendPasswordReset;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() {
      _isLoggingIn = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      final strings = AppLocalizations.of(context)!;
      String message;

      switch (error.code) {
        case 'invalid-credential':
          message = strings.incorrectEmailOrPassword;
          break;

        case 'user-disabled':
          message = strings.accountDisabled;
          break;

        case 'invalid-email':
          message = strings.pleaseEnterValidEmail;
          break;

        case 'too-many-requests':
          message = strings.tooManyLoginAttempts;
          break;

        case 'network-request-failed':
          message = strings.noInternetConnection;
          break;

        default:
          message = strings.couldNotLogIn;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  void _openSignup() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  void _openDeveloperPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const MainNavigationScreen(developerPreview: true),
      ),
    );
  }

  Future<void> _openPasswordRecovery() async {
    final strings = AppLocalizations.of(context)!;
    final sent = await showDialog<bool>(
      context: context,
      builder: (_) => _PasswordResetDialog(
        initialEmail: _emailController.text.trim(),
        sender: widget.sendPasswordReset,
      ),
    );

    if (sent == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.passwordResetSent)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final validators = LocalizedFormValidators(strings);

    return Scaffold(
      appBar: AppBar(title: Text(strings.logIn)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    const SilaBrandMark(size: 68, showShadow: false),

                    const SizedBox(height: 24),

                    Text(
                      strings.welcomeBackToSila,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      strings.loginDescription,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    const SizedBox(height: 36),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      validator: validators.validateEmail,
                      decoration: InputDecoration(
                        labelText: strings.emailAddress,
                        hintText: strings.emailAddressHint,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      textInputAction: TextInputAction.done,
                      validator: validators.validatePassword,
                      onFieldSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        labelText: strings.password,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          },
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: _isLoggingIn ? null : _openPasswordRecovery,
                        child: Text(strings.forgotPassword),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isLoggingIn ? null : _login,
                        child: Text(
                          _isLoggingIn ? strings.loggingIn : strings.logIn,
                        ),
                      ),
                    ),

                    if (kDebugMode) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isLoggingIn
                              ? null
                              : _openDeveloperPreview,
                          icon: const Icon(Icons.developer_mode_rounded),
                          label: Text(strings.enterDeveloperFamily),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          strings.debugPreviewDescription,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(strings.noAccount),
                        TextButton(
                          onPressed: _openSignup,
                          child: Text(strings.createOne),
                        ),
                      ],
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

class _PasswordResetDialog extends StatefulWidget {
  const _PasswordResetDialog({required this.initialEmail, this.sender});

  final String initialEmail;
  final PasswordResetSender? sender;

  @override
  State<_PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<_PasswordResetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSending || !(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSending = true);
    final strings = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();

    try {
      final sender = widget.sender;
      if (sender != null) {
        await sender(email);
      } else {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      }

      if (mounted) Navigator.pop(context, true);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      if (error.code == 'user-not-found') {
        Navigator.pop(context, true);
        return;
      }

      final message = switch (error.code) {
        'invalid-email' => strings.pleaseEnterValidEmail,
        'too-many-requests' => strings.tooManyLoginAttempts,
        'network-request-failed' => strings.noInternetConnection,
        _ => strings.couldNotSendReset,
      };
      setState(() => _isSending = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.couldNotSendReset)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final validators = LocalizedFormValidators(strings);

    return AlertDialog(
      scrollable: true,
      icon: const Icon(Icons.mark_email_read_outlined),
      title: Text(strings.resetPassword),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(strings.passwordRecoveryComing),
            const SizedBox(height: 18),
            TextFormField(
              key: const ValueKey('password-reset-email'),
              controller: _emailController,
              enabled: !_isSending,
              autofocus: _emailController.text.isEmpty,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              validator: validators.validateEmail,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: strings.emailAddress,
                hintText: strings.emailAddressHint,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSending ? null : () => Navigator.pop(context, false),
          child: Text(strings.cancel),
        ),
        FilledButton.icon(
          onPressed: _isSending ? null : _submit,
          icon: _isSending
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send_outlined),
          label: Text(
            _isSending ? strings.sending : strings.sendPasswordReset,
          ),
        ),
      ],
    );
  }
}
