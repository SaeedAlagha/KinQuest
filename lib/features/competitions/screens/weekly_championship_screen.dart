import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../games/screens/games_screen.dart';

class WeeklyChampionshipScreen extends StatefulWidget {
  const WeeklyChampionshipScreen({super.key, this.developerPreview = false});

  final bool developerPreview;

  @override
  State<WeeklyChampionshipScreen> createState() =>
      _WeeklyChampionshipScreenState();
}

class _WeeklyChampionshipScreenState extends State<WeeklyChampionshipScreen> {
  static const int _maxRounds = 3;
  static const int _pointsPerRound = 10;

  bool _isLoading = true;
  bool _isClaiming = false;
  bool _playedRound = false;

  String? _familyId;
  String? _errorMessage;

  int _completedRounds = 0;

  final Map<String, int> _scores = {};
  final Map<String, String> _memberNames = {};

  String get _weekKey {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final monday = today.subtract(
      Duration(days: today.weekday - DateTime.monday),
    );

    return '${monday.year}-'
        '${monday.month.toString().padLeft(2, '0')}-'
        '${monday.day.toString().padLeft(2, '0')}';
  }

  String get _weekLabel {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final monday = today.subtract(
      Duration(days: today.weekday - DateTime.monday),
    );

    final sunday = monday.add(const Duration(days: 6));

    return '${_monthName(monday.month)} ${monday.day}'
        ' - '
        '${_monthName(sunday.month)} ${sunday.day}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  @override
  void initState() {
    super.initState();

    if (widget.developerPreview) {
      _loadDeveloperPreview();
    } else {
      _loadChampionship();
    }
  }

  void _loadDeveloperPreview() {
    _memberNames.addAll({
      'preview-user': 'You',
      'member-2': 'Family Member 2',
      'member-3': 'Family Member 3',
    });

    _scores.addAll({'preview-user': 20, 'member-2': 30, 'member-3': 10});

    setState(() {
      _completedRounds = 2;
      _isLoading = false;
    });
  }

  Future<void> _loadChampionship() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'You must be signed in to join the Weekly Championship.';
      });

      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;

      final userDoc = await firestore.collection('users').doc(user.uid).get();

      final familyId = userDoc.data()?['familyId'] as String?;

      if (familyId == null || familyId.isEmpty) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _errorMessage =
              'Join or create a family before entering the Weekly Championship.';
        });

        return;
      }

      final membersSnapshot = await firestore
          .collection('users')
          .where('familyId', isEqualTo: familyId)
          .get();

      final roundsSnapshot = await firestore
          .collection('families')
          .doc(familyId)
          .collection('weeklyChampionshipRounds')
          .where('weekKey', isEqualTo: _weekKey)
          .get();

      final memberNames = <String, String>{};
      final scores = <String, int>{};

      for (final member in membersSnapshot.docs) {
        final data = member.data();

        memberNames[member.id] = data['name'] as String? ?? 'Family Member';

        scores[member.id] = 0;
      }

      var userRounds = 0;

      for (final round in roundsSnapshot.docs) {
        final data = round.data();

        final userId = data['userId'] as String?;
        final points = data['points'] as num? ?? 0;

        if (userId == null) {
          continue;
        }

        scores[userId] = (scores[userId] ?? 0) + points.toInt();

        if (userId == user.uid) {
          userRounds++;
        }
      }

      if (!mounted) return;

      setState(() {
        _familyId = familyId;
        _memberNames
          ..clear()
          ..addAll(memberNames);

        _scores
          ..clear()
          ..addAll(scores);

        _completedRounds = userRounds;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Could not load the Weekly Championship. Please try again.';
      });
    }
  }

  Future<void> _playRound() async {
    if (_completedRounds >= _maxRounds) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GamesScreen(developerPreview: widget.developerPreview),
      ),
    );

    if (!mounted) return;

    setState(() {
      _playedRound = true;
    });
  }

  Future<void> _claimRound() async {
    if (_isClaiming || !_playedRound || _completedRounds >= _maxRounds) {
      return;
    }

    if (widget.developerPreview) {
      setState(() {
        _completedRounds++;
        _scores['preview-user'] =
            (_scores['preview-user'] ?? 0) + _pointsPerRound;
        _playedRound = false;
      });

      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final familyId = _familyId;

    if (user == null || familyId == null) {
      return;
    }

    setState(() {
      _isClaiming = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      final nextRound = _completedRounds + 1;

      final roundId = '${_weekKey}_${user.uid}_round$nextRound';

      final roundRef = firestore
          .collection('families')
          .doc(familyId)
          .collection('weeklyChampionshipRounds')
          .doc(roundId);

      final completed = await firestore.runTransaction<bool>((
        transaction,
      ) async {
        final existingRound = await transaction.get(roundRef);

        if (existingRound.exists) {
          return false;
        }

        transaction.set(roundRef, {
          'weekKey': _weekKey,
          'familyId': familyId,
          'userId': user.uid,
          'round': nextRound,
          'points': _pointsPerRound,
          'completedAt': FieldValue.serverTimestamp(),
        });

        transaction.update(firestore.collection('users').doc(user.uid), {
          'weeklyChampionshipRounds': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return true;
      });

      if (!mounted) return;

      if (completed) {
        setState(() {
          _completedRounds++;
          _scores[user.uid] = (_scores[user.uid] ?? 0) + _pointsPerRound;
          _playedRound = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Round complete! You earned 10 championship points.'),
          ),
        );
      } else {
        await _loadChampionship();
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save this round. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isClaiming = false;
        });
      }
    }
  }

  List<MapEntry<String, int>> get _rankedScores {
    final entries = _scores.entries.toList();

    entries.sort((a, b) => b.value.compareTo(a.value));

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Championship'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_errorMessage!, textAlign: TextAlign.center),
                ),
              )
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final progress = _completedRounds / _maxRounds;

    return RefreshIndicator(
      onRefresh: widget.developerPreview ? () async {} : _loadChampionship,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              gradient: AppTheme.brandGradient,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 58,
                ),
                const SizedBox(height: 16),
                Text(
                  'Family Championship',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _weekLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Complete up to 3 rounds this week. '
                  'Every round earns 10 championship points.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Your progress',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$_completedRounds / $_maxRounds',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 9,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  const SizedBox(height: 20),
                  if (_completedRounds >= _maxRounds)
                    const Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.tealColor,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'You completed all championship rounds for this week.',
                          ),
                        ),
                      ],
                    )
                  else ...[
                    FilledButton.icon(
                      onPressed: _playRound,
                      icon: const Icon(Icons.sports_esports_rounded),
                      label: Text('Play Round ${_completedRounds + 1}'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _playedRound && !_isClaiming
                          ? _claimRound
                          : null,
                      icon: _isClaiming
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(
                        _isClaiming ? 'Saving round...' : 'Complete Round',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Play a family game before completing the round.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Weekly Leaderboard',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildLeaderboard(),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppTheme.goldColor,
                    size: 34,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Champion Reward',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'The family member leading at the end of the week becomes the Weekly Champion.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    final ranked = _rankedScores;

    if (ranked.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No championship scores yet. Play the first round!'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: List.generate(ranked.length, (index) {
            final entry = ranked[index];

            final name = _memberNames[entry.key] ?? 'Family Member';

            return ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(name),
              subtitle: Text(
                '${entry.value ~/ _pointsPerRound} rounds completed',
              ),
              trailing: Text(
                '${entry.value} pts',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            );
          }),
        ),
      ),
    );
  }
}
