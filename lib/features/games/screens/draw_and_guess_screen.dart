import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../competitions/config/competition_games.dart';
import '../../competitions/models/competition_game_result.dart';
import '../../competitions/models/competition_player_result.dart';
import '../../competitions/models/game_play_mode.dart';
import '../services/draw_and_guess_ai_service.dart';
import '../widgets/game_setup_widgets.dart';

enum _DrawGamePhase {
  setup,
  passToArtist,
  revealPrompt,
  drawing,
  chooseGuesser,
  roundResult,
  finalLeaderboard,
}

enum _DrawLoadError { signedOut, noFamily, loadFailed }

class DrawAndGuessScreen extends StatefulWidget {
  const DrawAndGuessScreen({
    super.key,
    this.playMode = GamePlayMode.quickPlay,
    this.participantIds,
    this.developerPreview = false,
  });

  final GamePlayMode playMode;
  final Set<String>? participantIds;
  final bool developerPreview;

  @override
  State<DrawAndGuessScreen> createState() => _DrawAndGuessScreenState();
}

class _DrawAndGuessScreenState extends State<DrawAndGuessScreen> {
  final List<_DrawingStroke> _strokes = [];
  List<Offset> _currentStrokePoints = [];

  Color _selectedColor = Colors.black;
  double _selectedStrokeWidth = 4;
  bool _isEraser = false;

  Timer? _drawingTimer;
  int _secondsRemaining = 60;
  final _aiService = const DrawAndGuessAiService();

  final Map<String, int> _scores = {};

  String _roundResultMessage = '';

  bool _isPreparingGame = false;

  List<_DrawPlayer> _players = [];
  List<DrawAndGuessPrompt> _prompts = [];

  int _currentArtistIndex = 0;
  int _currentPromptIndex = 0;
  int _currentRound = 1;
  int _selectedRounds = 3;

  _DrawGamePhase _phase = _DrawGamePhase.setup;
  bool _isLoading = true;
  _DrawLoadError? _loadError;

