import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/family_year_banner.dart';
import '../../../core/widgets/sila_page_backdrop.dart';
import '../../home/screens/main_navigation_screen.dart';

enum _DemoStage { mission, competition, reward, memory, complete }

class CompetitionDemoScreen extends StatefulWidget {
  const CompetitionDemoScreen({super.key});

  @override
  State<CompetitionDemoScreen> createState() => _CompetitionDemoScreenState();
}

class _CompetitionDemoScreenState extends State<CompetitionDemoScreen> {
  _DemoStage _stage = _DemoStage.mission;
  int _tokens = 480;
  bool _isVerifying = false;
  String? _selectedAnswer;
  bool _winnerCrowned = false;
  bool _rewardRedeemed = false;

  void _restart() {
    setState(() {
      _stage = _DemoStage.mission;
      _tokens = 480;
      _isVerifying = false;
      _selectedAnswer = null;
      _winnerCrowned = false;
      _rewardRedeemed = false;
    });
  }

  Future<void> _verifyMission() async {
    if (_isVerifying) return;

    setState(() => _isVerifying = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      _isVerifying = false;
      _tokens += 20;
      _stage = _DemoStage.competition;
    });
  }

  void _finishCompetition() {
    if (_selectedAnswer == null || _winnerCrowned) return;

    setState(() {
      _winnerCrowned = true;
      _tokens += 50;
    });
  }

  void _redeemReward() {
    if (_rewardRedeemed || _tokens < 350) return;

    setState(() {
      _rewardRedeemed = true;
      _tokens -= 350;
    });
  }

  @override
  Widget build(BuildContext context) {
    final copy = CompetitionDemoCopy.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(copy.title),
        actions: [
          TextButton.icon(
            onPressed: _restart,
            icon: const Icon(Icons.restart_alt_rounded),
            label: Text(copy.restart),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SilaPageBackdrop(
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 640;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  compact ? 16 : 28,
                  20,
                  compact ? 16 : 28,
                  40,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _DemoHeader(
                          copy: copy,
                          tokens: _tokens,
                          compact: compact,
                        ),
                        const SizedBox(height: 20),
                        _DemoProgress(copy: copy, currentIndex: _stage.index),
                        const SizedBox(height: 20),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 320),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.025, 0.04),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                          child: _buildStage(copy),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStage(CompetitionDemoCopy copy) {
    return switch (_stage) {
      _DemoStage.mission => _MissionStage(
        key: const ValueKey('mission'),
        copy: copy,
        isVerifying: _isVerifying,
        onVerify: _verifyMission,
      ),
      _DemoStage.competition => _CompetitionStage(
        key: const ValueKey('competition'),
        copy: copy,
        selectedAnswer: _selectedAnswer,
        winnerCrowned: _winnerCrowned,
        onAnswerSelected: (answer) {
          if (!_winnerCrowned) setState(() => _selectedAnswer = answer);
        },
        onFinish: _finishCompetition,
        onContinue: () => setState(() => _stage = _DemoStage.reward),
      ),
      _DemoStage.reward => _RewardStage(
        key: const ValueKey('reward'),
        copy: copy,
        tokens: _tokens,
        redeemed: _rewardRedeemed,
        onRedeem: _redeemReward,
        onContinue: () => setState(() => _stage = _DemoStage.memory),
      ),
      _DemoStage.memory => _MemoryStage(
        key: const ValueKey('memory'),
        copy: copy,
        onSave: () => setState(() => _stage = _DemoStage.complete),
      ),
      _DemoStage.complete => _CompleteStage(
        key: const ValueKey('complete'),
        copy: copy,
        tokens: _tokens,
        onRestart: _restart,
        onExplore: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) =>
                  const MainNavigationScreen(developerPreview: true),
            ),
          );
        },
      ),
    };
  }
}

class _DemoHeader extends StatelessWidget {
  const _DemoHeader({
    required this.copy,
    required this.tokens,
    required this.compact,
  });

  final CompetitionDemoCopy copy;
  final int tokens;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final family = _FamilyStrip(copy: copy);
    final balance = _TokenBalance(copy: copy, tokens: tokens);

