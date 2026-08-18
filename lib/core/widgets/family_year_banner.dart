import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class FamilyYearBanner extends StatelessWidget {
  const FamilyYearBanner({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label:
          'UAE Year of Family 2026. Growing in Unity. عام الأسرة، نماء وانتماء.',
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 15,
          vertical: compact ? 11 : 13,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _UaeFlag(width: compact ? 42 : 48),
                SizedBox(width: compact ? 11 : 13),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'عام الأسرة 2026',
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: 'نماء وانتماء'),
                            if (!compact) ...[
                              const TextSpan(text: '  •  '),
                              const TextSpan(text: 'Growing in Unity'),
                            ],
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.uaeGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(width: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      'UAE',
                      style: TextStyle(
                        color: AppTheme.uaeBlack,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: compact ? 8 : 10),
            const UaeColorRibbon(height: 4),
          ],
        ),
      ),
    );
  }
}

class UaeColorRibbon extends StatelessWidget {
  const UaeColorRibbon({super.key, this.height = 5});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: AppTheme.uaeBlack.withValues(alpha: 0.09),
          width: 0.7,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: ColoredBox(color: AppTheme.uaeRed)),
          Expanded(child: ColoredBox(color: AppTheme.uaeGreen)),
          Expanded(child: ColoredBox(color: AppTheme.uaeWhiteAccent)),
          Expanded(child: ColoredBox(color: AppTheme.uaeBlack)),
        ],
      ),
    );
  }
}

class _UaeFlag extends StatelessWidget {
  const _UaeFlag({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final height = width * 0.66;

    return Semantics(
      image: true,
      label: 'United Arab Emirates flag',
      child: Container(
        width: width,
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.uaeBlack.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(width: width * 0.26, color: AppTheme.uaeRed),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(child: ColoredBox(color: AppTheme.uaeGreen)),
                  const Expanded(child: ColoredBox(color: Colors.white)),
                  const Expanded(child: ColoredBox(color: AppTheme.uaeBlack)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
