import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/sila_game_coach.dart';

import '../../../l10n/app_localizations.dart';
import '../../competitions/config/competition_games.dart';
import '../../competitions/models/competition_game_result.dart';
import '../../competitions/models/competition_player_result.dart';
import '../../competitions/models/game_play_mode.dart';
import '../services/family_impostor_ai_service.dart';
import '../utils/game_localization.dart';
import '../widgets/game_setup_widgets.dart';
import '../widgets/game_exit_guard.dart';

enum _GamePhase {
  setup,
  passDevice,
  revealRole,
  clueRound,
  clueDecision,
  votePassDevice,
  voting,
  voteResults,
  impostorGuess,
  roundResult,
  finalLeaderboard,
}

enum _FamilyImpostorLoadError { signedOut, noFamily, loadFailed }

class FamilyImpostorScreen extends StatefulWidget {
  const FamilyImpostorScreen({
    super.key,
    this.playMode = GamePlayMode.quickPlay,
    this.participantIds,
    this.developerPreview = false,
  });

  final GamePlayMode playMode;
  final Set<String>? participantIds;
  final bool developerPreview;
  @override
  State<FamilyImpostorScreen> createState() => _FamilyImpostorScreenState();
}

class _FamilyImpostorScreenState extends State<FamilyImpostorScreen> {
  bool _isLoading = true;
  _FamilyImpostorLoadError? _loadError;

  final List<_FamilyPlayer> _familyMembers = [];
  final Set<String> _selectedPlayerIds = {};
  final _aiService = const FamilyImpostorAiService();
  String? _selectedCategory;
  int _selectedRounds = 3;

  bool _isStartingGame = false;

  List<_FamilyPlayer> _players = [];
  List<FamilyImpostorRound> _rounds = [];

  int _currentRoundIndex = 0;
  int _currentRevealPlayerIndex = 0;
  int _clueRoundNumber = 1;
  int _currentVoterIndex = 0;

  final Map<String, String> _votes = {};

  final Map<String, int> _scores = {};

  bool? _impostorWonRound;
  String _roundResultMessage = '';

  final _impostorGuessController = TextEditingController();

  String? _impostorPlayerId;

  _GamePhase _phase = _GamePhase.setup;

  @override
  void initState() {
    super.initState();
    if (widget.developerPreview) {
      _loadPreviewMembers();
    } else {
      _loadFamilyMembers();
    }
  }

  @override
  void dispose() {
    _impostorGuessController.dispose();
    super.dispose();
  }

  void _loadPreviewMembers() {
    const members = [
      _FamilyPlayer(id: 'preview-1', name: 'Alex'),
      _FamilyPlayer(id: 'preview-2', name: 'Sam'),
      _FamilyPlayer(id: 'preview-3', name: 'Jordan'),
      _FamilyPlayer(id: 'preview-4', name: 'Taylor'),
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

  Future<void> _loadFamilyMembers() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _loadError = _FamilyImpostorLoadError.signedOut;
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
          _loadError = _FamilyImpostorLoadError.noFamily;
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

        return _FamilyPlayer(
          id: document.id,
          name: name?.trim().isNotEmpty == true
              ? name!
              : email ?? strings.familyMemberFallback,
        );
      }).toList();