  final List<_DrawPlayer> _familyMembers = [];
  final Set<String> _selectedPlayerIds = {};

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
      _DrawPlayer(id: 'preview-1', name: 'Alex'),
      _DrawPlayer(id: 'preview-2', name: 'Sam'),
      _DrawPlayer(id: 'preview-3', name: 'Jordan'),
      _DrawPlayer(id: 'preview-4', name: 'Taylor'),
    ];
    final availableMembers = widget.participantIds == null
        ? members
        : members
              .where((member) => widget.participantIds!.contains(member.id))
              .toList();
    _familyMembers.addAll(availableMembers);
    _selectedPlayerIds.addAll(availableMembers.map((member) => member.id));
    _isLoading = false;
  }

  @override
  void dispose() {
    _drawingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFamilyMembers() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _loadError = _DrawLoadError.signedOut;
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
          _loadError = _DrawLoadError.noFamily;
        });

        return;
      }

      final membersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('familyId', isEqualTo: familyId)
          .get();

      if (!mounted) {
        return;
      }
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

            return _DrawPlayer(
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

      if (!mounted) {
        return;
      }

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
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _loadError = _DrawLoadError.loadFailed;
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
    final strings = AppLocalizations.of(context)!;
    if (_selectedPlayerIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.minimumPlayersForGame(strings.drawAndGuess, 2)),
        ),
      );
      return;
    }

    setState(() {
      _isPreparingGame = true;
    });

    try {
      final selectedPlayers = _familyMembers
          .where((player) => _selectedPlayerIds.contains(player.id))
          .toList();
      _scores.clear();

      for (final player in selectedPlayers) {
        _scores[player.id] = 0;
      }

      final promptCount = selectedPlayers.length * _selectedRounds;
      final languageCode = Localizations.localeOf(context).languageCode;
      List<DrawAndGuessPrompt> prompts;

      if (widget.developerPreview) {
        prompts = DrawAndGuessAiService.offlinePrompts(
          count: promptCount,
          languageCode: languageCode,
        );
      } else {
        try {
          prompts = await _aiService.generatePrompts(
            count: promptCount,
            languageCode: languageCode,
          );
        } catch (_) {
          prompts = DrawAndGuessAiService.offlinePrompts(
            count: promptCount,
            languageCode: languageCode,
          );
        }
      }

      if (prompts.length < promptCount) {
        prompts = DrawAndGuessAiService.offlinePrompts(
          count: promptCount,
          languageCode: languageCode,
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _players = selectedPlayers;
        _prompts = prompts;

        _currentArtistIndex = 0;
        _currentPromptIndex = 0;
        _currentRound = 1;

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
        SnackBar(
          content: Text(strings.couldNotStartGame(strings.drawAndGuess)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(strings.drawAndGuess)),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    final strings = AppLocalizations.of(context)!;
    if (_phase == _DrawGamePhase.passToArtist) {
      return _buildPassToArtistScreen();
    }

    if (_phase == _DrawGamePhase.revealPrompt) {
      return _buildRevealPromptScreen();
    }
    if (_phase == _DrawGamePhase.drawing) {
      return _buildDrawingScreen();
    }
    if (_phase == _DrawGamePhase.chooseGuesser) {
      return _buildChooseGuesserScreen();
    }

    if (_phase == _DrawGamePhase.roundResult) {
      return _buildRoundResultScreen();
    }

    if (_phase == _DrawGamePhase.finalLeaderboard) {
      return _buildFinalLeaderboardScreen();
    }
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      final errorMessage = switch (_loadError!) {
        _DrawLoadError.signedOut => strings.mustBeLoggedInToPlay,
        _DrawLoadError.noFamily => strings.joinOrCreateFamilyBeforeGame(
          strings.drawAndGuess,
        ),
        _DrawLoadError.loadFailed => strings.couldNotLoadFamilyMembers,
      };
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64),
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
            strings.minimumFamilyMembersForGame(strings.drawAndGuess, 2),
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
            strings.whoIsPlaying,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            strings.chooseAtLeastTwoPlayers,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          GameRoundSelector(
            value: _selectedRounds,
            onChanged: (rounds) {
              setState(() {
                _selectedRounds = rounds;
              });
            },
            keyPrefix: 'drawing-round-option',
            description: strings.drawingTurnEachRound,
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
                    onChanged: widget.participantIds == null
                        ? (_) => _togglePlayer(player)
                        : null,
                    secondary: CircleAvatar(
                      child: Text(
                        player.name.isEmpty
                            ? '?'
                            : player.name[0].toUpperCase(),
                      ),
                    ),
                    title: Text(
                      player.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          Text(
            strings.selectedPlayersCount(_selectedPlayerIds.length),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          FilledButton.icon(
            onPressed: _selectedPlayerIds.length >= 2 && !_isPreparingGame
                ? _continueToGame
                : null,
            icon: const Icon(Icons.arrow_forward),
            label: Text(
              _isPreparingGame ? strings.preparingGame : strings.continueLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassToArtistScreen() {
    final artist = _players[_currentArtistIndex];
    final strings = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              strings.roundProgress(_currentRound, _selectedRounds),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            const Icon(Icons.lock_outline, size: 72),
            const SizedBox(height: 24),
            Text(
              strings.passPhoneTo(artist.name),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(strings.everyoneElseLookAway, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  setState(() {
                    _phase = _DrawGamePhase.revealPrompt;
                  });
                },
                child: Text(strings.iAmPlayer(artist.name)),
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
    final strings = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.draw_outlined, size: 72),
            const SizedBox(height: 20),
            Text(
              strings.artistDrawingPrompt(artist.name),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            Text(
              prompt.text,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(strings.rememberDrawingPrompt, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _startDrawing,
                icon: const Icon(Icons.brush_outlined),
                label: Text(strings.startDrawing),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startDrawing() {
    final strings = AppLocalizations.of(context)!;
    _drawingTimer?.cancel();

    setState(() {
      _strokes.clear();
      _currentStrokePoints = [];
      _secondsRemaining = 60;
      _phase = _DrawGamePhase.drawing;
    });

    _drawingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining <= 1) {
        timer.cancel();

        setState(() {
          _secondsRemaining = 0;
          _roundResultMessage = strings.drawingTimeUp;
          _phase = _DrawGamePhase.roundResult;
        });

        return;
      }

      setState(() {
        _secondsRemaining--;
      });
    });
  }

  Widget _buildDrawingScreen() {
    final artist = _players[_currentArtistIndex];
    final strings = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.playerIsDrawing(artist.name),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                strings.secondsRemaining(_secondsRemaining),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(strings.guessAloud, textAlign: TextAlign.center),

          const SizedBox(height: 16),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (details) {
                    setState(() {
                      _currentStrokePoints = [details.localPosition];
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _currentStrokePoints.add(details.localPosition);
                    });
                  },
                  onPanEnd: (_) {
                    if (_currentStrokePoints.isEmpty) {
                      return;
                    }

                    setState(() {
                      _strokes.add(
                        _DrawingStroke(
                          points: List.of(_currentStrokePoints),
                          color: _isEraser ? Colors.white : _selectedColor,
                          strokeWidth: _isEraser
                              ? _selectedStrokeWidth * 2
                              : _selectedStrokeWidth,
                        ),
                      );

                      _currentStrokePoints = [];
                    });
                  },
                  child: CustomPaint(
                    painter: _DrawingPainter(
                      strokes: _strokes,
                      currentStrokePoints: _currentStrokePoints,
                      currentColor: _isEraser ? Colors.white : _selectedColor,
                      currentStrokeWidth: _isEraser
                          ? _selectedStrokeWidth * 2
                          : _selectedStrokeWidth,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  [
                    Colors.black,
                    Colors.red,
                    Colors.blue,
                    Colors.green,
                    Colors.yellow,
                    Colors.purple,
                  ].map((color) {
                    final selected = !_isEraser && _selectedColor == color;

                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                            _isEraser = false;
                          });
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                              width: selected ? 4 : 1,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Text(strings.brush),
              const SizedBox(width: 12),

              for (final size in [2.0, 4.0, 8.0])
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(
                      size == 2
                          ? strings.thin
                          : size == 4
                          ? strings.medium
                          : strings.thick,
                    ),
                    selected: _selectedStrokeWidth == size,
                    onSelected: (_) {
                      setState(() {
                        _selectedStrokeWidth = size;
                      });
                    },
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: _strokes.isEmpty
                    ? null
                    : () {
                        setState(() {
                          _strokes.removeLast();
                        });
                      },
                icon: const Icon(Icons.undo),
                label: Text(strings.undo),
              ),

              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _isEraser = !_isEraser;
                  });
                },
                icon: const Icon(Icons.cleaning_services_outlined),
                label: Text(_isEraser ? strings.eraserOn : strings.eraser),
              ),

              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _strokes.clear();
                    _currentStrokePoints = [];
                  });
                },
                icon: const Icon(Icons.delete_outline),
                label: Text(strings.clear),
              ),

              FilledButton.icon(
                onPressed: _secondsRemaining > 0 ? _someoneGuessedIt : null,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(strings.someoneGuessedIt),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _someoneGuessedIt() {
    _drawingTimer?.cancel();

    setState(() {
      _phase = _DrawGamePhase.chooseGuesser;
    });
  }

  Widget _buildChooseGuesserScreen() {
    final artist = _players[_currentArtistIndex];
    final strings = AppLocalizations.of(context)!;

    final possibleGuessers = _players
        .where((player) => player.id != artist.id)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.whoGuessedIt,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(strings.chooseCorrectGuesser, textAlign: TextAlign.center),
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

  void _awardCorrectGuess(_DrawPlayer guesser) {
    final artist = _players[_currentArtistIndex];
    final strings = AppLocalizations.of(context)!;

    _scores[artist.id] = (_scores[artist.id] ?? 0) + 1;
    _scores[guesser.id] = (_scores[guesser.id] ?? 0) + 1;

    setState(() {
      _roundResultMessage = strings.drawingCorrectPoints(
        guesser.name,
        artist.name,
      );

      _phase = _DrawGamePhase.roundResult;
    });
  }

  Widget _buildRoundResultScreen() {
    final prompt = _prompts[_currentPromptIndex];
    final strings = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration_outlined, size: 72),
            const SizedBox(height: 20),

            Text(
              strings.roundComplete,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Text(_roundResultMessage, textAlign: TextAlign.center),

            const SizedBox(height: 24),

            Text(
              strings.promptLabel(prompt.text),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _continueAfterRound,
                child: Text(
                  _currentRound == _selectedRounds &&
                          _currentArtistIndex == _players.length - 1
                      ? strings.viewFinalLeaderboard
                      : _currentArtistIndex == _players.length - 1
                      ? strings.startRound(_currentRound + 1)
                      : strings.nextArtist,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _continueAfterRound() {
    final isLastArtist = _currentArtistIndex == _players.length - 1;
    final isLastRound = _currentRound == _selectedRounds;

    if (isLastArtist && isLastRound) {
      setState(() {
        _phase = _DrawGamePhase.finalLeaderboard;
      });

      return;
    }

    setState(() {
      if (isLastArtist) {
        _currentRound++;
        _currentArtistIndex = 0;
      } else {
        _currentArtistIndex++;
      }

      _currentPromptIndex = (_currentPromptIndex + 1) % _prompts.length;

      _strokes.clear();
      _currentStrokePoints = [];
      _secondsRemaining = 60;
      _roundResultMessage = '';

      _phase = _DrawGamePhase.passToArtist;
    });
  }

  CompetitionGameResult _buildCompetitionResult() {
    final leaderboard = [..._players];

    leaderboard.sort(
      (a, b) => (_scores[b.id] ?? 0).compareTo(_scores[a.id] ?? 0),
    );

    final results = <CompetitionPlayerResult>[];

    for (var index = 0; index < leaderboard.length; index++) {
      final player = leaderboard[index];

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
      gameId: CompetitionGameIds.drawAndGuess,
      gameName: 'Draw & Guess',
      players: results,
    );
  }

  Widget _buildFinalLeaderboardScreen() {
    final strings = AppLocalizations.of(context)!;
    final leaderboard = [..._players];

    leaderboard.sort(
      (a, b) => (_scores[b.id] ?? 0).compareTo(_scores[a.id] ?? 0),
    );

    final isOfficial = widget.playMode.isOfficial;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.emoji_events_outlined, size: 72),
          const SizedBox(height: 16),
          Text(
            strings.gameCompleteTitle(strings.drawAndGuess),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isOfficial
                ? strings.officialGameResultsReady
                : strings.quickPlayResultsOnly,
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
                    strings.pointsAbbreviation(score),
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
                  : strings.backToGames,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawingStroke {
  const _DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  final List<Offset> points;
  final Color color;
  final double strokeWidth;
}

class _DrawingPainter extends CustomPainter {
  const _DrawingPainter({
    required this.strokes,
    required this.currentStrokePoints,
    required this.currentColor,
    required this.currentStrokeWidth,
  });

  final List<_DrawingStroke> strokes;
  final List<Offset> currentStrokePoints;
  final Color currentColor;
  final double currentStrokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke.points, stroke.color, stroke.strokeWidth);
    }

    _drawStroke(canvas, currentStrokePoints, currentColor, currentStrokeWidth);
  }

  void _drawStroke(
    Canvas canvas,
    List<Offset> points,
    Color color,
    double width,
  ) {
    if (points.isEmpty) {
      return;
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (points.length == 1) {
      canvas.drawCircle(points.first, width / 2, paint);
      return;
    }

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) {
    return true;
  }
}

class _DrawPlayer {
  const _DrawPlayer({required this.id, required this.name});

  final String id;
  final String name;
}
