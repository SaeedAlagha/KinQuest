import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/sila_game_coach.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../competitions/config/competition_games.dart';
import '../../competitions/models/competition_game_result.dart';
import '../../competitions/models/competition_player_result.dart';
import '../../competitions/models/game_play_mode.dart';
import '../services/caption_battle_ai_service.dart';
import '../widgets/game_setup_widgets.dart';
import '../widgets/game_exit_guard.dart';

enum _CaptionBattlePhase {
  setup,
  privateCaption,
  prepareVoting,
  voting,
  roundResults,
  finalResults,
}

enum _CaptionBattleLoadError { signedOut, noFamily, loadFailed }

class CaptionBattleScreen extends StatefulWidget {
  const CaptionBattleScreen({
    super.key,
    this.playMode = GamePlayMode.quickPlay,
    this.participantIds,
    this.developerPreview = false,
  });

  final GamePlayMode playMode;
  final Set<String>? participantIds;
  final bool developerPreview;

  @override
  State<CaptionBattleScreen> createState() => _CaptionBattleScreenState();
}

class _CaptionBattleScreenState extends State<CaptionBattleScreen> {
  final CaptionBattleAiService _aiService = const CaptionBattleAiService();

  final TextEditingController _captionController = TextEditingController();

  final Random _random = Random();

  _CaptionBattlePhase _phase = _CaptionBattlePhase.setup;

  bool _isLoading = true;
  bool _isStarting = false;
  bool _captionVisible = false;

  _CaptionBattleLoadError? _loadError;

  List<_CaptionPlayer> _familyMembers = [];
  final Set<String> _selectedPlayerIds = {};

  List<_CaptionMemory> _memories = [];
  List<_CaptionMemory> _roundMemories = [];
  List<String> _roundModes = [];

  int _roundIndex = 0;
  int _selectedRounds = 3;
  String _selectedPromptStyle = CaptionBattleAiService.promptStyles.first;
  int _captionPlayerIndex = 0;
  int _voterIndex = 0;

  final Map<String, String> _captions = {};
  final Map<String, int> _roundVotes = {};
  final Map<String, int> _scores = {};

  List<String> _shuffledCaptionPlayerIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.developerPreview) {
      _loadPreviewData();
    } else {
      _loadGameData();
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _loadPreviewData() {
    const members = [
      _CaptionPlayer(id: 'preview-1', name: 'Alex'),
      _CaptionPlayer(id: 'preview-2', name: 'Sam'),
      _CaptionPlayer(id: 'preview-3', name: 'Jordan'),
      _CaptionPlayer(id: 'preview-4', name: 'Taylor'),
    ];
    final availableMembers = widget.participantIds == null
        ? members
        : members
              .where((member) => widget.participantIds!.contains(member.id))
              .toList();
    final previewImage = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );

    _familyMembers = availableMembers;
    _memories = List.generate(
      5,
      (index) => _CaptionMemory(
        id: 'preview-memory-$index',
        title: 'Developer Family Memory ${index + 1}',
        imageBytes: previewImage,
      ),
    );
    _selectedPlayerIds
      ..clear()
      ..addAll(availableMembers.map((member) => member.id));
    _isLoading = false;
  }

  Future<void> _loadGameData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          _isLoading = false;
          _loadError = _CaptionBattleLoadError.signedOut;
        });
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDoc.data();
      final familyId = userData?['familyId'] as String?;

      if (familyId == null || familyId.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _loadError = _CaptionBattleLoadError.noFamily;
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
                : strings.familyMemberFallback;

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
                : strings.familyMemoryFallback,
            imageBytes: imageBytes,
            imageUrl: imageUrl,
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _familyMembers = members;
        _memories = memories;
        if (memories.isNotEmpty && memories.length < _selectedRounds) {
          _selectedRounds = gameRoundOptions.lastWhere(
            (rounds) => rounds <= memories.length,
            orElse: () => 1,
          );
        }

        _selectedPlayerIds
          ..clear()
          ..addAll(widget.participantIds ?? members.map((member) => member.id));

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadError = _CaptionBattleLoadError.loadFailed;
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
    final strings = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final players = _selectedPlayers;

    if (players.length < 2) {
      _showMessage(strings.selectAtLeastTwoFamilyMembers);
      return;
    }

    if (_memories.isEmpty) {
      _showMessage(strings.captionBattleNeedsPhoto);
      return;
    }

    setState(() {
      _isStarting = true;
    });

    try {
      final shuffledMemories = List<_CaptionMemory>.from(_memories)
        ..shuffle(_random);

      final roundCount = min(_selectedRounds, shuffledMemories.length);

      final chosenMemories = shuffledMemories.take(roundCount).toList();

      List<String> modes;

      try {
        modes = await _aiService.generateModes(
          count: roundCount,
          languageCode: languageCode,
          promptStyle: _selectedPromptStyle,
        );

        if (modes.length < roundCount) {
          throw Exception('Not enough modes');
        }
      } catch (_) {
        modes = CaptionBattleAiService.offlineModes(
          count: roundCount,
          promptStyle: _selectedPromptStyle,
          languageCode: languageCode,
          random: _random,
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

      _showMessage(strings.couldNotStartGame(strings.captionBattle));
    }
  }

  void _revealCaptionEntry() {
    setState(() {
      _captionVisible = true;
      _captionController.clear();
    });
  }

  void _submitCaption() {
    final strings = AppLocalizations.of(context)!;
    final caption = _captionController.text.trim();

    if (caption.isEmpty) {
      _showMessage(strings.writeCaptionFirst);
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
    final strings = AppLocalizations.of(context)!;
    final voter = _currentVoter;

    if (authorId == voter.id) {
      _showMessage(strings.cannotVoteOwnCaption);
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
    final strings = AppLocalizations.of(context)!;
    final gameInProgress =
        _phase != _CaptionBattlePhase.setup &&
        _phase != _CaptionBattlePhase.finalResults;

    return GameExitGuard(
      gameInProgress: gameInProgress,
      child: Scaffold(
        floatingActionButton: gameInProgress
            ? SilaGameCoachButton(
                tone: _isLoading
                    ? SilaGameCoachTone.thinking
                    : _phase == _CaptionBattlePhase.roundResults
                    ? SilaGameCoachTone.celebrating
                    : SilaGameCoachTone.play,
              )
            : null,
        appBar: AppBar(title: Text(strings.captionBattle)),
        body: SafeArea(
          top: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildCurrentPhase(),
          ),
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

    if (_loadError != null) {
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
    final strings = AppLocalizations.of(context)!;
    final errorMessage = switch (_loadError!) {
      _CaptionBattleLoadError.signedOut => strings.mustBeLoggedInToPlay,
      _CaptionBattleLoadError.noFamily => strings.joinOrCreateFamilyBeforeGame(
        strings.captionBattle,
      ),
      _CaptionBattleLoadError.loadFailed => strings.unknownError,
    };
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
                strings.couldNotLoadCaptionBattle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(errorMessage, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loadGameData,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(strings.tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _localizedPromptStyle(AppLocalizations strings, String style) {
    return switch (style) {
      'Storytelling' => strings.captionStyleStorytelling,
      'Headlines & Posts' => strings.captionStyleHeadlines,
      'Wild Ideas' => strings.captionStyleWild,
      _ => strings.captionStyleSurprise,
    };
  }

  Widget _buildSetup() {
    final strings = AppLocalizations.of(context)!;
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
                title: strings.captionBattle,
                description: strings.captionBattleSetupDescription,
              ),
              const SizedBox(height: 22),
              SilaGameCoachBanner(message: strings.mascotGameSetupMessage),
              const SizedBox(height: 18),
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.howItWorks,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
                    _RuleRow(
                      icon: Icons.photo_rounded,
                      text: strings.captionRulePhoto,
                    ),
                    _RuleRow(
                      icon: Icons.edit_rounded,
                      text: strings.captionRuleWrite,
                    ),
                    _RuleRow(
                      icon: Icons.shuffle_rounded,
                      text: strings.captionRuleShuffle,
                    ),
                    _RuleRow(
                      icon: Icons.how_to_vote_rounded,
                      text: strings.captionRuleVote,
                    ),
                    _RuleRow(
                      icon: Icons.star_rounded,
                      text: strings.captionRulePoint,
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
                      strings.promptVariety,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      strings.promptVarietyDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 9,
                      runSpacing: 9,
                      children: CaptionBattleAiService.promptStyles.map((
                        style,
                      ) {
                        return ChoiceChip(
                          key: ValueKey('caption-style-$style'),
                          label: Text(_localizedPromptStyle(strings, style)),
                          selected: _selectedPromptStyle == style,
                          onSelected: (_) {
                            setState(() {
                              _selectedPromptStyle = style;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      CaptionBattleAiService.descriptionForStyle(
                        _selectedPromptStyle,
                        languageCode: Localizations.localeOf(
                          context,
                        ).languageCode,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CaptionBattleAiService.examplesForStyle(
                        _selectedPromptStyle,
                        languageCode: Localizations.localeOf(
                          context,
                        ).languageCode,
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
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
                      strings.familyPhotos,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _memories.isEmpty
                          ? strings.noPhotoMemories
                          : strings.photoMemoriesAvailable(_memories.length),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (_memories.isEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        strings.addPhotoMemoryFirst,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      Text(
                        strings.captionBattleRoundCount(_selectedRounds),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (_memories.isNotEmpty) ...[
                GameRoundSelector(
                  value: _selectedRounds,
                  maximum: _memories.length,
                  onChanged: (rounds) {
                    setState(() {
                      _selectedRounds = rounds;
                    });
                  },
                  keyPrefix: 'caption-round-option',
                  description: strings.captionRoundPhotoDescription,
                ),
                const SizedBox(height: 18),
              ],
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.choosePlayers,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      strings.selectAtLeastTwoFamilyMembers,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final member in _familyMembers)
                      Material(
                        color: Colors.transparent,
                        child: CheckboxListTile(
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
                      ? strings.preparingNamedGame(strings.captionBattle)
                      : strings.startNamedGame(strings.captionBattle),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.quickPlayNoRanking,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    final strings = AppLocalizations.of(context)!;

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
                        strings.takeThePhone(player.name),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        strings.keepCaptionPrivate,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: _revealCaptionEntry,
                        icon: const Icon(Icons.visibility_rounded),
                        label: Text(strings.imReady),
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
                        strings.yourChallenge,
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
                      const SizedBox(height: 6),
                      Text(
                        CaptionBattleAiService.instructionForMode(
                          _currentMode,
                          languageCode: Localizations.localeOf(
                            context,
                          ).languageCode,
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _captionController,
                        autofocus: true,
                        maxLength: 120,
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: strings.writeYourCaption,
                          hintText: CaptionBattleAiService.hintForMode(
                            _currentMode,
                            languageCode: Localizations.localeOf(
                              context,
                            ).languageCode,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _submitCaption,
                        icon: const Icon(Icons.check_rounded),
                        label: Text(
                          _captionPlayerIndex < _selectedPlayers.length - 1
                              ? strings.submitAndPassPhone
                              : strings.submitFinalCaption,
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
    final strings = AppLocalizations.of(context)!;

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
                  strings.takeThePhone(voter.name),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text(strings.privateCaptionVote, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _startVoting,
                  icon: const Icon(Icons.visibility_rounded),
                  label: Text(strings.showCaptions),
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
    final strings = AppLocalizations.of(context)!;

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
                strings.chooseFavoriteCaption(voter.name),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                strings.captionAuthorsHidden,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    final strings = AppLocalizations.of(context)!;
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
                strings.captionReveal,
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
                      ? strings.nextRound
                      : strings.finalLeaderboard,
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
    final strings = AppLocalizations.of(context)!;
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
                title: strings.officialResultsTitle(strings.captionBattle),
                description: widget.playMode.isOfficial
                    ? strings.officialGameResultsReady
                    : strings.captionFinalLeaderboard,
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
                      ? strings.returnToCompetition(
                          widget.playMode.localizedName(strings),
                        )
                      : strings.playAgain,
                ),
              ),

              if (!widget.playMode.isOfficial) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(strings.backToQuickPlay),
                ),
              ],
              if (!widget.playMode.isOfficial) ...[
                const SizedBox(height: 12),
                Text(
                  strings.quickPlayResultsOnly,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _roundHeader() {
    final strings = AppLocalizations.of(context)!;
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
              strings.roundProgress(_roundIndex + 1, _roundMemories.length),
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
    final strings = AppLocalizations.of(context)!;
    final memoryTitle = _currentMemory.id.startsWith('preview-memory-')
        ? strings.developerFamilyMemory(_roundIndex + 1)
        : _currentMemory.title;
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
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
                memoryTitle,
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
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
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
    final strings = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isWinner
            ? AppTheme.goldColor.withValues(alpha: 0.12)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isWinner
              ? AppTheme.goldColor
              : Theme.of(context).colorScheme.outlineVariant,
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
                strings.voteCount(votes),
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
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: place == 1
              ? AppTheme.goldColor
              : Theme.of(context).colorScheme.outlineVariant,
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
            AppLocalizations.of(context)!.pointsAbbreviation(score),
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
