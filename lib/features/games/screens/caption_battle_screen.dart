import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../competitions/config/competition_games.dart';
import '../../competitions/models/competition_game_result.dart';
import '../../competitions/models/competition_player_result.dart';
import '../../competitions/models/game_play_mode.dart';
import '../services/caption_battle_ai_service.dart';

enum _CaptionBattlePhase {
  setup,
  privateCaption,
  prepareVoting,
  voting,
  roundResults,
  finalResults,
}

class CaptionBattleScreen extends StatefulWidget {
  const CaptionBattleScreen({
    super.key,
    this.playMode = GamePlayMode.quickPlay,
    this.participantIds,
  });

  final GamePlayMode playMode;
  final Set<String>? participantIds;

  @override
  State<CaptionBattleScreen> createState() => _CaptionBattleScreenState();
}

class _CaptionBattleScreenState extends State<CaptionBattleScreen> {
  static const int _maximumRounds = 3;

  final CaptionBattleAiService _aiService = const CaptionBattleAiService();

  final TextEditingController _captionController = TextEditingController();

  final Random _random = Random();

  _CaptionBattlePhase _phase = _CaptionBattlePhase.setup;

  bool _isLoading = true;
  bool _isStarting = false;
  bool _captionVisible = false;

  String? _errorMessage;

  List<_CaptionPlayer> _familyMembers = [];
  final Set<String> _selectedPlayerIds = {};

  List<_CaptionMemory> _memories = [];
  List<_CaptionMemory> _roundMemories = [];
  List<String> _roundModes = [];

  int _roundIndex = 0;
  int _captionPlayerIndex = 0;
  int _voterIndex = 0;

  final Map<String, String> _captions = {};
  final Map<String, int> _roundVotes = {};
  final Map<String, int> _scores = {};

  List<String> _shuffledCaptionPlayerIds = [];

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _loadGameData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('You must be signed in to play.');
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDoc.data();
      final familyId = userData?['familyId'] as String?;

      if (familyId == null || familyId.isEmpty) {
        throw Exception('Join or create a family before playing.');
      }

      final membersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('familyId', isEqualTo: familyId)
          .get();

      final members = membersSnapshot.docs
          .where(
            (doc) =>
                widget.participantIds == null ||
                widget.participantIds!.contains(doc.id),
          )
          .map((doc) {
            final data = doc.data();

            final displayName =
                (data['name'] as String?)?.trim().isNotEmpty == true
                ? (data['name'] as String).trim()
                : (data['displayName'] as String?)?.trim().isNotEmpty == true
                ? (data['displayName'] as String).trim()
                : (data['email'] as String?)?.trim().isNotEmpty == true
                ? (data['email'] as String).trim()
                : 'Family Member';

            return _CaptionPlayer(id: doc.id, name: displayName);
          })
          .toList();

      members.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      final memorySnapshot = await FirebaseFirestore.instance
          .collection('families')
          .doc(familyId)
          .collection('memories')
          .orderBy('createdAt', descending: true)
          .get();

      final memories = <_CaptionMemory>[];