    return Container(
      padding: EdgeInsets.all(compact ? 20 : 26),
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: 0.2),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const UaeColorRibbon(height: 5),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeaderBadge(
                icon: Icons.auto_awesome_rounded,
                label: copy.eyebrow,
              ),
              _HeaderBadge(icon: Icons.timer_outlined, label: copy.duration),
              _HeaderBadge(
                icon: Icons.cloud_off_rounded,
                label: copy.offlineSafe,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            copy.heading,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontSize: compact ? 30 : 38,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            copy.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 22),
          if (compact) ...[
            family,
            const SizedBox(height: 16),
            balance,
          ] else
            Row(
              children: [
                Expanded(child: family),
                const SizedBox(width: 16),
                balance,
              ],
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                size: 17,
                color: colorScheme.primaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  copy.privateDemo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilyStrip extends StatelessWidget {
  const _FamilyStrip({required this.copy});

  final CompetitionDemoCopy copy;

  @override
  Widget build(BuildContext context) {
    const members = [
      ('M', Color(0xFFD71920)),
      ('O', Color(0xFFB88A37)),
      ('S', Color(0xFF00843D)),
      ('Z', Color(0xFF3567A6)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          copy.familyName,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final member in members) ...[
              CircleAvatar(
                radius: 19,
                backgroundColor: member.$2,
                child: Text(
                  member.$1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 7),
            ],
          ],
        ),
      ],
    );
  }
}

class _TokenBalance extends StatelessWidget {
  const _TokenBalance({required this.copy, required this.tokens});

  final CompetitionDemoCopy copy;
  final int tokens;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${copy.tokens}: $tokens',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars_rounded, color: Color(0xFFFFD77A)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  copy.tokens,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.white70),
                ),
                TweenAnimationBuilder<int>(
                  tween: IntTween(end: tokens),
                  duration: const Duration(milliseconds: 450),
                  builder: (context, value, _) => Text(
                    '$value',
                    key: const ValueKey('demo-token-balance'),
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoProgress extends StatelessWidget {
  const _DemoProgress({required this.copy, required this.currentIndex});

  final CompetitionDemoCopy copy;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final steps = copy.steps;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (currentIndex + 1) / steps.length,
              minHeight: 7,
              borderRadius: BorderRadius.circular(99),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var index = 0; index < steps.length; index++)
                  _StepPill(
                    index: index,
                    label: steps[index],
                    active: index == currentIndex,
                    complete: index < currentIndex,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  const _StepPill({
    required this.index,
    required this.label,
    required this.active,
    required this.complete,
  });

  final int index;
  final String label;
  final bool active;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = active || complete ? colors.onPrimary : colors.onSurface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active
            ? colors.primary
            : complete
            ? colors.primary.withValues(alpha: 0.78)
            : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            complete ? Icons.check_rounded : Icons.circle,
            size: complete ? 17 : 9,
            color: foreground,
          ),
          const SizedBox(width: 7),
          Text(
            '${index + 1}. $label',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: colors.primaryContainer,
                  child: Icon(icon, color: colors.onPrimaryContainer),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eyebrow.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(description),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

class _MissionStage extends StatelessWidget {
  const _MissionStage({
    super.key,
    required this.copy,
    required this.isVerifying,
    required this.onVerify,
  });

  final CompetitionDemoCopy copy;
  final bool isVerifying;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    return _StageCard(
      eyebrow: copy.stepMission,
      title: copy.missionTitle,
      description: copy.missionDescription,
      icon: Icons.restaurant_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE8D8B7), Color(0xFF9CC9A9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.dinner_dining_rounded,
                    size: 82,
                    color: AppTheme.primaryDark,
                  ),
                ),
                PositionedDirectional(
                  start: 14,
                  top: 14,
                  child: _EvidenceBadge(label: copy.simulatedProof),
                ),
                PositionedDirectional(
                  end: 14,
                  bottom: 14,
                  child: _EvidenceBadge(label: copy.familyMeal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoBanner(
            icon: Icons.privacy_tip_outlined,
            text: copy.proofPrivacy,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            key: const ValueKey('verify-demo-mission'),
            onPressed: isVerifying ? null : onVerify,
            icon: isVerifying
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome_rounded),
            label: Text(isVerifying ? copy.verifying : copy.verifyMission),
          ),
        ],
      ),
    );
  }
}

