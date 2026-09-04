part of 'sila_mascot.dart';

// Sila's source poses are soft, dimensional illustrations. These painters use
// the same pearl, teal, navy, gold, and coral material language so equipped
// pieces feel like part of the character instead of flat stickers.

double _cosmeticStroke(Size size, double fraction, {double minimum = 0.7}) =>
    math.max(minimum, size.width * fraction);

double _cosmeticShadow(Size size) => math.max(0.65, size.width * 0.012);

bool _useCosmeticGlow(Size size) => size.width >= 64;

void _paintBondMark(
  Canvas canvas,
  Offset center,
  double width, {
  required Color color,
  Color? highlight,
}) {
  final stroke = math.max(0.65, width * 0.105);
  final loopSize = Size(width * 0.54, width * 0.34);
  for (final direction in [-1.0, 1.0]) {
    canvas.save();
    canvas.translate(center.dx + direction * width * 0.13, center.dy);
    canvas.rotate(direction * math.pi / 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: loopSize.width,
          height: loopSize.height,
        ),
        Radius.circular(loopSize.height / 2),
      ),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }
  if (highlight case final highlight?) {
    canvas.drawCircle(
      center.translate(-width * 0.08, -width * 0.08),
      math.max(0.45, width * 0.035),
      Paint()..color = highlight,
    );
  }
}

