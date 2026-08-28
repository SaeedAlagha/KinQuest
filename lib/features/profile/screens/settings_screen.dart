import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/appearance_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_theme_catalog.dart';
import '../../../core/theme/theme_unlock_service.dart';
import '../../../core/widgets/sila_page_backdrop.dart';
import '../../../l10n/app_localizations.dart';
import 'legal_privacy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.developerPreview = false});

  final bool developerPreview;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _tokenBalance = 0;
  bool _isUnlockingTheme = false;

  @override
  void initState() {
    super.initState();
    _loadThemeAccess();
  }

  Future<void> _loadThemeAccess() async {
    if (widget.developerPreview) {
      if (mounted) {
        setState(() {
          _tokenBalance = 2400;
        });
      }
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    try {
      await AppearanceController.instance.load(ownershipScope: user.uid);

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = snapshot.data();

      final unlockedNames =
          (data?['unlockedAppearances'] as List<dynamic>?)
              ?.map((value) => value.toString())
              .toSet() ??
          const <String>{};

      final unlocked = AppAppearance.values.where(
        (appearance) => unlockedNames.contains(appearance.name),
      );

      await AppearanceController.instance.registerUnlocked(unlocked);

      if (mounted) {
        setState(() {
          _tokenBalance = (data?['tokens'] as num?)?.toInt() ?? 0;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final currentLanguage = LocaleController.instance.locale.languageCode;

    return ListenableBuilder(
      listenable: AppearanceController.instance,
      builder: (context, child) {
        final appearance = AppearanceController.instance.appearance;

        return Scaffold(
          appBar: AppBar(title: Text(strings.settings)),
          body: SilaPageBackdrop(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 6,
                        bottom: 10,
                      ),
                      child: Text(
                        strings.preferences,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),

                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(_appearanceIcon(appearance)),
                            title: Text(strings.appearance),
                            subtitle: Text(
                              _appearanceName(strings, appearance),
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _showAppearancePicker(
                              context,
                              strings,
                              appearance,
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.language_rounded),
                            title: Text(strings.language),
                            subtitle: Text(
                              currentLanguage == 'ar'
                                  ? strings.arabic
                                  : strings.english,
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => _showLanguagePicker(
                              context,
                              strings,
                              currentLanguage,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.notifications_outlined),
                            title: Text(strings.notifications),
                            subtitle: Text(strings.manageReminders),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const NotificationSettingsScreen(),
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAppearancePicker(
    BuildContext context,
    AppLocalizations strings,
    AppAppearance selectedAppearance,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        strings.themeStudio,
                        style: Theme.of(sheetContext).textTheme.headlineSmall,
                      ),
                    ),
                    _TokenPill(label: strings.themeTokenBalance(_tokenBalance)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  strings.themeStudioDescription,
                  style: Theme.of(sheetContext).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                for (final offer in AppThemeCatalog.offers) ...[
                  _AppearanceOption(
                    offer: offer,
                    title: _appearanceName(strings, offer.appearance),
                    description: _appearanceDescription(
                      strings,
                      offer.appearance,
                    ),
                    icon: _appearanceIcon(offer.appearance),
                    selected: selectedAppearance == offer.appearance,
                    unlocked: AppearanceController.instance.isUnlocked(
                      offer.appearance,
                    ),
                    priceLabel: _themePriceLabel(strings, offer),
                    onTap: _isUnlockingTheme
                        ? null
                        : () => _handleThemeTap(sheetContext, offer),
                  ),
                  if (offer != AppThemeCatalog.offers.last)
                    const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showLanguagePicker(
    BuildContext context,
    AppLocalizations strings,
    String currentLanguage,
  ) {
    return showModalBottomSheet<void>(
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
                  await LocaleController.instance.setLocale(const Locale('en'));
                },
              ),
              ListTile(
                leading: currentLanguage == 'ar'
                    ? const Icon(Icons.check_rounded)
                    : const SizedBox(width: 24),
                title: Text(strings.arabic),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await LocaleController.instance.setLocale(const Locale('ar'));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _appearanceName(AppLocalizations strings, AppAppearance appearance) {
    return switch (appearance) {
      AppAppearance.light => strings.silaLightTheme,
      AppAppearance.dark => strings.darkTheme,
      AppAppearance.familyYear2026 => strings.uaeFamilyYearTheme,
      AppAppearance.space => strings.spaceTheme,
      AppAppearance.khalifaUniversity => strings.khalifaUniversityTheme,
      AppAppearance.desertNights => strings.desertNightsTheme,
      AppAppearance.pearlLagoon => strings.pearlLagoonTheme,
    };
  }

  String _appearanceDescription(
    AppLocalizations strings,
    AppAppearance appearance,
  ) {
    return switch (appearance) {
      AppAppearance.light => strings.silaLightThemeDescription,
      AppAppearance.dark => strings.darkThemeDescription,
      AppAppearance.familyYear2026 => strings.uaeFamilyYearThemeDescription,
      AppAppearance.space => strings.spaceThemeDescription,
      AppAppearance.khalifaUniversity =>
        strings.khalifaUniversityThemeDescription,
      AppAppearance.desertNights => strings.desertNightsThemeDescription,
      AppAppearance.pearlLagoon => strings.pearlLagoonThemeDescription,
    };
  }

  IconData _appearanceIcon(AppAppearance appearance) {
    return switch (appearance) {
      AppAppearance.light => Icons.light_mode_rounded,
      AppAppearance.dark => Icons.dark_mode_rounded,
      AppAppearance.familyYear2026 => Icons.family_restroom_rounded,
      AppAppearance.space => Icons.rocket_launch_rounded,
      AppAppearance.khalifaUniversity => Icons.science_rounded,
      AppAppearance.desertNights => Icons.nights_stay_rounded,
      AppAppearance.pearlLagoon => Icons.water_rounded,
    };
  }

  String _themePriceLabel(AppLocalizations strings, AppThemeOffer offer) {
    if (AppearanceController.instance.isUnlocked(offer.appearance)) {
      return offer.isIncluded ? strings.themeIncluded : strings.themeOwned;
    }

    return strings.themeTokenPrice(offer.tokenCost!);
  }

  Future<void> _handleThemeTap(
    BuildContext sheetContext,
    AppThemeOffer offer,
  ) async {
    if (AppearanceController.instance.isUnlocked(offer.appearance)) {
      Navigator.pop(sheetContext);
      await AppearanceController.instance.setAppearance(offer.appearance);
      return;
    }

    Navigator.pop(sheetContext);
    await _confirmThemeUnlock(offer);
  }

  Future<void> _confirmThemeUnlock(AppThemeOffer offer) async {
    final strings = AppLocalizations.of(context)!;
    final themeName = _appearanceName(strings, offer.appearance);
    final cost = offer.tokenCost!;

    if (!widget.developerPreview && FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.signInToUnlockThemes)));
      return;
    }

    if (_tokenBalance < cost) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          scrollable: true,
          icon: const Icon(Icons.stars_rounded),
          title: Text(strings.notEnoughTokensTitle),
          content: Text(strings.notEnoughTokensMessage(cost, _tokenBalance)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.close),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        icon: const Icon(Icons.auto_awesome_rounded),
        title: Text(strings.unlockThemeTitle(themeName)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(strings.unlockThemeMessage(cost)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 18,
                  color: Theme.of(dialogContext).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    strings.themeUnlockBenefit,
                    style: Theme.of(dialogContext).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.cancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.stars_rounded),
            label: Text(strings.unlockForTokens(cost)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _isUnlockingTheme = true);

    try {
      final remainingBalance = widget.developerPreview
          ? _tokenBalance - cost
          : (await ThemeUnlockService().unlockWithTokens(
              userId: FirebaseAuth.instance.currentUser!.uid,
              offer: offer,
            )).remainingTokens;

      await AppearanceController.instance.registerUnlocked([
        offer.appearance,
      ], persist: !widget.developerPreview);
      await AppearanceController.instance.setAppearance(
        offer.appearance,
        persist: !widget.developerPreview,
      );

      if (!mounted) {
        return;
      }

      setState(() => _tokenBalance = remainingBalance);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.themeUnlocked(themeName))));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.themeUnlockFailed)));
      }
    } finally {
      if (mounted) {
        setState(() => _isUnlockingTheme = false);
      }
    }
  }
}

class _TokenPill extends StatelessWidget {
  const _TokenPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stars_rounded, size: 16, color: colorScheme.tertiary),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onTertiaryContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceOption extends StatelessWidget {
  const _AppearanceOption({
    required this.offer,
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.unlocked,
    required this.priceLabel,
    required this.onTap,
  });

  final AppThemeOffer offer;
  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final bool unlocked;
  final String priceLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final previewTheme = AppTheme.forAppearance(offer.appearance);
    final previewScheme = previewTheme.colorScheme;
    final previewGradient = previewTheme
        .extension<SilaThemeTokens>()!
        .heroGradient;

    return Material(
      color: selected
          ? colorScheme.primaryContainer.withValues(alpha: 0.72)
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? colorScheme.primary : colorScheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 68,
                height: 64,
                decoration: BoxDecoration(
                  gradient: previewGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: previewScheme.primary.withValues(alpha: 0.24),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    PositionedDirectional(
                      top: 8,
                      start: 9,
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
                    PositionedDirectional(
                      end: 8,
                      bottom: 8,
                      child: Row(
                        children: [
                          _ColorDot(color: previewScheme.tertiary),
                          const SizedBox(width: 4),
                          _ColorDot(color: previewScheme.secondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: unlocked
                              ? colorScheme.primaryContainer
                              : colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          priceLabel,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: unlocked
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : unlocked
                    ? Icons.chevron_right_rounded
                    : Icons.lock_rounded,
                color: selected
                    ? colorScheme.primary
                    : unlocked
                    ? colorScheme.outline
                    : colorScheme.tertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
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
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LegalPrivacyScreen()),
            ),
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
