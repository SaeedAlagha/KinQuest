import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/draw_and_guess_ai_service.dart';

enum _DrawGamePhase {
  setup,
  passToArtist,
  revealPrompt,
}
class DrawAndGuessScreen extends StatefulWidget {
  const DrawAndGuessScreen({super.key});

  @override
  State<DrawAndGuessScreen> createState() => _DrawAndGuessScreenState();
}


class _DrawAndGuessScreenState extends State<DrawAndGuessScreen> {
  final _aiService = const DrawAndGuessAiService();

  bool _isPreparingGame = false;

  List<_DrawPlayer> _players = [];
  List<DrawAndGuessPrompt> _prompts = [];

  int _currentArtistIndex = 0;
  int _currentPromptIndex = 0;

  _DrawGamePhase _phase = _DrawGamePhase.setup;
    bool _isLoading = true;
    String? _errorMessage;

  final List<_DrawPlayer> _familyMembers = [];
  final Set<String> _selectedPlayerIds = {};

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
              'Join or create a family before playing Draw & Guess.';
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

        return _DrawPlayer(
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

  void _togglePlayer(_DrawPlayer player) {
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Draw & Guess needs at least 2 players.',
        ),
      ),
    );
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

    final prompts = await _aiService.generatePrompts(
      count: 6,
    );

    if (prompts.isEmpty) {
      throw Exception('No prompts generated');
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _players = selectedPlayers;
      _prompts = prompts;

      _currentArtistIndex = 0;
      _currentPromptIndex = 0;

      _phase = _DrawGamePhase.passToArtist;
      _isPreparingGame = false;
    });
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
          'Could not prepare Draw & Guess. Make sure the AI server is running.',
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw & Guess'),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_phase == _DrawGamePhase.passToArtist) {
  return _buildPassToArtistScreen();
}

if (_phase == _DrawGamePhase.revealPrompt) {
  return _buildRevealPromptScreen();
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

    if (_familyMembers.length < 2) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Draw & Guess needs at least 2 family members.',
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
            'Choose at least 2 family members who are together with you.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView.separated(
              itemCount: _familyMembers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final player = _familyMembers[index];

                final selected =
                    _selectedPlayerIds.contains(player.id);

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
            onPressed: _selectedPlayerIds.length >= 2 && !_isPreparingGame
            ? _continueToGame
            : null,
            icon: const Icon(Icons.arrow_forward),
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
  Widget _buildPassToArtistScreen() {
  final artist = _players[_currentArtistIndex];

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
            'Pass the phone to ${artist.name}',
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
                  _phase = _DrawGamePhase.revealPrompt;
                });
              },
              child: Text(
                'I\'m ${artist.name}',
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildRevealPromptScreen() {
  final artist = _players[_currentArtistIndex];
  final prompt = _prompts[_currentPromptIndex];

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.draw_outlined,
            size: 72,
          ),
          const SizedBox(height: 20),
          Text(
            '${artist.name}, your drawing prompt is:',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          Text(
            prompt.text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Remember the prompt. Do not show it to the other players.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Drawing canvas is next.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.brush_outlined),
              label: const Text('Start Drawing'),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class _DrawPlayer {
  const _DrawPlayer({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}