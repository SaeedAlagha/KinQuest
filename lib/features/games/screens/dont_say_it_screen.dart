import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/sila_game_coach.dart';

import '../../../l10n/app_localizations.dart';
import '../../competitions/config/competition_games.dart';
import '../../competitions/models/competition_game_result.dart';
import '../../competitions/models/competition_player_result.dart';
import '../../competitions/models/game_play_mode.dart';
import '../services/dont_say_it_ai_service.dart';
import '../widgets/game_setup_widgets.dart';
import '../widgets/game_exit_guard.dart';

enum _DontSayItPhase {
  setup,
  passToClueGiver,
  revealCard,
  playingTurn,
  chooseGuesser,
  turnResult,
  finalLeaderboard,
}

enum _DontSayItLoadError { signedOut, noFamily, invalidPlayers, loadFailed }

class DontSayItScreen extends StatefulWidget {
  const DontSayItScreen({
    super.key,
    this.playMode = GamePlayMode.quickPlay,
    this.participantIds,
    this.developerPreview = false,
  });

  final GamePlayMode playMode;
  final Set<String>? participantIds;
  final bool developerPreview;

  @override
  State<DontSayItScreen> createState() => _DontSayItScreenState();
}

class _DontSayItScreenState extends State<DontSayItScreen> {
  bool _isLoading = true;
  _DontSayItLoadError? _loadError;
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
    if (widget.developerPreview) {
      _loadPreviewMembers();
    } else {
      _loadFamilyMembers();
    }
  }

  void _loadPreviewMembers() {
    const members = [
      _DontSayItPlayer(id: 'preview-1', name: 'Alex'),
      _DontSayItPlayer(id: 'preview-2', name: 'Sam'),
      _DontSayItPlayer(id: 'preview-3', name: 'Jordan'),
      _DontSayItPlayer(id: 'preview-4', name: 'Taylor'),
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
    _turnTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFamilyMembers() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _loadError = _DontSayItLoadError.signedOut;
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
          _loadError = _DontSayItLoadError.noFamily;
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
      final members = membersSnapshot.docs.map((document) {
        final data = document.data();

        final name = data['name'] as String?;
        final email = data['email'] as String?;

        return _DontSayItPlayer(
          id: document.id,
          name: name?.trim().isNotEmpty == true
              ? name!
              : email ?? strings.familyMemberFallback,
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
          _loadError = _DontSayItLoadError.invalidPlayers;
        } else {
          _loadError = null;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _loadError = _DontSayItLoadError.loadFailed;
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
    final strings = AppLocalizations.of(context)!;
    final selectedPlayers = _familyMembers
        .where((player) => _selectedPlayerIds.contains(player.id))
        .toList();

    if (selectedPlayers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.minimumPlayersForGame(strings.dontSayIt, 2)),
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
      final languageCode = Localizations.localeOf(context).languageCode;
      List<DontSayItCard> cards;

      if (widget.developerPreview) {
        cards = DontSayItAiService.offlineCards(
          count: totalTurns,
          languageCode: languageCode,
        );
      } else {
        try {
          cards = await _aiService.generateCards(
            count: totalTurns,
            languageCode: languageCode,
          );
        } catch (_) {
          cards = DontSayItAiService.offlineCards(
            count: totalTurns,
            languageCode: languageCode,
          );
        }
      }

      if (cards.length < totalTurns) {
        cards = DontSayItAiService.offlineCards(
          count: totalTurns,
          languageCode: languageCode,
        );
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

      // Private turn reveal comes next.
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isPreparingGame = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.couldNotStartGame(strings.dontSayIt))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final gameInProgress =
        _phase != _DontSayItPhase.setup &&
        _phase != _DontSayItPhase.finalLeaderboard;

    return GameExitGuard(
      gameInProgress: gameInProgress,
      child: Scaffold(
        floatingActionButton: gameInProgress
            ? SilaGameCoachButton(
                tone: _phase == _DontSayItPhase.turnResult
                    ? SilaGameCoachTone.celebrating
                    : SilaGameCoachTone.play,
              )
            : null,
        appBar: AppBar(title: Text(strings.dontSayIt)),
        body: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    final strings = AppLocalizations.of(context)!;
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

    if (_loadError != null) {
      final errorMessage = switch (_loadError!) {
        _DontSayItLoadError.signedOut => strings.mustBeLoggedInToPlay,
        _DontSayItLoadError.noFamily => strings.joinOrCreateFamilyBeforeGame(
          strings.dontSayIt,
        ),
        _DontSayItLoadError.invalidPlayers =>
          strings.officialMatchInvalidPlayers(strings.dontSayIt),
        _DontSayItLoadError.loadFailed => strings.couldNotLoadFamilyMembers,
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SilaGameCoachBanner(message: strings.mascotGameSetupMessage),
          const SizedBox(height: 20),
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

          GameRoundSelector(
            value: _selectedRounds,
            onChanged: (rounds) {
              setState(() {
                _selectedRounds = rounds;
              });
            },
          ),

          const SizedBox(height: 28),

          Text(
            strings.timePerTurn,
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
                label: Text(strings.secondsShort(seconds)),
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
              _isPreparingGame ? strings.preparingGame : strings.continueLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassToClueGiverScreen() {
    final player = _players[_currentPlayerIndex];
    final strings = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 72),
            const SizedBox(height: 24),

            Text(
              strings.passPhoneTo(player.name),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(
              strings.roundProgress(_currentRound, _selectedRounds),
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 12),

            Text(strings.everyoneElseLookAway, textAlign: TextAlign.center),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  setState(() {
                    _phase = _DontSayItPhase.revealCard;
                  });
                },
                child: Text(strings.iAmPlayer(player.name)),
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
    final strings = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              strings.playerSecretWord(player.name),
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
              strings.dontSayHeading,
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

            Text(strings.rememberWordCard, textAlign: TextAlign.center),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _startTurn,
                icon: const Icon(Icons.timer_outlined),
                label: Text(strings.startTurn),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startTurn() {
    final strings = AppLocalizations.of(context)!;
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
          _turnResultMessage = strings.turnTimeUp;
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
    final strings = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              strings.playerIsDescribing(player.name),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Text(
              strings.secondsRemaining(_secondsRemaining),
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            Text(strings.guessAloud, textAlign: TextAlign.center),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _someoneGuessedIt,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(strings.someoneGuessedIt),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _skipTurn,
                icon: const Icon(Icons.skip_next),
                label: Text(strings.skip),
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
    final strings = AppLocalizations.of(context)!;
    _turnTimer?.cancel();

    setState(() {
      _turnResultMessage = strings.turnSkipped;
      _phase = _DontSayItPhase.turnResult;
    });
  }

  Widget _buildChooseGuesserScreen() {
    final clueGiver = _players[_currentPlayerIndex];
    final strings = AppLocalizations.of(context)!;

    final possibleGuessers = _players
        .where((player) => player.id != clueGiver.id)
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

          Text(strings.chooseSecretWordGuesser, textAlign: TextAlign.center),

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
    final strings = AppLocalizations.of(context)!;

    if (_isLockedHeadToHead) {
      _scores[clueGiver.id] = (_scores[clueGiver.id] ?? 0) + 1;

      setState(() {
        _turnResultMessage = strings.clueGiverPointResult(
          guesser.name,
          clueGiver.name,
        );

        _phase = _DontSayItPhase.turnResult;
      });

      return;
    }

    _scores[clueGiver.id] = (_scores[clueGiver.id] ?? 0) + 1;

    _scores[guesser.id] = (_scores[guesser.id] ?? 0) + 1;

    setState(() {
      _turnResultMessage = strings.sharedPointResult(
        guesser.name,
        clueGiver.name,
      );

      _phase = _DontSayItPhase.turnResult;
    });
  }

  Widget _buildTurnResultScreen() {
    final card = _cards[_currentCardIndex];
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
              strings.turnComplete,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Text(_turnResultMessage, textAlign: TextAlign.center),

            const SizedBox(height: 24),

            Text(
              strings.secretWordLabel(card.word),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _continueAfterTurn,
                child: Text(strings.continueLabel),
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
    final strings = AppLocalizations.of(context)!;
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
            strings.gameCompleteTitle(strings.dontSayIt),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            widget.playMode.isOfficial
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
              if (widget.playMode.isOfficial) {
                Navigator.of(context).pop(_buildCompetitionResult());
                return;
              }

              Navigator.of(context).pop();
            },
            child: Text(
              widget.playMode.isOfficial
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

class _DontSayItPlayer {
  const _DontSayItPlayer({required this.id, required this.name});

  final String id;
  final String name;
}
