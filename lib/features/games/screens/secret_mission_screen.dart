import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/sila_game_coach.dart';

import '../../../l10n/app_localizations.dart';
import '../services/secret_mission_ai_service.dart';
import '../widgets/game_setup_widgets.dart';
import '../../competitions/config/competition_games.dart';
import '../../competitions/models/competition_game_result.dart';
import '../../competitions/models/competition_player_result.dart';
import '../../competitions/models/game_play_mode.dart';
import '../widgets/game_exit_guard.dart';

enum _SecretMissionPhase {
  setup,
  privateReveal,
  missionPhase,
  judging,
  roundResults,
  leaderboard,
}

enum _SecretMissionLoadError { signedOut, noFamily, loadFailed }

class SecretMissionScreen extends StatefulWidget {
  const SecretMissionScreen({
    super.key,
    this.playMode = GamePlayMode.quickPlay,
    this.participantIds,
    this.developerPreview = false,
  });

  final GamePlayMode playMode;
  final Set<String>? participantIds;
  final bool developerPreview;

  @override
  State<SecretMissionScreen> createState() => _SecretMissionScreenState();
}

class _SecretMissionScreenState extends State<SecretMissionScreen> {
  static const Duration _roundDuration = Duration(minutes: 10);

  int _selectedRounds = 3;

  final _aiService = const SecretMissionAiService();

  final List<_MissionPlayer> _familyMembers = [];
  final Set<String> _selectedPlayerIds = {};

  List<_MissionPlayer> _players = [];
  List<SecretMission> _missions = [];

  final Map<String, bool> _completedMissions = {};
  final Map<String, int> _scores = {};

  bool _isLoading = true;
  bool _isGeneratingMissions = false;
  bool _missionVisible = false;

  _SecretMissionLoadError? _loadError;

  int _currentRound = 1;
  int _currentRevealIndex = 0;
  int _currentJudgeIndex = 0;

  Duration _timeRemaining = _roundDuration;
  DateTime? _roundEndsAt;
  Timer? _roundTimer;

  _SecretMissionPhase _phase = _SecretMissionPhase.setup;

  @override
  void initState() {
    super.initState();
    if (widget.developerPreview) {
      _loadPreviewMembers();
    } else {
      _loadFamilyMembers();
    }
  }

  void _loadPreviewMembers() {
    const members = [
      _MissionPlayer(id: 'preview-1', name: 'Alex'),
      _MissionPlayer(id: 'preview-2', name: 'Sam'),
      _MissionPlayer(id: 'preview-3', name: 'Jordan'),
      _MissionPlayer(id: 'preview-4', name: 'Taylor'),
    ];
    final availableMembers = widget.participantIds == null
        ? members
        : members
              .where((member) => widget.participantIds!.contains(member.id))
              .toList();

    _familyMembers
      ..clear()
      ..addAll(availableMembers);
    _selectedPlayerIds
      ..clear()
      ..addAll(availableMembers.map((member) => member.id));
    _isLoading = false;
  }

