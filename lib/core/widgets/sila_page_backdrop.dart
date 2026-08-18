import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SilaPageBackdrop extends StatelessWidget {
  const SilaPageBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppTheme.pageGradientFor(context)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: CustomPaint(painter: _SilaBackdropPainter(isDark: isDark)),
          ),
          child,
        ],
      ),
    );
  }
}

class _SilaBackdropPainter extends CustomPainter {
  const _SilaBackdropPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
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

  @override
  bool shouldRepaint(covariant _SilaBackdropPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