Path _fourPointStarPath(Offset center, double outer, double inner) {
  final path = Path();
  for (var index = 0; index < 8; index += 1) {
    final radius = index.isEven ? outer : inner;
    final angle = -math.pi / 2 + index * math.pi / 4;
    final point = Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
    if (index == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }
  return path..close();
}

Path _heartPath(Offset center, double radius) {
  return Path()
    ..moveTo(center.dx, center.dy + radius * 0.86)
    ..cubicTo(
      center.dx - radius * 1.62,
      center.dy - radius * 0.18,
      center.dx - radius * 0.78,
      center.dy - radius * 1.34,
      center.dx,
      center.dy - radius * 0.52,
    )
    ..cubicTo(
      center.dx + radius * 0.78,
      center.dy - radius * 1.34,
      center.dx + radius * 1.62,
      center.dy - radius * 0.18,
      center.dx,
      center.dy + radius * 0.86,
    )
    ..close();
}

Path _leafPath(Offset center, double length, double width, double angle) {
  final local = Path()
    ..moveTo(-length / 2, 0)
    ..quadraticBezierTo(0, -width, length / 2, 0)
    ..quadraticBezierTo(0, width, -length / 2, 0)
    ..close();
  final matrix = Matrix4.identity()
    ..setTranslationRaw(center.dx, center.dy, 0)
    ..rotateZ(angle);
  return local.transform(matrix.storage);
}

void _drawMaterialPath(
  Canvas canvas,
  Path path,
  Size size, {
  required List<Color> colors,
  Alignment begin = Alignment.topLeft,
  Alignment end = Alignment.bottomRight,
  Color shadow = const Color(0x55000000),
  Color? rim,
}) {
  final bounds = path.getBounds();
  canvas.drawShadow(path, shadow, _cosmeticShadow(size), false);
  canvas.drawPath(
    path,
    Paint()
      ..shader = LinearGradient(
        begin: begin,
        end: end,
        colors: colors,
      ).createShader(bounds),
  );
  if (rim case final rim?) {
    canvas.drawPath(
      path,
      Paint()
        ..color = rim
        ..style = PaintingStyle.stroke
        ..strokeWidth = _cosmeticStroke(size, 0.007),
    );
  }
}

class _SilaOutfitPainter extends CustomPainter {
  const _SilaOutfitPainter(this.assetKey, this.layer, this.pose);

  final String assetKey;
  final _SilaCosmeticLayer layer;
  final SilaMascotPose pose;

  @override
  void paint(Canvas canvas, Size size) {
    final protectHands =
        layer == _SilaCosmeticLayer.front &&
        pose != SilaMascotPose.idle &&
        pose != SilaMascotPose.celebrating;
    if (protectHands) {
      canvas.save();
      canvas.clipPath(_frontOutfitPaintArea(size), doAntiAlias: true);
    }
    switch (assetKey) {
      case SilaMascotOutfits.familyCape:
        _paintFamilyCape(canvas, size);
      case SilaMascotOutfits.gameJersey:
        _paintGameJersey(canvas, size);
      case SilaMascotOutfits.memoryKeeper:
        _paintMemoryKeeper(canvas, size);
      case SilaMascotOutfits.spaceScout:
        _paintSpaceScout(canvas, size);
      case SilaMascotOutfits.desertExplorer:
        _paintDesertExplorer(canvas, size);
    }
    if (protectHands) canvas.restore();
  }

  Path _frontOutfitPaintArea(Size size) {
    final masks = switch (pose) {
      SilaMascotPose.welcome => const [(Offset(0.27, 0.60), Size(0.22, 0.28))],
      SilaMascotPose.thinking => const [(Offset(0.36, 0.59), Size(0.28, 0.29))],
      SilaMascotPose.oops => const [
        (Offset(0.30, 0.56), Size(0.23, 0.25)),
        (Offset(0.70, 0.56), Size(0.23, 0.25)),
      ],
      SilaMascotPose.encouraging => const [
        (Offset(0.27, 0.60), Size(0.21, 0.26)),
        (Offset(0.73, 0.60), Size(0.21, 0.26)),
      ],
      SilaMascotPose.winner => const [
        (Offset(0.28, 0.59), Size(0.27, 0.30)),
        (Offset(0.71, 0.68), Size(0.23, 0.27)),
      ],
      _ => const <(Offset, Size)>[],
    };
    final paintArea = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size);
    for (final mask in masks) {
      paintArea.addOval(
        Rect.fromCenter(
          center: Offset(size.width * mask.$1.dx, size.height * mask.$1.dy),
          width: size.width * mask.$2.width,
          height: size.height * mask.$2.height,
        ),
      );
    }
    return paintArea;
  }

  void _paintFamilyCape(Canvas canvas, Size size) {
    if (layer == _SilaCosmeticLayer.back) {
      final cape = Path()
        ..moveTo(size.width * 0.31, size.height * 0.57)
        ..cubicTo(
          size.width * 0.20,
          size.height * 0.61,
          size.width * 0.18,
          size.height * 0.78,
          size.width * 0.25,
          size.height * 0.90,
        )
        ..cubicTo(
          size.width * 0.34,
          size.height * 0.87,
          size.width * 0.43,
          size.height * 0.80,
          size.width * 0.50,
          size.height * 0.70,
        )
        ..cubicTo(
          size.width * 0.57,
          size.height * 0.80,
          size.width * 0.66,
          size.height * 0.87,
          size.width * 0.75,
          size.height * 0.90,
        )
        ..cubicTo(
          size.width * 0.82,
          size.height * 0.76,
          size.width * 0.79,
          size.height * 0.62,
          size.width * 0.69,
          size.height * 0.57,
        )
        ..quadraticBezierTo(
          size.width * 0.50,
          size.height * 0.64,
          size.width * 0.31,
          size.height * 0.57,
        )
        ..close();
      _drawMaterialPath(
        canvas,
        cape,
        size,
        colors: const [Color(0xFF0BB184), Color(0xFF087443), Color(0xFF043C2F)],
        shadow: const Color(0x77002018),
        rim: const Color(0x883DE0B4),
      );

      final foldPaint = Paint()
        ..color = const Color(0xFF8AF0D2).withValues(alpha: 0.44)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _cosmeticStroke(size, 0.006)
        ..strokeCap = StrokeCap.round;
      for (final direction in [-1.0, 1.0]) {
        canvas.drawPath(
          Path()
            ..moveTo(size.width * (0.50 + direction * 0.08), size.height * 0.64)
            ..quadraticBezierTo(
              size.width * (0.50 + direction * 0.22),
              size.height * 0.75,
              size.width * (0.50 + direction * 0.24),
              size.height * 0.86,
            ),
          foldPaint,
        );
      }
      return;
    }

    final leftLapell = Path()
      ..moveTo(size.width * 0.34, size.height * 0.585)
      ..quadraticBezierTo(
        size.width * 0.40,
        size.height * 0.615,
        size.width * 0.49,
        size.height * 0.638,
      )
      ..lineTo(size.width * 0.45, size.height * 0.68)
      ..quadraticBezierTo(
        size.width * 0.36,
        size.height * 0.65,
        size.width * 0.34,
        size.height * 0.585,
      )
      ..close();
    final rightLapell = Path()
      ..moveTo(size.width * 0.66, size.height * 0.585)
      ..quadraticBezierTo(
        size.width * 0.60,
        size.height * 0.615,
        size.width * 0.51,
        size.height * 0.638,
      )
      ..lineTo(size.width * 0.55, size.height * 0.68)
      ..quadraticBezierTo(
        size.width * 0.64,
        size.height * 0.65,
        size.width * 0.66,
        size.height * 0.585,
      )
      ..close();
    for (final lapel in [leftLapell, rightLapell]) {
      _drawMaterialPath(
        canvas,
        lapel,
        size,
        colors: const [Color(0xFF31D2A4), Color(0xFF087443), Color(0xFF03513B)],
        shadow: const Color(0x55002A1C),
        rim: const Color(0xCC9AF5D9),
      );
    }

    final claspCenter = Offset(size.width * 0.5, size.height * 0.652);
    final claspRect = Rect.fromCircle(
      center: claspCenter,
      radius: size.width * 0.042,
    );
    canvas.drawCircle(
      claspCenter,
      size.width * 0.044,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.4),
          colors: [Color(0xFFFFF0A6), Color(0xFFE4A719), Color(0xFF8E5908)],
        ).createShader(claspRect),
    );
    _paintBondMark(
      canvas,
      claspCenter,
      size.width * 0.052,
      color: const Color(0xFF087443),
      highlight: Colors.white.withValues(alpha: 0.8),
    );
  }

  void _paintGameJersey(Canvas canvas, Size size) {
    if (layer == _SilaCosmeticLayer.back) return;

    final jerseySilhouette = Path()
      ..moveTo(size.width * 0.36, size.height * 0.60)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.64,
        size.width * 0.64,
        size.height * 0.60,
      )
      ..quadraticBezierTo(
        size.width * 0.71,
        size.height * 0.68,
        size.width * 0.69,
        size.height * 0.80,
      )
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.87,
        size.width * 0.31,
        size.height * 0.80,
      )
      ..quadraticBezierTo(
        size.width * 0.29,
        size.height * 0.68,
        size.width * 0.36,
        size.height * 0.60,
      )
      ..close();
    canvas.drawPath(
      jerseySilhouette,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0x4428BFC3), Color(0x12FFFFFF), Color(0x44364F9C)],
        ).createShader(jerseySilhouette.getBounds()),
    );
    canvas.drawPath(
      jerseySilhouette,
      Paint()
        ..color = const Color(0xFF76EAD7).withValues(alpha: 0.64)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _cosmeticStroke(size, 0.006),
    );

    final leftPanel = Path()
      ..moveTo(size.width * 0.36, size.height * 0.60)
      ..quadraticBezierTo(
        size.width * 0.29,
        size.height * 0.67,
        size.width * 0.31,
        size.height * 0.80,
      )
      ..quadraticBezierTo(
        size.width * 0.34,
        size.height * 0.85,
        size.width * 0.43,
        size.height * 0.82,
      )
      ..lineTo(size.width * 0.445, size.height * 0.665)
      ..close();
    final rightPanel = Path()
      ..moveTo(size.width * 0.64, size.height * 0.60)
      ..quadraticBezierTo(
        size.width * 0.71,
        size.height * 0.67,
        size.width * 0.69,
        size.height * 0.80,
      )
      ..quadraticBezierTo(
        size.width * 0.66,
        size.height * 0.85,
        size.width * 0.57,
        size.height * 0.82,
      )
      ..lineTo(size.width * 0.555, size.height * 0.665)
      ..close();
    for (final panel in [leftPanel, rightPanel]) {
      _drawMaterialPath(
        canvas,
        panel,
        size,
        colors: const [Color(0xFF19B8BE), Color(0xFF0B5CA9), Color(0xFF071D59)],
        shadow: const Color(0x66002151),
        rim: const Color(0xFF75F1DD),
      );
    }

    final collar = Path()
      ..moveTo(size.width * 0.37, size.height * 0.60)
      ..quadraticBezierTo(
        size.width * 0.43,
        size.height * 0.615,
        size.width * 0.50,
        size.height * 0.665,
      )
      ..quadraticBezierTo(
        size.width * 0.57,
        size.height * 0.615,
        size.width * 0.63,
        size.height * 0.60,
      );
    canvas.drawPath(
      collar,
      Paint()
        ..color = const Color(0xFFFFE39A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _cosmeticStroke(size, 0.012)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      collar,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _cosmeticStroke(size, 0.004)
        ..strokeCap = StrokeCap.round,
    );

    final hem = Path()
      ..moveTo(size.width * 0.32, size.height * 0.80)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.855,
        size.width * 0.68,
        size.height * 0.80,
      );
    canvas.drawPath(
      hem,
      Paint()
        ..color = const Color(0xFFFFD875)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _cosmeticStroke(size, 0.009)
        ..strokeCap = StrokeCap.round,
    );

    // Card/profile Silas are too small for legible typography. At those sizes
    // the clean color blocking carries the jersey identity without a fuzzy or
    // oversized badge; richer details return in the shop and Studio.
    if (size.width >= 64) {
      final badgeCenter = Offset(size.width * 0.395, size.height * 0.705);
      canvas.drawCircle(
        badgeCenter,
        size.width * 0.036,
        Paint()..color = SilaMascotPalette.pearl.withValues(alpha: 0.95),
      );
      _paintBondMark(
        canvas,
        badgeCenter,
        size.width * 0.044,
        color: const Color(0xFF087443),
      );

      final numberPainter = TextPainter(
        text: TextSpan(
          text: '26',
          style: TextStyle(
            color: const Color(0xFFFFE39A),
            fontSize: math.max(5, size.width * 0.072),
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      numberPainter.paint(
        canvas,
        Offset(
          size.width * 0.615 - numberPainter.width / 2,
          size.height * 0.68,
        ),
      );
    }
  }

  Offset _memoryStrapStart(Size size) {
    final normalized = switch (pose) {
      SilaMascotPose.thinking => const Offset(0.46, 0.66),
      SilaMascotPose.oops => const Offset(0.40, 0.625),
      SilaMascotPose.encouraging => const Offset(0.39, 0.62),
      SilaMascotPose.winner => const Offset(0.39, 0.62),
      _ => const Offset(0.36, 0.585),
    };
    return Offset(size.width * normalized.dx, size.height * normalized.dy);
  }

  void _paintMemoryKeeper(Canvas canvas, Size size) {
    final strapEnd = Offset(size.width * 0.625, size.height * 0.805);
    if (layer == _SilaCosmeticLayer.back) {
      final strapStart = _memoryStrapStart(size);
      final rearStrap = Path()
        ..moveTo(strapStart.dx, strapStart.dy)
        ..quadraticBezierTo(
          size.width * 0.49,
          size.height * 0.69,
          strapEnd.dx,
          strapEnd.dy,
        );
      canvas.drawPath(
        rearStrap,
        Paint()
          ..color = const Color(0x55002F24)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _cosmeticStroke(size, 0.026)
          ..strokeCap = StrokeCap.round,
      );
      return;
    }

    final strap = Path()
      ..moveTo(_memoryStrapStart(size).dx, _memoryStrapStart(size).dy)
      ..quadraticBezierTo(
        size.width * 0.52,
        size.height * 0.70,
        strapEnd.dx,
        strapEnd.dy,
      );
    canvas.drawPath(
      strap,
      Paint()
        ..color = const Color(0x55000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _cosmeticStroke(size, 0.024)
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      strap,
      Paint()
        ..shader =
            const LinearGradient(
              colors: [Color(0xFFE8C47E), Color(0xFF9B662D), Color(0xFF087443)],
            ).createShader(
              Rect.fromLTRB(
                0,
                size.height * 0.58,
                size.width,
                size.height * 0.82,
              ),
            )
        ..style = PaintingStyle.stroke
        ..strokeWidth = _cosmeticStroke(size, 0.016)
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      strap,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.48)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _cosmeticStroke(size, 0.004)
        ..strokeCap = StrokeCap.round,
    );

    final bagRect = Rect.fromCenter(
      center: Offset(size.width * 0.645, size.height * 0.81),
      width: size.width * 0.19,
      height: size.height * 0.105,
    );
    final bag = RRect.fromRectAndRadius(
      bagRect,
      Radius.circular(size.width * 0.035),
    );
    final bagPath = Path()..addRRect(bag);
    _drawMaterialPath(
      canvas,
      bagPath,
      size,
      colors: const [Color(0xFFE6B86A), Color(0xFF9C632B), Color(0xFF5E351A)],
      shadow: const Color(0x77000000),
      rim: const Color(0xFFFFE0A0),
    );
    final flap = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        bagRect.left + size.width * 0.008,
        bagRect.top + size.height * 0.006,
        bagRect.width - size.width * 0.016,
        bagRect.height * 0.42,
      ),
      Radius.circular(size.width * 0.024),
    );
    canvas.drawRRect(
      flap,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFD88C), Color(0xFFAA6B2E)],
        ).createShader(flap.outerRect),
    );
    final lensCenter = bagRect.center.translate(
      size.width * 0.02,
      size.height * 0.008,
    );
    for (final entry in [
      (size.width * 0.047, const Color(0xFF062E55)),
      (size.width * 0.034, const Color(0xFF35D9C2)),
      (size.width * 0.023, const Color(0xFF0D4D80)),
    ]) {
      canvas.drawCircle(lensCenter, entry.$1, Paint()..color = entry.$2);
    }
    canvas.drawCircle(
      lensCenter.translate(-size.width * 0.009, -size.width * 0.009),
      size.width * 0.006,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawCircle(
      bagRect.topLeft.translate(size.width * 0.035, size.height * 0.02),
      size.width * 0.009,
      Paint()..color = const Color(0xFFFFF0A6),
    );
  }

  void _paintSpaceScout(Canvas canvas, Size size) {
    if (layer == _SilaCosmeticLayer.back) {
      for (final direction in [-1.0, 1.0]) {
        final fin = Path()
          ..moveTo(size.width * (0.50 + direction * 0.17), size.height * 0.64)
          ..quadraticBezierTo(
            size.width * (0.50 + direction * 0.29),
            size.height * 0.68,
            size.width * (0.50 + direction * 0.26),
            size.height * 0.81,
          )
          ..lineTo(size.width * (0.50 + direction * 0.15), size.height * 0.76)
          ..close();
        _drawMaterialPath(
          canvas,
          fin,
          size,
          colors: const [
            Color(0xFFEFFAF2),
            Color(0xFF69DACA),
            Color(0xFF29417F),
          ],
          shadow: const Color(0x660A1742),
          rim: const Color(0xFFB8FFF0),
        );
        final glowCenter = Offset(
          size.width * (0.50 + direction * 0.255),
          size.height * 0.795,
        );
        canvas.drawCircle(
          glowCenter,
          size.width * 0.028,
          Paint()
            ..color = const Color(0xFF5BF4E2).withValues(alpha: 0.40)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              size.width * 0.025,
            ),
        );
      }
      return;
    }

    for (final direction in [-1.0, 1.0]) {
      final panel = Path()
        ..moveTo(size.width * (0.50 + direction * 0.125), size.height * 0.61)
        ..quadraticBezierTo(
          size.width * (0.50 + direction * 0.205),
          size.height * 0.65,
          size.width * (0.50 + direction * 0.19),
          size.height * 0.79,
        )
        ..quadraticBezierTo(
          size.width * (0.50 + direction * 0.13),
          size.height * 0.83,
          size.width * (0.50 + direction * 0.075),
          size.height * 0.785,
        )
        ..lineTo(size.width * (0.50 + direction * 0.07), size.height * 0.66)
        ..close();
      _drawMaterialPath(
        canvas,
        panel,
        size,
        colors: direction < 0
            ? const [Color(0xFFF8F4DE), Color(0xFF70E2D2), Color(0xFF18336F)]
            : const [Color(0xFF9AF4E5), Color(0xFF3155A0), Color(0xFF0B174D)],
        shadow: const Color(0x66071645),
        rim: const Color(0xFF92F5E2),
      );
    }

    final collar = Path()
      ..moveTo(size.width * 0.37, size.height * 0.605)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.67,
        size.width * 0.63,
        size.height * 0.605,
      );
    canvas.drawPath(
      collar,
      Paint()
        ..color = const Color(0xFF10275E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _cosmeticStroke(size, 0.024)
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      collar,
      Paint()
        ..color = const Color(0xFF7CF4E3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _cosmeticStroke(size, 0.008)
        ..strokeCap = StrokeCap.round,
    );

    final core = Offset(size.width * 0.50, size.height * 0.72);
    canvas.drawCircle(
      core,
      size.width * 0.105,
      Paint()
        ..color = const Color(0xFF54E6D2).withValues(alpha: 0.16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _cosmeticStroke(size, 0.01),
    );
    _paintBondMark(
      canvas,
      core,
      size.width * 0.075,
      color: const Color(0xFFFFD875).withValues(alpha: 0.86),
      highlight: Colors.white.withValues(alpha: 0.7),
    );
    for (final point in [
      Offset(size.width * 0.37, size.height * 0.69),
      Offset(size.width * 0.63, size.height * 0.69),
    ]) {
      canvas.drawCircle(
        point,
        size.width * 0.012,
        Paint()
          ..color = point.dx < size.width / 2
              ? SilaMascotPalette.coral
              : const Color(0xFF80F5DF),
      );
    }
  }

  void _paintDesertExplorer(Canvas canvas, Size size) {
    if (layer == _SilaCosmeticLayer.back) {
      final tail = Path()
        ..moveTo(size.width * 0.59, size.height * 0.615)
        ..cubicTo(
          size.width * 0.72,
          size.height * 0.64,
          size.width * 0.79,
          size.height * 0.72,
          size.width * 0.81,
          size.height * 0.83,
        )
        ..lineTo(size.width * 0.73, size.height * 0.79)
        ..lineTo(size.width * 0.68, size.height * 0.86)
        ..cubicTo(
          size.width * 0.65,
          size.height * 0.73,
          size.width * 0.58,
          size.height * 0.68,
          size.width * 0.53,
          size.height * 0.64,
        )
        ..close();
      _drawMaterialPath(
        canvas,
        tail,
        size,
        colors: const [Color(0xFFFFD98A), Color(0xFFF28A4B), Color(0xFF9E482D)],
        shadow: const Color(0x66562812),
        rim: const Color(0xFFFFE8B3),
      );
      for (var index = 0; index < 3; index += 1) {
        final x = size.width * (0.705 + index * 0.035);
        canvas.drawLine(
          Offset(x, size.height * 0.79),
          Offset(x + size.width * 0.018, size.height * 0.84),
          Paint()
            ..color = const Color(0xFF75402B)
            ..strokeWidth = _cosmeticStroke(size, 0.006)
            ..strokeCap = StrokeCap.round,
        );
      }
      return;
    }

    final wrap = Path()
      ..moveTo(size.width * 0.32, size.height * 0.585)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.625,
        size.width * 0.68,
        size.height * 0.585,
      )
      ..lineTo(size.width * 0.64, size.height * 0.65)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.68,
        size.width * 0.36,
        size.height * 0.65,
      )
      ..close();
    _drawMaterialPath(
      canvas,
      wrap,
      size,
      colors: const [Color(0xFFFFE8AC), Color(0xFFFFB864), Color(0xFFE56F45)],
      shadow: const Color(0x66562812),
      rim: const Color(0xFFFFF4D5),
    );

    final fold = Path()
      ..moveTo(size.width * 0.36, size.height * 0.624)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.655,
        size.width * 0.64,
        size.height * 0.624,
      );
    canvas.drawPath(
      fold,
      Paint()
        ..color = const Color(0xFFB65B36).withValues(alpha: 0.72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _cosmeticStroke(size, 0.007),
    );
    for (var index = 0; index < 5; index += 1) {
      final x = size.width * (0.405 + index * 0.047);
      canvas.drawLine(
        Offset(x, size.height * 0.635),
        Offset(x + size.width * 0.018, size.height * 0.647),
        Paint()
          ..color = const Color(0xFF087443)
          ..strokeWidth = _cosmeticStroke(size, 0.005)
          ..strokeCap = StrokeCap.round,
      );
    }
    final knot = Offset(size.width * 0.65, size.height * 0.648);
    canvas.drawCircle(
      knot,
      size.width * 0.027,
      Paint()
        ..shader =
            const RadialGradient(
              colors: [Color(0xFFFFE6A7), Color(0xFFE17742), Color(0xFFA2472E)],
            ).createShader(
              Rect.fromCircle(center: knot, radius: size.width * 0.028),
            ),
    );
  }

  @override
  bool shouldRepaint(covariant _SilaOutfitPainter oldDelegate) =>
      oldDelegate.assetKey != assetKey ||
      oldDelegate.layer != layer ||
      oldDelegate.pose != pose;
}

