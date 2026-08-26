import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/mascot/sila_mascot.dart';
import 'digital_reward_definition.dart';
import 'equipped_digital_rewards.dart';

typedef DigitalRewardStyleWidgetBuilder =
    Widget Function(BuildContext context, EquippedDigitalRewards rewards);

class DigitalRewardStyleBuilder extends StatelessWidget {
  const DigitalRewardStyleBuilder({
    super.key,
    required this.userId,
    required this.builder,
    this.preview,
    this.firestore,
  });

  final String? userId;
  final DigitalRewardStyleWidgetBuilder builder;
  final EquippedDigitalRewards? preview;
  final FirebaseFirestore? firestore;

  @override
  Widget build(BuildContext context) {
    if (preview case final preview?) {
      return builder(context, preview);
    }

    final id = userId?.trim();
    if (id == null || id.isEmpty) {
      return builder(context, const EquippedDigitalRewards());
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: (firestore ?? FirebaseFirestore.instance)
          .collection('users')
          .doc(id)
          .collection('settings')
          .doc('digitalRewards')
          .snapshots(),
      builder: (context, snapshot) {
        return builder(
          context,
          EquippedDigitalRewards.fromMap(snapshot.data?.data()),
        );
      },
    );
  }
}

class DigitalRewardAvatar extends StatelessWidget {
  const DigitalRewardAvatar({
    super.key,
    required this.rewards,
    this.radius = 24,
    this.icon = Icons.person_rounded,
    this.initials,
  });

  final EquippedDigitalRewards rewards;
  final double radius;
  final IconData icon;
  final String? initials;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final frame = _frameGradient(rewards.profileFrame);
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      child: initials?.trim().isNotEmpty == true
          ? Text(
              initials!.trim(),
              style: TextStyle(
                fontSize: radius * 0.62,
                fontWeight: FontWeight.w900,
              ),
            )
          : Icon(icon, size: radius * 1.05),
    );

    if (frame == null) return avatar;

    return Semantics(
      label: '${rewards.profileFrame} profile frame equipped',
      child: Container(
        key: ValueKey('digital-frame-${rewards.profileFrame}'),
        padding: EdgeInsets.all(radius * 0.12 + 3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: frame,
          boxShadow: [
            BoxShadow(
              color: frame.colors.first.withValues(alpha: 0.34),
              blurRadius: radius * 0.46,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.surface,
          ),
          child: avatar,
        ),
      ),
    );
  }
}

class DigitalRewardNameplate extends StatelessWidget {
  const DigitalRewardNameplate({
    super.key,
    required this.name,
    required this.rewards,
    this.style,
    this.textAlign,
  });

  final String name;
  final EquippedDigitalRewards rewards;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final treatment = _nameplateTreatment(context, rewards.nameplate);
    final badge = _badgeIcon(rewards.profileBadge);
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            name,
            textAlign: textAlign,
            overflow: TextOverflow.ellipsis,
            style: style?.copyWith(
              color: treatment?.foreground ?? style?.color,
            ),
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 7),
          Icon(
            badge,
            key: ValueKey('digital-badge-${rewards.profileBadge}'),
            size: (style?.fontSize ?? 18) * 0.92,
            color: treatment?.foreground ?? _badgeColor(rewards.profileBadge),
          ),
        ],
      ],
    );

    if (treatment == null) return content;

    return Container(
      key: ValueKey('digital-nameplate-${rewards.nameplate}'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: treatment.gradient,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: treatment.border),
        boxShadow: treatment.shadow,
      ),
      child: content,
    );
  }
}

class DigitalRewardProfileSurface extends StatelessWidget {
  const DigitalRewardProfileSurface({
    super.key,
    required this.rewards,
    required this.child,
    this.padding = const EdgeInsets.all(22),
  });

  final EquippedDigitalRewards rewards;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradient = _profileGradient(rewards.profileTheme, colorScheme);
    final themed = rewards.profileTheme != 'default';

    return Container(
      key: ValueKey('digital-profile-theme-${rewards.profileTheme}'),
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? colorScheme.surface : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: themed
              ? Colors.white.withValues(alpha: 0.3)
              : colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: themed ? 0.24 : 0.1),
            blurRadius: themed ? 24 : 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: DefaultTextStyle.merge(
        style: themed ? const TextStyle(color: Colors.white) : null,
        child: IconTheme.merge(
          data: IconThemeData(color: themed ? Colors.white : null),
          child: child,
        ),
      ),
    );
  }
}

class DigitalRewardPreview extends StatelessWidget {
  const DigitalRewardPreview({super.key, required this.reward});

  final DigitalRewardDefinition reward;

