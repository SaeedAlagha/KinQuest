import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class SilaBrandMark extends StatelessWidget {
  const SilaBrandMark({super.key, this.size = 112, this.showShadow = true});

  final double size;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label:
          AppLocalizations.of(context)?.silaLogoSemanticLabel ??
          'Sila family connection logo',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: AppTheme.heroGradientFor(context),
          borderRadius: BorderRadius.circular(size * 0.3),
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.24),
                    blurRadius: size * 0.27,
                    offset: Offset(0, size * 0.12),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.2),
          child: const CustomPaint(painter: _SilaConnectionPainter()),
        ),
      ),
    );
  }
}

class _SilaConnectionPainter extends CustomPainter {
  const _SilaConnectionPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final connectionPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.92)
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final nodes = <Offset>[
      Offset(size.width * 0.5, size.height * 0.16),
      Offset(size.width * 0.84, size.height * 0.5),
      Offset(size.width * 0.5, size.height * 0.84),
      Offset(size.width * 0.16, size.height * 0.5),
    ];

    final path = Path()..moveTo(nodes.first.dx, nodes.first.dy);
    for (final node in nodes.skip(1)) {
      path.lineTo(node.dx, node.dy);
    }
    path.close();
    canvas.drawPath(path, connectionPaint);

    final nodePaint = Paint()..color = Colors.white;
    final nodeRadius = size.width * 0.12;
    for (final node in nodes) {
      canvas.drawCircle(node, nodeRadius, nodePaint);
    }

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.105,
      Paint()..color = AppTheme.uaeRed,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