      for (final doc in memorySnapshot.docs) {
        final data = doc.data();

        final imageUrl = (data['imageUrl'] as String?)?.trim();

        final imageData = data['imageData'];

        final Uint8List? imageBytes = imageData is Blob
            ? imageData.bytes
            : null;

        final hasBlob = imageBytes != null && imageBytes.isNotEmpty;

        final hasUrl = imageUrl != null && imageUrl.isNotEmpty;

        if (!hasBlob && !hasUrl) {
          continue;
        }

        memories.add(
          _CaptionMemory(
            id: doc.id,
            title: (data['title'] as String?)?.trim().isNotEmpty == true
                ? (data['title'] as String).trim()
                : 'Family Memory',
            imageBytes: imageBytes,
            imageUrl: imageUrl,
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _familyMembers = members;
        _memories = memories;

        _selectedPlayerIds
          ..clear()
          ..addAll(widget.participantIds ?? members.map((member) => member.id));

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<_CaptionPlayer> get _selectedPlayers {
    return _familyMembers
        .where((member) => _selectedPlayerIds.contains(member.id))
        .toList();
  }

  _CaptionMemory get _currentMemory {
    return _roundMemories[_roundIndex];
  }

  String get _currentMode {
    return _roundModes[_roundIndex];
  }

  _CaptionPlayer get _currentCaptionPlayer {
    return _selectedPlayers[_captionPlayerIndex];
  }

  _CaptionPlayer get _currentVoter {
    return _selectedPlayers[_voterIndex];
  }

  _CaptionPlayer _playerById(String id) {
    return _selectedPlayers.firstWhere((player) => player.id == id);
  }

  Future<void> _startGame() async {
    final players = _selectedPlayers;

    if (players.length < 2) {
      _showMessage('Select at least 2 family members.');
      return;
    }

    if (_memories.isEmpty) {
      _showMessage('Caption Battle needs at least one Memory with a photo.');
      return;
    }

    setState(() {
      _isStarting = true;
    });

    try {
      final shuffledMemories = List<_CaptionMemory>.from(_memories)
        ..shuffle(_random);

      final roundCount = min(_maximumRounds, shuffledMemories.length);

      final chosenMemories = shuffledMemories.take(roundCount).toList();

      List<String> modes;

      try {
        modes = await _aiService.generateModes(
          count: roundCount,
          languageCode: 'en',
        );

        if (modes.length < roundCount) {
          throw Exception('Not enough modes');
        }
      } catch (_) {
        const fallbacks = ['Funny Caption', 'Breaking News', 'Movie Title'];

        modes = List.generate(
          roundCount,
          (index) => fallbacks[index % fallbacks.length],
        );
      }

      if (!mounted) return;

      setState(() {
        _roundMemories = chosenMemories;
        _roundModes = modes.take(roundCount).toList();

        _scores
          ..clear()
          ..addEntries(players.map((player) => MapEntry(player.id, 0)));

        _roundIndex = 0;
        _captionPlayerIndex = 0;
        _voterIndex = 0;
        _captions.clear();
        _roundVotes.clear();
        _shuffledCaptionPlayerIds.clear();

        _captionVisible = false;
        _captionController.clear();

        _phase = _CaptionBattlePhase.privateCaption;
        _isStarting = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isStarting = false;
      });

      _showMessage('Could not start Caption Battle.');
    }
  }

  void _revealCaptionEntry() {
    setState(() {
      _captionVisible = true;
      _captionController.clear();
    });
  }

  void _submitCaption() {
    final caption = _captionController.text.trim();

    if (caption.isEmpty) {
      _showMessage('Write a caption before continuing.');
      return;
    }

    final player = _currentCaptionPlayer;

    _captions[player.id] = caption;

    if (_captionPlayerIndex < _selectedPlayers.length - 1) {
      setState(() {
        _captionPlayerIndex++;
        _captionVisible = false;
        _captionController.clear();
      });

      return;
    }

    _prepareVoting();
  }

  void _prepareVoting() {
    _shuffledCaptionPlayerIds = _captions.keys.toList()..shuffle(_random);

    _roundVotes
      ..clear()
      ..addEntries(_selectedPlayers.map((player) => MapEntry(player.id, 0)));

    setState(() {
      _captionVisible = false;
      _captionController.clear();
      _voterIndex = 0;
      _phase = _CaptionBattlePhase.prepareVoting;
    });
  }

  void _startVoting() {
    setState(() {
      _phase = _CaptionBattlePhase.voting;
    });
  }

  void _submitVote(String authorId) {
    final voter = _currentVoter;

    if (authorId == voter.id) {
      _showMessage('You cannot vote for your own caption.');
      return;
    }

    _roundVotes[authorId] = (_roundVotes[authorId] ?? 0) + 1;

    if (_voterIndex < _selectedPlayers.length - 1) {
      setState(() {
        _voterIndex++;
        _phase = _CaptionBattlePhase.prepareVoting;
      });

      return;
    }

    for (final entry in _roundVotes.entries) {
      _scores[entry.key] = (_scores[entry.key] ?? 0) + entry.value;
    }

    setState(() {
      _phase = _CaptionBattlePhase.roundResults;
    });
  }

  void _nextRound() {
    if (_roundIndex >= _roundMemories.length - 1) {
      setState(() {
        _phase = _CaptionBattlePhase.finalResults;
      });

      return;
    }

    setState(() {
      _roundIndex++;
      _captionPlayerIndex = 0;
      _voterIndex = 0;

      _captions.clear();
      _roundVotes.clear();
      _shuffledCaptionPlayerIds.clear();

      _captionController.clear();
      _captionVisible = false;

      _phase = _CaptionBattlePhase.privateCaption;
    });
  }

  void _playAgain() {
    setState(() {
      _phase = _CaptionBattlePhase.setup;
      _roundIndex = 0;
      _captionPlayerIndex = 0;
      _voterIndex = 0;
      _captions.clear();
      _roundVotes.clear();
      _scores.clear();
      _roundMemories.clear();
      _roundModes.clear();
      _shuffledCaptionPlayerIds.clear();
      _captionVisible = false;
      _captionController.clear();
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caption Battle')),
      body: SafeArea(
        top: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _buildCurrentPhase(),
        ),
      ),
    );
  }

  Widget _buildCurrentPhase() {
    if (_isLoading) {
      return const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    return switch (_phase) {
      _CaptionBattlePhase.setup => _buildSetup(),
      _CaptionBattlePhase.privateCaption => _buildPrivateCaption(),
      _CaptionBattlePhase.prepareVoting => _buildPrepareVoting(),
      _CaptionBattlePhase.voting => _buildVoting(),
      _CaptionBattlePhase.roundResults => _buildRoundResults(),
      _CaptionBattlePhase.finalResults => _buildFinalResults(),
    };
  }

  Widget _buildError() {
    return Center(
      key: const ValueKey('error'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppTheme.coralColor,
              ),
              const SizedBox(height: 20),
              Text(
                'Could not load Caption Battle',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage ?? 'Unknown error',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loadGameData,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetup() {
    return SingleChildScrollView(
      key: const ValueKey('setup'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _heroCard(
                icon: Icons.add_comment_rounded,
                title: 'Caption Battle',
                description:
                    'Everyone captions the same family photo. Then the captions are shuffled and the family votes anonymously.',
              ),
              const SizedBox(height: 22),
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How it works',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
                    const _RuleRow(
                      icon: Icons.photo_rounded,
                      text: 'A real family Memory photo appears each round.',
                    ),
                    const _RuleRow(
                      icon: Icons.edit_rounded,
                      text: 'Each player secretly writes one caption.',
                    ),
                    const _RuleRow(
                      icon: Icons.shuffle_rounded,
                      text: 'Captions are shuffled so authors stay hidden.',
                    ),
                    const _RuleRow(
                      icon: Icons.how_to_vote_rounded,
                      text: 'Everyone votes, but cannot vote for themselves.',
                    ),
                    const _RuleRow(
                      icon: Icons.star_rounded,
                      text: 'Each vote is worth 1 local Quick Play point.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Family photos',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _memories.isEmpty
                          ? 'No Memories with photos were found.'
                          : '${_memories.length} photo ${_memories.length == 1 ? 'memory' : 'memories'} available.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (_memories.isEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Add a Memory with a photo first, then return here.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      Text(
                        'This game will play ${min(_maximumRounds, _memories.length)} ${min(_maximumRounds, _memories.length) == 1 ? 'round' : 'rounds'}.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose players',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Select at least 2 family members.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final member in _familyMembers)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _selectedPlayerIds.contains(member.id),
                        title: Text(member.name),
                        secondary: const Icon(Icons.person_rounded),
                        onChanged: widget.participantIds == null
                            ? (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedPlayerIds.add(member.id);
                                  } else {
                                    _selectedPlayerIds.remove(member.id);
                                  }
                                });
                              }
                            : null,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: _isStarting || _memories.isEmpty ? null : _startGame,
                icon: _isStarting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow_rounded),
                label: Text(
                  _isStarting
                      ? 'Preparing Caption Battle...'
                      : 'Start Caption Battle',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Quick Play only • No Tokens or global ranking',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivateCaption() {
    final player = _currentCaptionPlayer;

    return SingleChildScrollView(
      key: ValueKey(
        'caption-$_roundIndex-$_captionPlayerIndex-$_captionVisible',
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _roundHeader(),
              const SizedBox(height: 18),
              if (!_captionVisible)
                _sectionCard(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.phone_android_rounded,
                        size: 54,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '${player.name}, take the phone',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Make sure nobody else can see your caption.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: _revealCaptionEntry,
                        icon: const Icon(Icons.visibility_rounded),
                        label: const Text('I\'m Ready'),
                      ),
                    ],
                  ),
                )
              else ...[
                _photoCard(),
                const SizedBox(height: 18),
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Your challenge',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentMode,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _captionController,
                        autofocus: true,
                        maxLength: 120,
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Write your caption',
                          hintText: 'Make the family laugh...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _submitCaption,
                        icon: const Icon(Icons.check_rounded),
                        label: Text(
                          _captionPlayerIndex < _selectedPlayers.length - 1
                              ? 'Submit & Pass Phone'
                              : 'Submit Final Caption',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrepareVoting() {
    final voter = _currentVoter;

    return Center(
      key: ValueKey('prepare-vote-$_roundIndex-$_voterIndex'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: _sectionCard(
            child: Column(
              children: [
                const Icon(
                  Icons.how_to_vote_rounded,
                  size: 58,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 18),
                Text(
                  '${voter.name}, take the phone',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Vote privately for your favorite caption. You will not be able to vote for your own.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _startVoting,
                  icon: const Icon(Icons.visibility_rounded),
                  label: const Text('Show Captions'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoting() {
    final voter = _currentVoter;

    final availableAuthorIds = _shuffledCaptionPlayerIds
        .where((authorId) => authorId != voter.id)
        .toList();

    return SingleChildScrollView(
      key: ValueKey('vote-$_roundIndex-$_voterIndex'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _roundHeader(),
              const SizedBox(height: 16),
              _photoCard(),
              const SizedBox(height: 18),
              Text(
                '${voter.name}, choose your favorite',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Authors stay hidden until everyone votes.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < availableAuthorIds.length; i++) ...[
                _anonymousCaptionCard(
                  number: i + 1,
                  caption: _captions[availableAuthorIds[i]] ?? '',
                  onVote: () => _submitVote(availableAuthorIds[i]),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundResults() {
    final resultIds = _roundVotes.keys.toList()
      ..sort((a, b) => (_roundVotes[b] ?? 0).compareTo(_roundVotes[a] ?? 0));

    final bestVotes = resultIds.isEmpty ? 0 : _roundVotes[resultIds.first] ?? 0;

    return SingleChildScrollView(
      key: ValueKey('round-results-$_roundIndex'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _roundHeader(),
              const SizedBox(height: 16),
              _photoCard(),
              const SizedBox(height: 20),
              Text(
                'Caption reveal',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              for (final authorId in resultIds) ...[
                _resultCaptionCard(
                  player: _playerById(authorId),
                  caption: _captions[authorId] ?? '',
                  votes: _roundVotes[authorId] ?? 0,
                  isWinner:
                      bestVotes > 0 &&
                      (_roundVotes[authorId] ?? 0) == bestVotes,
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _nextRound,
                icon: Icon(
                  _roundIndex < _roundMemories.length - 1
                      ? Icons.arrow_forward_rounded
                      : Icons.emoji_events_rounded,
                ),
                label: Text(
                  _roundIndex < _roundMemories.length - 1
                      ? 'Next Round'
                      : 'Final Leaderboard',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  CompetitionGameResult _buildCompetitionResult() {
    final leaderboard = _familyMembers
        .where((player) => _selectedPlayerIds.contains(player.id))
        .toList();

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
      gameId: CompetitionGameIds.captionBattle,
      gameName: 'Caption Battle',
      players: results,
    );
  }

  Widget _buildFinalResults() {
    final players = List<_CaptionPlayer>.from(_selectedPlayers)
      ..sort((a, b) => (_scores[b.id] ?? 0).compareTo(_scores[a.id] ?? 0));

    return SingleChildScrollView(
      key: const ValueKey('final-results'),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _heroCard(
                icon: Icons.emoji_events_rounded,
                title: 'Caption Battle Results',
                description: widget.playMode.isOfficial
                    ? '${widget.playMode.displayName} results are ready.'
                    : 'Every vote counted. Here is the final local leaderboard.',
              ),
              const SizedBox(height: 20),
              for (var i = 0; i < players.length; i++) ...[
                _leaderboardCard(
                  place: i + 1,
                  player: players[i],
                  score: _scores[players[i].id] ?? 0,
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  if (widget.playMode.isOfficial) {
                    Navigator.of(context).pop(_buildCompetitionResult());
                    return;
                  }

                  _playAgain();
                },
                icon: Icon(
                  widget.playMode.isOfficial
                      ? Icons.arrow_back_rounded
                      : Icons.replay_rounded,
                ),
                label: Text(
                  widget.playMode.isOfficial
                      ? 'Return to ${widget.playMode.displayName}'
                      : 'Play Again',
                ),
              ),

              if (!widget.playMode.isOfficial) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back to Quick Play'),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Quick Play scores are local to this game and do not affect Tokens or global rankings.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roundHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Round ${_roundIndex + 1} of ${_roundMemories.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(
            _currentMode,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppTheme.outlineColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: _currentMemory.imageBytes != null
                  ? Image.memory(_currentMemory.imageBytes!, fit: BoxFit.cover)
                  : Image.network(
                      _currentMemory.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image_outlined, size: 64),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                _currentMemory.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _anonymousCaptionCard({
    required int number,
    required String caption,
    required VoidCallback onVote,
  }) {
    return Material(
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppTheme.outlineColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onVote,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(child: Text('$number')),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  caption,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.favorite_border_rounded,
                color: AppTheme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultCaptionCard({
    required _CaptionPlayer player,
    required String caption,
    required int votes,
    required bool isWinner,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isWinner
            ? AppTheme.goldColor.withValues(alpha: 0.12)
            : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isWinner ? AppTheme.goldColor : AppTheme.outlineColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isWinner) ...[
                const Icon(
                  Icons.emoji_events_rounded,
                  color: AppTheme.goldColor,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  player.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '$votes ${votes == 1 ? 'vote' : 'votes'}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(caption, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _leaderboardCard({
    required int place,
    required _CaptionPlayer player,
    required int score,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: place == 1
            ? AppTheme.goldColor.withValues(alpha: 0.12)
            : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: place == 1 ? AppTheme.goldColor : AppTheme.outlineColor,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(child: Text('$place')),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              player.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(
            '$score ${score == 1 ? 'pt' : 'pts'}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _heroCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.outlineColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 30, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineColor),
      ),
      child: child,
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _CaptionPlayer {
  const _CaptionPlayer({required this.id, required this.name});

  final String id;
  final String name;
}

class _CaptionMemory {
  const _CaptionMemory({
    required this.id,
    required this.title,
    this.imageBytes,
    this.imageUrl,
  });

  final String id;
  final String title;
  final Uint8List? imageBytes;
  final String? imageUrl;
}
