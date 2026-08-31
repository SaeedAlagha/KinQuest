import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../mascot/sila_mascot.dart';
import '../theme/app_theme.dart';
import 'family_year_banner.dart';

@immutable
class SilaCelebrationReward {
  const SilaCelebrationReward({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// A reusable winner moment for daily, weekly, monthly, and demo journeys.
///
/// The animation is deliberately short and one-shot so it remains friendly to
/// accessibility settings and deterministic in widget tests.
class SilaCelebrationCard extends StatefulWidget {
  const SilaCelebrationCard({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.icon = Icons.emoji_events_rounded,
    this.rewards = const [],
    this.footer,
    this.effect = 'default',
    this.mascotAccessory = SilaMascotAccessories.none,
    this.mascotOutfit = SilaMascotOutfits.none,
    this.mascotAura = SilaMascotAuras.none,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<SilaCelebrationReward> rewards;
  final Widget? footer;
  final String effect;
  final String mascotAccessory;
  final String mascotOutfit;
  final String mascotAura;

  @override
  State<SilaCelebrationCard> createState() => _SilaCelebrationCardState();
}

class _SilaCelebrationCardState extends State<SilaCelebrationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _entrance;
  bool? _reduceMotion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    );
    _entrance = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion) return;
    _reduceMotion = reduceMotion;
    if (reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '${widget.eyebrow}. ${widget.title}. ${widget.subtitle}',
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF102E25), Color(0xFF006B49), Color(0xFF0A8B59)],
            stops: [0, 0.56, 1],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryDark.withValues(alpha: 0.24),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) => CustomPaint(
                    key: ValueKey('celebration-effect-${widget.effect}'),
                    painter: _CelebrationPainter(
                      progress: _controller.value,
                      effect: widget.effect,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const UaeColorRibbon(height: 5),
                  const SizedBox(height: 22),
                  ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.62,
                      end: 1,
                    ).animate(_entrance),
                    child: Center(
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SilaMascot(
                              pose: SilaMascotPose.winner,
                              height: 150,
                              animate: !(_reduceMotion ?? false),
                              semanticLabel: AppLocalizations.of(
                                context,
                              )?.mascotSemanticLabel,
                              accessoryAssetKey: widget.mascotAccessory,
                              outfitAssetKey: widget.mascotOutfit,
                              auraAssetKey: widget.mascotAura,
                            ),
                            PositionedDirectional(
                              end: 3,
                              bottom: 10,
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF163E32),
                                  border: Border.all(
                                    color: const Color(0xFFFFD77A),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  widget.icon,
                                  size: 21,
                                  color: const Color(0xFFFFD77A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FadeTransition(
                    opacity: _controller,
                    child: Column(
                      children: [
                        Text(
                          widget.eyebrow.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.15,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.subtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.84),
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.rewards.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 9,
                      runSpacing: 9,
                      children: [
                        for (final reward in widget.rewards)
                          _RewardPill(reward: reward),
                      ],
                    ),
                  ],
                  if (widget.footer case final footer?) ...[
                    const SizedBox(height: 22),
                    footer,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardPill extends StatelessWidget {
  const _RewardPill({required this.reward});

  final SilaCelebrationReward reward;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(reward.icon, color: const Color(0xFFFFD77A), size: 18),
          const SizedBox(width: 7),
          Text(
            reward.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CelebrationPainter extends CustomPainter {
  const _CelebrationPainter({required this.progress, required this.effect});

  final double progress;
  final String effect;

  static const _colors = [
    AppTheme.uaeRed,
    AppTheme.uaeGreen,
    Color(0xFFFFD77A),
    Colors.white,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final eased = Curves.easeOutCubic.transform(progress);
    final particleCount = effect == 'confetti' ? 44 : 22;

    for (var index = 0; index < particleCount; index += 1) {
      final column = ((index * 47) % 101) / 100;
      final startY = -0.12 - ((index * 19) % 32) / 100;
      final travel = 0.42 + ((index * 13) % 36) / 100;
      final sway = math.sin((progress * math.pi * 2) + index) * 8;
      final center = Offset(
        size.width * column + sway,
        size.height * (startY + (travel * eased)),
      );
      final paint = Paint()
        ..color = _colors[index % _colors.length].withValues(
          alpha: 0.38 + (index % 3) * 0.16,
        );

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(progress * math.pi * (1.5 + (index % 4) * 0.35));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: index.isEven ? 5 : 8,
            height: index.isEven ? 11 : 5,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }

    if (effect == 'fireworks') {
      _paintFireworks(canvas, size, eased);
    } else if (effect == 'stars') {
      _paintStars(canvas, size, eased);
    }

    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.33),
      72 + (eased * 26),
      ringPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.33),
      102 + (eased * 34),
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CelebrationPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.effect != effect;
  }

  void _paintFireworks(Canvas canvas, Size size, double eased) {
    final centers = [
      Offset(size.width * 0.2, size.height * 0.28),
      Offset(size.width * 0.8, size.height * 0.22),
    ];

    for (var burst = 0; burst < centers.length; burst += 1) {
      final paint = Paint()
        ..color = _colors[(burst + 2) % _colors.length].withValues(
          alpha: 0.78 * (1 - progress * 0.35),
        )
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;
      for (var ray = 0; ray < 12; ray += 1) {
        final angle = (math.pi * 2 * ray) / 12;
        final inner = 8 + eased * 9;
        final outer = 14 + eased * 34;
        canvas.drawLine(
          centers[burst] +
              Offset(math.cos(angle) * inner, math.sin(angle) * inner),
          centers[burst] +
              Offset(math.cos(angle) * outer, math.sin(angle) * outer),
          paint,
        );
      }
    }
  }

  void _paintStars(Canvas canvas, Size size, double eased) {
    final paint = Paint()
      ..color = const Color(0xFFFFD77A).withValues(alpha: 0.82);
    for (var index = 0; index < 14; index += 1) {
      final x = size.width * (((index * 31) % 97) / 100);
      final y = size.height * (0.08 + (((index * 23) % 52) / 100) * eased);
      final radius = 3.0 + (index % 3);
      final path = Path();
      for (var point = 0; point < 8; point += 1) {
        final angle = -math.pi / 2 + (math.pi * point / 4);
        final pointRadius = point.isEven ? radius : radius * 0.42;
        final offset = Offset(
          x + math.cos(angle) * pointRadius,
          y + math.sin(angle) * pointRadius,
        );
        if (point == 0) {
          path.moveTo(offset.dx, offset.dy);
        } else {
          path.lineTo(offset.dx, offset.dy);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }
}
