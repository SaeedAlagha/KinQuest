import 'package:flutter/material.dart';

import '../../../core/branding/app_brand.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/family_year_banner.dart';
import '../../../core/widgets/sila_brand_mark.dart';
import '../../../l10n/app_localizations.dart';
import '../../demo/screens/competition_demo_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _openLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _openSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignupScreen()),
    );
  }

  void _openCompetitionDemo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CompetitionDemoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _WelcomeBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 880;
                final horizontalPadding = constraints.maxWidth < 480
                    ? 20.0
                    : 32.0;

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: isWide ? 48 : 28,
                          ),
                          child: isWide
                              ? Row(
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: _WelcomeHero(
                                        isWide: true,
                                        onDemo: () =>
                                            _openCompetitionDemo(context),
                                      ),
                                    ),
                                    const SizedBox(width: 64),
                                    Expanded(
                                      flex: 4,
                                      child: _WelcomeActions(
                                        onLogin: () => _openLogin(context),
                                        onSignup: () => _openSignup(context),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _WelcomeHero(
                                      isWide: false,
                                      onDemo: () =>
                                          _openCompetitionDemo(context),
                                    ),
                                    const SizedBox(height: 36),
                                    _WelcomeActions(
                                      onLogin: () => _openLogin(context),
                                      onSignup: () => _openSignup(context),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({required this.isWide, required this.onDemo});

  final bool isWide;
  final VoidCallback onDemo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: isWide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Align(
          alignment: isWide
              ? AlignmentDirectional.centerStart
              : Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: FamilyYearBanner(compact: !isWide),
          ),
        ),
        SizedBox(height: isWide ? 26 : 22),
        const SilaBrandMark(),
        SizedBox(height: isWide ? 30 : 22),
        Wrap(
          alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 14,
          runSpacing: 8,
          children: [
            Text(
              AppBrand.name,
              style: textTheme.displaySmall?.copyWith(
                fontSize: isWide ? 62 : 50,
                letterSpacing: -1.8,
                color: colorScheme.onSurface,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.uaeRed.withValues(alpha: 0.075),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: AppTheme.uaeRed.withValues(alpha: 0.18),
                ),
              ),
              child: Text(
                AppBrand.arabicName,
                textDirection: TextDirection.rtl,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          AppBrand.tagline,
          textAlign: isWide ? TextAlign.start : TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            color: colorScheme.primary,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppBrand.arabicTagline,
          textAlign: isWide ? TextAlign.start : TextAlign.center,
          textDirection: TextDirection.rtl,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            strings.welcomePrivateFamilySpace,
            textAlign: isWide ? TextAlign.start : TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SizedBox(
            width: isWide ? null : double.infinity,
            child: FilledButton.tonalIcon(
              key: const ValueKey('competition-demo-cta'),
              onPressed: onDemo,
              icon: const Icon(Icons.play_circle_fill_rounded),
              label: Text(CompetitionDemoCopy.launchLabel(context)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: const [
            _WelcomePill(
              icon: Icons.park_outlined,
              label: 'Roots • الجذور',
              accent: AppTheme.uaeBlack,
            ),
            _WelcomePill(
              icon: Icons.join_inner_rounded,
              label: 'Bonds • الروابط',
              accent: AppTheme.uaeRed,
            ),
            _WelcomePill(
              icon: Icons.eco_outlined,
              label: 'Growth • النمو',
              accent: AppTheme.uaeGreen,
            ),
          ],
        ),
      ],
    );
  }
}

class _WelcomePill extends StatelessWidget {
  const _WelcomePill({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}

class _WelcomeActions extends StatelessWidget {
  const _WelcomeActions({required this.onLogin, required this.onSignup});

  final VoidCallback onLogin;
  final VoidCallback onSignup;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.16),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const UaeColorRibbon(height: 5),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.uaeGreen.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              strings.uaeYearOfFamily2026,
              style: textTheme.labelSmall?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            strings.everyBondHelpsFamilyGrow,
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            strings.silaEverydayMoments,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onLogin,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(strings.logIn),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onSignup,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: Text(strings.createAccount),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  strings.familyMomentsStayPrivate,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WelcomeBackground extends StatelessWidget {
  const _WelcomeBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppTheme.pageGradientFor(context)),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: _ConnectionRings(size: 290, color: AppTheme.uaeRed),
          ),
          Positioned(
            bottom: -130,
            left: -100,
            child: _ConnectionRings(size: 350, color: AppTheme.uaeGreen),
          ),
        ],
      ),
    );
  }
}

class _ConnectionRings extends StatelessWidget {
  const _ConnectionRings({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: size * 0.12,
            child: _Ring(size: size * 0.68, color: color),
          ),
          Positioned(
            right: 0,
            bottom: size * 0.08,
            child: _Ring(size: size * 0.68, color: color),
          ),
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.035),
        border: Border.all(color: color.withValues(alpha: 0.12), width: 2),
      ),
    );
  }
}
