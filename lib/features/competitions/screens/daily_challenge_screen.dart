import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../games/screens/family_missions_screen.dart';
import '../../games/screens/family_quiz_screen.dart';
import '../../games/screens/memory_challenge_screen.dart';
import '../../games/screens/games_screen.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key, this.developerPreview = false});

  final bool developerPreview;

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  bool _isLoading = true;
  bool _isClaiming = false;
  bool _completedToday = false;
  bool _openedChallenge = false;

  String? _familyId;
  _DailyChallengeError? _error;

  String get _dateKey {
    final now = DateTime.now();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  late final _DailyChallenge _challenge = _challengeForToday();

  @override
  void initState() {
    super.initState();

    if (widget.developerPreview) {
      _isLoading = false;
    } else {
      _loadStatus();
    }
  }

  _DailyChallenge _challengeForToday() {
    final now = DateTime.now();

    final dayNumber =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;

    final challenges = [
      const _DailyChallenge(
        type: _DailyChallengeType.familyQuiz,
        icon: Icons.quiz_rounded,
        title: 'Family Quiz Day',
        description:
            'See how well your family knows one another in today\'s Family Quiz.',
      ),
      const _DailyChallenge(
        type: _DailyChallengeType.memoryChallenge,
        icon: Icons.photo_library_rounded,
        title: 'Memory Challenge Day',
        description:
            'Look back at your family moments and test how well you remember them.',
      ),
      const _DailyChallenge(
        type: _DailyChallengeType.familyMissions,
        icon: Icons.groups_rounded,
        title: 'Family Mission Day',
        description:
            'Complete one meaningful activity together from Family Missions.',
      ),
      const _DailyChallenge(
        type: _DailyChallengeType.partyGames,
        icon: Icons.celebration_rounded,
        title: 'Party Game Day',
        description:
            'Pick a quick family game and share a few laughs together.',
      ),
    ];

    return challenges[dayNumber % challenges.length];
  }

  Future<void> _loadStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _error = _DailyChallengeError.signInRequired;
      });
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final familyId = userDoc.data()?['familyId'] as String?;

      if (familyId == null || familyId.isEmpty) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _error = _DailyChallengeError.familyRequired;
        });

        return;
      }

      final completionId = '${_dateKey}_${user.uid}';

      final completionDoc = await FirebaseFirestore.instance
          .collection('families')
          .doc(familyId)
          .collection('dailyChallengeCompletions')
          .doc(completionId)
          .get();

      if (!mounted) return;

      setState(() {
        _familyId = familyId;
        _completedToday = completionDoc.exists;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = _DailyChallengeError.loadFailed;
      });
    }
  }

  Future<void> _openChallenge() async {
    Widget screen;

    switch (_challenge.type) {
      case _DailyChallengeType.familyQuiz:
        screen = const FamilyQuizScreen();

      case _DailyChallengeType.memoryChallenge:
        screen = const MemoryChallengeScreen();

      case _DailyChallengeType.familyMissions:
        screen = const FamilyMissionsScreen();

      case _DailyChallengeType.partyGames:
        screen = const PartyGamesScreen();
    }

    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

    if (!mounted) return;

    setState(() {
      _openedChallenge = true;
    });
  }

  Future<void> _claimCompletion() async {
    final user = FirebaseAuth.instance.currentUser;
    final familyId = _familyId;

    if (user == null || familyId == null) {
      return;
    }

    if (_completedToday || _isClaiming) {
      return;
    }

    setState(() {
      _isClaiming = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      final completionId = '${_dateKey}_${user.uid}';

      final completionRef = firestore
          .collection('families')
          .doc(familyId)
          .collection('dailyChallengeCompletions')
          .doc(completionId);

      final userRef = firestore.collection('users').doc(user.uid);

      final completed = await firestore.runTransaction<bool>((
        transaction,
      ) async {
        final completionDoc = await transaction.get(completionRef);
        final userDoc = await transaction.get(userRef);

        if (completionDoc.exists) {
          return false;
        }

        final userData = userDoc.data();

        final currentStreak = (userData?['currentStreak'] ?? 0) as int;

        final lastPlayedTimestamp = userData?['lastPlayedAt'] as Timestamp?;

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        var newStreak = 1;

        if (lastPlayedTimestamp != null) {
          final lastPlayed = lastPlayedTimestamp.toDate();

          final lastPlayedDay = DateTime(
            lastPlayed.year,
            lastPlayed.month,
            lastPlayed.day,
          );

          final difference = today.difference(lastPlayedDay).inDays;

          if (difference == 0) {
            newStreak = currentStreak == 0 ? 1 : currentStreak;
          } else if (difference == 1) {
            newStreak = currentStreak + 1;
          }
        }

        transaction.set(completionRef, {
          'userId': user.uid,
          'familyId': familyId,
          'dateKey': _dateKey,
          'challengeTitle': _challenge.title,
          'challengeType': _challenge.type.name,
          'tokenReward': 10,
          'completedAt': FieldValue.serverTimestamp(),
        });

        transaction.update(userRef, {
          'tokens': FieldValue.increment(10),
          'gamesPlayed': FieldValue.increment(1),
          'currentStreak': newStreak,
          'lastPlayedAt': FieldValue.serverTimestamp(),
          'dailyChallengesCompleted': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return true;
      });

      if (!mounted) return;

      setState(() {
        _completedToday = completed || _completedToday;
        _isClaiming = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            completed
                ? AppLocalizations.of(context)!.dailyChallengeCompleteMessage
                : AppLocalizations.of(context)!.dailyChallengeAlreadyClaimed,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isClaiming = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.dailyChallengeSaveError),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.dailyChallenge)),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _localizedDailyChallengeError(strings, _error!),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : _buildChallenge(),
      ),
    );
  }

  Widget _buildChallenge() {
    final strings = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    Text(
                      strings.todaysFamilyChallenge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Icon(
                        _challenge.icon,
                        size: 42,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _localizedDailyChallengeTitle(strings, _challenge),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _localizedDailyChallengeDescription(strings, _challenge),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.stars_rounded,
                        color: AppTheme.goldColor,
                        size: 34,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.dailyReward,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 3),
                            Text(strings.dailyRewardDescription),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_completedToday)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.tealColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.tealColor,
                        size: 32,
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Text(strings.dailyChallengeCompleted)),
                    ],
                  ),
                )
              else ...[
                FilledButton.icon(
                  onPressed: _openChallenge,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(strings.playTodaysChallenge),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _openedChallenge || widget.developerPreview
                      ? _claimCompletion
                      : null,
                  icon: _isClaiming
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(
                    _isClaiming
                        ? strings.savingCompletion
                        : strings.iCompletedIt,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  strings.openChallengeBeforeClaiming,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum _DailyChallengeType {
  familyQuiz,
  memoryChallenge,
  familyMissions,
  partyGames,
}

enum _DailyChallengeError { signInRequired, familyRequired, loadFailed }

class _DailyChallenge {
  const _DailyChallenge({
    required this.type,
    required this.icon,
    required this.title,
    required this.description,
  });

  final _DailyChallengeType type;
  final IconData icon;
  final String title;
  final String description;
}

String _localizedDailyChallengeTitle(
  AppLocalizations strings,
  _DailyChallenge challenge,
) => switch (challenge.type) {
  _DailyChallengeType.familyQuiz => strings.familyQuizDay,
  _DailyChallengeType.memoryChallenge => strings.memoryChallengeDay,
  _DailyChallengeType.familyMissions => strings.familyMissionDay,
  _DailyChallengeType.partyGames => strings.partyGameDay,
};

String _localizedDailyChallengeDescription(
  AppLocalizations strings,
  _DailyChallenge challenge,
) {
  final localizedDescription = switch (challenge.type) {
    _DailyChallengeType.familyQuiz => strings.familyQuizDayDescription,
    _DailyChallengeType.memoryChallenge =>
      strings.memoryChallengeDayDescription,
    _DailyChallengeType.familyMissions => strings.familyMissionDayDescription,
    _DailyChallengeType.partyGames => strings.partyGameDayDescription,
  };

  return localizedDescription.isEmpty
      ? challenge.description
      : localizedDescription;
}

String _localizedDailyChallengeError(
  AppLocalizations strings,
  _DailyChallengeError error,
) => switch (error) {
  _DailyChallengeError.signInRequired => strings.dailyChallengeSignInRequired,
  _DailyChallengeError.familyRequired => strings.dailyChallengeFamilyRequired,
  _DailyChallengeError.loadFailed => strings.dailyChallengeLoadError,
};
