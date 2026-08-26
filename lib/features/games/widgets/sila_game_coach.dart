import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../../core/mascot/sila_mascot.dart';
import '../../../l10n/app_localizations.dart';
import '../../rewards/digital/digital_reward_visuals.dart';
import '../../rewards/digital/equipped_digital_rewards.dart';

class SilaGameCoachButton extends StatelessWidget {
  const SilaGameCoachButton({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final userId = _currentUserId();
    return DigitalRewardStyleBuilder(
      userId: userId,
      builder: (context, rewards) =>
          _CoachButton(rewards: rewards, message: message),
    );
  }
}

class SilaGameCoachBanner extends StatelessWidget {
  const SilaGameCoachBanner({
    super.key,
    this.message,
    this.pose = SilaMascotPose.encouraging,
  });

  final String? message;
  final SilaMascotPose pose;

  @override
  Widget build(BuildContext context) {
    final userId = _currentUserId();
    final strings = AppLocalizations.of(context)!;
    return DigitalRewardStyleBuilder(
      userId: userId,
      builder: (context, rewards) => SilaMascotGuide(
        key: const ValueKey('sila-game-coach-banner'),
        title: strings.mascotName,
        message: message ?? strings.silaGameCoachMessage,
        semanticLabel: strings.mascotSemanticLabel,
        pose: pose,
        motion: SilaMascotMotion.gameReady,
        compact: true,
        accessoryAssetKey: rewards.mascotAccessory,
        outfitAssetKey: rewards.mascotOutfit,
        auraAssetKey: rewards.mascotAura,
      ),
    );
  }
}

String? _currentUserId() {
  try {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseAuth.instance.currentUser?.uid;
  } on FirebaseException {
    return null;
  }
}

class _CoachButton extends StatelessWidget {
  const _CoachButton({required this.rewards, this.message});

  final EquippedDigitalRewards rewards;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: strings.mascotSemanticLabel,
      child: Tooltip(
        message: strings.silaGameCoachMessage,
        child: Material(
          elevation: 10,
          color: colors.surface,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: const ValueKey('sila-game-coach-button'),
            onTap: () => _showCoach(context),
            child: SizedBox.square(
              dimension: 78,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SilaMascot(
                    pose: SilaMascotPose.encouraging,
                    motion: SilaMascotMotion.gameReady,
                    height: 72,
                    accessoryAssetKey: rewards.mascotAccessory,
                    outfitAssetKey: rewards.mascotOutfit,
                    auraAssetKey: rewards.mascotAura,
                  ),
                  PositionedDirectional(
                    end: 4,
                    top: 4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.surface, width: 2),
                      ),
                      child: Icon(
                        Icons.chat_bubble_rounded,
                        size: 11,
                        color: colors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCoach(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SilaMascotGuide(
            title: strings.mascotName,
            message: message ?? strings.silaGameCoachMessage,
            semanticLabel: strings.mascotSemanticLabel,
            pose: SilaMascotPose.encouraging,
            motion: SilaMascotMotion.gameReady,
            accessoryAssetKey: rewards.mascotAccessory,
            outfitAssetKey: rewards.mascotOutfit,
            auraAssetKey: rewards.mascotAura,
          ),
        ),
      ),
    );
  }
}
