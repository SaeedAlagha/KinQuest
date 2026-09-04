import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/branding/app_brand.dart';
import '../../../core/mascot/sila_mascot.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/family_year_banner.dart';
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
                                      child: _WelcomeHero(isWide: true),
                                    ),
                                    const SizedBox(width: 64),
                                    Expanded(
                                      flex: 4,
                                      child: _WelcomeActions(
                                        onLogin: () => _openLogin(context),
                                        onSignup: () => _openSignup(context),
                                        onDemo: kIsWeb
                                            ? () =>
                                                  _openCompetitionDemo(context)
                                            : null,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _WelcomeHero(isWide: false),
                                    const SizedBox(height: 36),
                                    _WelcomeActions(
                                      onLogin: () => _openLogin(context),
                                      onSignup: () => _openSignup(context),
                                      onDemo: kIsWeb
                                          ? () => _openCompetitionDemo(context)
                                          : null,
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
  const _WelcomeHero({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

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
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 660),
          child: _WelcomeSilaSpotlight(
            isWide: isWide,
            animateMascot: !reduceMotion,
          ),
        ),
        SizedBox(height: isWide ? 26 : 22),
        Wrap(
          alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
          textDirection: TextDirection.ltr,
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
          textDirection: TextDirection.ltr,
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
      ],
    );
  }
}

class _WelcomeSilaSpotlight extends StatelessWidget {
  const _WelcomeSilaSpotlight({
    required this.isWide,
    required this.animateMascot,
  });

  final bool isWide;
  final bool animateMascot;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context)!;

    return Semantics(
      container: true,
      child: Container(
        key: const ValueKey('welcome-sila-spotlight'),
        padding: EdgeInsets.all(isWide ? 20 : 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.76),
              colorScheme.surface.withValues(alpha: 0.92),
            ],
          ),
          borderRadius: BorderRadius.circular(isWide ? 34 : 28),
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.14),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      strings.silaMeetCompanion,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.55,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SilaMascotGuide(
              key: const ValueKey('welcome-mascot-guide'),
              title: strings.mascotName,
              message: strings.mascotWelcomeMessage,
              semanticLabel: strings.mascotSemanticLabel,
              pose: SilaMascotPose.welcome,
              motion: SilaMascotMotion.gameReady,
              animate: animateMascot,
              compact: !isWide,
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeActions extends StatelessWidget {
  const _WelcomeActions({
    required this.onLogin,
    required this.onSignup,
    this.onDemo,
  });

  final VoidCallback onLogin;
  final VoidCallback onSignup;
  final VoidCallback? onDemo;

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
          if (onDemo != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                key: const ValueKey('competition-demo-cta'),
                onPressed: onDemo,
                icon: const Icon(Icons.play_circle_outline_rounded),
                label: Text(CompetitionDemoCopy.launchLabel(context)),
              ),
            ),
          ],
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
