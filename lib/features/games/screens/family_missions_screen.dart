import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class FamilyMissionsScreen extends StatefulWidget {
  const FamilyMissionsScreen({super.key});

  @override
  State<FamilyMissionsScreen> createState() => _FamilyMissionsScreenState();
}

class _FamilyMissionsScreenState extends State<FamilyMissionsScreen> {
  static const List<_FamilyMission> _missions = [
    _FamilyMission(
      id: 'family_walk',
      icon: Icons.directions_walk_rounded,
      title: 'Take a Family Walk',
      description:
          'Spend at least 15 minutes walking together without rushing.',
    ),
    _FamilyMission(
      id: 'meal_together',
      icon: Icons.restaurant_rounded,
      title: 'Share a Meal Together',
      description:
          'Sit together for a meal and keep phones away from the table.',
    ),
    _FamilyMission(
      id: 'family_photo',
      icon: Icons.photo_camera_rounded,
      title: 'Capture Today',
      description:
          'Take a new family photo and save the moment in your memories.',
    ),
    _FamilyMission(
      id: 'appreciation',
      icon: Icons.favorite_rounded,
      title: 'Share Some Appreciation',
      description:
          'Tell one family member something you appreciate about them.',
    ),
    _FamilyMission(
      id: 'call_relative',
      icon: Icons.phone_in_talk_rounded,
      title: 'Call Someone You Love',
      description:
          'Call or video chat with a relative you have not spoken to recently.',
    ),
    _FamilyMission(
      id: 'play_together',
      icon: Icons.sports_esports_rounded,
      title: 'Play Together',
      description: 'Play any Sila family game or another game together.',
    ),
    _FamilyMission(
      id: 'family_story',
      icon: Icons.auto_stories_rounded,
      title: 'Share a Family Story',
      description:
          'Ask someone to share a funny, meaningful, or memorable family story.',
    ),
    _FamilyMission(
      id: 'help_each_other',
      icon: Icons.volunteer_activism_rounded,
      title: 'Help Each Other',
      description:
          'Do one helpful thing for a family member without being asked.',
    ),
  ];

  final Set<String> _completedMissionIds = {};
  final Set<String> _savingMissionIds = {};

  bool _isLoading = true;
  String? _familyId;
  String? _errorMessage;

  String get _dateKey {
    final now = DateTime.now();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'You must be signed in to view Family Missions.';
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
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Join or create a family before completing Family Missions.';
        });

        return;
      }

      final completedIds = <String>{};

      for (final mission in _missions) {
        final completionId = '${_dateKey}_${user.uid}_${mission.id}';

        final completionDoc = await FirebaseFirestore.instance
            .collection('families')
            .doc(familyId)
            .collection('missionCompletions')
            .doc(completionId)
            .get();

        if (completionDoc.exists) {
          completedIds.add(mission.id);
        }
      }

      if (!mounted) return;

      setState(() {
        _familyId = familyId;
        _completedMissionIds
          ..clear()
          ..addAll(completedIds);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load Family Missions. Please try again.';
      });
    }
  }

  Future<void> _completeMission(_FamilyMission mission) async {
    final user = FirebaseAuth.instance.currentUser;
    final familyId = _familyId;

    if (user == null || familyId == null) return;

    if (_completedMissionIds.contains(mission.id) ||
        _savingMissionIds.contains(mission.id)) {
      return;
    }

    setState(() {
      _savingMissionIds.add(mission.id);
    });

    try {
      final firestore = FirebaseFirestore.instance;

      final completionId = '${_dateKey}_${user.uid}_${mission.id}';

      final completionRef = firestore
          .collection('families')
          .doc(familyId)
          .collection('missionCompletions')
          .doc(completionId);

      final userRef = firestore.collection('users').doc(user.uid);

      final completed = await firestore.runTransaction<bool>((
        transaction,
      ) async {
        final existingCompletion = await transaction.get(completionRef);

        if (existingCompletion.exists) {
          return false;
        }

        transaction.set(completionRef, {
          'missionId': mission.id,
          'missionTitle': mission.title,
          'userId': user.uid,
          'familyId': familyId,
          'dateKey': _dateKey,
          'completedAt': FieldValue.serverTimestamp(),
          'tokenReward': 5,
        });

        transaction.update(userRef, {
          'missionsCompleted': FieldValue.increment(1),
          'tokens': FieldValue.increment(5),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return true;
      });

      if (!mounted) return;

      setState(() {
        _savingMissionIds.remove(mission.id);

        if (completed) {
          _completedMissionIds.add(mission.id);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            completed
                ? 'Mission complete! You earned 5 tokens.'
                : 'You already completed this mission today.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _savingMissionIds.remove(mission.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not complete the mission. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Missions')),
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
            : _buildMissionList(),
      ),
    );
  }

  Widget _buildMissionList() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.22),
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.groups_rounded,
                size: 52,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 14),
              Text(
                'Do something meaningful together',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete daily family activities, strengthen your bond, and earn tokens.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${_completedMissionIds.length} / ${_missions.length} completed today',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ..._missions.map((mission) {
          final isCompleted = _completedMissionIds.contains(mission.id);
          final isSaving = _savingMissionIds.contains(mission.id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Icon(mission.icon, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mission.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            mission.description,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.secondaryTextColor),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const Icon(
                                Icons.monetization_on_rounded,
                                size: 18,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 5),
                              const Text('+5 tokens'),
                              const Spacer(),
                              FilledButton.icon(
                                onPressed: isCompleted || isSaving
                                    ? null
                                    : () => _completeMission(mission),
                                icon: isSaving
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        isCompleted
                                            ? Icons.check_rounded
                                            : Icons.flag_rounded,
                                      ),
                                label: Text(
                                  isCompleted ? 'Completed' : 'Complete',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _FamilyMission {
  const _FamilyMission({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
  });

  final String id;
  final IconData icon;
  final String title;
  final String description;
}
