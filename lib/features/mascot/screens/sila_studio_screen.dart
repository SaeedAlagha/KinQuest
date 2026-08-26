import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/mascot/sila_mascot.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/sila_page_backdrop.dart';
import '../../../l10n/app_localizations.dart';
import '../../rewards/digital/digital_reward_catalog.dart';
import '../../rewards/digital/digital_reward_definition.dart';
import '../../rewards/digital/digital_reward_service.dart';
import '../../rewards/digital/equipped_digital_rewards.dart';

enum _StudioCategory { headwear, outfits, auras }

class SilaStudioScreen extends StatefulWidget {
  const SilaStudioScreen({super.key, this.developerPreview = false});

  final bool developerPreview;

  @override
  State<SilaStudioScreen> createState() => _SilaStudioScreenState();
}

class _SilaStudioScreenState extends State<SilaStudioScreen> {
  final DigitalRewardService _rewardService = DigitalRewardService();
  final Future<List<DigitalRewardDefinition>> _catalog =
      DigitalRewardCatalog.load();

  _StudioCategory _category = _StudioCategory.headwear;
  SilaMascotPose _pose = SilaMascotPose.idle;
  SilaMascotMotion _motion = SilaMascotMotion.hover;
  EquippedDigitalRewards? _tryOn;
  String? _processingRewardId;

  int _previewTokens = 1350;
  final Set<String> _previewOwned = {
    'mascot_guardian_crown',
    'mascot_family_cape',
    'mascot_family_sparkles',
  };
  final Set<String> _previewEquipped = {
    'mascot_guardian_crown',
    'mascot_family_cape',
    'mascot_family_sparkles',
  };
  EquippedDigitalRewards _previewRewards = const EquippedDigitalRewards(
    mascotAccessory: SilaMascotAccessories.guardianCrown,
    mascotOutfit: SilaMascotOutfits.familyCape,
    mascotAura: SilaMascotAuras.familySparkles,
  );

  void _playReaction(SilaMascotMotion motion) {
    setState(() {
      _motion = motion;
      _pose = switch (motion) {
        SilaMascotMotion.hover => SilaMascotPose.idle,
        SilaMascotMotion.gameReady => SilaMascotPose.encouraging,
        SilaMascotMotion.thinking => SilaMascotPose.thinking,
        SilaMascotMotion.excited => SilaMascotPose.welcome,
        SilaMascotMotion.celebrate => SilaMascotPose.celebrating,
      };
    });
  }

  void _playNextReaction() {
    final motions = [
      SilaMascotMotion.hover,
      SilaMascotMotion.gameReady,
      SilaMascotMotion.thinking,
      SilaMascotMotion.celebrate,
    ];
    _playReaction(motions[(motions.indexOf(_motion) + 1) % motions.length]);
  }

  String _errorMessage(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ')
        ? text.substring('Exception: '.length)
        : AppLocalizations.of(context)!.silaStudioLoadError;
  }

