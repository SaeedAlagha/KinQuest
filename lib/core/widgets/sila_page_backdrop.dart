import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SilaPageBackdrop extends StatelessWidget {
  const SilaPageBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<SilaThemeTokens>();
    final isDark = theme.brightness == Brightness.dark;
    final visualStyle = tokens?.visualStyle ?? SilaVisualStyle.classic;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppTheme.pageGradientFor(context)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: CustomPaint(
              painter: _SilaBackdropPainter(
                isDark: isDark,
                visualStyle: visualStyle,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _SilaBackdropPainter extends CustomPainter {
  const _SilaBackdropPainter({required this.isDark, required this.visualStyle});

  final bool isDark;
  final SilaVisualStyle visualStyle;

  @override
  void paint(Canvas canvas, Size size) {
    switch (visualStyle) {
      case SilaVisualStyle.familyYear:
        _paintFamilyYear(canvas, size);
      case SilaVisualStyle.space:
        _paintSpace(canvas, size);
      case SilaVisualStyle.khalifaUniversity:
        _paintKhalifaUniversity(canvas, size);
      case SilaVisualStyle.desertNights:
        _paintDesertNights(canvas, size);
      case SilaVisualStyle.pearlLagoon:
        _paintPearlLagoon(canvas, size);
      case SilaVisualStyle.classic:
        _paintClassic(canvas, size);
    }
  }

  void _paintClassic(Canvas canvas, Size size) {
    final shortSide = size.shortestSide;
    final connectionPaint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: isDark ? 0.16 : 0.045)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final greenOrb = Paint()
      ..color = AppTheme.uaeGreen.withValues(alpha: isDark ? 0.13 : 0.045)
      ..style = PaintingStyle.fill;
    final redOrb = Paint()
      ..color = AppTheme.uaeRed.withValues(alpha: isDark ? 0.085 : 0.032)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.03, size.height * 0.86),
      shortSide * 0.26,
      greenOrb,
    );
    canvas.drawCircle(
      Offset(size.width * 0.94, size.height * 0.1),
      shortSide * 0.2,
      redOrb,
    );

    final nodes = [
      Offset(size.width * 0.77, size.height * 0.18),
      Offset(size.width * 0.9, size.height * 0.32),
      Offset(size.width * 0.8, size.height * 0.47),
      Offset(size.width * 0.67, size.height * 0.32),
    ];
    final path = Path()..moveTo(nodes.first.dx, nodes.first.dy);
    for (final node in nodes.skip(1)) {
      path.lineTo(node.dx, node.dy);
    }
    path.close();
    canvas.drawPath(path, connectionPaint);

    final nodePaint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: isDark ? 0.24 : 0.07)
      ..style = PaintingStyle.fill;
    for (final node in nodes) {
      canvas.drawCircle(node, 4, nodePaint);
    }
  }

  void _paintFamilyYear(Canvas canvas, Size size) {
    final shortSide = size.shortestSide;
    final gold = Paint()
      ..color = const Color(0xFFC3943E).withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final red = Paint()
      ..color = const Color(0xFF7A2432).withValues(alpha: 0.075)
      ..style = PaintingStyle.fill;
    final green = Paint()
      ..color = AppTheme.uaeGreen.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.93, size.height * 0.1),
      shortSide * 0.24,
      red,
    );
    canvas.drawCircle(
      Offset(size.width * 0.04, size.height * 0.82),
      shortSide * 0.28,
      green,
    );

    final archWidth = shortSide * 0.25;
    final archHeight = shortSide * 0.42;
    final arch = Path()
      ..moveTo(size.width * 0.72, size.height * 0.02 + archHeight)
      ..lineTo(size.width * 0.72, size.height * 0.02 + archWidth / 2)
      ..arcToPoint(
        Offset(
          size.width * 0.72 + archWidth,
          size.height * 0.02 + archWidth / 2,
        ),
        radius: Radius.circular(archWidth / 2),
      )
      ..lineTo(size.width * 0.72 + archWidth, size.height * 0.02 + archHeight);
    canvas.drawPath(arch, gold);

    final diamondPaint = Paint()
      ..color = const Color(0xFF7A2432).withValues(alpha: 0.11)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (var index = 0; index < 4; index++) {
      final center = Offset(size.width * 0.08 + index * 42, size.height * 0.9);
      final diamond = Path()
        ..moveTo(center.dx, center.dy - 12)
        ..lineTo(center.dx + 12, center.dy)
        ..lineTo(center.dx, center.dy + 12)
        ..lineTo(center.dx - 12, center.dy)
        ..close();
      canvas.drawPath(diamond, diamondPaint);
    }
  }

  void _paintSpace(Canvas canvas, Size size) {
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.5);
    const stars = <Offset>[
      Offset(0.08, 0.10),
      Offset(0.18, 0.24),
      Offset(0.32, 0.08),
      Offset(0.44, 0.32),
      Offset(0.57, 0.14),
      Offset(0.72, 0.26),
      Offset(0.87, 0.07),
      Offset(0.94, 0.4),
      Offset(0.12, 0.57),
      Offset(0.35, 0.68),
      Offset(0.62, 0.55),
      Offset(0.83, 0.73),
      Offset(0.2, 0.9),
      Offset(0.7, 0.91),
    ];
    for (var index = 0; index < stars.length; index++) {
      final star = stars[index];
      canvas.drawCircle(
        Offset(star.dx * size.width, star.dy * size.height),
        index.isEven ? 1.7 : 1,
        starPaint,
      );
    }

    final orbit = Paint()
      ..color = const Color(0xFF69D8FF).withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final planet = Offset(size.width * 0.84, size.height * 0.17);
    canvas.drawCircle(
      planet,
      size.shortestSide * 0.09,
      Paint()..color = const Color(0xFFAE8BFF).withValues(alpha: 0.14),
    );
    canvas.save();
    canvas.translate(planet.dx, planet.dy);
    canvas.rotate(-0.35);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.shortestSide * 0.29,
        height: size.shortestSide * 0.08,
      ),
      orbit,
    );
    canvas.restore();

    final comet = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x0069D8FF), Color(0x9969D8FF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width * 0.28, 2))
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width * 0.05, size.height * 0.72),
      Offset(size.width * 0.31, size.height * 0.65),
      comet,
    );
  }

  void _paintKhalifaUniversity(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFF0057B8).withValues(alpha: 0.055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const spacing = 36.0;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final circuit = Paint()
      ..color = const Color(0xFF00A9CE).withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      ..moveTo(size.width * 0.64, size.height * 0.06)
      ..lineTo(size.width * 0.82, size.height * 0.06)
      ..lineTo(size.width * 0.82, size.height * 0.18)
      ..lineTo(size.width * 0.96, size.height * 0.18);
    canvas.drawPath(path, circuit);
    for (final node in [
      Offset(size.width * 0.64, size.height * 0.06),
      Offset(size.width * 0.82, size.height * 0.18),
      Offset(size.width * 0.96, size.height * 0.18),
    ]) {
      canvas.drawCircle(node, 4, Paint()..color = const Color(0xFF0057B8));
    }

    final hexagon = Path();
    final center = Offset(size.width * 0.1, size.height * 0.83);
    final radius = size.shortestSide * 0.12;
    for (var index = 0; index < 6; index++) {
      final angle = index * 1.0472;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (index == 0) {
        hexagon.moveTo(point.dx, point.dy);
      } else {
        hexagon.lineTo(point.dx, point.dy);
      }
    }
    hexagon.close();
    canvas.drawPath(hexagon, circuit);
  }

  void _paintDesertNights(Canvas canvas, Size size) {
    final moonCenter = Offset(size.width * 0.84, size.height * 0.13);
    canvas.drawCircle(
      moonCenter,
      size.shortestSide * 0.095,
      Paint()..color = const Color(0xFFE8BD68).withValues(alpha: 0.28),
    );
    canvas.drawCircle(
      moonCenter.translate(size.shortestSide * 0.035, -6),
      size.shortestSide * 0.085,
      Paint()..color = const Color(0xFF20122D).withValues(alpha: 0.92),
    );

    final dunes = Paint()
      ..color = const Color(0xFFE17B69).withValues(alpha: 0.11)
      ..style = PaintingStyle.fill;
    final frontDune = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.7,
        size.width * 0.56,
        size.height * 0.84,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.92,
        size.width,
        size.height * 0.76,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(frontDune, dunes);

    final star = Paint()
      ..color = const Color(0xFFE8BD68).withValues(alpha: 0.5);
    for (final point in const [
      Offset(0.11, 0.16),
      Offset(0.28, 0.08),
      Offset(0.52, 0.21),
      Offset(0.68, 0.09),
      Offset(0.92, 0.34),
    ]) {
      canvas.drawCircle(
        Offset(point.dx * size.width, point.dy * size.height),
        1.5,
        star,
      );
    }
  }

  void _paintPearlLagoon(Canvas canvas, Size size) {
    final bubbleStroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.58)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final bubbleFill = Paint()
      ..color = const Color(0xFF45B9B0).withValues(alpha: 0.08);
    for (final bubble in [
      (Offset(size.width * 0.88, size.height * 0.12), 52.0),
      (Offset(size.width * 0.73, size.height * 0.2), 22.0),
      (Offset(size.width * 0.11, size.height * 0.78), 40.0),
      (Offset(size.width * 0.22, size.height * 0.88), 18.0),
    ]) {
      canvas.drawCircle(bubble.$1, bubble.$2, bubbleFill);
      canvas.drawCircle(bubble.$1, bubble.$2, bubbleStroke);
    }

    final wave = Paint()
      ..color = const Color(0xFF087F8C).withValues(alpha: 0.085)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22;
    final wavePath = Path()
      ..moveTo(-20, size.height * 0.9)
      ..cubicTo(
        size.width * 0.2,
        size.height * 0.79,
        size.width * 0.35,
        size.height,
        size.width * 0.56,
        size.height * 0.88,
      )
      ..cubicTo(
        size.width * 0.75,
        size.height * 0.78,
        size.width * 0.88,
        size.height * 0.96,
        size.width + 20,
        size.height * 0.84,
      );
    canvas.drawPath(wavePath, wave);
  }

  @override
  bool shouldRepaint(covariant _SilaBackdropPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.visualStyle != visualStyle;
  }
}
