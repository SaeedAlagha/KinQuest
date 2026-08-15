import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final currentLanguage = LocaleController.instance.locale.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(strings.settings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: Text(strings.language),
            subtitle: Text(
              currentLanguage == 'ar' ? strings.arabic : strings.english,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (sheetContext) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: currentLanguage == 'en'
                              ? const Icon(Icons.check_rounded)
                              : const SizedBox(width: 24),
                          title: Text(strings.english),
                          onTap: () async {
                            Navigator.pop(sheetContext);

                            await LocaleController.instance.setLocale(
                              const Locale('en'),
                            );
                          },
                        ),
                        ListTile(
                          leading: currentLanguage == 'ar'
                              ? const Icon(Icons.check_rounded)
                              : const SizedBox(width: 24),
                          title: Text(strings.arabic),
                          onTap: () async {
                            Navigator.pop(sheetContext);

                            await LocaleController.instance.setLocale(
                              const Locale('ar'),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(strings.notifications),
            subtitle: Text(strings.manageReminders),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.lock_outline_rounded),
            title: Text(strings.privacySecurity),
            subtitle: Text(strings.passwordAccountSecurity),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PrivacySecurityScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _notifications = true;
  bool _dailyChallenges = true;
  bool _missions = true;
  bool _competitions = true;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = snapshot.data();

      if (!mounted) {
        return;
      }

      setState(() {
        _notifications = data?['notificationsEnabled'] as bool? ?? true;
        _dailyChallenges =
            data?['dailyChallengeNotifications'] as bool? ?? true;
        _missions = data?['missionNotifications'] as bool? ?? true;
        _competitions = data?['competitionNotifications'] as bool? ?? true;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      final strings = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.couldNotLoadNotifications)),
      );
    }
  }

  Future<void> _savePreferences() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'notificationsEnabled': _notifications,
        'dailyChallengeNotifications': _dailyChallenges,
        'missionNotifications': _missions,
        'competitionNotifications': _competitions,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      if (!mounted) {
        return;
      }

      final strings = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.couldNotSaveNotifications)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.notifications)),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications_rounded),
            title: Text(strings.notifications),
            subtitle: Text(strings.allowSilaReminders),
            value: _notifications,
            onChanged: _isSaving
                ? null
                : (value) async {
                    setState(() {
                      _notifications = value;
                    });

                    await _savePreferences();
                  },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: Text(strings.dailyChallenge),
            subtitle: Text(strings.dailyChallengeReminder),
            value: _dailyChallenges && _notifications,
            onChanged: !_notifications || _isSaving
                ? null
                : (value) async {
                    setState(() {
                      _dailyChallenges = value;
                    });

                    await _savePreferences();
                  },
          ),
          SwitchListTile(
            title: Text(strings.familyMissions),
            subtitle: Text(strings.familyMissionsReminder),
            value: _missions && _notifications,
            onChanged: !_notifications || _isSaving
                ? null
                : (value) async {
                    setState(() {
                      _missions = value;
                    });

                    await _savePreferences();
                  },
          ),
          SwitchListTile(
            title: Text(strings.competitions),
            subtitle: Text(strings.competitionReminder),
            value: _competitions && _notifications,
            onChanged: !_notifications || _isSaving
                ? null
                : (value) async {
                    setState(() {
                      _competitions = value;
                    });

                    await _savePreferences();
                  },
          ),
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  Future<void> _sendPasswordReset(BuildContext context) async {
    final strings = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.noEmailAvailable)));
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.passwordResetSent)));
    } on FirebaseAuthException catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.couldNotSendReset)));
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.couldNotSendReset)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? strings.noEmailAvailable;

    return Scaffold(
      appBar: AppBar(title: Text(strings.privacySecurity)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: Text(strings.privacy),
            subtitle: Text(strings.privacyDescription),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: Text(strings.accountEmail),
            subtitle: Text(email),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.password_rounded),
            title: Text(strings.changePassword),
            subtitle: Text(strings.sendPasswordReset),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _sendPasswordReset(context),
          ),
        ],
      ),
    );
  }
}