class _SilaAuraPainter extends CustomPainter {
  _SilaAuraPainter(this.assetKey, this.animation, this.layer)
    : super(repaint: animation);

  final String assetKey;
  final Animation<double> animation;
  final _SilaCosmeticLayer layer;

  double get progress => animation.value;

  @override
  void paint(Canvas canvas, Size size) {
    switch (assetKey) {
      case SilaMascotAuras.familySparkles:
        _paintFamilySparkles(canvas, size);
      case SilaMascotAuras.cosmicOrbit:
        _paintCosmicOrbit(canvas, size);
      case SilaMascotAuras.uaeRibbon:
        _paintUaeRibbon(canvas, size);
      case SilaMascotAuras.memoryHearts:
        _paintMemoryHearts(canvas, size);
      case SilaMascotAuras.victoryBurst:
        _paintVictoryBurst(canvas, size);
    }
  }

  void _paintFamilySparkles(Canvas canvas, Size size) {
    final phase = progress * math.pi * 2;
    final points = layer == _SilaCosmeticLayer.back
        ? const [
            Offset(0.14, 0.24),
            Offset(0.84, 0.22),
            Offset(0.10, 0.55),
            Offset(0.90, 0.56),
            Offset(0.18, 0.83),
            Offset(0.82, 0.86),
          ]
        : const [Offset(0.15, 0.45), Offset(0.85, 0.49), Offset(0.50, 0.94)];
    const colors = [Color(0xFF2EC99A), Color(0xFFFFCA57), Color(0xFFFF8069)];
    for (var index = 0; index < points.length; index += 1) {
      final point = points[index];
      final pulse = 0.84 + 0.16 * math.sin(phase + index * 0.9);
      final center = Offset(
        size.width * point.dx,
        size.height * (point.dy + math.sin(phase + index) * 0.007),
      );
      final radius = size.width * (index.isEven ? 0.047 : 0.038) * pulse;
      if (_useCosmeticGlow(size)) {
        canvas.drawPath(
          _fourPointStarPath(center, radius * 1.55, radius * 0.32),
          Paint()
            ..color = colors[index % colors.length].withValues(alpha: 0.24)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.02),
        );
      }
      canvas.drawPath(
        _fourPointStarPath(center, radius, radius * 0.28),
        Paint()
          ..shader = RadialGradient(
            colors: [Colors.white, colors[index % colors.length]],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }
    if (layer == _SilaCosmeticLayer.back) {
      _paintBondMark(
        canvas,
        Offset(size.width * 0.12, size.height * 0.72),
        size.width * 0.075,
        color: const Color(0xFF087443).withValues(alpha: 0.72),
      );
      canvas.drawPath(
        _leafPath(
          Offset(size.width * 0.88, size.height * 0.72),
          size.width * 0.08,
          size.width * 0.026,
          -0.75,
        ),
        Paint()..color = const Color(0xFF54C987).withValues(alpha: 0.76),
      );
    }
  }

  void _paintCosmicOrbit(Canvas canvas, Size size) {
    final orbit = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.57),
      width: size.width * 0.88,
      height: size.height * 0.39,
    );
    canvas.save();
    canvas.translate(orbit.center.dx, orbit.center.dy);
    canvas.rotate(-0.25);
    canvas.translate(-orbit.center.dx, -orbit.center.dy);
    if (layer == _SilaCosmeticLayer.back) {
      if (_useCosmeticGlow(size)) {
        final glow = Paint()
          ..color = const Color(0xFF6CEBE7).withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _cosmeticStroke(size, 0.026)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.02);
        canvas.drawOval(orbit, glow);
      }
      canvas.drawArc(
        orbit,
        math.pi * 0.92,
        math.pi * 1.12,
        false,
        Paint()
          ..shader = const SweepGradient(
            colors: [
              Color(0xFF55E5DF),
              Color(0xFF8A6AF4),
              Color(0xFFFFCE68),
              Color(0xFF55E5DF),
            ],
          ).createShader(orbit)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _cosmeticStroke(size, 0.011)
          ..strokeCap = StrokeCap.round,
      );
      final inner = orbit.deflate(size.width * 0.075);
      canvas.drawArc(
        inner,
        math.pi * 0.85,
        math.pi * 1.25,
        false,
        Paint()
          ..color = const Color(0xFFB7FFF3).withValues(alpha: 0.38)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _cosmeticStroke(size, 0.006),
      );
    } else {
      canvas.drawArc(
        orbit,
        math.pi * 0.04,
        math.pi * 0.88,
        false,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF8D70FF), Color(0xFFFFD36A), Color(0xFF55E5DF)],
          ).createShader(orbit)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _cosmeticStroke(size, 0.012)
          ..strokeCap = StrokeCap.round,
      );
    }

    final angle = progress * math.pi * 2;
    final planetIsFront = math.sin(angle) > 0;
    if ((layer == _SilaCosmeticLayer.front) == planetIsFront) {
      final point = Offset(
        orbit.center.dx + math.cos(angle) * orbit.width / 2,
        orbit.center.dy + math.sin(angle) * orbit.height / 2,
      );
      final depth = 0.72 + 0.28 * ((math.sin(angle) + 1) / 2);
      if (_useCosmeticGlow(size)) {
        canvas.drawCircle(
          point,
          size.width * 0.052 * depth,
          Paint()
            ..color = const Color(0xFF7C63F2).withValues(alpha: 0.25)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              size.width * 0.025,
            ),
        );
      }
      canvas.drawCircle(
        point,
        size.width * 0.027 * depth,
        Paint()
          ..shader =
              const RadialGradient(
                center: Alignment(-0.35, -0.4),
                colors: [Colors.white, Color(0xFF7C63F2), Color(0xFF362470)],
              ).createShader(
                Rect.fromCircle(center: point, radius: size.width * 0.03),
              ),
      );
    }
    canvas.restore();
  }

  Path _uaeRibbonPath(Size size, double verticalOffset) {
    return Path()
      ..moveTo(size.width * 0.04, size.height * (0.68 + verticalOffset))
      ..cubicTo(
        size.width * 0.16,
        size.height * (0.28 + verticalOffset),
        size.width * 0.70,
        size.height * (0.27 + verticalOffset),
        size.width * 0.96,
        size.height * (0.51 + verticalOffset),
      );
  }

  void _paintUaeRibbon(Canvas canvas, Size size) {
    final drift = math.sin(progress * math.pi * 2) * 0.008;
    const colors = [
      Color(0xFFE31B23),
      Color(0xFF00843D),
      Color(0xFFFFFFFF),
      Color(0xFF101820),
    ];
    if (layer == _SilaCosmeticLayer.back) {
      final basePath = _uaeRibbonPath(size, drift);
      canvas.drawPath(
        basePath,
        Paint()
          ..color = const Color(0xFF001A12).withValues(alpha: 0.10)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _cosmeticStroke(size, 0.086)
          ..strokeCap = StrokeCap.round,
      );
      for (var index = 0; index < colors.length; index += 1) {
        final offset = (index - 1.5) * 0.017 + drift;
        final path = _uaeRibbonPath(size, offset);
        if (index == 2) {
          canvas.drawPath(
            path,
            Paint()
              ..color = const Color(0xFF42524D).withValues(alpha: 0.18)
              ..style = PaintingStyle.stroke
              ..strokeWidth = _cosmeticStroke(size, 0.029)
              ..strokeCap = StrokeCap.round,
          );
        }
        canvas.drawPath(
          path,
          Paint()
            ..color = colors[index].withValues(alpha: index == 2 ? 1 : 0.96)
            ..style = PaintingStyle.stroke
            ..strokeWidth = _cosmeticStroke(size, 0.026)
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white.withValues(alpha: index == 2 ? 0.48 : 0.18)
            ..style = PaintingStyle.stroke
            ..strokeWidth = _cosmeticStroke(size, 0.003)
            ..strokeCap = StrokeCap.round,
        );
      }
      return;
    }

    // A short foreground fold makes the ribbon wrap around Sila instead of
    // reading as four disconnected rainbow arcs.
    final frontBase = Path()
      ..moveTo(size.width * 0.59, size.height * (0.79 + drift))
      ..quadraticBezierTo(
        size.width * 0.80,
        size.height * (0.75 + drift),
        size.width * 0.96,
        size.height * (0.51 + drift),
      );
    canvas.drawPath(
      frontBase,
      Paint()
        ..color = const Color(0xFF001A12).withValues(alpha: 0.09)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _cosmeticStroke(size, 0.084)
        ..strokeCap = StrokeCap.round,
    );
    for (var index = 0; index < colors.length; index += 1) {
      final stripeOffset = (index - 1.5) * 0.017;
      final path = Path()
        ..moveTo(size.width * 0.59, size.height * (0.79 + stripeOffset + drift))
        ..quadraticBezierTo(
          size.width * 0.80,
          size.height * (0.75 + stripeOffset + drift),
          size.width * 0.96,
          size.height * (0.51 + stripeOffset + drift),
        );
      if (index == 2) {
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFF384944).withValues(alpha: 0.17)
            ..style = PaintingStyle.stroke
            ..strokeWidth = _cosmeticStroke(size, 0.028)
            ..strokeCap = StrokeCap.round,
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = colors[index].withValues(alpha: index == 2 ? 1 : 0.94)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _cosmeticStroke(size, 0.025)
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: index == 2 ? 0.38 : 0.14)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _cosmeticStroke(size, 0.003)
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _paintMemoryHearts(Canvas canvas, Size size) {
    final phase = progress * math.pi * 2;
    final points = layer == _SilaCosmeticLayer.back
        ? const [
            Offset(0.14, 0.29),
            Offset(0.84, 0.27),
            Offset(0.09, 0.61),
            Offset(0.90, 0.62),
            Offset(0.22, 0.88),
            Offset(0.78, 0.89),
          ]
        : const [Offset(0.15, 0.48), Offset(0.85, 0.49), Offset(0.50, 0.94)];
    const colors = [
      Color(0xFFFF6985),
      Color(0xFFFFB35B),
      Color(0xFF5ED8B4),
      Color(0xFFAB8AEF),
    ];
    for (var index = 0; index < points.length; index += 1) {
      final point = points[index];
      final rise = math.sin(phase + index * 0.8) * 0.012;
      final center = Offset(
        size.width * point.dx,
        size.height * (point.dy + rise),
      );
      final radius = size.width * (index.isEven ? 0.038 : 0.030);
      final heart = _heartPath(center, radius);
      if (_useCosmeticGlow(size)) {
        canvas.drawPath(
          heart,
          Paint()
            ..color = colors[index % colors.length].withValues(alpha: 0.22)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              size.width * 0.018,
            ),
        );
      }
      canvas.drawPath(
        heart,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, colors[index % colors.length]],
          ).createShader(heart.getBounds()),
      );
    }
    if (layer == _SilaCosmeticLayer.back) {
      _paintBondMark(
        canvas,
        Offset(size.width * 0.12, size.height * 0.78),
        size.width * 0.07,
        color: const Color(0xFF087443).withValues(alpha: 0.62),
      );
      _paintBondMark(
        canvas,
        Offset(size.width * 0.88, size.height * 0.78),
        size.width * 0.07,
        color: const Color(0xFFE4A719).withValues(alpha: 0.68),
      );
    }
  }

  void _paintVictoryBurst(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.54);
    final phase = progress * math.pi * 2;
    const colors = [
      Color(0xFFFFD15C),
      Color(0xFFFF715F),
      Color(0xFF54DFC1),
      Color(0xFF8E75F4),
    ];
    if (layer == _SilaCosmeticLayer.back) {
      if (_useCosmeticGlow(size)) {
        canvas.drawCircle(
          center,
          size.width * 0.42,
          Paint()
            ..color = const Color(0xFFFFD15C).withValues(alpha: 0.12)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.07),
        );
      }
      for (var index = 0; index < 16; index += 1) {
        final angle = index * math.pi * 2 / 16 + math.sin(phase) * 0.035;
        final pulse = 0.92 + 0.08 * math.sin(phase + index);
        final start = Offset(
          center.dx + math.cos(angle) * size.width * 0.35,
          center.dy + math.sin(angle) * size.height * 0.31,
        );
        final end = Offset(
          center.dx + math.cos(angle) * size.width * 0.49 * pulse,
          center.dy + math.sin(angle) * size.height * 0.44 * pulse,
        );
        canvas.drawLine(
          start,
          end,
          Paint()
            ..color = colors[index % colors.length].withValues(alpha: 0.90)
            ..strokeWidth = _cosmeticStroke(size, index.isEven ? 0.015 : 0.010)
            ..strokeCap = StrokeCap.round,
        );
      }
      return;
    }

    const confetti = [
      Offset(0.18, 0.42),
      Offset(0.82, 0.40),
      Offset(0.22, 0.78),
      Offset(0.79, 0.80),
      Offset(0.50, 0.93),
    ];
    for (var index = 0; index < confetti.length; index += 1) {
      final point = confetti[index];
      final center = Offset(
        size.width * point.dx,
        size.height * (point.dy + math.sin(phase + index) * 0.008),
      );
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: size.width * 0.027,
          height: size.height * 0.032,
        ),
        Radius.circular(size.width * 0.006),
      );
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(math.sin(phase + index * 0.6) * 0.32 + index * 0.7);
      canvas.translate(-center.dx, -center.dy);
      canvas.drawRRect(rect, Paint()..color = colors[index % colors.length]);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SilaAuraPainter oldDelegate) =>
      oldDelegate.assetKey != assetKey ||
      oldDelegate.layer != layer ||
      oldDelegate.animation != animation;
}

