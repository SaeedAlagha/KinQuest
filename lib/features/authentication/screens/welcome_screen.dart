import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
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
                                    const Expanded(
                                      flex: 6,
                                      child: _WelcomeHero(isWide: true),
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
                                    const _WelcomeHero(isWide: false),
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
  const _WelcomeHero({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: isWide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        const _BrandMark(),
        SizedBox(height: isWide ? 30 : 22),
        Text(
          'KinQuest',
          textAlign: isWide ? TextAlign.start : TextAlign.center,
          style: textTheme.displaySmall?.copyWith(
            fontSize: isWide ? 58 : 46,
            letterSpacing: -1.8,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Play Together. Learn Together. Grow Together.',
          textAlign: isWide ? TextAlign.start : TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            color: AppTheme.primaryDark,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            'Turn everyday family time into stories, laughter, and friendly challenges made for everyone.',
            textAlign: isWide ? TextAlign.start : TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: AppTheme.secondaryTextColor,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 26),
        Wrap(
          alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: const [
            _WelcomePill(
              icon: Icons.groups_2_outlined,
              label: 'Made for every generation',
            ),
            _WelcomePill(
              icon: Icons.auto_awesome_outlined,
              label: 'Fresh activities with AI',
            ),
          ],
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'KinQuest family logo',
      child: Container(
        width: 112,
        height: 112,
        decoration: BoxDecoration(
          gradient: AppTheme.brandGradient,
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.24),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: const Icon(
          Icons.family_restroom_rounded,
          size: 58,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _WelcomePill extends StatelessWidget {
  const _WelcomePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppTheme.outlineColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppTheme.textColor),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textColor.withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.goldColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              'YOUR FAMILY ADVENTURE',
              style: textTheme.labelSmall?.copyWith(
                color: const Color(0xFF9A5A00),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text('Bring everyone closer', style: textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text(
            'Sign in to continue your family journey, or create a space for your family in minutes.',
            style: textTheme.bodyLarge?.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onLogin,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Log In'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onSignup,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Create Account'),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: AppTheme.secondaryTextColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'A private place for your family moments.',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryTextColor,
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF1ECFF),
            AppTheme.backgroundColor,
            Color(0xFFFFF1E8),
          ],
          stops: [0, 0.56, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: _GlowCircle(
              size: 280,
              color: AppTheme.coralColor.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            bottom: -130,
            left: -100,
            child: _GlowCircle(
              size: 340,
              color: AppTheme.primaryColor.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