class _EvidenceBadge extends StatelessWidget {
  const _EvidenceBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.uaeBlack.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _CompetitionStage extends StatelessWidget {
  const _CompetitionStage({
    super.key,
    required this.copy,
    required this.selectedAnswer,
    required this.winnerCrowned,
    required this.onAnswerSelected,
    required this.onFinish,
    required this.onContinue,
  });

  final CompetitionDemoCopy copy;
  final String? selectedAnswer;
  final bool winnerCrowned;
  final ValueChanged<String> onAnswerSelected;
  final VoidCallback onFinish;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return _StageCard(
      eyebrow: copy.stepCompetition,
      title: copy.competitionTitle,
      description: copy.competitionDescription,
      icon: Icons.emoji_events_rounded,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: winnerCrowned
            ? _WinnerPanel(copy: copy, onContinue: onContinue)
            : Column(
                key: const ValueKey('competition-question'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          copy.roundLabel,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          copy.competitionQuestion,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final answer in copy.answers)
                        ChoiceChip(
                          key: ValueKey('demo-answer-$answer'),
                          label: Text(answer),
                          selected: selectedAnswer == answer,
                          onSelected: (_) => onAnswerSelected(answer),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    key: const ValueKey('finish-demo-round'),
                    onPressed: selectedAnswer == null ? null : onFinish,
                    icon: const Icon(Icons.flag_rounded),
                    label: Text(copy.finishRound),
                  ),
                ],
              ),
      ),
    );
  }
}

class _WinnerPanel extends StatelessWidget {
  const _WinnerPanel({required this.copy, required this.onContinue});

  final CompetitionDemoCopy copy;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('winner-panel'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF173A2E), Color(0xFF0B7A50)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: _ConfettiPainter()),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 68,
                  color: Color(0xFFFFD77A),
                ),
                const SizedBox(height: 12),
                Text(
                  copy.winnerTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  copy.winnerDescription,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onContinue,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryDark,
                  ),
                  icon: const Icon(Icons.redeem_rounded),
                  label: Text(copy.continueToRewards),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardStage extends StatelessWidget {
  const _RewardStage({
    super.key,
    required this.copy,
    required this.tokens,
    required this.redeemed,
    required this.onRedeem,
    required this.onContinue,
  });

  final CompetitionDemoCopy copy;
  final int tokens;
  final bool redeemed;
  final VoidCallback onRedeem;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return _StageCard(
      eyebrow: copy.stepReward,
      title: copy.rewardTitle,
      description: copy.rewardDescription,
      icon: Icons.redeem_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.tertiaryContainer,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colors.tertiary,
                  child: Icon(
                    Icons.restaurant_menu_rounded,
                    color: colors.onTertiary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        copy.rewardName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(copy.rewardDetail),
                    ],
                  ),
                ),
                Chip(
                  avatar: const Icon(Icons.stars_rounded, size: 18),
                  label: const Text('350'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (redeemed)
            _InfoBanner(
              icon: Icons.check_circle_rounded,
              text: copy.rewardRedeemed,
            )
          else
            _InfoBanner(
              icon: Icons.account_balance_wallet_outlined,
              text: copy.balanceReady(tokens),
            ),
          const SizedBox(height: 18),
          FilledButton.icon(
            key: const ValueKey('redeem-demo-reward'),
            onPressed: redeemed ? onContinue : onRedeem,
            icon: Icon(
              redeemed ? Icons.photo_library_outlined : Icons.redeem_rounded,
            ),
            label: Text(redeemed ? copy.continueToMemory : copy.redeemReward),
          ),
        ],
      ),
    );
  }
}

class _MemoryStage extends StatelessWidget {
  const _MemoryStage({super.key, required this.copy, required this.onSave});

  final CompetitionDemoCopy copy;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return _StageCard(
      eyebrow: copy.stepMemory,
      title: copy.memoryTitle,
      description: copy.memoryDescription,
      icon: Icons.photo_library_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 210),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF183B31), Color(0xFFB88A37)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.family_restroom_rounded,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  copy.memoryName,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  copy.memoryDetail,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            key: const ValueKey('save-demo-memory'),
            onPressed: onSave,
            icon: const Icon(Icons.bookmark_add_rounded),
            label: Text(copy.saveMemory),
          ),
        ],
      ),
    );
  }
}

class _CompleteStage extends StatelessWidget {
  const _CompleteStage({
    super.key,
    required this.copy,
    required this.tokens,
    required this.onRestart,
    required this.onExplore,
  });