  Future<void> _updateReward({
    required DigitalRewardDefinition reward,
    required bool owned,
    required bool equipped,
  }) async {
    if (_processingRewardId != null) return;
    final strings = AppLocalizations.of(context)!;
    setState(() => _processingRewardId = reward.id);

    try {
      if (widget.developerPreview) {
        if (!owned) {
          if (_previewTokens < reward.cost) return;
          _previewTokens -= reward.cost;
          _previewOwned.add(reward.id);
        }

        if (equipped) {
          _previewEquipped.remove(reward.id);
          _previewRewards = _previewRewards.withAsset(reward.category, 'none');
        } else {
          final catalog = await _catalog;
          _previewEquipped.removeWhere((id) {
            final item = catalog.where((entry) => entry.id == id).firstOrNull;
            return item?.category == reward.category;
          });
          _previewEquipped.add(reward.id);
          _previewRewards = _previewRewards.withAsset(
            reward.category,
            reward.assetKey,
          );
        }
        if (!mounted) return;
        setState(() => _tryOn = null);
      } else {
        if (!owned) {
          await _rewardService.purchase(reward.id);
          await _rewardService.equip(reward.id);
        } else if (equipped) {
          await _rewardService.unequip(reward.id);
        } else {
          await _rewardService.equip(reward.id);
        }
        if (!mounted) return;
        setState(() => _tryOn = null);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !owned
                ? strings.silaStudioUnlockSuccess
                : strings.silaStudioUpdateSuccess,
          ),
        ),
      );
      _playReaction(SilaMascotMotion.excited);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_errorMessage(error))));
    } finally {
      if (mounted) setState(() => _processingRewardId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<DigitalRewardDefinition>>(
          future: _catalog,
          builder: (context, catalogSnapshot) {
            if (!catalogSnapshot.hasData && !catalogSnapshot.hasError) {
              return const Center(child: CircularProgressIndicator());
            }
            if (catalogSnapshot.hasError) return const _StudioLoadError();

            final wardrobe = (catalogSnapshot.data ?? const [])
                .where((reward) => _isMascotCategory(reward.category))
                .toList();

            if (widget.developerPreview) {
              return _buildStudio(
                wardrobe: wardrobe,
                tokens: _previewTokens,
                owned: _previewOwned,
                equippedIds: _previewEquipped,
                equippedRewards: _previewRewards,
              );
            }

            final user = FirebaseAuth.instance.currentUser;
            if (user == null) return const _StudioSignedOut();

            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, userSnapshot) {
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('ownedRewards')
                      .snapshots(),
                  builder: (context, ownedSnapshot) {
                    return StreamBuilder<
                      DocumentSnapshot<Map<String, dynamic>>
                    >(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('settings')
                          .doc('digitalRewards')
                          .snapshots(),
                      builder: (context, settingsSnapshot) {
                        if ((!userSnapshot.hasData || !ownedSnapshot.hasData) &&
                            !userSnapshot.hasError &&
                            !ownedSnapshot.hasError) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (userSnapshot.hasError || ownedSnapshot.hasError) {
                          return const _StudioLoadError();
                        }

                        final documents = ownedSnapshot.data?.docs ?? const [];
                        return _buildStudio(
                          wardrobe: wardrobe,
                          tokens:
                              (userSnapshot.data?.data()?['tokens'] as num?)
                                  ?.toInt() ??
                              0,
                          owned: documents.map((item) => item.id).toSet(),
                          equippedIds: documents
                              .where((item) => item.data()['equipped'] == true)
                              .map((item) => item.id)
                              .toSet(),
                          equippedRewards: EquippedDigitalRewards.fromMap(
                            settingsSnapshot.data?.data(),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildStudio({
    required List<DigitalRewardDefinition> wardrobe,
    required int tokens,
    required Set<String> owned,
    required Set<String> equippedIds,
    required EquippedDigitalRewards equippedRewards,
  }) {
    final strings = AppLocalizations.of(context)!;
    final visibleRewards = wardrobe
        .where((reward) => _studioCategoryFor(reward.category) == _category)
        .toList();
    final preview = _tryOn ?? equippedRewards;

    return SilaPageBackdrop(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stage = _SilaStage(
            pose: _pose,
            motion: _motion,
            rewards: preview,
            tokens: tokens,
            onTapSila: _playNextReaction,
            onReaction: _playReaction,
          );
          final closet = _StudioCloset(
            category: _category,
            rewards: visibleRewards,
            tokens: tokens,
            owned: owned,
            equipped: equippedIds,
            processingRewardId: _processingRewardId,
            onCategoryChanged: (value) => setState(() {
              _category = value;
              _tryOn = null;
            }),
            onTryOn: (reward) => setState(() {
              _tryOn = equippedRewards.withAsset(
                reward.category,
                reward.assetKey,
              );
              _playReaction(SilaMascotMotion.gameReady);
            }),
            onUpdate: (reward) => _updateReward(
              reward: reward,
              owned: owned.contains(reward.id),
              equipped: equippedIds.contains(reward.id),
            ),
          );

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              constraints.maxWidth < 520 ? 18 : 28,
              24,
              constraints.maxWidth < 520 ? 18 : 28,
              42,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.silaStudioTitle,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      strings.silaStudioSubtitle,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 22),
                    stage,
                    const SizedBox(height: 24),
                    closet,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SilaStage extends StatefulWidget {
  const _SilaStage({
    required this.pose,
    required this.motion,
    required this.rewards,
    required this.tokens,
    required this.onTapSila,
    required this.onReaction,
  });

  final SilaMascotPose pose;
  final SilaMascotMotion motion;
  final EquippedDigitalRewards rewards;
  final int tokens;
  final VoidCallback onTapSila;
  final ValueChanged<SilaMascotMotion> onReaction;

  @override
  State<_SilaStage> createState() => _SilaStageState();
}

class _SilaStageState extends State<_SilaStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final reactions = [
      (
        SilaMascotMotion.hover,
        strings.silaStudioReactionHover,
        Icons.air_rounded,
      ),
      (
        SilaMascotMotion.gameReady,
        strings.silaStudioReactionReady,
        Icons.sports_esports_rounded,
      ),
      (
        SilaMascotMotion.thinking,
        strings.silaStudioReactionThink,
        Icons.psychology_rounded,
      ),
      (
        SilaMascotMotion.celebrate,
        strings.silaStudioReactionCelebrate,
        Icons.celebration_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;
        final frameHeight = compact ? 520.0 : 590.0;
        final mascotHeight = compact ? 305.0 : 435.0;

        return Container(
          height: frameHeight,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD879), Color(0xFF64E7C2), Color(0xFFFF8D73)],
            ),
            borderRadius: BorderRadius.circular(38),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.24),
                blurRadius: 42,
                spreadRadius: 2,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppTheme.heroGradientFor(context),
              ),
              child: AnimatedBuilder(
                animation: _ambientController,
                builder: (context, _) => Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _StudioAtmospherePainter(
                          progress: _ambientController.value,
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: compact ? 14 : 20,
                      start: compact ? 14 : 22,
                      end: compact ? 14 : 22,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: compact ? 12 : 16,
                                vertical: compact ? 10 : 13,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.16),
                                ),
                              ),
                              child: Text(
                                strings.silaStudioWelcomeMessage,
                                maxLines: compact ? 2 : 3,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Chip(
                            avatar: const Icon(Icons.stars_rounded, size: 18),
                            label: Text('${widget.tokens}'),
                            backgroundColor: Colors.white,
                            side: BorderSide.none,
                          ),
                        ],
                      ),
                    ),
                    Positioned.fill(
                      top: compact ? 70 : 64,
                      bottom: compact ? 104 : 98,
                      child: GestureDetector(
                        key: const ValueKey('sila-studio-mascot'),
                        onTap: widget.onTapSila,
                        child: Semantics(
                          button: true,
                          label: strings.silaStudioTapHint,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Positioned(
                                bottom: compact ? 12 : 18,
                                child: Container(
                                  width: compact ? 245 : 360,
                                  height: compact ? 55 : 76,
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withValues(alpha: 0.58),
                                        Colors.white.withValues(alpha: 0.04),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                              SilaMascot(
                                key: ValueKey(
                                  'studio-${widget.pose.name}-${widget.motion.name}',
                                ),
                                pose: widget.pose,
                                motion: widget.motion,
                                loop: true,
                                height: mascotHeight,
                                semanticLabel: strings.mascotSemanticLabel,
                                accessoryAssetKey:
                                    widget.rewards.mascotAccessory,
                                outfitAssetKey: widget.rewards.mascotOutfit,
                                auraAssetKey: widget.rewards.mascotAura,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      start: 14,
                      end: 14,
                      bottom: 15,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            strings.silaStudioTapHint,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.86),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 9),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 7,
                            children: [
                              for (final reaction in reactions)
                                ChoiceChip(
                                  key: ValueKey(
                                    'sila-motion-${reaction.$1.name}',
                                  ),
                                  selected: widget.motion == reaction.$1,
                                  onSelected: (_) =>
                                      widget.onReaction(reaction.$1),
                                  avatar: Icon(reaction.$3, size: 18),
                                  label: Text(reaction.$2),
                                  side: BorderSide.none,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StudioAtmospherePainter extends CustomPainter {
  const _StudioAtmospherePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.51);
    final shortest = math.min(size.width, size.height);
    final pulse = (math.sin(progress * math.pi * 2) + 1) / 2;

    canvas.drawCircle(
      center,
      shortest * (0.28 + pulse * 0.025),
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.24),
                const Color(0xFF66E6C4).withValues(alpha: 0.08),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(center: center, radius: shortest * 0.34),
            ),
    );

    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.white.withValues(alpha: 0.16);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(progress * math.pi * 0.22);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.width * 0.56,
        height: shortest * 0.56,
      ),
      orbitPaint,
    );
    canvas.rotate(-progress * math.pi * 0.44);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.width * 0.43,
        height: shortest * 0.72,
      ),
      orbitPaint..color = Colors.white.withValues(alpha: 0.11),
    );
    canvas.restore();

    const particleColors = [
      Color(0xFFFFD36A),
      Color(0xFF65E7C1),
      Color(0xFFFF8A73),
      Color(0xFFC5B6FF),
    ];
    for (var index = 0; index < 14; index += 1) {
      final angle = progress * math.pi * 2 + index * math.pi * 2 / 14;
      final radiusX = size.width * (0.25 + (index % 3) * 0.045);
      final radiusY = shortest * (0.24 + (index % 4) * 0.035);
      final position = Offset(
        center.dx + math.cos(angle * (index.isEven ? 1 : -1)) * radiusX,
        center.dy + math.sin(angle) * radiusY,
      );
      final particlePulse = (math.sin(progress * math.pi * 2 + index) + 1) / 2;
      canvas.drawCircle(
        position,
        2.5 + particlePulse * 3.2,
        Paint()
          ..color = particleColors[index % particleColors.length].withValues(
            alpha: 0.45 + particlePulse * 0.45,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StudioAtmospherePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _StudioCloset extends StatelessWidget {
  const _StudioCloset({
    required this.category,
    required this.rewards,
    required this.tokens,
    required this.owned,
    required this.equipped,
    required this.processingRewardId,
    required this.onCategoryChanged,
    required this.onTryOn,
    required this.onUpdate,
  });

  final _StudioCategory category;
  final List<DigitalRewardDefinition> rewards;
  final int tokens;
  final Set<String> owned;
  final Set<String> equipped;
  final String? processingRewardId;
  final ValueChanged<_StudioCategory> onCategoryChanged;
  final ValueChanged<DigitalRewardDefinition> onTryOn;
  final ValueChanged<DigitalRewardDefinition> onUpdate;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final categories = [
      (
        _StudioCategory.headwear,
        strings.silaStudioHeadwear,
        Icons.face_retouching_natural_rounded,
      ),
      (
        _StudioCategory.outfits,
        strings.silaStudioOutfits,
        Icons.checkroom_rounded,
      ),
      (
        _StudioCategory.auras,
        strings.silaStudioAuras,
        Icons.auto_awesome_rounded,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.silaStudioCloset,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(strings.silaStudioClosetDescription),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in categories)
                ChoiceChip(
                  key: ValueKey('sila-category-${entry.$1.name}'),
                  selected: category == entry.$1,
                  onSelected: (_) => onCategoryChanged(entry.$1),
                  avatar: Icon(entry.$3, size: 18),
                  label: Text(entry.$2),
                ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth >= 620
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final reward in rewards)
                    SizedBox(
                      width: cardWidth,
                      child: _StudioRewardCard(
                        reward: reward,
                        tokens: tokens,
                        owned: owned.contains(reward.id),
                        equipped: equipped.contains(reward.id),
                        processing: processingRewardId == reward.id,
                        blocked:
                            processingRewardId != null &&
                            processingRewardId != reward.id,
                        onTryOn: () => onTryOn(reward),
                        onUpdate: () => onUpdate(reward),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StudioRewardCard extends StatelessWidget {
  const _StudioRewardCard({
    required this.reward,
    required this.tokens,
    required this.owned,
    required this.equipped,
    required this.processing,
    required this.blocked,
    required this.onTryOn,
    required this.onUpdate,
  });

  final DigitalRewardDefinition reward;
  final int tokens;
  final bool owned;
  final bool equipped;
  final bool processing;
  final bool blocked;
  final VoidCallback onTryOn;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final canAfford = tokens >= reward.cost;
    final name = _localizedRewardName(context, reward);
    final description = _localizedRewardDescription(context, reward);

    return Card(
      key: ValueKey('sila-studio-reward-${reward.id}'),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTryOn,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: SilaMascot(
                  height: 126,
                  animate: false,
                  accessoryAssetKey:
                      reward.category == DigitalRewardCategory.mascotAccessory
                      ? reward.assetKey
                      : SilaMascotAccessories.none,
                  outfitAssetKey:
                      reward.category == DigitalRewardCategory.mascotOutfit
                      ? reward.assetKey
                      : SilaMascotOutfits.none,
                  auraAssetKey:
                      reward.category == DigitalRewardCategory.mascotAura
                      ? reward.assetKey
                      : SilaMascotAuras.none,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  Chip(
                    avatar: const Icon(Icons.stars_rounded, size: 17),
                    label: Text('${reward.cost}'),
                  ),
                  Chip(
                    label: Text(
                      equipped
                          ? strings.silaStudioEquipped
                          : owned
                          ? strings.silaStudioOwned
                          : strings.silaStudioPermanent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onTryOn,
                      child: Text(strings.silaStudioTryOn),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      key: ValueKey('sila-studio-action-${reward.id}'),
                      onPressed: processing || blocked || (!owned && !canAfford)
                          ? null
                          : onUpdate,
                      child: processing
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              equipped
                                  ? strings.silaStudioUnequip
                                  : owned
                                  ? strings.silaStudioEquip
                                  : canAfford
                                  ? strings.silaStudioUnlock(reward.cost)
                                  : strings.silaStudioNotEnoughTokens(
                                      reward.cost - tokens,
                                    ),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudioLoadError extends StatelessWidget {
  const _StudioLoadError();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Text(
        AppLocalizations.of(context)!.silaStudioLoadError,
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class _StudioSignedOut extends StatelessWidget {
  const _StudioSignedOut();

  @override
  Widget build(BuildContext context) =>
      Center(child: Text(AppLocalizations.of(context)!.noUserSignedIn));
}

bool _isMascotCategory(DigitalRewardCategory category) =>
    category == DigitalRewardCategory.mascotAccessory ||
    category == DigitalRewardCategory.mascotOutfit ||
    category == DigitalRewardCategory.mascotAura;

_StudioCategory _studioCategoryFor(DigitalRewardCategory category) {
  return switch (category) {
    DigitalRewardCategory.mascotAccessory => _StudioCategory.headwear,
    DigitalRewardCategory.mascotOutfit => _StudioCategory.outfits,
    DigitalRewardCategory.mascotAura => _StudioCategory.auras,
    _ => throw ArgumentError.value(category),
  };
}

String _localizedRewardName(
  BuildContext context,
  DigitalRewardDefinition reward,
) {
  if (Localizations.localeOf(context).languageCode != 'ar') return reward.name;
  return switch (reward.id) {
    'mascot_guardian_crown' => 'تاج حارس العائلة',
    'mascot_explorer_cap' => 'قبعة مستكشف العائلة',
    'mascot_star_halo' => 'هالة نجمة الإرث',
    'mascot_family_cape' => 'رداء بطل العائلة',
    'mascot_game_jersey' => 'زي ليلة الألعاب',
    'mascot_memory_keeper' => 'عدة حارس الذكريات',
    'mascot_family_sparkles' => 'هالة بريق العائلة',
    'mascot_cosmic_orbit' => 'هالة المدار الكوني',
    'mascot_uae_ribbon' => 'شريط وحدة الإمارات',
    _ => reward.name,
  };
}

String _localizedRewardDescription(
  BuildContext context,
  DigitalRewardDefinition reward,
) {
  if (Localizations.localeOf(context).languageCode != 'ar') {
    return reward.description;
  }
  return switch (reward.id) {
    'mascot_guardian_crown' => 'تاج ذهبي لانتصارات العائلة المميزة.',
    'mascot_explorer_cap' => 'قبعة خضراء لمغامرة صلة العائلية التالية.',
    'mascot_star_halo' => 'مدار متوهج من نجوم العائلة حول صلة.',
    'mascot_family_cape' => 'رداء أخضر وذهبي للحظات العائلة البطولية.',
    'mascot_game_jersey' => 'زي رياضي مرح عندما يقود صلة الألعاب.',
    'mascot_memory_keeper' => 'حقيبة كاميرا صغيرة لذكريات العائلة.',
    'mascot_family_sparkles' => 'ألوان الجذور والروابط والنمو تدور حول صلة.',
    'mascot_cosmic_orbit' => 'مدار فضائي متحرك لمغامرات صلة.',
    'mascot_uae_ribbon' => 'قوس بألوان الإمارات يحتفي بوحدة العائلة.',
    _ => reward.description,
  };
}