class _SilaAccessoryPainter extends CustomPainter {
  _SilaAccessoryPainter(this.assetKey, this.animation, this.layer)
    : super(
        repaint:
            layer == _SilaCosmeticLayer.front &&
                (assetKey == SilaMascotAccessories.guardianCrown ||
                    assetKey == SilaMascotAccessories.starHalo ||
                    assetKey == SilaMascotAccessories.scholarCap)
            ? animation
            : null,
      );

  final String assetKey;
  final Animation<double> animation;
  final _SilaCosmeticLayer layer;

  double get progress => animation.value;

  @override
  void paint(Canvas canvas, Size size) {
    switch (assetKey) {
      case SilaMascotAccessories.guardianCrown:
        _paintCrown(canvas, size);
      case SilaMascotAccessories.explorerCap:
        _paintExplorerCap(canvas, size);
      case SilaMascotAccessories.starHalo:
        _paintStarHalo(canvas, size);
      case SilaMascotAccessories.familyLeafWreath:
        _paintFamilyLeafWreath(canvas, size);
      case SilaMascotAccessories.scholarCap:
        _paintScholarCap(canvas, size);
    }
  }

  void _paintCrown(Canvas canvas, Size size) {
    final centerX = size.width * 0.5;
    final baseY = size.height * 0.248;
    if (layer == _SilaCosmeticLayer.back) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(centerX, baseY + size.height * 0.012),
          width: size.width * 0.31,
          height: size.height * 0.045,
        ),
        Paint()
          ..color = const Color(0xFF4A2A09).withValues(alpha: 0.32)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.018),
      );
      return;
    }

    final crown = Path()
      ..moveTo(size.width * 0.35, baseY)
      ..lineTo(size.width * 0.36, size.height * 0.174)
      ..lineTo(size.width * 0.435, size.height * 0.212)
      ..lineTo(size.width * 0.50, size.height * 0.142)
      ..lineTo(size.width * 0.565, size.height * 0.212)
      ..lineTo(size.width * 0.64, size.height * 0.174)
      ..lineTo(size.width * 0.65, baseY)
      ..quadraticBezierTo(
        centerX,
        size.height * 0.275,
        size.width * 0.35,
        baseY,
      )
      ..close();
    _drawMaterialPath(
      canvas,
      crown,
      size,
      colors: const [
        Color(0xFFFFF3B8),
        Color(0xFFF3C147),
        Color(0xFFC27B12),
        Color(0xFF8B4D08),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      shadow: const Color(0x77563200),
      rim: const Color(0xFFFFE99B),
    );
    final band = Path()
      ..moveTo(size.width * 0.35, size.height * 0.232)
      ..quadraticBezierTo(
        centerX,
        size.height * 0.267,
        size.width * 0.65,
        size.height * 0.232,
      )
      ..lineTo(size.width * 0.64, size.height * 0.264)
      ..quadraticBezierTo(
        centerX,
        size.height * 0.291,
        size.width * 0.36,
        size.height * 0.264,
      )
      ..close();
    canvas.drawPath(
      band,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFED9C), Color(0xFFD99117), Color(0xFFFFCD54)],
        ).createShader(band.getBounds()),
    );
    canvas.drawPath(
      band,
      Paint()
        ..color = const Color(0xFFFFF4C8).withValues(alpha: 0.86)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _cosmeticStroke(size, 0.006),
    );

    const gemColors = [Color(0xFF39D9B3), Color(0xFFFF6D58), Color(0xFF39D9B3)];
    final gems = [
      Offset(size.width * 0.39, size.height * 0.205),
      Offset(size.width * 0.50, size.height * 0.166),
      Offset(size.width * 0.61, size.height * 0.205),
    ];
    for (var index = 0; index < gems.length; index += 1) {
      final center = gems[index];
      final gem = _fourPointStarPath(
        center,
        size.width * (index == 1 ? 0.023 : 0.018),
        size.width * 0.009,
      );
      canvas.drawPath(
        gem,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.4, -0.4),
            colors: [Colors.white, gemColors[index]],
          ).createShader(gem.getBounds()),
      );
    }
    _paintBondMark(
      canvas,
      Offset(centerX, size.height * 0.259),
      size.width * 0.058,
      color: const Color(0xFF087443),
      highlight: Colors.white.withValues(alpha: 0.72),
    );

    final shineTravel = (1 - math.cos(progress * math.pi * 2)) / 2;
    final shineX = size.width * (0.38 + shineTravel * 0.24);
    canvas.drawLine(
      Offset(shineX, size.height * 0.228),
      Offset(shineX + size.width * 0.025, size.height * 0.25),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.42)
        ..strokeWidth = _cosmeticStroke(size, 0.006)
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintExplorerCap(Canvas canvas, Size size) {
    if (layer == _SilaCosmeticLayer.back) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * 0.51, size.height * 0.285),
          width: size.width * 0.43,
          height: size.height * 0.055,
        ),
        Paint()
          ..color = const Color(0xFF002F25).withValues(alpha: 0.30)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.017),
      );
      return;
    }

    final dome = Path()
      ..moveTo(size.width * 0.30, size.height * 0.265)
      ..cubicTo(
        size.width * 0.31,
        size.height * 0.175,
        size.width * 0.39,
        size.height * 0.145,
        size.width * 0.49,
        size.height * 0.148,
      )
      ..cubicTo(
        size.width * 0.61,
        size.height * 0.15,
        size.width * 0.68,
        size.height * 0.195,
        size.width * 0.68,
        size.height * 0.268,
      )
      ..quadraticBezierTo(
        size.width * 0.49,
        size.height * 0.29,
        size.width * 0.30,
        size.height * 0.265,
      )
      ..close();
    _drawMaterialPath(
      canvas,
      dome,
      size,
      colors: const [Color(0xFF54D9A1), Color(0xFF087443), Color(0xFF034331)],
      shadow: const Color(0x6600271B),
      rim: const Color(0xFF8FF0C8),
    );
    final seamPaint = Paint()
      ..color = const Color(0xFFD2FFE7).withValues(alpha: 0.44)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _cosmeticStroke(size, 0.005);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.49, size.height * 0.15)
        ..quadraticBezierTo(
          size.width * 0.45,
          size.height * 0.205,
          size.width * 0.45,
          size.height * 0.275,
        ),
      seamPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.49, size.height * 0.15)
        ..quadraticBezierTo(
          size.width * 0.58,
          size.height * 0.20,
          size.width * 0.61,
          size.height * 0.27,
        ),
      seamPaint,
    );

    final brim = Path()
      ..moveTo(size.width * 0.42, size.height * 0.265)
      ..quadraticBezierTo(
        size.width * 0.63,
        size.height * 0.25,
        size.width * 0.75,
        size.height * 0.294,
      )
      ..quadraticBezierTo(
        size.width * 0.61,
        size.height * 0.326,
        size.width * 0.42,
        size.height * 0.29,
      )
      ..close();
    _drawMaterialPath(
      canvas,
      brim,
      size,
      colors: const [Color(0xFF14966A), Color(0xFF064E39), Color(0xFF032C23)],
      shadow: const Color(0x77001812),
      rim: const Color(0xFF69D7AE),
    );

    final patchCenter = Offset(size.width * 0.39, size.height * 0.222);
    canvas.drawCircle(
      patchCenter,
      size.width * 0.042,
      Paint()
        ..shader =
            const RadialGradient(
              colors: [Color(0xFFFFF3BC), Color(0xFFE4A719), Color(0xFF9A600A)],
            ).createShader(
              Rect.fromCircle(center: patchCenter, radius: size.width * 0.043),
            ),
    );
    _paintBondMark(
      canvas,
      patchCenter,
      size.width * 0.05,
      color: const Color(0xFF087443),
    );
  }

  void _paintStarHalo(Canvas canvas, Size size) {
    final haloRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.13),
      width: size.width * 0.43,
      height: size.height * 0.057,
    );
    if (layer == _SilaCosmeticLayer.back) {
      canvas.drawOval(
        haloRect,
        Paint()
          ..color = const Color(0xFFFFD76C).withValues(alpha: 0.30)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _cosmeticStroke(size, 0.032)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.027),
      );
      canvas.drawOval(
        haloRect,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFFF4C1), Color(0xFFE9AB27), Color(0xFFFFDF7B)],
          ).createShader(haloRect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _cosmeticStroke(size, 0.012),
      );
      return;
    }

    canvas.drawArc(
      haloRect,
      0,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFFFF6D3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _cosmeticStroke(size, 0.009)
        ..strokeCap = StrokeCap.round,
    );
    final glints = [
      (const Offset(0.31, 0.126), 0.025),
      (const Offset(0.53, 0.095), 0.034),
      (const Offset(0.70, 0.132), 0.022),
    ];
    for (var index = 0; index < glints.length; index += 1) {
      final entry = glints[index];
      final pulse = 0.82 + 0.18 * math.sin(progress * math.pi * 2 + index);
      final center = Offset(
        size.width * entry.$1.dx,
        size.height * entry.$1.dy,
      );
      final star = _fourPointStarPath(
        center,
        size.width * entry.$2 * pulse,
        size.width * entry.$2 * 0.25,
      );
      canvas.drawPath(
        star,
        Paint()
          ..color = const Color(0xFFFFE596).withValues(alpha: 0.30)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.018),
      );
      canvas.drawPath(
        star,
        Paint()
          ..shader = const RadialGradient(
            colors: [Colors.white, Color(0xFFFFD568)],
          ).createShader(star.getBounds()),
      );
    }
  }

  void _paintFamilyLeafWreath(Canvas canvas, Size size) {
    if (layer == _SilaCosmeticLayer.back) return;

    final branchPaint = Paint()
      ..shader =
          const LinearGradient(
            colors: [Color(0xFFB87512), Color(0xFFFFD56D), Color(0xFF8E5908)],
          ).createShader(
            Rect.fromLTWH(
              size.width * 0.25,
              size.height * 0.21,
              size.width * 0.5,
              size.height * 0.16,
            ),
          )
      ..style = PaintingStyle.stroke
      ..strokeWidth = _cosmeticStroke(size, 0.009)
      ..strokeCap = StrokeCap.round;
    for (final direction in [-1.0, 1.0]) {
      final branch = Path()
        ..moveTo(size.width * (0.50 + direction * 0.03), size.height * 0.235)
        ..quadraticBezierTo(
          size.width * (0.50 + direction * 0.16),
          size.height * 0.25,
          size.width * (0.50 + direction * 0.25),
          size.height * 0.345,
        );
      canvas.drawPath(branch, branchPaint);

      for (var index = 0; index < 4; index += 1) {
        final t = (index + 0.45) / 4.5;
        final center = Offset(
          size.width * (0.50 + direction * (0.05 + t * 0.19)),
          size.height * (0.235 + t * t * 0.105),
        );
        final angle = direction * (0.5 + index * 0.13);
        final leaf = _leafPath(
          center,
          size.width * 0.078,
          size.width * 0.026,
          direction < 0 ? math.pi - angle : angle,
        );
        _drawMaterialPath(
          canvas,
          leaf,
          size,
          colors: index.isEven
              ? const [Color(0xFF76DB8E), Color(0xFF087443), Color(0xFF034A34)]
              : const [Color(0xFFFFD774), Color(0xFF49A95F), Color(0xFF087443)],
          shadow: const Color(0x44002D1F),
          rim: Colors.white.withValues(alpha: 0.26),
        );
        canvas.drawLine(
          center.translate(-direction * size.width * 0.02, 0),
          center.translate(direction * size.width * 0.02, 0),
          Paint()
            ..color = const Color(0xFFE9FFD9).withValues(alpha: 0.48)
            ..strokeWidth = _cosmeticStroke(size, 0.003),
        );
      }
    }

    final center = Offset(size.width * 0.5, size.height * 0.237);
    final gem = _fourPointStarPath(
      center,
      size.width * 0.027,
      size.width * 0.012,
    );
    canvas.drawPath(
      gem,
      Paint()
        ..shader = const RadialGradient(
          colors: [Colors.white, Color(0xFFFFD45F), Color(0xFFB87512)],
        ).createShader(gem.getBounds()),
    );
  }

  void _paintScholarCap(Canvas canvas, Size size) {
    final board = Path()
      ..moveTo(size.width * 0.29, size.height * 0.202)
      ..lineTo(size.width * 0.485, size.height * 0.158)
      ..lineTo(size.width * 0.72, size.height * 0.205)
      ..lineTo(size.width * 0.515, size.height * 0.251)
      ..close();
    if (layer == _SilaCosmeticLayer.back) {
      final underside = Path()
        ..moveTo(size.width * 0.30, size.height * 0.208)
        ..lineTo(size.width * 0.515, size.height * 0.258)
        ..lineTo(size.width * 0.71, size.height * 0.212)
        ..lineTo(size.width * 0.71, size.height * 0.226)
        ..lineTo(size.width * 0.515, size.height * 0.271)
        ..lineTo(size.width * 0.30, size.height * 0.22)
        ..close();
      canvas.drawPath(underside, Paint()..color = const Color(0xFF3E102E));
      canvas.drawShadow(
        board,
        const Color(0x77000000),
        _cosmeticShadow(size),
        false,
      );
      return;
    }

    _drawMaterialPath(
      canvas,
      board,
      size,
      colors: const [Color(0xFFD54A8A), Color(0xFF861B55), Color(0xFF41102E)],
      shadow: const Color(0x66000000),
      rim: const Color(0xFFF38DB9),
    );
    final headBand = Path()
      ..moveTo(size.width * 0.39, size.height * 0.232)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.27,
        size.width * 0.61,
        size.height * 0.232,
      )
      ..lineTo(size.width * 0.60, size.height * 0.26)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.287,
        size.width * 0.40,
        size.height * 0.26,
      )
      ..close();
    canvas.drawPath(
      headBand,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF9D2A64), Color(0xFF4A1234)],
        ).createShader(headBand.getBounds()),
    );

    final buttonCenter = Offset(size.width * 0.505, size.height * 0.204);
    canvas.drawCircle(
      buttonCenter,
      size.width * 0.022,
      Paint()
        ..shader =
            const RadialGradient(
              colors: [Colors.white, Color(0xFFFFD469), Color(0xFF9B620B)],
            ).createShader(
              Rect.fromCircle(center: buttonCenter, radius: size.width * 0.023),
            ),
    );
    _paintBondMark(
      canvas,
      buttonCenter,
      size.width * 0.03,
      color: const Color(0xFF087443),
    );

    final swing = math.sin(progress * math.pi * 2) * 0.018;
    final tasselEnd = Offset(size.width * (0.69 + swing), size.height * 0.345);
    final tassel = Path()
      ..moveTo(buttonCenter.dx, buttonCenter.dy)
      ..quadraticBezierTo(
        size.width * (0.66 + swing * 0.4),
        size.height * 0.23,
        tasselEnd.dx,
        tasselEnd.dy,
      );
    canvas.drawPath(
      tassel,
      Paint()
        ..color = const Color(0xFF87570A).withValues(alpha: 0.38)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _cosmeticStroke(size, 0.014)
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      tassel,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFED9B), Color(0xFFE4A719), Color(0xFF9B620B)],
        ).createShader(Rect.fromPoints(buttonCenter, tasselEnd))
        ..style = PaintingStyle.stroke
        ..strokeWidth = _cosmeticStroke(size, 0.008)
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      tasselEnd,
      size.width * 0.018,
      Paint()..color = const Color(0xFFFFD568),
    );
    for (final direction in [-1.0, 0.0, 1.0]) {
      canvas.drawLine(
        tasselEnd,
        tasselEnd.translate(
          size.width * direction * 0.015,
          size.height * 0.035,
        ),
        Paint()
          ..color = const Color(0xFFD99213)
          ..strokeWidth = _cosmeticStroke(size, 0.004)
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SilaAccessoryPainter oldDelegate) =>
      oldDelegate.assetKey != assetKey ||
      oldDelegate.layer != layer ||
      oldDelegate.animation != animation;
}
