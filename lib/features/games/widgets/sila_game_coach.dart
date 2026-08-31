import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../../core/mascot/sila_mascot.dart';
import '../../../l10n/app_localizations.dart';
import '../../rewards/digital/digital_reward_visuals.dart';
import '../../rewards/digital/equipped_digital_rewards.dart';

/// The reactions Sila can use while hosting a game.
///
/// Keep these semantic rather than game-specific so every game can give Sila
/// the same recognizable personality without duplicating mascot logic.
enum SilaGameCoachTone { play, thinking, celebrating, oops, winner }

class SilaGameCoachButton extends StatelessWidget {
  const SilaGameCoachButton({
    super.key,
    this.message,
    this.tone = SilaGameCoachTone.play,
    this.resultScreen = false,
  });

  final String? message;
  final SilaGameCoachTone tone;
  final bool resultScreen;

  @override
  Widget build(BuildContext context) {
    final userId = _currentUserId();
    return DigitalRewardStyleBuilder(
      userId: userId,
      builder: (context, rewards) => _CoachButton(
        rewards: rewards,
        message: message,
        tone: tone,
        resultScreen: resultScreen,
      ),
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
        animate: !MediaQuery.disableAnimationsOf(context),
        loop: true,
        loopPause: const Duration(milliseconds: 2600),
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
  const _CoachButton({
    required this.rewards,
    required this.tone,
    required this.resultScreen,
    this.message,
  });

  final EquippedDigitalRewards rewards;
  final String? message;
  final SilaGameCoachTone tone;
  final bool resultScreen;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final coachMessage =
        message ??
        switch (tone) {
          SilaGameCoachTone.play => strings.silaGameCoachMessage,
          SilaGameCoachTone.thinking => strings.mascotThinkingMessage,
          SilaGameCoachTone.celebrating => strings.mascotCelebrationMessage,
          SilaGameCoachTone.oops => strings.mascotOopsMessage,
          SilaGameCoachTone.winner => strings.silaGameWinnerMessage,
        };
    final (pose, motion) = switch (tone) {
      SilaGameCoachTone.play => (
        SilaMascotPose.encouraging,
        SilaMascotMotion.gameReady,
      ),
      SilaGameCoachTone.thinking => (
        SilaMascotPose.thinking,
        SilaMascotMotion.thinking,
      ),
      SilaGameCoachTone.celebrating => (
        SilaMascotPose.celebrating,
        SilaMascotMotion.celebrate,
      ),
      SilaGameCoachTone.oops => (SilaMascotPose.oops, SilaMascotMotion.excited),
      SilaGameCoachTone.winner => (
        SilaMascotPose.winner,
        SilaMascotMotion.celebrate,
      ),
    };
    final mediaQuery = MediaQuery.of(context);
    // A wide pill can cover score cards and replay buttons on phone result
    // screens. Keep the trophy reaction compact there, while retaining the
    // fully branded host card on tablets and desktops.
    final compactWinner =
        tone == SilaGameCoachTone.winner && mediaQuery.size.width < 720;
    final supportsPill =
        !compactWinner &&
        mediaQuery.size.width >= 360 &&
        mediaQuery.textScaler.scale(1) <= 1.35;
    final showExpanded = supportsPill && mediaQuery.size.width >= 720;
    final shape = supportsPill
        ? StadiumBorder(
            side: BorderSide(color: colors.primary.withValues(alpha: 0.22)),
          )
        : CircleBorder(
            side: BorderSide(color: colors.primary.withValues(alpha: 0.22)),
          );
    void handleCoachTap() {
      unawaited(
        _showCoach(
          context,
          coachMessage: coachMessage,
          pose: pose,
          motion: motion,
        ),
      );
    }

    final coach = Semantics(
      button: true,
      label: '${strings.mascotSemanticLabel}. $coachMessage',
      excludeSemantics: true,
      onTap: handleCoachTap,
      child: Tooltip(
        message: coachMessage,
        excludeFromSemantics: true,
        child: Material(
          elevation: 10,
          color: colors.surface,
          shadowColor: colors.primary.withValues(alpha: 0.28),
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: const ValueKey('sila-game-coach-button'),
            excludeFromSemantics: true,
            onTap: handleCoachTap,
            customBorder: shape,
            child: showExpanded
                ? _ExpandedCoachButton(
                    rewards: rewards,
                    message: coachMessage,
                    pose: pose,
                    motion: motion,
                  )
                : supportsPill
                ? _PhoneCoachButton(
                    rewards: rewards,
                    message: coachMessage,
                    pose: pose,
                    motion: motion,
                  )
                : _CompactCoachButton(
                    rewards: rewards,
                    pose: pose,
                    motion: motion,
                  ),
          ),
        ),
      ),
    );

    // Games commonly keep their main/replay actions at the bottom. Reserve
    // that action zone for every coach size, with extra room for result screens.
    return Padding(
      padding: EdgeInsetsDirectional.only(
        bottom: resultScreen || tone == SilaGameCoachTone.winner ? 128 : 84,
      ),
      child: coach,
    );
  }

