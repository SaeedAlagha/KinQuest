import 'package:flutter/material.dart';

import '../../../core/mascot/sila_mascot.dart';
import '../../rewards/digital/digital_reward_visuals.dart';
import '../../rewards/digital/equipped_digital_rewards.dart';

/// A restrained, reusable Sila moment for guidance, empty states and recovery.
///
/// The callout deliberately uses a one-shot motion instead of an endless loop,
/// and automatically stacks on narrow screens or with large text.
class SilaCompanionCallout extends StatelessWidget {
  const SilaCompanionCallout({
    super.key,
    required this.title,
    required this.message,
    this.action,
    this.pose = SilaMascotPose.encouraging,
    this.motion,
    this.userId,
    this.previewRewards,
    this.mascotHeight = 104,
    this.animate = true,
  });

  final String title;
  final String message;
  final Widget? action;
  final SilaMascotPose pose;
  final SilaMascotMotion? motion;
  final String? userId;
  final EquippedDigitalRewards? previewRewards;
  final double mascotHeight;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return DigitalRewardStyleBuilder(
      userId: userId,
      preview: previewRewards,
      builder: (context, rewards) => _SilaCompanionCalloutContent(
        title: title,
        message: message,
        action: action,
        pose: pose,
        motion: motion,
        rewards: rewards,
        mascotHeight: mascotHeight,
        animate: animate,
      ),
    );
  }
}

class _SilaCompanionCalloutContent extends StatelessWidget {
  const _SilaCompanionCalloutContent({
    required this.title,
    required this.message,
    required this.action,
    required this.pose,
    required this.motion,
    required this.rewards,
    required this.mascotHeight,
    required this.animate,
  });

  final String title;
  final String message;
  final Widget? action;
  final SilaMascotPose pose;
  final SilaMascotMotion? motion;
  final EquippedDigitalRewards rewards;
  final double mascotHeight;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return Semantics(
      key: const ValueKey('sila-companion-callout'),
      container: true,
      explicitChildNodes: true,
      label: '$title. $message',
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [
              colors.primaryContainer.withValues(alpha: 0.84),
              colors.surface,
              colors.tertiaryContainer.withValues(alpha: 0.52),
            ],
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: colors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.08),
              blurRadius: 22,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stack = constraints.maxWidth < 390 || textScale > 1.35;
            final mascot = SilaMascot(
              key: const ValueKey('sila-companion-callout-mascot'),
              pose: pose,
              motion: motion,
              height: mascotHeight,
              animate: animate,
              accessoryAssetKey: rewards.mascotAccessory,
              outfitAssetKey: rewards.mascotOutfit,
              auraAssetKey: rewards.mascotAura,
            );
            final copy = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: stack
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: Column(
                    crossAxisAlignment: stack
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        textAlign: stack ? TextAlign.center : TextAlign.start,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        message,
                        textAlign: stack ? TextAlign.center : TextAlign.start,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                if (action case final action?) ...[
                  const SizedBox(height: 14),
                  action,
                ],
              ],
            );

            return Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 20, 16),
              child: stack
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [mascot, const SizedBox(height: 8), copy],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        mascot,
                        const SizedBox(width: 16),
                        Expanded(child: copy),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}
