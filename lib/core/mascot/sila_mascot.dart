import 'dart:math' as math;

import 'package:flutter/material.dart';

enum SilaMascotPose {
  idle('assets/mascot/sila_idle.png'),
  welcome('assets/mascot/sila_welcome.png'),
  thinking('assets/mascot/sila_thinking.png'),
  celebrating('assets/mascot/sila_celebrating.png'),
  oops('assets/mascot/sila_oops.png'),
  encouraging('assets/mascot/sila_encouraging.png'),
  winner('assets/mascot/sila_winner.png');

  const SilaMascotPose(this.assetPath);

  final String assetPath;
}

class SilaMascotPalette {
  const SilaMascotPalette._();

  static const deepGreen = Color(0xFF087443);
  static const sandGold = Color(0xFFE4A719);
  static const coral = Color(0xFFF45D48);
  static const faceNavy = Color(0xFF07123D);
  static const pearl = Color(0xFFFFF5DF);
}

abstract final class SilaMascotAccessories {
  static const none = 'none';
  static const guardianCrown = 'guardian_crown';
  static const explorerCap = 'explorer_cap';
  static const starHalo = 'star_halo';

  static const supported = {guardianCrown, explorerCap, starHalo};
}

/// The fixed Sila character artwork. App themes may style the surrounding
/// surface, but never recolor or replace the mascot itself.
class SilaMascot extends StatefulWidget {
  const SilaMascot({
    super.key,
    this.pose = SilaMascotPose.idle,
    this.height = 128,
    this.animate = true,
    this.semanticLabel,
    this.accessoryAssetKey = SilaMascotAccessories.none,
  });

  final SilaMascotPose pose;
  final double height;
  final bool animate;
  final String? semanticLabel;
  final String accessoryAssetKey;

  @override
  State<SilaMascot> createState() => _SilaMascotState();
}

class _SilaMascotState extends State<SilaMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _float = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant SilaMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate || oldWidget.pose != widget.pose) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.animate) {
      _controller.forward(from: 0);
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = SizedBox(
      width: widget.height * 0.75,
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          Image.asset(
            widget.pose.assetPath,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
            excludeFromSemantics: widget.semanticLabel == null,
            semanticLabel: widget.semanticLabel,
          ),
          _SilaAccessoryOverlay(assetKey: widget.accessoryAssetKey),
        ],
      ),
    );

    if (!widget.animate || MediaQuery.disableAnimationsOf(context)) {
      return image;
    }

    return AnimatedBuilder(
      animation: _float,
      child: image,
      builder: (context, child) {
        final progress = _float.value;
        return Transform.translate(
          offset: Offset(0, -3.5 * progress),
          child: Transform.rotate(
            angle: math.sin(progress * math.pi) * 0.006,
            child: child,
          ),
        );
      },
    );
  }
}

class _SilaAccessoryOverlay extends StatelessWidget {
  const _SilaAccessoryOverlay({required this.assetKey});

  final String assetKey;

  @override
  Widget build(BuildContext context) {
    if (!SilaMascotAccessories.supported.contains(assetKey)) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        key: ValueKey('sila-mascot-accessory-$assetKey'),
        painter: _SilaAccessoryPainter(assetKey),
      ),
    );
  }
}

class _SilaAccessoryPainter extends CustomPainter {
  const _SilaAccessoryPainter(this.assetKey);

  final String assetKey;

  @override
  void paint(Canvas canvas, Size size) {
    switch (assetKey) {
      case SilaMascotAccessories.guardianCrown:
        _paintCrown(canvas, size);
      case SilaMascotAccessories.explorerCap:
        _paintExplorerCap(canvas, size);
      case SilaMascotAccessories.starHalo:
        _paintStarHalo(canvas, size);
    }
  }

  void _paintCrown(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final baseY = size.height * 0.205;
    final halfWidth = size.width * 0.23;
    final crownHeight = size.height * 0.105;
    final crown = Path()
      ..moveTo(centerX - halfWidth, baseY)
      ..lineTo(centerX - halfWidth * 0.86, baseY - crownHeight * 0.92)
      ..lineTo(centerX - halfWidth * 0.3, baseY - crownHeight * 0.47)
      ..lineTo(centerX, baseY - crownHeight * 1.18)
      ..lineTo(centerX + halfWidth * 0.3, baseY - crownHeight * 0.47)
      ..lineTo(centerX + halfWidth * 0.86, baseY - crownHeight * 0.92)
      ..lineTo(centerX + halfWidth, baseY)
      ..close();
    final bounds = crown.getBounds();
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFF0A6), Color(0xFFF0B62F), Color(0xFFB77612)],
      ).createShader(bounds)
      ..style = PaintingStyle.fill;
    canvas.drawShadow(crown, const Color(0xAA5B3900), 5, false);
    canvas.drawPath(crown, paint);
    canvas.drawPath(
      crown,
      Paint()
        ..color = const Color(0xFFFFF2B7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, size.width * 0.012),
    );

    for (final point in [
      Offset(centerX - halfWidth * 0.82, baseY - crownHeight * 0.88),
      Offset(centerX, baseY - crownHeight * 1.13),
      Offset(centerX + halfWidth * 0.82, baseY - crownHeight * 0.88),
    ]) {
      canvas.drawCircle(
        point,
        size.width * 0.026,
        Paint()..color = const Color(0xFFFF6B52),
      );
    }
  }

  void _paintExplorerCap(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final crown = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, size.height * 0.155),
        width: size.width * 0.43,
        height: size.height * 0.105,
      ),
      Radius.circular(size.width * 0.12),
    );
    final crownPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF16A56A), Color(0xFF006B49), Color(0xFF064C39)],
      ).createShader(crown.outerRect);
    canvas.drawShadow(
      Path()..addRRect(crown),
      const Color(0x9900271B),
      4,
      false,
    );
    canvas.drawRRect(crown, crownPaint);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + size.width * 0.13, size.height * 0.19),
        width: size.width * 0.34,
        height: size.height * 0.052,
      ),
      Paint()..color = const Color(0xFF074D39),
    );
    canvas.drawCircle(
      Offset(centerX - size.width * 0.07, size.height * 0.15),
      size.width * 0.035,
      Paint()..color = const Color(0xFFFFD77A),
    );
  }

  void _paintStarHalo(Canvas canvas, Size size) {
    final haloRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.255),
      width: size.width * 0.86,
      height: size.height * 0.29,
    );
    final haloPaint = Paint()
      ..color = const Color(0xFFFFD77A).withValues(alpha: 0.82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.3, size.width * 0.012);
    canvas.drawOval(haloRect, haloPaint);

    final sparklePaint = Paint()..color = const Color(0xFFFFE9A8);
    for (final angle in [-2.5, -1.35, -0.25, 0.7, 2.25]) {
      final point = Offset(
        haloRect.center.dx + math.cos(angle) * haloRect.width / 2,
        haloRect.center.dy + math.sin(angle) * haloRect.height / 2,
      );
      final radius = size.width * (angle == -1.35 ? 0.035 : 0.024);
      canvas.save();
      canvas.translate(point.dx, point.dy);
      canvas.rotate(math.pi / 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: radius * 1.2,
            height: radius * 2.6,
          ),
          Radius.circular(radius),
        ),
        sparklePaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: radius * 2.6,
            height: radius * 1.2,
          ),
          Radius.circular(radius),
        ),
        sparklePaint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SilaAccessoryPainter oldDelegate) {
    return oldDelegate.assetKey != assetKey;
  }
}