  Future<void> _showCoach(
    BuildContext context, {
    required String coachMessage,
    required SilaMascotPose pose,
    required SilaMascotMotion motion,
  }) {
    final strings = AppLocalizations.of(context)!;
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: SilaMascotGuide(
                title: strings.mascotName,
                message: coachMessage,
                semanticLabel: strings.mascotSemanticLabel,
                pose: pose,
                motion: motion,
                animate: !MediaQuery.disableAnimationsOf(context),
                loop: true,
                accessoryAssetKey: rewards.mascotAccessory,
                outfitAssetKey: rewards.mascotOutfit,
                auraAssetKey: rewards.mascotAura,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactCoachButton extends StatelessWidget {
  const _CompactCoachButton({
    required this.rewards,
    required this.pose,
    required this.motion,
  });

  final EquippedDigitalRewards rewards;
  final SilaMascotPose pose;
  final SilaMascotMotion motion;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox.square(
      key: const ValueKey('sila-game-coach-compact'),
      dimension: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _RecurringCoachMascot(
            rewards: rewards,
            height: 68,
            pose: pose,
            motion: motion,
          ),
          PositionedDirectional(
            end: 3,
            top: 3,
            child: _CoachChatBadge(colors: colors),
          ),
        ],
      ),
    );
  }
}

class _ExpandedCoachButton extends StatelessWidget {
  const _ExpandedCoachButton({
    required this.rewards,
    required this.message,
    required this.pose,
    required this.motion,
  });

  final EquippedDigitalRewards rewards;
  final String message;
  final SilaMascotPose pose;
  final SilaMascotMotion motion;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      key: const ValueKey('sila-game-coach-expanded'),
      width: 286,
      height: 82,
      child: Row(
        children: [
          const SizedBox(width: 4),
          SizedBox(
            width: 74,
            child: _RecurringCoachMascot(
              rewards: rewards,
              height: 76,
              pose: pose,
              motion: motion,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.mascotName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 8, end: 12),
            child: _CoachChatBadge(colors: colors),
          ),
        ],
      ),
    );
  }
}

class _PhoneCoachButton extends StatelessWidget {
  const _PhoneCoachButton({
    required this.rewards,
    required this.message,
    required this.pose,
    required this.motion,
  });

  final EquippedDigitalRewards rewards;
  final String message;
  final SilaMascotPose pose;
  final SilaMascotMotion motion;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      key: const ValueKey('sila-game-coach-phone'),
      width: 212,
      height: 72,
      child: Row(
        children: [
          const SizedBox(width: 4),
          SizedBox(
            width: 62,
            child: _RecurringCoachMascot(
              rewards: rewards,
              height: 68,
              pose: pose,
              motion: motion,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.mascotName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6, end: 9),
            child: _CoachChatBadge(colors: colors),
          ),
        ],
      ),
    );
  }
}

class _CoachChatBadge extends StatelessWidget {
  const _CoachChatBadge({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: colors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: colors.surface, width: 2),
      ),
      child: Icon(Icons.chat_bubble_rounded, size: 12, color: colors.onPrimary),
    );
  }
}

/// Gives the in-game helper a calm recurring motion instead of a distracting
/// nonstop animation. The pause between cycles also lets widget trees settle.
class _RecurringCoachMascot extends StatefulWidget {
  const _RecurringCoachMascot({
    required this.rewards,
    required this.height,
    required this.pose,
    required this.motion,
  });

  final EquippedDigitalRewards rewards;
  final double height;
  final SilaMascotPose pose;
  final SilaMascotMotion motion;

  @override
  State<_RecurringCoachMascot> createState() => _RecurringCoachMascotState();
}

class _RecurringCoachMascotState extends State<_RecurringCoachMascot> {
  static const _cycleInterval = Duration(milliseconds: 4400);

  Timer? _cycleTimer;
  var _cycle = 0;
  var _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion && _cycleTimer != null) return;

    _reduceMotion = reduceMotion;
    _cycleTimer?.cancel();
    _cycleTimer = null;
    if (!_reduceMotion) {
      _scheduleNextCycle();
    }
  }

  void _scheduleNextCycle() {
    _cycleTimer = Timer(_cycleInterval, () {
      if (!mounted || _reduceMotion) return;
      setState(() {
        _cycle += 1;
      });
      _scheduleNextCycle();
    });
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SilaMascot(
      key: ValueKey('sila-game-coach-motion-$_cycle'),
      pose: widget.pose,
      motion: widget.motion,
      height: widget.height,
      animate: !_reduceMotion,
      accessoryAssetKey: widget.rewards.mascotAccessory,
      outfitAssetKey: widget.rewards.mascotOutfit,
      auraAssetKey: widget.rewards.mascotAura,
    );
  }
}
