import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../services/memory_challenge_ai_service.dart';

class MemoryChallengeScreen extends StatefulWidget {
  const MemoryChallengeScreen({super.key});

  @override
  State<MemoryChallengeScreen> createState() => _MemoryChallengeScreenState();
}

class _MemoryChallengeScreenState extends State<MemoryChallengeScreen> {
  final MemoryChallengeAiService _aiService = MemoryChallengeAiService();

  bool _isLoading = false;
  bool _isPlaying = false;
  bool _showResults = false;

  String? _errorMessage;

  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;

  List<_PlayableMemoryQuestion> _questions = [];

  Future<void> _startChallenge() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _errorMessage = 'You must be signed in to play Memory Challenge.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isPlaying = false;
      _showResults = false;
      _errorMessage = null;
      _currentIndex = 0;
      _score = 0;
      _selectedAnswer = null;
      _questions = [];
    });

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final familyId = userDoc.data()?['familyId'] as String?;

      if (familyId == null || familyId.isEmpty) {
        throw Exception('NO_FAMILY');
      }

      final memorySnapshot = await FirebaseFirestore.instance
          .collection('families')
          .doc(familyId)
          .collection('memories')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      final eligibleMemories = memorySnapshot.docs.where((document) {
        final data = document.data();
        final imageUrl = data['imageUrl'] as String?;

        return imageUrl != null && imageUrl.trim().isNotEmpty;
      }).toList();

      if (eligibleMemories.isEmpty) {
        throw Exception('NO_MEMORIES');
      }

      eligibleMemories.shuffle(Random());

      final selectedMemories = eligibleMemories.take(5).toList();

      final generatedQuestions = <_PlayableMemoryQuestion>[];

      for (final memory in selectedMemories) {
        final data = memory.data();

        final imageUrl = data['imageUrl'] as String;
        final title = data['title'] as String? ?? 'Family Memory';
        final description = data['description'] as String? ?? '';
        final location = data['location'] as String? ?? '';

        final timestamp = data['date'] as Timestamp?;
        final date = timestamp?.toDate();

        final formattedDate = date == null
            ? ''
            : '${date.day.toString().padLeft(2, '0')}/'
                  '${date.month.toString().padLeft(2, '0')}/'
                  '${date.year}';

        try {
          final questions = await _aiService.generateQuestions(
            imageUrl: imageUrl,
            title: title,
            description: description,
            location: location,
            date: formattedDate,
            count: 1,
          );

          if (questions.isEmpty) {
            continue;
          }

          generatedQuestions.add(
            _PlayableMemoryQuestion(
              memoryId: memory.id,
              memoryTitle: title,
              imageUrl: imageUrl,
              question: questions.first,
            ),
          );
        } catch (_) {
          // Skip memories that cannot generate a safe question.
        }
      }

      if (generatedQuestions.isEmpty) {
        throw Exception('GENERATION_FAILED');
      }

      if (!mounted) return;

      setState(() {
        _questions = generatedQuestions;
        _isLoading = false;
        _isPlaying = true;
      });
    } catch (error) {
      if (!mounted) return;

      String message;

      if (error.toString().contains('NO_FAMILY')) {
        message = 'Join or create a family before playing Memory Challenge.';
      } else if (error.toString().contains('NO_MEMORIES')) {
        message =
            'Your family needs at least one memory with a photo before playing.';
      } else {
        message =
            'We could not create a Memory Challenge right now. Make sure the AI server is running and try again.';
      }

      setState(() {
        _isLoading = false;
        _errorMessage = message;
      });
    }
  }

  void _selectAnswer(int index) {
    if (_selectedAnswer != null) return;

    setState(() {
      _selectedAnswer = index;

      if (index == _questions[_currentIndex].question.correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
      });

      return;
    }

    setState(() {
      _isPlaying = false;
      _showResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memory Challenge')),
      body: SafeArea(
        child: _showResults
            ? _buildResults()
            : _isPlaying
            ? _buildGame()
            : _buildSetup(),
      ),
    );
  }

  Widget _buildSetup() {
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
                  color: AppTheme.primaryColor.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        gradient: AppTheme.brandGradient,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: const Icon(
                        Icons.photo_library_rounded,
                        size: 42,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'How well do you remember?',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sila uses your family photos and stories to create unique questions from moments you shared together.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 24),
                Text(_errorMessage!, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _isLoading ? null : _startChallenge,
                child: Text(
                  _isLoading
                      ? 'Creating your challenge...'
                      : 'Start Memory Challenge',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGame() {
    final playableQuestion = _questions[_currentIndex];
    final question = playableQuestion.question;

    final showPhoto = question.type == 'visual' || question.type == 'memory';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Question ${_currentIndex + 1} of ${_questions.length}'),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _questions.length,
              ),
              const SizedBox(height: 24),
              if (showPhoto) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.network(
                      playableQuestion.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    question.question,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ...List.generate(question.options.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OutlinedButton(
                    onPressed: _selectedAnswer == null
                        ? () => _selectAnswer(index)
                        : null,
                    child: Text(question.options[index]),
                  ),
                );
              }),
              if (_selectedAnswer != null) ...[
                const SizedBox(height: 12),
                Text(
                  _selectedAnswer == question.correctIndex
                      ? 'Correct!'
                      : 'Correct answer: ${question.options[question.correctIndex]}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: _nextQuestion,
                  child: Text(
                    _currentIndex == _questions.length - 1
                        ? 'See Results'
                        : 'Next Memory',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 80),
            const SizedBox(height: 24),
            Text(
              'Memory Challenge Complete!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Score: $_score / ${_questions.length}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _startChallenge,
              child: const Text('Play Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayableMemoryQuestion {
  const _PlayableMemoryQuestion({
    required this.memoryId,
    required this.memoryTitle,
    required this.imageUrl,
    required this.question,
  });

  final String memoryId;
  final String memoryTitle;
  final String imageUrl;
  final MemoryChallengeQuestion question;
}
