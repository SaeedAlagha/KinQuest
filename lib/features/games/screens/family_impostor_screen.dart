import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../services/family_impostor_ai_service.dart';

enum _GamePhase {
  setup,
  passDevice,
  revealRole,
}

class FamilyImpostorScreen extends StatefulWidget {
  const FamilyImpostorScreen({super.key});

  @override
  State<FamilyImpostorScreen> createState() => _FamilyImpostorScreenState();
}

class _FamilyImpostorScreenState extends State<FamilyImpostorScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  final List<_FamilyPlayer> _familyMembers = [];
  final Set<String> _selectedPlayerIds = {};
  final _aiService = const FamilyImpostorAiService();

  bool _isStartingGame = false;

  List<_FamilyPlayer> _players = [];
  List<FamilyImpostorRound> _rounds = [];

  int _currentRoundIndex = 0;
  int _currentRevealPlayerIndex = 0;

  String? _impostorPlayerId;

  _GamePhase _phase = _GamePhase.setup;

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

        return _FamilyPlayer(
          id: document.id,
          name: name?.trim().isNotEmpty == true
              ? name!
              : email ?? 'Family Member',
        );
      }).toList();

      members.sort(
        (a, b) => a.name.toLowerCase().compareTo(
              b.name.toLowerCase(),
            ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _familyMembers
          ..clear()
          ..addAll(members);

        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load your family members.';
      });
    }
  }

  void _togglePlayer(_FamilyPlayer player) {
    setState(() {
      if (_selectedPlayerIds.contains(player.id)) {
        _selectedPlayerIds.remove(player.id);
      } else {
        _selectedPlayerIds.add(player.id);
      }
    });
  }

  Future<void> _startGame() async {
  if (_selectedPlayerIds.length < 3) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Family Impostor needs at least 3 players.',
        ),
      ),
    );
    return;
  }

  setState(() {
    _isStartingGame = true;
  });

  try {
    final selectedPlayers = _familyMembers
        .where(
          (player) => _selectedPlayerIds.contains(player.id),
        )
        .toList();

    final rounds = await _aiService.generateRounds(
      count: 5,
    );

    if (rounds.isEmpty) {
      throw Exception('No rounds generated');
    }

    final random = Random.secure();

    final impostor =
        selectedPlayers[random.nextInt(selectedPlayers.length)];

    if (!mounted) {
      return;
    }

    setState(() {
      _players = selectedPlayers;
      _rounds = rounds;

      _currentRoundIndex = 0;
      _currentRevealPlayerIndex = 0;

      _impostorPlayerId = impostor.id;

      _phase = _GamePhase.passDevice;
      _isStartingGame = false;
    });
  } catch (_) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isStartingGame = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Could not start Family Impostor. Make sure the AI server is running.',
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Impostor'),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
     if (_phase == _GamePhase.passDevice) {
      return _buildPassDeviceScreen();
    }

    if (_phase == _GamePhase.revealRole) {
      return _buildRoleRevealScreen();
    }
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
              ),
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

    if (_familyMembers.length < 3) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Family Impostor needs at least 3 family members.',
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
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose at least 3 family members who are together with you.',
            style: Theme.of(context).textTheme.bodyLarge,
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
                  margin: EdgeInsets.zero,
                  child: CheckboxListTile(
                    value: selected,
                    onChanged: (_) => _togglePlayer(player),
                    secondary: CircleAvatar(
                      child: Text(
                        player.name.isEmpty
                            ? '?'
                            : player.name[0].toUpperCase(),
                      ),
                    ),
                    title: Text(
                      player.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          Text(
            '${_selectedPlayerIds.length} selected',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

                    FilledButton.icon(
            onPressed:
                _selectedPlayerIds.length >= 3 && !_isStartingGame
                    ? _startGame
                    : null,
            icon: _isStartingGame
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(
              _isStartingGame
                  ? 'Preparing Game...'
                  : 'Start Game',
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPassDeviceScreen() {
  final player = _players[_currentRevealPlayerIndex];

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lock_outline,
            size: 72,
          ),
          const SizedBox(height: 24),

          Text(
            'Pass the phone to ${player.name}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Everyone else should look away.',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                setState(() {
                  _phase = _GamePhase.revealRole;
                });
              },
              child: Text(
                'I\'m ${player.name}',
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildRoleRevealScreen() {
  final player = _players[_currentRevealPlayerIndex];
  final round = _rounds[_currentRoundIndex];

  final isImpostor = player.id == _impostorPlayerId;

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Round ${_currentRoundIndex + 1}',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 24),

          if (isImpostor) ...[
            const Icon(
              Icons.visibility_off_outlined,
              size: 72,
            ),

            const SizedBox(height: 20),

            Text(
              'You are the IMPOSTOR',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 14),

            Text(
              'Category: ${round.category}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 10),

            const Text(
              'You do not know the secret word.\nBlend in and avoid getting caught.',
              textAlign: TextAlign.center,
            ),
          ] else ...[
            const Icon(
              Icons.key_outlined,
              size: 72,
            ),

            const SizedBox(height: 20),

            Text(
              'Category',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 6),

            Text(
              round.category,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Secret word',
            ),

            const SizedBox(height: 6),

            Text(
              round.word,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 14),

            const Text(
              'Remember it. Do not show anyone else.',
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 36),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _finishRoleReveal,
              child: const Text('Hide My Role'),
            ),
          ),
        ],
      ),
    ),
  );
}

void _finishRoleReveal() {
  final isLastPlayer =
      _currentRevealPlayerIndex == _players.length - 1;

  if (isLastPlayer) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Everyone has seen their role. Clue round is next.',
        ),
      ),
    );

    // We will replace this with the clue round next.
    return;
  }

  setState(() {
    _currentRevealPlayerIndex++;
    _phase = _GamePhase.passDevice;
  });
}
}

class _FamilyPlayer {
  const _FamilyPlayer({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}