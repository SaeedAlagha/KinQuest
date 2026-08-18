import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../competitions/config/competition_games.dart';
import '../../competitions/models/competition_game_result.dart';
import '../../competitions/models/competition_player_result.dart';
import '../../competitions/models/game_play_mode.dart';
import '../services/dont_say_it_ai_service.dart';

enum _DontSayItPhase {
  setup,
  passToClueGiver,
  revealCard,
  playingTurn,
  chooseGuesser,
  turnResult,
  finalLeaderboard,
}

class DontSayItScreen extends StatefulWidget {
  const DontSayItScreen({
    super.key,
    this.playMode = GamePlayMode.quickPlay,
    this.participantIds,
  });

  final GamePlayMode playMode;
  final Set<String>? participantIds;

  @override
  State<DontSayItScreen> createState() => _DontSayItScreenState();
}

class _DontSayItScreenState extends State<DontSayItScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  bool get _hasLockedParticipants => widget.participantIds != null;

  bool get _isLockedHeadToHead =>
      widget.playMode.isOfficial &&
      widget.participantIds != null &&
      widget.participantIds!.length == 2;
  final List<_DontSayItPlayer> _familyMembers = [];
  final Set<String> _selectedPlayerIds = {};

  int _selectedRounds = 3;
  int _secondsPerTurn = 45;

  final _aiService = const DontSayItAiService();

  bool _isPreparingGame = false;

  List<_DontSayItPlayer> _players = [];
  List<DontSayItCard> _cards = [];

  int _currentCardIndex = 0;

  int _currentPlayerIndex = 0;
  int _currentRound = 1;

  _DontSayItPhase _phase = _DontSayItPhase.setup;

  Timer? _turnTimer;
  int _secondsRemaining = 0;

  final Map<String, int> _scores = {};

  String _turnResultMessage = '';

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    super.dispose();
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
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
          _errorMessage =
              'Join or create a family before playing Don\'t Say It.';
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

        return _DontSayItPlayer(
          id: document.id,
          name: name?.trim().isNotEmpty == true
              ? name!
              : email ?? 'Family Member',
        );
      }).toList();

      members.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      final availableMembers = widget.participantIds == null
          ? members
          : members
                .where((member) => widget.participantIds!.contains(member.id))
                .toList();
      if (!mounted) {
        return;
      }

      setState(() {
        _familyMembers
          ..clear()
          ..addAll(availableMembers);

        _selectedPlayerIds.clear();

        if (_hasLockedParticipants) {
          _selectedPlayerIds.addAll(
            availableMembers.map((member) => member.id),
          );
        }

        _isLoading = false;

        if (_hasLockedParticipants && availableMembers.length < 2) {
          _errorMessage =
              'This official Don\'t Say It match does not have enough valid family members.';
        } else {
          _errorMessage = null;
        }
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

  void _togglePlayer(_DontSayItPlayer player) {
    setState(() {
      if (_selectedPlayerIds.contains(player.id)) {
        _selectedPlayerIds.remove(player.id);
      } else {
        _selectedPlayerIds.add(player.id);
      }
    });
  }

  Future<void> _continueToGame() async {
    final selectedPlayers = _familyMembers
        .where((player) => _selectedPlayerIds.contains(player.id))
        .toList();

    if (selectedPlayers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Don\'t Say It needs at least 2 players.'),
        ),
      );
      return;
    }

    setState(() {
      _isPreparingGame = true;
    });

    try {
      _scores.clear();

      for (final player in selectedPlayers) {
        _scores[player.id] = 0;
      }

      final totalTurns = selectedPlayers.length * _selectedRounds;

      final cards = await _aiService.generateCards(count: totalTurns);

      if (cards.length < totalTurns) {
        throw Exception('Not enough cards generated');
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _players = selectedPlayers;
        _cards = cards;

        _currentPlayerIndex = 0;
        _currentCardIndex = 0;
        _currentRound = 1;

        _phase = _DontSayItPhase.passToClueGiver;
        _isPreparingGame = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cards.length} AI cards generated successfully.'),
        ),
      );

      // Private turn reveal comes next.
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isPreparingGame = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not prepare Don\'t Say It. Make sure the AI server is running.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Don\'t Say It')),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_phase == _DontSayItPhase.passToClueGiver) {
      return _buildPassToClueGiverScreen();
    }

    if (_phase == _DontSayItPhase.revealCard) {
      return _buildRevealCardScreen();
    }
    if (_phase == _DontSayItPhase.playingTurn) {
      return _buildPlayingTurnScreen();
    }

    if (_phase == _DontSayItPhase.chooseGuesser) {
      return _buildChooseGuesserScreen();
    }

    if (_phase == _DontSayItPhase.turnResult) {
      return _buildTurnResultScreen();
    }

    if (_phase == _DontSayItPhase.finalLeaderboard) {
      return _buildFinalLeaderboardScreen();
    }
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
              const Icon(Icons.error_outline, size: 64),
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

    return SingleChildScrollView(
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
          Text(
            'Choose at least 2 players.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),

          ..._familyMembers.map((player) {
            final selected = _selectedPlayerIds.contains(player.id);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                margin: EdgeInsets.zero,
                child: CheckboxListTile(
                  value: selected,
                  onChanged: _hasLockedParticipants
                      ? null
                      : (_) => _togglePlayer(player),
                  secondary: CircleAvatar(
                    child: Text(
                      player.name.isEmpty ? '?' : player.name[0].toUpperCase(),
                    ),
                  ),
                  title: Text(
                    player.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          Text(
            'How many rounds?',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [3, 5, 10].map((rounds) {
              return ChoiceChip(
                label: Text('$rounds rounds'),
                selected: _selectedRounds == rounds,
                onSelected: (_) {
                  setState(() {
                    _selectedRounds = rounds;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          Text(
            'Time per turn',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [30, 45, 60].map((seconds) {
              return ChoiceChip(
                label: Text('$seconds sec'),
                selected: _secondsPerTurn == seconds,
                onSelected: (_) {
                  setState(() {
                    _secondsPerTurn = seconds;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 30),

          FilledButton.icon(
            onPressed: _selectedPlayerIds.length >= 2 && !_isPreparingGame
                ? _continueToGame
                : null,
            icon: const Icon(Icons.play_arrow),
            label: Text(_isPreparingGame ? 'Preparing Game...' : 'Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildPassToClueGiverScreen() {
    final player = _players[_currentPlayerIndex];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 72),
            const SizedBox(height: 24),

            Text(
              'Pass the phone to ${player.name}',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(
              'Round $_currentRound of $_selectedRounds',
              style: Theme.of(context).textTheme.titleMedium,
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
                    _phase = _DontSayItPhase.revealCard;
                  });
                },
                child: Text('I\'m ${player.name}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevealCardScreen() {
    final player = _players[_currentPlayerIndex];
    final card = _cards[_currentCardIndex];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${player.name}, your word is:',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 16),

            Text(
              card.word,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 28),

            Text(
              'DON\'T SAY:',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            ...card.forbiddenWords.map(
              (word) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                  child: Text(
                    word,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Remember the card. Don\'t let anyone else see it.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _startTurn,
                icon: const Icon(Icons.timer_outlined),
                label: const Text('Start Turn'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startTurn() {
    _turnTimer?.cancel();

    setState(() {
      _secondsRemaining = _secondsPerTurn;
      _phase = _DontSayItPhase.playingTurn;
    });

    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining <= 1) {
        timer.cancel();

        setState(() {
          _secondsRemaining = 0;
          _turnResultMessage = 'Time\'s up! No points this turn.';
          _phase = _DontSayItPhase.turnResult;
        });

        return;
      }

      setState(() {
        _secondsRemaining--;
      });
    });
  }

  Widget _buildPlayingTurnScreen() {
    final player = _players[_currentPlayerIndex];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${player.name} is describing',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Text(
              '$_secondsRemaining s',
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            const Text(
              'Everyone else: guess aloud!',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _someoneGuessedIt,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Someone Guessed It'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _skipTurn,
                icon: const Icon(Icons.skip_next),
                label: const Text('Skip'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _someoneGuessedIt() {
    _turnTimer?.cancel();

    setState(() {
      _phase = _DontSayItPhase.chooseGuesser;
    });
  }

  void _skipTurn() {
    _turnTimer?.cancel();

    setState(() {
      _turnResultMessage = 'Turn skipped. No points awarded.';
      _phase = _DontSayItPhase.turnResult;
    });
  }

  Widget _buildChooseGuesserScreen() {
    final clueGiver = _players[_currentPlayerIndex];

    final possibleGuessers = _players
        .where((player) => player.id != clueGiver.id)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Who guessed it?',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          const Text(
            'Choose the player who guessed the secret word correctly.',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          Expanded(
            child: ListView.separated(
              itemCount: possibleGuessers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final player = possibleGuessers[index];

                return FilledButton.tonal(
                  onPressed: () => _awardCorrectGuess(player),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(player.name),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _awardCorrectGuess(_DontSayItPlayer guesser) {
    final clueGiver = _players[_currentPlayerIndex];

    if (_isLockedHeadToHead) {
      _scores[clueGiver.id] = (_scores[clueGiver.id] ?? 0) + 1;

      setState(() {
        _turnResultMessage =
            '${guesser.name} guessed correctly!\n\n'
            '${clueGiver.name} +1 point';

        _phase = _DontSayItPhase.turnResult;
      });

      return;
    }

    _scores[clueGiver.id] = (_scores[clueGiver.id] ?? 0) + 1;

    _scores[guesser.id] = (_scores[guesser.id] ?? 0) + 1;

    setState(() {
      _turnResultMessage =
          '${guesser.name} guessed correctly!\n\n'
          '${clueGiver.name} +1 point\n'
          '${guesser.name} +1 point';

      _phase = _DontSayItPhase.turnResult;
    });
  }

  Widget _buildTurnResultScreen() {
    final card = _cards[_currentCardIndex];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration_outlined, size: 72),

            const SizedBox(height: 20),

            Text(
              'Turn Complete',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Text(_turnResultMessage, textAlign: TextAlign.center),

            const SizedBox(height: 24),

            Text(
              'Secret word: ${card.word}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _continueAfterTurn,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _continueAfterTurn() {
    final isLastPlayer = _currentPlayerIndex == _players.length - 1;

    final isLastRound = _currentRound == _selectedRounds;

    if (isLastPlayer && isLastRound) {
      setState(() {
        _phase = _DontSayItPhase.finalLeaderboard;
      });

      return;
    }

    setState(() {
      _currentCardIndex++;
      _turnResultMessage = '';

      if (isLastPlayer) {
        _currentPlayerIndex = 0;
        _currentRound++;
      } else {
        _currentPlayerIndex++;
      }

      _phase = _DontSayItPhase.passToClueGiver;
    });
  }

  CompetitionGameResult _buildCompetitionResult() {
    final leaderboard = List<_DontSayItPlayer>.from(_players)
      ..sort((a, b) => (_scores[b.id] ?? 0).compareTo(_scores[a.id] ?? 0));

    final results = <CompetitionPlayerResult>[];

    int placement = 0;
    int? previousScore;

    for (var index = 0; index < leaderboard.length; index++) {
      final player = leaderboard[index];
      final score = _scores[player.id] ?? 0;

      if (previousScore == null || score != previousScore) {
        placement = index + 1;
      }

      results.add(
        CompetitionPlayerResult(
          userId: player.id,
          name: player.name,
          gameScore: score,
          placement: placement,
        ),
      );

      previousScore = score;
    }

    return CompetitionGameResult(
      gameId: CompetitionGameIds.dontSayIt,
      gameName: 'Don\'t Say It',
      players: results,
    );
  }

  Widget _buildFinalLeaderboardScreen() {
    final leaderboard = [..._players];

    leaderboard.sort(
      (a, b) => (_scores[b.id] ?? 0).compareTo(_scores[a.id] ?? 0),
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.emoji_events_outlined, size: 72),

          const SizedBox(height: 16),

          Text(
            'Don\'t Say It Complete!',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            widget.playMode.isOfficial
                ? '${widget.playMode.displayName} results are ready.'
                : 'Quick Play results only — no Tokens or official ranking.',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 28),

          Expanded(
            child: ListView.separated(
              itemCount: leaderboard.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final player = leaderboard[index];
                final score = _scores[player.id] ?? 0;

                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(
                    player.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Text(
                    '$score pts',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          FilledButton(
            onPressed: () {
              if (widget.playMode.isOfficial) {
                Navigator.of(context).pop(_buildCompetitionResult());
                return;
              }

              Navigator.of(context).pop();
            },
            child: Text(
              widget.playMode.isOfficial
                  ? 'Return to ${widget.playMode.displayName}'
                  : 'Back to Games',
            ),
          ),
        ],
      ),
    );
  }
}

class _DontSayItPlayer {
  const _DontSayItPlayer({required this.id, required this.name});

  final String id;
  final String name;
}
