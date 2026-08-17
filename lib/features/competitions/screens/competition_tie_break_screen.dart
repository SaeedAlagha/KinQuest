import 'package:flutter/material.dart';

import '../models/competition_player_result.dart';

class CompetitionTieBreakScreen extends StatefulWidget {
  const CompetitionTieBreakScreen({super.key, required this.players});

  final List<CompetitionPlayerResult> players;

  @override
  State<CompetitionTieBreakScreen> createState() =>
      _CompetitionTieBreakScreenState();
}

class _CompetitionTieBreakScreenState extends State<CompetitionTieBreakScreen> {
  static const int _targetMilliseconds = 5000;

  final Stopwatch _stopwatch = Stopwatch();

  late List<CompetitionPlayerResult> _roundPlayers;

  final Map<String, int> _distances = {};

  int _currentPlayerIndex = 0;
  int _roundNumber = 1;

  bool _isTiming = false;
  bool _showingResults = false;

  CompetitionPlayerResult? _winner;

  @override
  void initState() {
    super.initState();

    _roundPlayers = List<CompetitionPlayerResult>.from(widget.players);
  }

  CompetitionPlayerResult get _currentPlayer =>
      _roundPlayers[_currentPlayerIndex];

  void _startAttempt() {
    _stopwatch
      ..reset()
      ..start();

    setState(() {
      _isTiming = true;
    });
  }

  void _stopAttempt() {
    if (!_isTiming) {
      return;
    }

    _stopwatch.stop();

    final elapsedMilliseconds = _stopwatch.elapsedMilliseconds;

    final distance = (elapsedMilliseconds - _targetMilliseconds).abs();

    _distances[_currentPlayer.userId] = distance;

    setState(() {
      _isTiming = false;
    });

    if (_currentPlayerIndex < _roundPlayers.length - 1) {
      setState(() {
        _currentPlayerIndex++;
      });

      return;
    }

    _finishRound();
  }

  void _finishRound() {
    final bestDistance = _roundPlayers
        .map((player) => _distances[player.userId] ?? 1 << 30)
        .reduce((a, b) => a < b ? a : b);

    final leaders = _roundPlayers
        .where((player) => _distances[player.userId] == bestDistance)
        .toList();

    if (leaders.length == 1) {
      setState(() {
        _winner = leaders.first;
        _showingResults = true;
      });

      return;
    }

    setState(() {
      _roundPlayers = leaders;
      _currentPlayerIndex = 0;
      _roundNumber++;
      _distances.clear();
      _showingResults = true;
      _winner = null;
    });
  }

  void _continueAfterTie() {
    setState(() {
      _showingResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tie-Break')),
      body: SafeArea(child: _showingResults ? _buildResults() : _buildTurn()),
    );
  }

  Widget _buildTurn() {
    final player = _currentPlayer;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            children: [
              Text(
                'Sudden Death • Round $_roundNumber',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              Icon(
                _isTiming ? Icons.timer_rounded : Icons.person_rounded,
                size: 72,
              ),
              const SizedBox(height: 20),
              Text(
                _isTiming ? 'Counting...' : 'Pass the phone to ${player.name}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isTiming
                    ? 'Stop when you think exactly 5 seconds have passed.'
                    : 'Your goal is to stop as close as possible to exactly 5 seconds.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 10),
              const Text(
                'The timer stays hidden. Closest result wins.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              if (!_isTiming)
                FilledButton.icon(
                  onPressed: _startAttempt,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start'),
                )
              else
                FilledButton.icon(
                  onPressed: _stopAttempt,
                  icon: const Icon(Icons.stop_rounded),
                  label: const Text('STOP'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    final winner = _winner;

    if (winner != null) {
      final distance = _distances[winner.userId] ?? 0;

      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              children: [
                const Icon(Icons.emoji_events_rounded, size: 80),
                const SizedBox(height: 20),
                Text(
                  '${winner.name} wins the tie-break!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Only ${(distance / 1000).toStringAsFixed(3)} seconds away from exactly 5.000 seconds.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(winner);
                  },
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('Confirm Winner'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            children: [
              const Icon(Icons.balance_rounded, size: 72),
              const SizedBox(height: 20),
              Text(
                'Still tied!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${_roundPlayers.length} players were equally close. '
                'Only those players continue to Round $_roundNumber.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _continueAfterTie,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text('Start Tie-Break Round $_roundNumber'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