  @override
  void dispose() {
    _roundTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFamilyMembers() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _loadError = _SecretMissionLoadError.signedOut;
      });
      return;
    }

    try {
      final userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final familyId = userDocument.data()?['familyId'] as String?;

      if (familyId == null || familyId.isEmpty) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _loadError = _SecretMissionLoadError.noFamily;
        });

        return;
      }

      final membersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('familyId', isEqualTo: familyId)
          .get();

      if (!mounted) return;
      final strings = AppLocalizations.of(context)!;
      final members = membersSnapshot.docs
          .where(
            (document) =>
                widget.participantIds == null ||
                widget.participantIds!.contains(document.id),
          )
          .map((document) {
            final data = document.data();

            final name = data['name'] as String?;
            final email = data['email'] as String?;

            return _MissionPlayer(
              id: document.id,
              name: name?.trim().isNotEmpty == true
                  ? name!
                  : email ?? strings.familyMemberFallback,
            );
          })
          .toList();

      members.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      if (!mounted) return;

      setState(() {
        _familyMembers
          ..clear()
          ..addAll(members);

        _selectedPlayerIds
          ..clear()
          ..addAll(widget.participantIds ?? members.map((member) => member.id));

        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadError = _SecretMissionLoadError.loadFailed;
      });
    }
  }

  void _togglePlayer(_MissionPlayer player) {
    setState(() {
      if (_selectedPlayerIds.contains(player.id)) {
        _selectedPlayerIds.remove(player.id);
      } else {
        _selectedPlayerIds.add(player.id);
      }
    });
  }

  Future<List<SecretMission>> _generateOrderedMissions(
    List<_MissionPlayer> players,
  ) async {
    final playerNames = players.map((player) => player.name).toList();
    final languageCode = Localizations.localeOf(context).languageCode;
    final offlineMissions = SecretMissionAiService.offlineMissions(
      playerNames: playerNames,
      languageCode: languageCode,
    );

    if (widget.developerPreview) {
      return _orderMissions(players, offlineMissions);
    }

    try {
      final generatedMissions = await _aiService.generateMissions(
        playerNames: playerNames,
        languageCode: languageCode,
      );

      return _orderMissions(players, generatedMissions);
    } catch (_) {
      return _orderMissions(players, offlineMissions);
    }
  }

  List<SecretMission> _orderMissions(
    List<_MissionPlayer> players,
    List<SecretMission> generatedMissions,
  ) {
    if (generatedMissions.length != players.length) {
      throw Exception('Mission count mismatch');
    }

    final remainingMissions = List<SecretMission>.from(generatedMissions);
    final orderedMissions = <SecretMission>[];

    for (final player in players) {
      final missionIndex = remainingMissions.indexWhere(
        (mission) =>
            mission.playerName.trim().toLowerCase() ==
            player.name.trim().toLowerCase(),
      );

      if (missionIndex == -1) {
        throw Exception('Missing mission for ${player.name}');
      }

      final mission = remainingMissions.removeAt(missionIndex);

      if (mission.mission.trim().isEmpty) {
        throw Exception('Empty mission');
      }

      orderedMissions.add(mission);
    }

    return orderedMissions;
  }

  Future<void> _startGame() async {
    final strings = AppLocalizations.of(context)!;
    if (_selectedPlayerIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.minimumPlayersForGame(strings.secretMission, 2),
          ),
        ),
      );

      return;
    }

    setState(() {
      _isGeneratingMissions = true;
    });

    try {
      final selectedPlayers = _familyMembers
          .where((player) => _selectedPlayerIds.contains(player.id))
          .toList();

      final orderedMissions = await _generateOrderedMissions(selectedPlayers);

      final scores = <String, int>{};

      for (final player in selectedPlayers) {
        scores[player.id] = 0;
      }

      if (!mounted) return;

      setState(() {
        _players = selectedPlayers;
        _missions = orderedMissions;

        _scores
          ..clear()
          ..addAll(scores);

        _completedMissions.clear();

        _currentRound = 1;
        _currentRevealIndex = 0;
        _currentJudgeIndex = 0;

        _missionVisible = false;
        _timeRemaining = _roundDuration;

        _phase = _SecretMissionPhase.privateReveal;
        _isGeneratingMissions = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isGeneratingMissions = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.couldNotGenerateMissions)));
    }
  }

  Future<void> _startNextRound() async {
    final strings = AppLocalizations.of(context)!;
    if (_currentRound >= _selectedRounds || _isGeneratingMissions) {
      return;
    }

    setState(() {
      _isGeneratingMissions = true;
    });

    try {
      final orderedMissions = await _generateOrderedMissions(_players);

      if (!mounted) return;

      setState(() {
        _currentRound++;

        _missions = orderedMissions;
        _completedMissions.clear();

        _currentRevealIndex = 0;
        _currentJudgeIndex = 0;

        _missionVisible = false;
        _timeRemaining = _roundDuration;

        _phase = _SecretMissionPhase.privateReveal;
        _isGeneratingMissions = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isGeneratingMissions = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.couldNotGenerateNextRound)),
      );
    }
  }

  void _showMission() {
    setState(() {
      _missionVisible = true;
    });
  }

  void _hideAndPass() {
    if (_currentRevealIndex + 1 >= _players.length) {
      setState(() {
        _missionVisible = false;
        _phase = _SecretMissionPhase.missionPhase;
      });

      _startRoundTimer();
      return;
    }

    setState(() {
      _currentRevealIndex++;
      _missionVisible = false;
    });
  }

  void _startRoundTimer() {
    _roundTimer?.cancel();

    _roundEndsAt = DateTime.now().add(_roundDuration);

    setState(() {
      _timeRemaining = _roundDuration;
    });

    _roundTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateRoundTimer(),
    );
  }

  void _updateRoundTimer() {
    final endsAt = _roundEndsAt;

    if (endsAt == null || !mounted) {
      return;
    }

    final remaining = endsAt.difference(DateTime.now());

    if (remaining <= Duration.zero) {
      _roundTimer?.cancel();
      _roundTimer = null;
      _roundEndsAt = null;

      setState(() {
        _timeRemaining = Duration.zero;
      });

      _startJudging();

      final strings = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.missionTimeUp)));

      return;
    }

    setState(() {
      _timeRemaining = remaining;
    });
  }

  Future<void> _finishRoundEarly() async {
    final strings = AppLocalizations.of(context)!;
    final shouldFinish = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.finishRoundEarlyTitle),
          content: Text(strings.finishRoundEarlyDescription),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(strings.keepPlaying),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(strings.finishRound),
            ),
          ],
        );
      },
    );

    if (shouldFinish != true || !mounted) {
      return;
    }

    _startJudging();
  }

  void _startJudging() {
    _roundTimer?.cancel();
    _roundTimer = null;
    _roundEndsAt = null;

    setState(() {
      _currentJudgeIndex = 0;
      _phase = _SecretMissionPhase.judging;
    });
  }

  void _judgeMission(bool completed) {
    final player = _players[_currentJudgeIndex];

    _completedMissions[player.id] = completed;

    if (completed) {
      _scores[player.id] = (_scores[player.id] ?? 0) + 1;
    }

    if (_currentJudgeIndex + 1 >= _players.length) {
      setState(() {
        _phase = _currentRound >= _selectedRounds
            ? _SecretMissionPhase.leaderboard
            : _SecretMissionPhase.roundResults;
      });

      return;
    }

    setState(() {
      _currentJudgeIndex++;
    });
  }

  void _playAgain() {
    _roundTimer?.cancel();
    _roundTimer = null;
    _roundEndsAt = null;

    setState(() {
      _phase = _SecretMissionPhase.setup;

      _players = [];
      _missions = [];

      _completedMissions.clear();
      _scores.clear();

      _selectedPlayerIds.clear();

      _currentRound = 1;
      _currentRevealIndex = 0;
      _currentJudgeIndex = 0;

      _missionVisible = false;
      _timeRemaining = _roundDuration;
      _isGeneratingMissions = false;
    });
  }

  String get _formattedTime {
    final totalSeconds = _timeRemaining.inSeconds.clamp(
      0,
      _roundDuration.inSeconds,
    );

    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  double get _timerProgress {
    return (_timeRemaining.inMilliseconds / _roundDuration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final gameInProgress =
        _phase != _SecretMissionPhase.setup &&
        _phase != _SecretMissionPhase.leaderboard;
    final showSila = _phase != _SecretMissionPhase.setup;

    return GameExitGuard(
      gameInProgress: gameInProgress,
      child: Scaffold(
        floatingActionButton: showSila
            ? SilaGameCoachButton(
                tone: switch (_phase) {
                  _SecretMissionPhase.judging => SilaGameCoachTone.thinking,
                  _SecretMissionPhase.roundResults =>
                    SilaGameCoachTone.celebrating,
                  _SecretMissionPhase.leaderboard => SilaGameCoachTone.winner,
                  _ => SilaGameCoachTone.play,
                },
              )
            : null,
        appBar: AppBar(title: Text(strings.secretMission)),
        body: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    switch (_phase) {
      case _SecretMissionPhase.setup:
        return _buildSetupScreen();

      case _SecretMissionPhase.privateReveal:
        return _buildPrivateRevealScreen();

      case _SecretMissionPhase.missionPhase:
        return _buildMissionPhaseScreen();

      case _SecretMissionPhase.judging:
        return _buildJudgingScreen();

      case _SecretMissionPhase.roundResults:
        return _buildRoundResultsScreen();

      case _SecretMissionPhase.leaderboard:
        return _buildLeaderboardScreen();
    }
  }

  Widget _buildSetupScreen() {
    final strings = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      final errorMessage = switch (_loadError!) {
        _SecretMissionLoadError.signedOut => strings.mustBeLoggedInToPlay,
        _SecretMissionLoadError.noFamily =>
          strings.joinOrCreateFamilyBeforeGame(strings.secretMission),
        _SecretMissionLoadError.loadFailed => strings.couldNotLoadFamilyMembers,
      };
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _loadError = null;
                  });

                  _loadFamilyMembers();
                },
                child: Text(strings.tryAgain),
              ),
            ],
          ),
        ),
      );
    }

    if (_familyMembers.length < 2) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            strings.minimumFamilyMembersForGame(strings.secretMission, 2),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Text(
                  strings.whoIsPlaying,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(strings.chooseMissionPlayers),
                const SizedBox(height: 18),
                SilaGameCoachBanner(message: strings.mascotGameSetupMessage),
                const SizedBox(height: 18),
                Text(strings.secretMissionSetupSummary(_selectedRounds)),
                const SizedBox(height: 10),
                Text(strings.secretMissionSetupInstructions),
                const SizedBox(height: 18),
                GameRoundSelector(
                  value: _selectedRounds,
                  onChanged: (rounds) {
                    setState(() {
                      _selectedRounds = rounds;
                    });
                  },
                  keyPrefix: 'mission-round-option',
                ),
                const SizedBox(height: 24),
                for (final player in _familyMembers) ...[
                  Card(
                    child: CheckboxListTile(
                      value: _selectedPlayerIds.contains(player.id),
                      onChanged: widget.participantIds == null
                          ? (_) => _togglePlayer(player)
                          : null,
                      title: Text(player.name),
                      secondary: CircleAvatar(
                        child: Text(
                          player.name.isEmpty
                              ? '?'
                              : player.name[0].toUpperCase(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isGeneratingMissions ? null : _startGame,
            icon: _isGeneratingMissions
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.visibility_off_rounded),
            label: Text(
              _isGeneratingMissions
                  ? strings.generatingRound(1)
                  : strings.startNamedGame(strings.secretMission),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivateRevealScreen() {
    final player = _players[_currentRevealIndex];
    final mission = _missions[_currentRevealIndex];
    final strings = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Text(
                strings.roundProgress(_currentRound, _selectedRounds),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                strings.playerProgress(
                  _currentRevealIndex + 1,
                  _players.length,
                ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              const Icon(Icons.visibility_off_rounded, size: 72),
              const SizedBox(height: 20),
              Text(
                strings.takeThePhone(player.name),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(strings.keepScreenPrivate, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              if (!_missionVisible)
                FilledButton.icon(
                  onPressed: _showMission,
                  icon: const Icon(Icons.visibility_rounded),
                  label: Text(strings.revealMyMission),
                ),
              if (_missionVisible) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        Text(
                          strings.yourSecretMission,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          mission.mission,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(strings.rememberMission, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _hideAndPass,
                  icon: const Icon(Icons.phone_android_rounded),
                  label: Text(
                    _currentRevealIndex + 1 >= _players.length
                        ? strings.hideMissionStartRound
                        : strings.hideMissionPassPhone,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionPhaseScreen() {
    final strings = AppLocalizations.of(context)!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Column(
            children: [
              Text(
                strings.roundProgress(_currentRound, _selectedRounds),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 22),
              const Icon(Icons.psychology_alt_rounded, size: 82),
              const SizedBox(height: 20),
              Text(
                strings.missionsAreLive,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                strings.missionsLiveInstructions,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      Text(strings.timeRemaining, textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      Text(
                        _formattedTime,
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 18),
                      LinearProgressIndicator(
                        value: _timerProgress,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(strings.missionAutoJudge, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _finishRoundEarly,
                icon: const Icon(Icons.flag_rounded),
                label: Text(strings.finishRoundEarly),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJudgingScreen() {
    final player = _players[_currentJudgeIndex];
    final mission = _missions[_currentJudgeIndex];
    final strings = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Column(
            children: [
              Text(
                strings.roundProgress(_currentRound, _selectedRounds),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                strings.judgeProgress(_currentJudgeIndex + 1, _players.length),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              Text(
                player.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    mission.mission,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                strings.missionCompletedQuestion,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _judgeMission(false),
                      icon: const Icon(Icons.close_rounded),
                      label: Text(strings.notCompleted),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _judgeMission(true),
                      icon: const Icon(Icons.check_rounded),
                      label: Text(strings.completedPlusOne),
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

  Widget _buildRoundResultsScreen() {
    final strings = AppLocalizations.of(context)!;
    final rankedPlayers = List<_MissionPlayer>.from(_players);

    rankedPlayers.sort(
      (a, b) => (_scores[b.id] ?? 0).compareTo(_scores[a.id] ?? 0),
    );

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          strings.roundNumberComplete(_currentRound),
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          strings.roundsRemaining(_selectedRounds - _currentRound),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ...List.generate(rankedPlayers.length, (index) {
          final player = rankedPlayers[index];
          final score = _scores[player.id] ?? 0;
          final completed = _completedMissions[player.id] ?? false;

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(
                  completed ? Icons.check_rounded : Icons.close_rounded,
                ),
              ),
              title: Text(player.name),
              subtitle: Text(
                completed
                    ? strings.missionCompletedThisRound
                    : strings.missionNotCompletedThisRound,
              ),
              trailing: Text(
                strings.pointsAbbreviation(score),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _isGeneratingMissions ? null : _startNextRound,
          icon: _isGeneratingMissions
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.arrow_forward_rounded),
          label: Text(
            _isGeneratingMissions
                ? strings.generatingRound(_currentRound + 1)
                : strings.startRound(_currentRound + 1),
          ),
        ),
      ],
    );
  }

  CompetitionGameResult _buildCompetitionResult() {
    final rankedPlayers = List<_MissionPlayer>.from(_players);

    rankedPlayers.sort(
      (a, b) => (_scores[b.id] ?? 0).compareTo(_scores[a.id] ?? 0),
    );

    final results = <CompetitionPlayerResult>[];

    for (var index = 0; index < rankedPlayers.length; index++) {
      final player = rankedPlayers[index];

      results.add(
        CompetitionPlayerResult(
          userId: player.id,
          name: player.name,
          gameScore: _scores[player.id] ?? 0,
          placement: index + 1,
        ),
      );
    }

    return CompetitionGameResult(
      gameId: CompetitionGameIds.secretMission,
      gameName: 'Secret Mission',
      players: results,
    );
  }

  Widget _buildLeaderboardScreen() {
    final strings = AppLocalizations.of(context)!;
    final rankedPlayers = List<_MissionPlayer>.from(_players);

    rankedPlayers.sort(
      (a, b) => (_scores[b.id] ?? 0).compareTo(_scores[a.id] ?? 0),
    );

    final highestScore = rankedPlayers.isEmpty
        ? 0
        : (_scores[rankedPlayers.first.id] ?? 0);

    final winnerCount = rankedPlayers
        .where((player) => (_scores[player.id] ?? 0) == highestScore)
        .length;

    final isOfficial = widget.playMode.isOfficial;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.emoji_events_rounded, size: 72),
        const SizedBox(height: 16),
        Text(
          strings.officialResultsTitle(strings.secretMission),
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          winnerCount > 1
              ? strings.gameTie
              : strings.playerWins(rankedPlayers.first.name),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          isOfficial
              ? strings.officialGameResultsReady
              : strings.quickPlayResultsOnly,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ...List.generate(rankedPlayers.length, (index) {
          final player = rankedPlayers[index];
          final score = _scores[player.id] ?? 0;

          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(player.name),
              subtitle: Text(
                strings.missionProgressSummary(score, _selectedRounds),
              ),
              trailing: Text(
                strings.pointsAbbreviation(score),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }),
        const SizedBox(height: 24),

        if (!isOfficial) ...[
          FilledButton.icon(
            onPressed: _playAgain,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(strings.playAgain),
          ),
          const SizedBox(height: 10),
        ],

        OutlinedButton(
          onPressed: () {
            if (isOfficial) {
              Navigator.of(context).pop(_buildCompetitionResult());
              return;
            }

            Navigator.of(context).pop();
          },
          child: Text(
            isOfficial
                ? strings.returnToCompetition(
                    widget.playMode.localizedName(strings),
                  )
                : strings.backToQuickPlay,
          ),
        ),
      ],
    );
  }
}

class _MissionPlayer {
  const _MissionPlayer({required this.id, required this.name});

  final String id;
  final String name;
}