  @override
  Widget build(BuildContext context) {
    final preview = const EquippedDigitalRewards().withAsset(
      reward.category,
      reward.assetKey,
    );

    return SizedBox(
      width: 104,
      height: 104,
      child: switch (reward.category) {
        DigitalRewardCategory.profileFrame => Center(
          child: DigitalRewardAvatar(rewards: preview, radius: 31),
        ),
        DigitalRewardCategory.profileBadge ||
        DigitalRewardCategory.nameplate => Center(
          child: DigitalRewardNameplate(
            name: 'Sila',
            rewards: preview,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        DigitalRewardCategory.profileTheme => DigitalRewardProfileSurface(
          rewards: preview,
          padding: const EdgeInsets.all(12),
          child: const Center(
            child: Icon(Icons.person_rounded, color: Colors.white, size: 38),
          ),
        ),
        DigitalRewardCategory.celebrationEffect => DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF102E25), Color(0xFF0A8B59)],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Center(
            child: Icon(
              _celebrationIcon(reward.assetKey),
              color: const Color(0xFFFFD77A),
              size: 46,
            ),
          ),
        ),
        DigitalRewardCategory.mascotAccessory ||
        DigitalRewardCategory.mascotOutfit ||
        DigitalRewardCategory.mascotAura => Center(
          child: SilaMascot(
            pose: SilaMascotPose.idle,
            height: 100,
            animate: false,
            accessoryAssetKey:
                reward.category == DigitalRewardCategory.mascotAccessory
                ? reward.assetKey
                : SilaMascotAccessories.none,
            outfitAssetKey:
                reward.category == DigitalRewardCategory.mascotOutfit
                ? reward.assetKey
                : SilaMascotOutfits.none,
            auraAssetKey: reward.category == DigitalRewardCategory.mascotAura
                ? reward.assetKey
                : SilaMascotAuras.none,
          ),
        ),
      },
    );
  }
}

LinearGradient? _frameGradient(String assetKey) {
  return switch (assetKey) {
    'gold' => const LinearGradient(
      colors: [Color(0xFFFFE39A), Color(0xFFB87816), Color(0xFFFFF1B8)],
    ),
    'neon' => const LinearGradient(
      colors: [Color(0xFF19F7FF), Color(0xFFB33CFF), Color(0xFFFF4FD8)],
    ),
    'ocean' => const LinearGradient(
      colors: [Color(0xFF59E3E8), Color(0xFF0877C9), Color(0xFF123B78)],
    ),
    _ => null,
  };
}

LinearGradient? _profileGradient(String assetKey, ColorScheme colors) {
  return switch (assetKey) {
    'galaxy' => const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF17113D), Color(0xFF513195), Color(0xFF136B89)],
    ),
    'ocean' => const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF063A58), Color(0xFF087F8C), Color(0xFF2EB9A8)],
    ),
    'sunset' => const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF6D2349), Color(0xFFD65B45), Color(0xFFF2A83B)],
    ),
    _ => null,
  };
}

IconData? _badgeIcon(String assetKey) {
  return switch (assetKey) {
    'champion' => Icons.emoji_events_rounded,
    'explorer' => Icons.explore_rounded,
    'family_star' => Icons.stars_rounded,
    _ => null,
  };
}

Color _badgeColor(String assetKey) {
  return switch (assetKey) {
    'champion' => const Color(0xFFC48A20),
    'explorer' => const Color(0xFF087F8C),
    'family_star' => const Color(0xFF0A8B59),
    _ => Colors.grey,
  };
}

IconData _celebrationIcon(String assetKey) {
  return switch (assetKey) {
    'fireworks' => Icons.auto_awesome_rounded,
    'stars' => Icons.stars_rounded,
    _ => Icons.celebration_rounded,
  };
}

_NameplateTreatment? _nameplateTreatment(
  BuildContext context,
  String assetKey,
) {
  return switch (assetKey) {
    'gold' => _NameplateTreatment(
      gradient: const LinearGradient(
        colors: [Color(0xFFFFF2BB), Color(0xFFD3A438)],
      ),
      foreground: const Color(0xFF3B2A05),
      border: const Color(0xFFC18B1A),
      shadow: const [],
    ),
    'neon' => _NameplateTreatment(
      gradient: const LinearGradient(
        colors: [Color(0xFF1B1A34), Color(0xFF4D245F)],
      ),
      foreground: const Color(0xFF7FF8FF),
      border: const Color(0xFF35EEF4),
      shadow: [
        BoxShadow(
          color: const Color(0xFF35EEF4).withValues(alpha: 0.28),
          blurRadius: 12,
        ),
      ],
    ),
    'champion' => _NameplateTreatment(
      gradient: const LinearGradient(
        colors: [Color(0xFF173F32), Color(0xFF0A8B59)],
      ),
      foreground: Colors.white,
      border: const Color(0xFFFFD77A),
      shadow: const [],
    ),
    _ => null,
  };
}

class _NameplateTreatment {
  const _NameplateTreatment({
    required this.gradient,
    required this.foreground,
    required this.border,
    required this.shadow,
  });

  final Gradient gradient;
  final Color foreground;
  final Color border;
  final List<BoxShadow> shadow;
}
