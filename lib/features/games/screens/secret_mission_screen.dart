import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/secret_mission_ai_service.dart';

enum _SecretMissionPhase {
  setup,
  privateReveal,
  missionPhase,
  judging,
  leaderboard,
}

class SecretMissionScreen extends StatefulWidget {
  const SecretMissionScreen({super.key});

  @override
  State<SecretMissionScreen> createState() => _SecretMissionScreenState();
}

class _SecretMissionScreenState extends State<SecretMissionScreen> {
  final _aiService = const SecretMissionAiService();

  final List<_MissionPlayer> _familyMembers = [];
  final Set<String> _selectedPlayerIds = {};

  List<_MissionPlayer> _players = [];
  List<SecretMission> _missions = [];

  final Map<String, bool> _completedMissions = {};
  final Map<String, int> _scores = {};

  bool _isLoading = true;
  bool _isStartingGame = false;
  bool _missionVisible = false;

  String? _errorMessage;

  int _currentRevealIndex = 0;
  int _currentJudgeIndex = 0;

  _SecretMissionPhase _phase = _SecretMissionPhase.setup;

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  Future<void> _loadFamilyMembers() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'You must be logged in to play.';
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
          _errorMessage = 'Join or create a family before playing.';
        });

        return;
      }

      final membersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('familyId', isEqualTo: familyId)
          .get();

      final members = membersSnapshot.docs.map((document) {
        final data = document.data();

        final name = data['name'] as String?;
        final email = data['email'] as String?;

        return _MissionPlayer(
          id: document.id,
          name: name?.trim().isNotEmpty == true
              ? name!
              : email ?? 'Family Member',
        );
      }).toList();

      members.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      if (!mounted) return;

      setState(() {
        _familyMembers
          ..clear()
          ..addAll(members);

        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load your family members.';
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

  Future<void> _startGame() async {
    if (_selectedPlayerIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Secret Mission needs at least 2 players.'),
        ),
      );

      return;
    }

    setState(() {
      _isStartingGame = true;
    });

    try {
      final selectedPlayers = _familyMembers
          .where((player) => _selectedPlayerIds.contains(player.id))
          .toList();

      final generatedMissions = await _aiService.generateMissions(
        playerNames: selectedPlayers.map((player) => player.name).toList(),
        languageCode: 'en',
      );

      if (generatedMissions.length != selectedPlayers.length) {
        throw Exception('Mission count mismatch');
      }

      final remainingMissions = List<SecretMission>.from(generatedMissions);

      final orderedMissions = <SecretMission>[];

      for (final player in selectedPlayers) {
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

        _currentRevealIndex = 0;
        _currentJudgeIndex = 0;

        _missionVisible = false;

        _phase = _SecretMissionPhase.privateReveal;
        _isStartingGame = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isStartingGame = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not generate Secret Missions. Make sure the AI server is running.',
          ),
        ),
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

      return;
    }

    setState(() {
      _currentRevealIndex++;
      _missionVisible = false;
    });
  }

  void _startJudging() {
    setState(() {
      _currentJudgeIndex = 0;
      _phase = _SecretMissionPhase.judging;
    });
  }

  void _judgeMission(bool completed) {
    final player = _players[_currentJudgeIndex];

    _completedMissions[player.id] = completed;
    _scores[player.id] = completed ? 1 : 0;

    if (_currentJudgeIndex + 1 >= _players.length) {
      setState(() {
        _phase = _SecretMissionPhase.leaderboard;
      });

      return;
    }

    setState(() {
      _currentJudgeIndex++;
    });
  }

  void _playAgain() {
    setState(() {
      _phase = _SecretMissionPhase.setup;

      _players = [];
      _missions = [];

      _completedMissions.clear();
      _scores.clear();

      _selectedPlayerIds.clear();

      _currentRevealIndex = 0;
      _currentJudgeIndex = 0;

      _missionVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secret Mission')),
      body: SafeArea(child: _buildBody()),
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

      case _SecretMissionPhase.leaderboard:
        return _buildLeaderboardScreen();
    }
  }

  Widget _buildSetupScreen() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });

                  _loadFamilyMembers();
                },
                child: const Text('Try Again'),
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
            'Secret Mission needs at least 2 family members.',
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
          Text(
            'Who is playing?',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose the family members playing together on this phone.',
          ),
          const SizedBox(height: 10),
          const Text(
            'Each player will secretly receive a mission. Do not let anyone else see yours.',
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: _familyMembers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final player = _familyMembers[index];

                final selected = _selectedPlayerIds.contains(player.id);

                return Card(
                  child: CheckboxListTile(
                    value: selected,
                    onChanged: (_) => _togglePlayer(player),
                    title: Text(player.name),
                    secondary: CircleAvatar(
                      child: Text(
                        player.name.isEmpty
                            ? '?'
                            : player.name[0].toUpperCase(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isStartingGame ? null : _startGame,
            icon: _isStartingGame
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.visibility_off_rounded),
            label: Text(
              _isStartingGame
                  ? 'Generating secret missions...'
                  : 'Start Secret Mission',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivateRevealScreen() {
    final player = _players[_currentRevealIndex];
    final mission = _missions[_currentRevealIndex];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Text(
                'Mission ${_currentRevealIndex + 1} of ${_players.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              const Icon(Icons.visibility_off_rounded, size: 72),
              const SizedBox(height: 20),
              Text(
                '${player.name}, take the phone',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Make sure nobody else can see the screen.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (!_missionVisible)
                FilledButton.icon(
                  onPressed: _showMission,
                  icon: const Icon(Icons.visibility_rounded),
                  label: const Text('Reveal My Mission'),
                ),
              if (_missionVisible) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        const Text(
                          'YOUR SECRET MISSION',
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
                const Text(
                  'Remember it. Do not tell anyone.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _hideAndPass,
                  icon: const Icon(Icons.phone_android_rounded),
                  label: Text(
                    _currentRevealIndex + 1 >= _players.length
                        ? 'Hide Mission & Start'
                        : 'Hide Mission & Pass Phone',
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
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Column(
            children: [
              const Icon(Icons.psychology_alt_rounded, size: 82),
              const SizedBox(height: 20),
              Text(
                'Missions are live!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Put the phone down and act naturally. Try to complete your mission without anyone figuring it out.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'When everyone is ready, come back and reveal the missions.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _startJudging,
                icon: const Icon(Icons.fact_check_rounded),
                label: const Text('Reveal & Judge Missions'),
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

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Column(
            children: [
              Text(
                'Mission ${_currentJudgeIndex + 1} of ${_players.length}',
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
              const Text(
                'Did they successfully complete the mission?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _judgeMission(false),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Not Completed'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _judgeMission(true),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Completed'),
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

  Widget _buildLeaderboardScreen() {
    final rankedPlayers = List<_MissionPlayer>.from(_players);

    rankedPlayers.sort(
      (a, b) => (_scores[b.id] ?? 0).compareTo(_scores[a.id] ?? 0),
    );

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Secret Mission Results',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Quick Play session only — no Tokens or official ranking changes.',
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
                score == 1 ? 'Mission completed' : 'Mission not completed',
              ),
              trailing: Text(
                '$score pt',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _playAgain,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Play Again'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to Quick Play'),
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