  final CompetitionDemoCopy copy;
  final int tokens;
  final VoidCallback onRestart;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      (Icons.flag_rounded, copy.metricMission),
      (Icons.emoji_events_rounded, copy.metricCompetition),
      (Icons.redeem_rounded, copy.metricReward),
      (Icons.photo_library_rounded, copy.metricMemory),
    ];

    return Card(
      key: const ValueKey('demo-complete'),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: const BoxDecoration(
                gradient: AppTheme.brandGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 54,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              copy.completeTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              copy.completeDescription(tokens),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final metric in metrics)
                  Chip(
                    avatar: Icon(metric.$1, size: 18),
                    label: Text(metric.$2),
                  ),
              ],
            ),
            const SizedBox(height: 26),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    key: const ValueKey('explore-full-app'),
                    onPressed: onExplore,
                    icon: const Icon(Icons.explore_rounded),
                    label: Text(copy.exploreSila),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: onRestart,
                    icon: const Icon(Icons.replay_rounded),
                    label: Text(copy.runAgain),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const points = [
      (0.08, 0.18, AppTheme.uaeRed),
      (0.17, 0.72, Color(0xFFFFD77A)),
      (0.28, 0.24, AppTheme.uaeGreen),
      (0.74, 0.2, Color(0xFFFFD77A)),
      (0.86, 0.68, AppTheme.uaeRed),
      (0.93, 0.3, Colors.white),
      (0.64, 0.82, AppTheme.uaeGreen),
    ];

    for (final point in points) {
      canvas.drawCircle(
        Offset(size.width * point.$1, size.height * point.$2),
        5,
        Paint()..color = point.$3.withValues(alpha: 0.82),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CompetitionDemoCopy {
  const CompetitionDemoCopy._({required this.arabic});

  final bool arabic;

  static CompetitionDemoCopy of(BuildContext context) {
    return CompetitionDemoCopy._(
      arabic: Localizations.localeOf(context).languageCode == 'ar',
    );
  }

  static String launchLabel(BuildContext context) => of(context).launch;

  String get launch => arabic
      ? 'جرّب العرض التنافسي في 3 دقائق'
      : 'Try the 3-minute Competition Demo';
  String get title => arabic ? 'العرض التنافسي' : 'Competition Demo';
  String get restart => arabic ? 'إعادة' : 'Restart';
  String get eyebrow =>
      arabic ? 'قصة تحكيم تفاعلية' : 'INTERACTIVE JUDGE STORY';
  String get duration => arabic ? '3 دقائق' : '3 minutes';
  String get offlineSafe => arabic ? 'يعمل بلا إنترنت' : 'Offline-safe';
  String get heading => arabic
      ? 'شاهد كيف تقرّب صلة العائلة'
      : 'See how Sila brings a family closer';
  String get subtitle => arabic
      ? 'أكمل رحلة حقيقية من مهمة عائلية إلى ذكرى لا تُنسى.'
      : 'Complete one meaningful journey from a family mission to a memory worth keeping.';
  String get familyName => arabic ? 'عائلة النور' : 'The Al Noor Family';
  String get privateDemo => arabic
      ? 'بيانات محاكاة خاصة بهذا العرض، ولا يتم رفع أي صور.'
      : 'Private simulated data for this demo. No photos are uploaded.';
  String get tokens => arabic ? 'رموز العائلة' : 'Family Tokens';
  String get stepMission => arabic ? 'المهمة' : 'Mission';
  String get stepCompetition => arabic ? 'المنافسة' : 'Competition';
  String get stepReward => arabic ? 'المكافأة' : 'Reward';
  String get stepMemory => arabic ? 'الذكرى' : 'Memory';
  String get stepComplete => arabic ? 'الأثر' : 'Impact';
  List<String> get steps => [
    stepMission,
    stepCompetition,
    stepReward,
    stepMemory,
    stepComplete,
  ];
  String get missionTitle =>
      arabic ? 'تناولوا وجبة بلا هواتف' : 'Share a phone-free family meal';
  String get missionDescription => arabic
      ? 'تحوّل صلة لحظة يومية بسيطة إلى وقت عائلي هادف.'
      : 'Sila turns one everyday moment into intentional family time.';
  String get simulatedProof => arabic ? 'إثبات تجريبي' : 'Simulated proof';
  String get familyMeal => arabic ? 'وجبة عائلية' : 'Family meal';
  String get proofPrivacy => arabic
      ? 'يعرض هذا المسار نتيجة تحقق آمنة من دون إرسال صورة حقيقية.'
      : 'This journey demonstrates safe verification without sending a real photo.';
  String get verifyMission =>
      arabic ? 'تحقق واربح 20 رمزًا' : 'Verify & earn 20 Tokens';
  String get verifying =>
      arabic ? 'جارٍ التحقق بأمان...' : 'Verifying safely...';
  String get competitionTitle =>
      arabic ? 'تحدي اختبار العائلة' : 'Family Quiz Challenge';
  String get competitionDescription => arabic
      ? 'حوّلوا معرفتكم ببعضكم إلى منافسة ودية وممتعة.'
      : 'Turn how well you know each other into a friendly competition.';
  String get roundLabel => arabic ? 'الجولة النهائية' : 'FINAL ROUND';
  String get competitionQuestion => arabic
      ? 'من يتذكر دائمًا أعياد ميلاد جميع أفراد العائلة؟'
      : 'Who always remembers every family birthday?';
  List<String> get answers => arabic
      ? const ['مريم', 'عمر', 'سارة', 'زايد']
      : const ['Mariam', 'Omar', 'Sara', 'Zayed'];
  String get finishRound =>
      arabic ? 'اعتمد الإجابة وأعلن الفائز' : 'Lock answer & crown winner';
  String get winnerTitle =>
      arabic ? 'سارة بطلة العائلة!' : 'Sara is the Family Champion!';
  String get winnerDescription => arabic
      ? 'ربحت العائلة 50 رمزًا ولحظة احتفال مشتركة.'
      : 'The family earned 50 Tokens and a celebration they shared together.';
  String get continueToRewards =>
      arabic ? 'اختر مكافأة عائلية' : 'Choose a family reward';
  String get rewardTitle =>
      arabic ? 'حوّل التقدم إلى مكافأة' : 'Turn progress into a reward';
  String get rewardDescription => arabic
      ? 'المكافآت تجعل اللعب والمهمات جزءًا من حياة العائلة.'
      : 'Rewards connect play and missions back to real family life.';
  String get rewardName =>
      arabic ? 'اختيار عشاء العائلة' : 'Choose Family Dinner';
  String get rewardDetail => arabic
      ? 'تختار سارة مكان عشاء الجمعة.'
      : 'Sara chooses where the family has Friday dinner.';
  String balanceReady(int tokens) => arabic
      ? 'رصيدكم $tokens رمزًا، والمكافأة جاهزة للاستبدال.'
      : 'Your $tokens Token balance is ready for this reward.';
  String get redeemReward => arabic ? 'استبدل 350 رمزًا' : 'Redeem 350 Tokens';
  String get rewardRedeemed => arabic
      ? 'تمت الموافقة: سارة تختار عشاء الجمعة.'
      : 'Approved: Sara chooses Friday dinner.';
  String get continueToMemory => arabic ? 'احفظ هذه الليلة' : 'Save this night';
  String get memoryTitle =>
      arabic ? 'حوّل اللحظة إلى ذكرى' : 'Turn the moment into a memory';
  String get memoryDescription => arabic
      ? 'لا تنتهي التجربة عند إعلان الفائز؛ بل تبقى في قصة العائلة.'
      : 'The experience does not end with a winner—it becomes part of the family story.';
  String get memoryName =>
      arabic ? 'ليلة تحدي عائلة النور' : 'Al Noor Family Challenge Night';
  String get memoryDetail => arabic
      ? 'مهمة، وضحكات، وبطلة، وعشاء اختارته العائلة معًا.'
      : 'One mission, plenty of laughter, a champion, and dinner chosen together.';
  String get saveMemory => arabic ? 'احفظ الذكرى' : 'Save family memory';
  String get completeTitle => arabic
      ? 'حلقة عائلية كاملة، وأثر حقيقي'
      : 'One complete family loop. Real impact.';
  String completeDescription(int tokens) => arabic
      ? 'تقاربت عائلة النور وحافظت على $tokens رمزًا للرحلة القادمة.'
      : 'The Al Noor Family connected and kept $tokens Tokens for their next journey.';
  String get metricMission => arabic ? 'مهمة مكتملة' : 'Mission completed';
  String get metricCompetition => arabic ? 'بطلة متوجة' : 'Champion crowned';
  String get metricReward => arabic ? 'مكافأة حقيقية' : 'Reward redeemed';
  String get metricMemory => arabic ? 'ذكرى محفوظة' : 'Memory saved';
  String get exploreSila =>
      arabic ? 'استكشف تطبيق صلة الكامل' : 'Explore the full Sila app';
  String get runAgain => arabic ? 'أعد العرض' : 'Run the story again';
}