      members.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      if (!mounted) {
        return;
      }
      final availableMembers = widget.participantIds == null
          ? members
          : members
                .where((member) => widget.participantIds!.contains(member.id))
                .toList();
      setState(() {
        _familyMembers
          ..clear()
          ..addAll(availableMembers);

        _selectedPlayerIds
          ..clear()
          ..addAll(
            widget.participantIds ??
                availableMembers.map((member) => member.id),
          );

        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _loadError = _FamilyImpostorLoadError.loadFailed;
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
    final strings = AppLocalizations.of(context)!;
    if (_selectedPlayerIds.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.minimumPlayersForGame(strings.familyImpostor, 3),
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
          .where((player) => _selectedPlayerIds.contains(player.id))
          .toList();
      _scores.clear();

      for (final player in selectedPlayers) {
        _scores[player.id] = 0;
      }

      final rounds = await _aiService.generateRounds(
        count: _selectedRounds,
        category: _selectedCategory,
        languageCode: Localizations.localeOf(context).languageCode,
      );

      if (rounds.isEmpty) {
        throw Exception('No rounds generated');
      }

      final random = Random.secure();

      final impostor = selectedPlayers[random.nextInt(selectedPlayers.length)];

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
        SnackBar(
          content: Text(strings.couldNotStartGame(strings.familyImpostor)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final gameInProgress =
        _phase != _GamePhase.setup && _phase != _GamePhase.finalLeaderboard;
    final showSila = _phase != _GamePhase.setup;

    return GameExitGuard(
      gameInProgress: gameInProgress,
      child: Scaffold(
        floatingActionButton: showSila
            ? SilaGameCoachButton(
                tone: switch (_phase) {
                  _GamePhase.voteResults ||
                  _GamePhase.roundResult => SilaGameCoachTone.celebrating,
                  _GamePhase.finalLeaderboard => SilaGameCoachTone.winner,
                  _ => SilaGameCoachTone.play,
                },
              )
            : null,
        appBar: AppBar(title: Text(strings.familyImpostor)),
        body: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    final strings = AppLocalizations.of(context)!;
    if (_phase == _GamePhase.passDevice) {
      return _buildPassDeviceScreen();
    }

    if (_phase == _GamePhase.revealRole) {
      return _buildRoleRevealScreen();
    }
    if (_phase == _GamePhase.clueRound) {
      return _buildClueRoundScreen();
    }

    if (_phase == _GamePhase.clueDecision) {
      return _buildClueDecisionScreen();
    }
    if (_phase == _GamePhase.votePassDevice) {
      return _buildVotePassDeviceScreen();
    }

    if (_phase == _GamePhase.voting) {
      return _buildVotingScreen();
    }

    if (_phase == _GamePhase.voteResults) {
      return _buildVoteResultsScreen();
    }
    if (_phase == _GamePhase.impostorGuess) {
      return _buildImpostorGuessScreen();
    }

    if (_phase == _GamePhase.roundResult) {
      return _buildRoundResultScreen();
    }

    if (_phase == _GamePhase.finalLeaderboard) {
      return _buildFinalLeaderboardScreen();
    }
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      final errorMessage = switch (_loadError!) {
        _FamilyImpostorLoadError.signedOut => strings.mustBeLoggedInToPlay,
        _FamilyImpostorLoadError.noFamily =>
          strings.joinOrCreateFamilyBeforeGame(strings.familyImpostor),
        _FamilyImpostorLoadError.loadFailed =>
          strings.couldNotLoadFamilyMembers,
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

    if (_familyMembers.length < 3) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            strings.minimumFamilyMembersForGame(strings.familyImpostor, 3),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          strings.impostorSetupTitle,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          strings.impostorSetupDescription,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        SilaGameCoachBanner(message: strings.mascotGameSetupMessage),
        const SizedBox(height: 18),
        _buildCategoryPicker(),
        const SizedBox(height: 18),
        GameRoundSelector(
          value: _selectedRounds,
          onChanged: (rounds) {
            setState(() {
              _selectedRounds = rounds;
            });
          },
          keyPrefix: 'impostor-round-option',
        ),
        const SizedBox(height: 28),
        Text(
          strings.whoIsPlaying,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          strings.chooseAtLeastThreePlayers,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        ..._familyMembers.map((player) {
          final selected = _selectedPlayerIds.contains(player.id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              margin: EdgeInsets.zero,
              child: CheckboxListTile(
                value: selected,
                onChanged: widget.participantIds == null
                    ? (_) => _togglePlayer(player)
                    : null,
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
        const SizedBox(height: 6),
        Text(
          strings.selectedPlayersCount(_selectedPlayerIds.length),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _selectedPlayerIds.length >= 3 && !_isStartingGame
              ? _startGame
              : null,
          icon: _isStartingGame
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.play_arrow),
          label: Text(
            _isStartingGame ? strings.preparingGame : strings.startGame,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPicker() {
    final colors = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context)!;

    return Card(
      margin: EdgeInsets.zero,
      color: colors.primaryContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category_rounded, color: colors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    strings.chooseCategory,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  key: const Key('impostor-category-random'),
                  avatar: const Icon(Icons.shuffle_rounded, size: 18),
                  label: Text(strings.randomMix),
                  selected: _selectedCategory == null,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                ),
                ...FamilyImpostorAiService.categories.map(
                  (category) => ChoiceChip(
                    key: ValueKey('impostor-category-$category'),
                    label: Text(localizedGameCategory(strings, category)),
                    selected: _selectedCategory == category,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _selectedCategory == null
                  ? strings.randomMixDescription
                  : strings.selectedCategoryDescription(
                      localizedGameCategory(strings, _selectedCategory!),
                    ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassDeviceScreen() {
    final player = _players[_currentRevealPlayerIndex];
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

            Text(strings.everyoneElseLookAway, textAlign: TextAlign.center),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  setState(() {
                    _phase = _GamePhase.revealRole;
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

  Widget _buildRoleRevealScreen() {
    final player = _players[_currentRevealPlayerIndex];
    final round = _rounds[_currentRoundIndex];
    final strings = AppLocalizations.of(context)!;

    final isImpostor = player.id == _impostorPlayerId;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              strings.roundNumber(_currentRoundIndex + 1),
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 24),

            if (isImpostor) ...[
              const Icon(Icons.visibility_off_outlined, size: 72),

              const SizedBox(height: 20),

              Text(
                strings.youAreTheImpostor,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                strings.categoryLabel(round.category),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),

              const SizedBox(height: 10),

              Text(
                strings.impostorRoleInstructions,
                textAlign: TextAlign.center,
              ),
            ] else ...[
              const Icon(Icons.key_outlined, size: 72),

              const SizedBox(height: 20),

              Text(
                strings.category,
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

              Text(strings.secretWord),

              const SizedBox(height: 6),

              Text(
                round.word,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              Text(strings.rememberSecretWord, textAlign: TextAlign.center),
            ],

            const SizedBox(height: 36),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _finishRoleReveal,
                child: Text(strings.hideMyRole),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _finishRoleReveal() {
    final isLastPlayer = _currentRevealPlayerIndex == _players.length - 1;

    if (isLastPlayer) {
      setState(() {
        _clueRoundNumber = 1;
        _phase = _GamePhase.clueRound;
      });

      return;
    }

    setState(() {
      _currentRevealPlayerIndex++;
      _phase = _GamePhase.passDevice;
    });
  }

  Widget _buildClueRoundScreen() {
    final round = _rounds[_currentRoundIndex];
    final strings = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.record_voice_over_outlined, size: 72),
            const SizedBox(height: 20),

            Text(
              strings.clueRoundNumber(_clueRoundNumber),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(
              strings.categoryLabel(round.category),
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 24),

            Text(strings.takeTurnsGivingClues, textAlign: TextAlign.center),

            const SizedBox(height: 10),

            Text(strings.clueRules, textAlign: TextAlign.center),

            const SizedBox(height: 10),

            Text(
              strings.impostorBluffInstructions,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  setState(() {
                    _phase = _GamePhase.clueDecision;
                  });
                },
                child: Text(strings.everyoneGaveClue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClueDecisionScreen() {
    final canContinue = _clueRoundNumber < 3;
    final strings = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.psychology_alt_outlined, size: 72),
            const SizedBox(height: 20),

            Text(
              strings.knowTheImpostorQuestion,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(
              strings.clueRoundComplete(_clueRoundNumber),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            if (canContinue) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _clueRoundNumber++;
                      _phase = _GamePhase.clueRound;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(strings.anotherClueRound),
                ),
              ),

              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _votes.clear();
                    _currentVoterIndex = 0;
                    _phase = _GamePhase.votePassDevice;
                  });
                },
                icon: const Icon(Icons.how_to_vote_outlined),
                label: Text(strings.startVoting),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVotePassDeviceScreen() {
    final voter = _players[_currentVoterIndex];
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
              strings.passPhoneTo(voter.name),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(strings.privateVoteInstructions, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  setState(() {
                    _phase = _GamePhase.voting;
                  });
                },
                child: Text(strings.iAmPlayer(voter.name)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVotingScreen() {
    final voter = _players[_currentVoterIndex];
    final strings = AppLocalizations.of(context)!;

    final candidates = _players
        .where((player) => player.id != voter.id)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.whoIsTheImpostor(voter.name),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(strings.votingInstructions, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: candidates.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final candidate = candidates[index];

                return FilledButton.tonal(
                  onPressed: () => _submitVote(
                    voterId: voter.id,
                    votedPlayerId: candidate.id,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(candidate.name),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _submitVote({required String voterId, required String votedPlayerId}) {
    _votes[voterId] = votedPlayerId;

    final isLastVoter = _currentVoterIndex == _players.length - 1;

    if (isLastVoter) {
      setState(() {
        _phase = _GamePhase.voteResults;
      });

      return;
    }

    setState(() {
      _currentVoterIndex++;
      _phase = _GamePhase.votePassDevice;
    });
  }

  Widget _buildVoteResultsScreen() {
    final strings = AppLocalizations.of(context)!;
    final voteCounts = <String, int>{};

    for (final votedPlayerId in _votes.values) {
      voteCounts.update(
        votedPlayerId,
        (currentcount) => currentcount + 1,
        ifAbsent: () => 1,
      );
    }

    final sortedPlayers = [..._players];

    sortedPlayers.sort((a, b) {
      final aVotes = voteCounts[a.id] ?? 0;
      final bVotes = voteCounts[b.id] ?? 0;

      return bVotes.compareTo(aVotes);
    });

    final topPlayer = sortedPlayers.first;
    final topVotes = voteCounts[topPlayer.id] ?? 0;

    final tiedTopPlayers = sortedPlayers
        .where((player) => (voteCounts[player.id] ?? 0) == topVotes)
        .toList();

    final hasTie = tiedTopPlayers.length > 1;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.voteResults,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView.separated(
              itemCount: sortedPlayers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final player = sortedPlayers[index];
                final votes = voteCounts[player.id] ?? 0;

                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(player.name),
                  trailing: Text(strings.voteCount(votes)),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          if (hasTie)
            FilledButton(
              onPressed: () {
                setState(() {
                  _votes.clear();
                  _currentVoterIndex = 0;
                  _phase = _GamePhase.votePassDevice;
                });
              },
              child: Text(strings.tieVoteAgain),
            )
          else
            FilledButton(
              onPressed: () {
                _revealVotedPlayer(topPlayer);
              },
              child: Text(strings.revealPlayer(topPlayer.name)),
            ),
        ],
      ),
    );
  }

  void _revealVotedPlayer(_FamilyPlayer player) {
    final strings = AppLocalizations.of(context)!;
    final isActuallyImpostor = player.id == _impostorPlayerId;

    if (isActuallyImpostor) {
      _impostorGuessController.clear();

      setState(() {
        _phase = _GamePhase.impostorGuess;
      });

      return;
    }

    final impostor = _players.firstWhere(
      (player) => player.id == _impostorPlayerId,
    );

    _scores[impostor.id] = (_scores[impostor.id] ?? 0) + 2;

    setState(() {
      _impostorWonRound = true;
      _roundResultMessage = strings.innocentImpostorEscaped(
        player.name,
        impostor.name,
      );
      _phase = _GamePhase.roundResult;
    });
  }

  Widget _buildImpostorGuessScreen() {
    final impostor = _players.firstWhere(
      (player) => player.id == _impostorPlayerId,
    );

    final round = _rounds[_currentRoundIndex];
    final strings = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 72),
            const SizedBox(height: 20),

            Text(
              strings.impostorWasCaught,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(
              strings.playerIsImpostor(impostor.name),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 24),

            Text(
              strings.categoryLabel(round.category),
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 12),

            Text(strings.impostorFinalChance, textAlign: TextAlign.center),

            const SizedBox(height: 24),

            TextField(
              controller: _impostorGuessController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: strings.secretWord,
                prefixIcon: const Icon(Icons.key_outlined),
              ),
              onSubmitted: (_) => _submitImpostorGuess(),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitImpostorGuess,
                child: Text(strings.submitGuess),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitImpostorGuess() {
    final strings = AppLocalizations.of(context)!;
    final guess = _impostorGuessController.text.trim().toLowerCase();

    if (guess.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.enterGuessFirst)));

      return;
    }

    final round = _rounds[_currentRoundIndex];

    final correctWord = round.word.trim().toLowerCase();

    final impostor = _players.firstWhere(
      (player) => player.id == _impostorPlayerId,
    );

    if (guess == correctWord) {
      _scores[impostor.id] = (_scores[impostor.id] ?? 0) + 1;

      setState(() {
        _impostorWonRound = true;
        _roundResultMessage = strings.caughtButGuessedCorrectly(
          impostor.name,
          round.word,
        );
        _phase = _GamePhase.roundResult;
      });

      return;
    }

    for (final player in _players) {
      if (player.id != _impostorPlayerId) {
        _scores[player.id] = (_scores[player.id] ?? 0) + 1;
      }
    }

    setState(() {
      _impostorWonRound = false;
      _roundResultMessage = strings.incorrectImpostorGuess(
        impostor.name,
        guess,
        round.word,
      );
      _phase = _GamePhase.roundResult;
    });
  }

  Widget _buildRoundResultScreen() {
    final round = _rounds[_currentRoundIndex];
    final strings = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _impostorWonRound == true
                  ? Icons.visibility_off_rounded
                  : Icons.groups_rounded,
              size: 72,
            ),

            const SizedBox(height: 20),

            Text(
              _impostorWonRound == true
                  ? strings.impostorWins
                  : strings.familyWins,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Text(_roundResultMessage, textAlign: TextAlign.center),

            const SizedBox(height: 24),

            Text(
              strings.secretWordLabel(round.word),
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
                  _currentRoundIndex == _rounds.length - 1
                      ? strings.viewFinalLeaderboard
                      : strings.nextRound,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _continueAfterRound() {
    final isLastRound = _currentRoundIndex == _rounds.length - 1;

    if (isLastRound) {
      setState(() {
        _phase = _GamePhase.finalLeaderboard;
      });

      return;
    }

    final random = Random.secure();

    final newImpostor = _players[random.nextInt(_players.length)];

    setState(() {
      _currentRoundIndex++;

      _currentRevealPlayerIndex = 0;
      _currentVoterIndex = 0;

      _votes.clear();

      _impostorWonRound = null;
      _roundResultMessage = '';

      _clueRoundNumber = 1;

      _impostorPlayerId = newImpostor.id;

      _impostorGuessController.clear();

      _phase = _GamePhase.passDevice;
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
      gameId: CompetitionGameIds.familyImpostor,
      gameName: 'Family Impostor',
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
            strings.gameCompleteTitle(strings.familyImpostor),
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

class _FamilyPlayer {
  const _FamilyPlayer({required this.id, required this.name});

  final String id;
  final String name;
}
