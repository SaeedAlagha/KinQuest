import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/sila_page_backdrop.dart';
import '../../../l10n/app_localizations.dart';

class LegalPrivacyScreen extends StatelessWidget {
  const LegalPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final sections = [
      (
        Icons.person_outline_rounded,
        strings.legalAccountDataTitle,
        strings.legalAccountDataBody,
      ),
      (
        Icons.family_restroom_rounded,
        strings.legalFamilyDataTitle,
        strings.legalFamilyDataBody,
      ),
      (Icons.auto_awesome_outlined, strings.legalAiTitle, strings.legalAiBody),
      (
        Icons.tune_rounded,
        strings.legalControlsTitle,
        strings.legalControlsBody,
      ),
      (Icons.gavel_rounded, strings.legalTermsTitle, strings.legalTermsBody),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(strings.legalPrivacyCenter)),
      body: SilaPageBackdrop(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _LegalHero(
                      title: strings.legalPrivacyCenter,
                      intro: strings.legalIntro,
                      effectiveDate: strings.legalEffectiveDate,
                    ),
                    const SizedBox(height: 18),
                    for (final section in sections) ...[
                      _LegalSection(
                        icon: section.$1,
                        title: section.$2,
                        body: section.$3,
                      ),
                      if (section != sections.last) const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalHero extends StatelessWidget {
  const _LegalHero({
    required this.title,
    required this.intro,
    required this.effectiveDate,
  });

  final String title;
  final String intro;
  final String effectiveDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradientFor(context),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.verified_user_rounded,
            color: Colors.white,
            size: 52,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            intro,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            effectiveDate,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.74),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalSection extends StatelessWidget {
  const _LegalSection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: colors.onPrimaryContainer),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
