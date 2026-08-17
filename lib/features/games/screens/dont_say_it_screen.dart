import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/dont_say_it_ai_service.dart';

enum _DontSayItPhase {
  setup,
  passToClueGiver,
  revealCard,
}

class DontSayItScreen extends StatefulWidget {
  const DontSayItScreen({super.key});

  @override
  State<DontSayItScreen> createState() => _DontSayItScreenState();
}

class _DontSayItScreenState extends State<DontSayItScreen> {
  bool _isLoading = true;
  String? _errorMessage;

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
  if (_selectedPlayerIds.length < 2) {
    
    return;
  }

  setState(() {
    _isPreparingGame = true;
  });

  try {
    final selectedPlayers = _familyMembers
        .where(
          (player) => _selectedPlayerIds.contains(player.id),
        )
        .toList();

    final totalTurns =
        selectedPlayers.length * _selectedRounds;

    final cards = await _aiService.generateCards(
      count: totalTurns,
    );

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
        content: Text(
          '${cards.length} AI cards generated successfully.',
        ),
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
      appBar: AppBar(
        title: const Text('Don\'t Say It'),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_phase == _DontSayItPhase.passToClueGiver) {
   return _buildPassToClueGiverScreen();
  }

    if (_phase == _DontSayItPhase.revealCard) {
  return _buildRevealCardScreen();
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

    return SingleChildScrollView(
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
            'Choose at least 2 players, including yourself if you\'re playing.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),

          ..._familyMembers.map((player) {
            final selected =
                _selectedPlayerIds.contains(player.id);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
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
              ),
            );
          }),

          const SizedBox(height: 24),

          Text(
            'How many rounds?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
            label: Text(
                _isPreparingGame
                    ? 'Preparing Game...'
                    : 'Continue',
            ),
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
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 28),

          Text(
            'DON\'T SAY:',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
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
              onPressed: () {
                // Timer/game turn comes next.
              },
              icon: const Icon(Icons.timer_outlined),
              label: const Text('Start Turn'),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class _DontSayItPlayer {
  const _DontSayItPlayer({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}