class SilaMascotGuide extends StatelessWidget {
  const SilaMascotGuide({
    super.key,
    required this.message,
    required this.semanticLabel,
    this.title,
    this.pose = SilaMascotPose.welcome,
    this.compact = false,
    this.animate = true,
    this.action,
    this.accessoryAssetKey = SilaMascotAccessories.none,
  });

  final String message;
  final String semanticLabel;
  final String? title;
  final SilaMascotPose pose;
  final bool compact;
  final bool animate;
  final Widget? action;
  final String accessoryAssetKey;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 340;
        final mascot = SilaMascot(
          pose: pose,
          height: compact ? 118 : 164,
          animate: animate,
          semanticLabel: semanticLabel,
          accessoryAssetKey: accessoryAssetKey,
        );
        final bubble = _MascotSpeechBubble(
          title: title,
          message: message,
          action: action,
          showSidePointer: !stacked,
          compact: compact,
        );

        if (stacked) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              mascot,
              const SizedBox(height: 4),
              SizedBox(width: double.infinity, child: bubble),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            mascot,
            SizedBox(width: compact ? 8 : 12),
            Expanded(child: bubble),
          ],
        );
      },
    );
  }
}

class _MascotSpeechBubble extends StatelessWidget {
  const _MascotSpeechBubble({
    required this.message,
    required this.showSidePointer,
    required this.compact,
    this.title,
    this.action,
  });

  final String message;
  final bool showSidePointer;
  final bool compact;
  final String? title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surface = colorScheme.surface;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (showSidePointer)
          PositionedDirectional(
            start: -6,
            top: compact ? 24 : 32,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: surface,
                  border: Border(
                    left: BorderSide(color: colorScheme.outlineVariant),
                    bottom: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
              ),
            ),
          ),
        Container(
          padding: EdgeInsets.all(compact ? 14 : 18),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(compact ? 20 : 24),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title case final title?) ...[
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
              ],
              Text(
                message,
                style:
                    (compact
                            ? theme.textTheme.bodyMedium
                            : theme.textTheme.bodyLarge)
                        ?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
              ),
              if (action case final action?) ...[
                const SizedBox(height: 12),
                action,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class SilaSharedRootsMark extends StatelessWidget {
  const SilaSharedRootsMark({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: const CustomPaint(painter: _SharedRootsPainter()),
      ),
    );
  }
}

class _SharedRootsPainter extends CustomPainter {
  const _SharedRootsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide;
    final stroke = math.max(2.0, scale * 0.075);
    final greenPaint = Paint()
      ..color = SilaMascotPalette.deepGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final rootPath = Path()
      ..moveTo(scale * 0.17, scale * 0.78)
      ..quadraticBezierTo(
        scale * 0.5,
        scale * 0.92,
        scale * 0.83,
        scale * 0.78,
      );
    canvas.drawPath(rootPath, greenPaint);

    final stems = [
      (Offset(scale * 0.30, scale * 0.73), Offset(scale * 0.30, scale * 0.48)),
      (Offset(scale * 0.50, scale * 0.80), Offset(scale * 0.50, scale * 0.25)),
      (Offset(scale * 0.70, scale * 0.73), Offset(scale * 0.70, scale * 0.48)),
    ];
    for (final stem in stems) {
      canvas.drawLine(stem.$1, stem.$2, greenPaint);
    }

    final radius = scale * 0.105;
    canvas.drawCircle(
      stems[0].$2,
      radius,
      Paint()..color = SilaMascotPalette.sandGold,
    );
    canvas.drawCircle(
      stems[1].$2,
      radius,
      Paint()..color = SilaMascotPalette.deepGreen,
    );
    canvas.drawCircle(
      stems[2].$2,
      radius,
      Paint()..color = SilaMascotPalette.coral,
    );
  }

  @override
  bool shouldRepaint(covariant _SharedRootsPainter oldDelegate) => false;
}
