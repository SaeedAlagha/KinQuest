import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../models/family_mission.dart';
import '../models/family_mission_localizations.dart';
import '../services/family_mission_ai_service.dart';

class FamilyMissionsScreen extends StatefulWidget {
  const FamilyMissionsScreen({super.key, this.developerPreview = false});

  final bool developerPreview;

  @override
  State<FamilyMissionsScreen> createState() => _FamilyMissionsScreenState();
}

class _FamilyMissionsScreenState extends State<FamilyMissionsScreen> {
  static const int _personalMissionCount = 6;
  static const int _familyMissionCount = 4;
  static const int _maxProofBytes = 700 * 1024;

  final _picker = ImagePicker();
  final _aiService = const FamilyMissionAiService();
  final _random = Random();
  String get _weekKey {
    final now = DateTime.now();

    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - DateTime.monday));

    return '${monday.year}-'
        '${monday.month.toString().padLeft(2, '0')}-'
        '${monday.day.toString().padLeft(2, '0')}';
  }

  final List<_MissionAssignment> _personalAssignments = [];
  final List<_MissionAssignment> _familyAssignments = [];
  final List<_MissionHistoryItem> _history = [];
  final List<_FamilyMember> _familyMembers = [];

  bool _isLoading = true;
  bool _isSaving = false;

  String? _familyId;
  String? _currentUserId;
  _MissionLoadError? _loadError;

  @override
  void initState() {
    super.initState();

    if (widget.developerPreview) {
      _loadPreview();
    } else {
      _loadBoard();
    }
  }

  void _loadPreview() {
    final personal = FamilyMissionCatalog.personal
        .take(_personalMissionCount)
        .map(_newAssignment)
        .toList();

    final family = FamilyMissionCatalog.family
        .take(_familyMissionCount)
        .map(_newAssignment)
        .toList();

    setState(() {
      _currentUserId = 'preview-user';

      _familyMembers
        ..clear()
        ..addAll(const [
          _FamilyMember(id: 'preview-user', name: 'You'),
          _FamilyMember(id: 'preview-member-2', name: 'Alex'),
          _FamilyMember(id: 'preview-member-3', name: 'Sam'),
        ]);

      _personalAssignments
        ..clear()
        ..addAll(personal);

      _familyAssignments
        ..clear()
        ..addAll(family);

      _isLoading = false;
    });
  }

  Future<void> _loadBoard() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _loadError = _MissionLoadError.signInRequired;
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
          _loadError = _MissionLoadError.familyRequired;
        });

        return;
      }

      final memberSnapshot = await firestore
          .collection('users')
          .where('familyId', isEqualTo: familyId)
          .get();

      final members = memberSnapshot.docs.map((document) {
        final data = document.data();

        final name = data['name']?.toString().trim();
        final email = data['email']?.toString().trim();

        return _FamilyMember(
          id: document.id,
          name: name?.isNotEmpty == true
              ? name!
              : email?.isNotEmpty == true
              ? email!
              : 'Family Member',
        );
      }).toList();

      members.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      final familyRef = firestore.collection('families').doc(familyId);

      final completionSnapshot = await familyRef
          .collection('missionCompletions')
          .get();

      final allCompletionData = completionSnapshot.docs
          .map((document) => document.data())
          .toList();

      final personalCompletionData = allCompletionData.where((data) {
        final scope = data['scope']?.toString();

        if (scope == 'personal') {
          return data['userId'] == user.uid;
        }

        // Support older mission completion records.
        return scope == null && data['userId'] == user.uid;
      }).toList();

      final familyCompletionData = allCompletionData.where((data) {
        return data['scope']?.toString() == 'family';
      }).toList();

      final personalBoardRef = familyRef
          .collection('missionBoards')
          .doc('personal_${user.uid}');

      final familyBoardRef = familyRef
          .collection('missionBoards')
          .doc('family_shared');

      final personalBoardDoc = await personalBoardRef.get();

      final familyBoardDoc = await familyBoardRef.get();

      final personalBoardWeekKey = personalBoardDoc
          .data()?['weekKey']
          ?.toString();

      final personalAssignments = personalBoardWeekKey == _weekKey
          ? _parseAssignments(
              personalBoardDoc.data()?['assignments'],
              MissionScope.personal,
            )
          : <_MissionAssignment>[];

      final familyBoardWeekKey = familyBoardDoc.data()?['weekKey']?.toString();

      final familyAssignments = familyBoardWeekKey == _weekKey
          ? _parseAssignments(
              familyBoardDoc.data()?['assignments'],
              MissionScope.family,
            )
          : <_MissionAssignment>[];
      _fillAssignments(
        assignments: personalAssignments,
        scope: MissionScope.personal,
        desiredCount: _personalMissionCount,
        completionData: personalCompletionData,
      );

      _fillAssignments(
        assignments: familyAssignments,
        scope: MissionScope.family,
        desiredCount: _familyMissionCount,
        completionData: familyCompletionData,
      );

      await personalBoardRef.set({
        'boardType': 'personal',
        'userId': user.uid,
        'familyId': familyId,
        'weekKey': _weekKey,
        'assignments': personalAssignments
            .map((item) => item.toFirestore())
            .toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      // Only create the shared board if one does not
      // already exist. This keeps every family member
      // looking at the same assignments.
      // Create or refresh the shared family board once per week.
      // The transaction ensures every family member uses the same
      // shared assignments for the current week.
      await firestore.runTransaction((transaction) async {
        final freshFamilyBoard = await transaction.get(familyBoardRef);

        final storedWeekKey = freshFamilyBoard.data()?['weekKey']?.toString();

        if (!freshFamilyBoard.exists || storedWeekKey != _weekKey) {
          transaction.set(familyBoardRef, {
            'boardType': 'family',
            'familyId': familyId,
            'weekKey': _weekKey,
            'assignments': familyAssignments
                .map((item) => item.toFirestore())
                .toList(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      final freshSharedBoard = await familyBoardRef.get();

      final sharedFamilyAssignments = _parseAssignments(
        freshSharedBoard.data()?['assignments'],
        MissionScope.family,
      );

      if (sharedFamilyAssignments.length < _familyMissionCount) {
        _fillAssignments(
          assignments: sharedFamilyAssignments,
          scope: MissionScope.family,
          desiredCount: _familyMissionCount,
          completionData: familyCompletionData,
        );

        await familyBoardRef.set({
          'boardType': 'family',
          'familyId': familyId,
          'weekKey': _weekKey,
          'assignments': sharedFamilyAssignments
              .map((item) => item.toFirestore())
              .toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      final history =
          completionSnapshot.docs
              .map((document) => _historyFromDocument(document, user.uid))
              .whereType<_MissionHistoryItem>()
              .toList()
            ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

      if (!mounted) return;

      setState(() {
        _familyId = familyId;
        _currentUserId = user.uid;

        _familyMembers
          ..clear()
          ..addAll(members);

        _personalAssignments
          ..clear()
          ..addAll(personalAssignments);

        _familyAssignments
          ..clear()
          ..addAll(sharedFamilyAssignments);

        _history
          ..clear()
          ..addAll(history);

        _isLoading = false;
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadError = _MissionLoadError.loadFailed;
      });
    }
  }

  List<_MissionAssignment> _parseAssignments(
    dynamic rawAssignments,
    MissionScope scope,
  ) {
    final result = <_MissionAssignment>[];

    if (rawAssignments is! List) {
      return result;
    }

    for (final raw in rawAssignments) {
      if (raw is! Map) continue;

      final missionId = raw['missionId']?.toString();
      final assignmentId = raw['assignmentId']?.toString();

      if (missionId == null || assignmentId == null) {
        continue;
      }

      final mission = FamilyMissionCatalog.byId(missionId);

      if (mission == null || mission.scope != scope) {
        continue;
      }

      final assignedAtValue = raw['assignedAt'];

      final assignedAt = assignedAtValue is Timestamp
          ? assignedAtValue.toDate()
          : DateTime.now();

      result.add(
        _MissionAssignment(
          assignmentId: assignmentId,
          mission: mission,
          assignedAt: assignedAt,
        ),
      );
    }

    return result;
  }

  void _fillAssignments({
    required List<_MissionAssignment> assignments,
    required MissionScope scope,
    required int desiredCount,
    required List<Map<String, dynamic>> completionData,
  }) {
    while (assignments.length < desiredCount) {
      final mission = _pickMission(
        scope: scope,
        currentAssignments: assignments,
        completionData: completionData,
      );

      if (mission == null) {
        break;
      }

      assignments.add(_newAssignment(mission));
    }

    if (assignments.length > desiredCount) {
      assignments.removeRange(desiredCount, assignments.length);
    }
  }

  FamilyMission? _pickMission({
    required MissionScope scope,
    required List<_MissionAssignment> currentAssignments,
    required List<Map<String, dynamic>> completionData,
  }) {
    final catalog = scope == MissionScope.personal
        ? FamilyMissionCatalog.personal
        : FamilyMissionCatalog.family;

    final activeIds = currentAssignments.map((item) => item.mission.id).toSet();

    final eligible = catalog.where((mission) {
      if (activeIds.contains(mission.id)) {
        return false;
      }

      DateTime? latestCompletion;

      for (final completion in completionData) {
        if (completion['missionId'] != mission.id) {
          continue;
        }

        final timestamp = completion['completedAt'];

        if (timestamp is! Timestamp) {
          continue;
        }

        final date = timestamp.toDate();

        if (latestCompletion == null || date.isAfter(latestCompletion)) {
          latestCompletion = date;
        }
      }

      if (latestCompletion == null) {
        return true;
      }

      final eligibleAgain = latestCompletion.add(
        Duration(days: mission.cooldownDays),
      );

      return !DateTime.now().isBefore(eligibleAgain);
    }).toList();

    if (eligible.isEmpty) {
      return null;
    }

    final activeCategories = currentAssignments
        .map((item) => item.mission.category)
        .toSet();

    final varied = eligible
        .where((mission) => !activeCategories.contains(mission.category))
        .toList();

    final pool = varied.isNotEmpty ? varied : eligible;

    return pool[_random.nextInt(pool.length)];
  }

  _MissionAssignment _newAssignment(FamilyMission mission) {
    final now = DateTime.now();

    return _MissionAssignment(
      assignmentId:
          '${mission.scope.name}_${mission.id}_${now.microsecondsSinceEpoch}_${_random.nextInt(999999)}',
      mission: mission,
      assignedAt: now,
    );
  }

  _MissionHistoryItem? _historyFromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
    String currentUserId,
  ) {
    final data = document.data();

    final missionId = data['missionId']?.toString();

    if (missionId == null) {
      return null;
    }

    final mission = FamilyMissionCatalog.byId(missionId);

    final timestamp = data['completedAt'];

    final completedAt = timestamp is Timestamp
        ? timestamp.toDate()
        : DateTime.fromMillisecondsSinceEpoch(0);

    final rawParticipants = data['participantIds'];

    final participantIds = rawParticipants is List
        ? rawParticipants.map((value) => value.toString()).toList()
        : <String>[];

    final rawNames = data['participantNames'];

    final participantNames = rawNames is List
        ? rawNames.map((value) => value.toString()).toList()
        : <String>[];

    final scopeString = data['scope']?.toString();

    final scope = scopeString == 'family'
        ? MissionScope.family
        : MissionScope.personal;

    final reward =
        (data['tokenRewardPerParticipant'] as num?)?.toInt() ??
        (data['tokenReward'] as num?)?.toInt() ??
        mission?.tokenReward ??
        0;

    final userEarnedReward = scope == MissionScope.personal
        ? data['userId'] == currentUserId
        : participantIds.contains(currentUserId);

    return _MissionHistoryItem(
      missionId: missionId,
      title: data['missionTitle']?.toString() ?? mission?.title ?? 'Mission',
      reward: reward,
      completedAt: completedAt,
      scope: scope,
      participantNames: participantNames,
      userEarnedReward: userEarnedReward,
    );
  }

  Future<void> _openMission(_MissionAssignment assignment) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return _MissionDetailsSheet(
          assignment: assignment,
          onSubmitProof: () {
            Navigator.pop(sheetContext);
            _prepareProofSubmission(assignment);
          },
        );
      },
    );
  }

  Future<void> _prepareProofSubmission(_MissionAssignment assignment) async {
    List<_FamilyMember> participants = [];

    if (assignment.mission.scope == MissionScope.family) {
      final selected = await _selectParticipants();

      if (selected == null || !mounted) {
        return;
      }

      participants = selected;
    } else {
      final strings = AppLocalizations.of(context)!;
      final userId = _currentUserId;

      if (userId == null) return;

      _FamilyMember? currentMember;

      for (final member in _familyMembers) {
        if (member.id == userId) {
          currentMember = member;
          break;
        }
      }

      participants = [
        currentMember ?? _FamilyMember(id: userId, name: strings.you),
      ];
    }

    await _chooseProofSource(assignment, participants);
  }

  Future<List<_FamilyMember>?> _selectParticipants() async {
    final strings = AppLocalizations.of(context)!;
    final currentUserId = _currentUserId;

    final selectedIds = <String>{?currentUserId};
    return showDialog<List<_FamilyMember>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final selectedMembers = _familyMembers
                .where((member) => selectedIds.contains(member.id))
                .toList();

            return AlertDialog(
              title: Text(strings.whoParticipated),
              content: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(strings.participantSelectionDescription),
                    const SizedBox(height: 14),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: _familyMembers.map((member) {
                          final selected = selectedIds.contains(member.id);
                          final memberName = _displayMemberName(
                            member,
                            strings,
                          );

                          return CheckboxListTile(
                            value: selected,
                            title: Text(memberName),
                            secondary: CircleAvatar(
                              child: Text(
                                memberName.isEmpty
                                    ? '?'
                                    : memberName[0].toUpperCase(),
                              ),
                            ),
                            onChanged: (value) {
                              setDialogState(() {
                                if (value == true) {
                                  selectedIds.add(member.id);
                                } else {
                                  selectedIds.remove(member.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(strings.cancel),
                ),
                FilledButton(
                  onPressed: selectedMembers.length < 2
                      ? null
                      : () => Navigator.pop(dialogContext, selectedMembers),
                  child: Text(strings.continueLabel),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _chooseProofSource(
    _MissionAssignment assignment,
    List<_FamilyMember> participants,
  ) async {
    final strings = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_rounded),
                  title: Text(strings.takePhoto),
                  subtitle: Text(strings.useCameraAsProof),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded),
                  title: Text(strings.choosePhotoOrScreenshot),
                  subtitle: Text(strings.chooseExistingImage),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null || !mounted) {
      return;
    }

    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 55,
      maxWidth: 900,
      maxHeight: 900,
    );

    if (pickedFile == null || !mounted) {
      return;
    }

    final bytes = await pickedFile.readAsBytes();

    if (!mounted) return;

    if (bytes.length > _maxProofBytes) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.missionImageTooLarge)));

      return;
    }

    await _showProofReview(
      assignment: assignment,
      participants: participants,
      imageBytes: bytes,
      mimeType: _mimeTypeForPath(pickedFile.path),
    );
  }

  String _mimeTypeForPath(String path) {
    final lower = path.toLowerCase();

    if (lower.endsWith('.png')) {
      return 'image/png';
    }

    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }

    return 'image/jpeg';
  }

  Future<void> _showProofReview({
    required _MissionAssignment assignment,
    required List<_FamilyMember> participants,
    required Uint8List imageBytes,
    required String mimeType,
  }) async {
    final strings = AppLocalizations.of(context)!;
    final noteController = TextEditingController();

    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(strings.reviewYourProof),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.memory(
                      imageBytes,
                      height: 230,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (assignment.mission.scope == MissionScope.family) ...[
                    const SizedBox(height: 16),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        strings.participantsLabel(
                          participants
                              .map(
                                (member) => _displayMemberName(member, strings),
                              )
                              .join(', '),
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  TextField(
                    controller: noteController,
                    maxLength: 300,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: strings.explanationOptional,
                      hintText: strings.missionExplanationHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(strings.cancel),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.verified_rounded),
              label: Text(strings.verifyProof),
            ),
          ],
        );
      },
    );

    final note = noteController.text;

    noteController.dispose();

    if (shouldSubmit != true || !mounted) {
      return;
    }

    await _verifyAndComplete(
      assignment: assignment,
      participants: participants,
      imageBytes: imageBytes,
      mimeType: mimeType,
      note: note,
    );
  }

  Future<void> _verifyAndComplete({
    required _MissionAssignment assignment,
    required List<_FamilyMember> participants,
    required Uint8List imageBytes,
    required String mimeType,
    required String note,
  }) async {
    final strings = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(strings.aiCheckingMissionProof)),
            ],
          ),
        );
      },
    );

    try {
      final verification = await _aiService.verifyProof(
        mission: assignment.mission,
        imageBytes: imageBytes,
        mimeType: mimeType,
        note: note,
      );

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      if (!verification.verified) {
        await _showVerificationFailure(verification);
        return;
      }

      await _awardMission(
        assignment: assignment,
        participants: participants,
        imageBytes: imageBytes,
        mimeType: mimeType,
        note: note,
        verification: verification,
      );
    } catch (error, stackTrace) {
      debugPrint('Mission proof verification failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.couldNotVerifyMissionProof)),
      );
    }
  }

  Future<void> _showVerificationFailure(MissionVerificationResult result) {
    final strings = AppLocalizations.of(context)!;

    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(
            result.uncertain
                ? Icons.help_outline_rounded
                : Icons.error_outline_rounded,
          ),
          title: Text(
            result.uncertain
                ? strings.needClearerProof
                : strings.proofNotVerified,
          ),
          content: Text(strings.verificationFailureDescription(result.reason)),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.tryAgain),
            ),
          ],
        );
      },
    );
  }

  Future<void> _awardMission({
    required _MissionAssignment assignment,
    required List<_FamilyMember> participants,
    required Uint8List imageBytes,
    required String mimeType,
    required String note,
    required MissionVerificationResult verification,
  }) async {
    final strings = AppLocalizations.of(context)!;

    if (widget.developerPreview) {
      if (!mounted) return;

      await _showSuccessDialog(
        mission: assignment.mission,
        participants: participants,
      );

      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final familyId = _familyId;

    if (user == null || familyId == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (assignment.mission.scope == MissionScope.personal) {
        await _awardPersonalMission(
          userId: user.uid,
          familyId: familyId,
          assignment: assignment,
          imageBytes: imageBytes,
          mimeType: mimeType,
          note: note,
          verification: verification,
        );
      } else {
        await _awardFamilyMission(
          submitterId: user.uid,
          familyId: familyId,
          assignment: assignment,
          participants: participants,
          imageBytes: imageBytes,
          mimeType: mimeType,
          note: note,
          verification: verification,
        );
      }

      if (!mounted) return;

      await _loadBoard();

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      await _showSuccessDialog(
        mission: assignment.mission,
        participants: participants,
      );
    } on _AlreadyRewardedException {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.missionAlreadyRewarded)));

      await _loadBoard();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.missionRewardSaveError)));
    }
  }

  Future<void> _awardPersonalMission({
    required String userId,
    required String familyId,
    required _MissionAssignment assignment,
    required Uint8List imageBytes,
    required String mimeType,
    required String note,
    required MissionVerificationResult verification,
  }) async {
    final firestore = FirebaseFirestore.instance;

    final familyRef = firestore.collection('families').doc(familyId);

    final boardRef = familyRef
        .collection('missionBoards')
        .doc('personal_$userId');

    final completionRef = familyRef
        .collection('missionCompletions')
        .doc('personal_${userId}_${assignment.assignmentId}');

    final userRef = firestore.collection('users').doc(userId);

    final completionSnapshot = await familyRef
        .collection('missionCompletions')
        .get();

    final completionData = completionSnapshot.docs
        .map((document) => document.data())
        .where(
          (data) => data['scope'] == 'personal' && data['userId'] == userId,
        )
        .toList();

    final remaining = List<_MissionAssignment>.from(_personalAssignments)
      ..removeWhere((item) => item.assignmentId == assignment.assignmentId);

    final replacement = _pickMission(
      scope: MissionScope.personal,
      currentAssignments: remaining,
      completionData: [
        ...completionData,
        {'missionId': assignment.mission.id, 'completedAt': Timestamp.now()},
      ],
    );

    if (replacement != null) {
      remaining.add(_newAssignment(replacement));
    }

    final rewarded = await firestore.runTransaction<bool>((transaction) async {
      final existing = await transaction.get(completionRef);

      if (existing.exists) {
        return false;
      }

      transaction.set(completionRef, {
        'scope': 'personal',
        'missionId': assignment.mission.id,
        'missionTitle': assignment.mission.title,
        'assignmentId': assignment.assignmentId,
        'userId': userId,
        'familyId': familyId,
        'tokenReward': assignment.mission.tokenReward,
        'tokenRewardPerParticipant': assignment.mission.tokenReward,
        'participantIds': [userId],
        'completedAt': FieldValue.serverTimestamp(),
        'proof': Blob(imageBytes),
        'proofMimeType': mimeType,
        'proofNote': note.trim(),
        'verificationVerdict': verification.verdict,
        'verificationConfidence': verification.confidence,
        'verificationReason': verification.reason,
        'submittedBy': userId,
        'rewarded': true,
      });

      transaction.update(userRef, {
        'missionsCompleted': FieldValue.increment(1),
        'tokens': FieldValue.increment(assignment.mission.tokenReward),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(boardRef, {
        'boardType': 'personal',
        'userId': userId,
        'familyId': familyId,
        'assignments': remaining.map((item) => item.toFirestore()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    });

    if (!rewarded) {
      throw const _AlreadyRewardedException();
    }
  }

  Future<void> _awardFamilyMission({
    required String submitterId,
    required String familyId,
    required _MissionAssignment assignment,
    required List<_FamilyMember> participants,
    required Uint8List imageBytes,
    required String mimeType,
    required String note,
    required MissionVerificationResult verification,
  }) async {
    if (participants.length < 2) {
      throw Exception('A family mission needs at least 2 participants.');
    }

    final firestore = FirebaseFirestore.instance;

    final familyRef = firestore.collection('families').doc(familyId);

    final boardRef = familyRef.collection('missionBoards').doc('family_shared');

    // No user ID in this completion ID.
    // The entire family can claim this
    // assignment only once.
    final completionRef = familyRef
        .collection('missionCompletions')
        .doc('family_${assignment.assignmentId}');

    final completionSnapshot = await familyRef
        .collection('missionCompletions')
        .get();

    final familyCompletionData = completionSnapshot.docs
        .map((document) => document.data())
        .where((data) => data['scope'] == 'family')
        .toList();

    final remaining = List<_MissionAssignment>.from(_familyAssignments)
      ..removeWhere((item) => item.assignmentId == assignment.assignmentId);

    final replacement = _pickMission(
      scope: MissionScope.family,
      currentAssignments: remaining,
      completionData: [
        ...familyCompletionData,
        {'missionId': assignment.mission.id, 'completedAt': Timestamp.now()},
      ],
    );

    if (replacement != null) {
      remaining.add(_newAssignment(replacement));
    }

    final participantIds = participants
        .map((member) => member.id)
        .toSet()
        .toList();

    final participantNames = participants.map((member) => member.name).toList();

    final rewarded = await firestore.runTransaction<bool>((transaction) async {
      final existing = await transaction.get(completionRef);

      if (existing.exists) {
        return false;
      }

      final currentBoard = await transaction.get(boardRef);

      final currentAssignments = _parseAssignments(
        currentBoard.data()?['assignments'],
        MissionScope.family,
      );

      final assignmentStillActive = currentAssignments.any(
        (item) => item.assignmentId == assignment.assignmentId,
      );

      if (!assignmentStillActive) {
        return false;
      }

      transaction.set(completionRef, {
        'scope': 'family',
        'missionId': assignment.mission.id,
        'missionTitle': assignment.mission.title,
        'assignmentId': assignment.assignmentId,
        'familyId': familyId,
        'submittedBy': submitterId,
        'participantIds': participantIds,
        'participantNames': participantNames,
        'tokenRewardPerParticipant': assignment.mission.tokenReward,
        'totalTokenReward':
            assignment.mission.tokenReward * participantIds.length,
        'completedAt': FieldValue.serverTimestamp(),
        'proof': Blob(imageBytes),
        'proofMimeType': mimeType,
        'proofNote': note.trim(),
        'verificationVerdict': verification.verdict,
        'verificationConfidence': verification.confidence,
        'verificationReason': verification.reason,
        'rewarded': true,
      });

      for (final participantId in participantIds) {
        final userRef = firestore.collection('users').doc(participantId);

        transaction.update(userRef, {
          'missionsCompleted': FieldValue.increment(1),
          'tokens': FieldValue.increment(assignment.mission.tokenReward),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      transaction.set(boardRef, {
        'boardType': 'family',
        'familyId': familyId,
        'assignments': remaining.map((item) => item.toFirestore()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    });

    if (!rewarded) {
      throw const _AlreadyRewardedException();
    }
  }

  Future<void> _showSuccessDialog({
    required FamilyMission mission,
    required List<_FamilyMember> participants,
  }) {
    final strings = AppLocalizations.of(context)!;
    final familyMission = mission.scope == MissionScope.family;

    final participantText = participants
        .map((member) => _displayMemberName(member, strings))
        .join(', ');

    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.verified_rounded,
            size: 54,
            color: AppTheme.primaryColor,
          ),
          title: Text(strings.missionVerified),
          content: Text(
            familyMission
                ? strings.familyMissionRewardSuccess(
                    mission.tokenReward,
                    participantText,
                  )
                : strings.personalMissionRewardSuccess(mission.tokenReward),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.nice),
            ),
          ],
        );
      },
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Outdoor':
        return Icons.park_rounded;
      case 'Together Time':
        return Icons.groups_rounded;
      case 'Memories':
        return Icons.photo_library_rounded;
      case 'Kindness':
        return Icons.favorite_rounded;
      case 'Connection':
        return Icons.forum_rounded;
      case 'Fun':
        return Icons.celebration_rounded;
      case 'Teamwork':
        return Icons.handshake_rounded;
      default:
        return Icons.flag_rounded;
    }
  }

  String _difficultyLabel(
    MissionDifficulty difficulty,
    AppLocalizations strings,
  ) {
    switch (difficulty) {
      case MissionDifficulty.easy:
        return strings.difficultyEasy;
      case MissionDifficulty.medium:
        return strings.difficultyMedium;
      case MissionDifficulty.hard:
        return strings.difficultyChallenge;
    }
  }

  String _formatDate(DateTime date) {
    return MaterialLocalizations.of(context).formatCompactDate(date);
  }

  String _displayMemberName(_FamilyMember member, AppLocalizations strings) {
    if (member.id == _currentUserId) {
      return strings.you;
    }

    if (member.name == 'Family Member') {
      return strings.familyMember;
    }

    return member.name;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.familyMissions)),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
            ? _buildError()
            : _buildContent(),
      ),
    );
  }

  Widget _buildError() {
    final strings = AppLocalizations.of(context)!;
    final message = switch (_loadError!) {
      _MissionLoadError.signInRequired => strings.missionsSignInRequired,
      _MissionLoadError.familyRequired => strings.missionsFamilyRequired,
      _MissionLoadError.loadFailed => strings.missionsLoadError,
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _loadError = null;
                });

                _loadBoard();
              },
              child: Text(strings.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final strings = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: _loadBoard,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader(),
          const SizedBox(height: 28),

          _SectionHeader(
            icon: Icons.person_rounded,
            title: strings.yourMissions,
            subtitle: strings.personalMissionsSubtitle(
              _personalAssignments.length,
            ),
            count: _personalAssignments.length,
          ),
          const SizedBox(height: 14),
          ..._personalAssignments.map(_buildMissionCard),

          const SizedBox(height: 28),

          _SectionHeader(
            icon: Icons.groups_rounded,
            title: strings.familyMissions,
            subtitle: strings.sharedMissionsSubtitle(_familyAssignments.length),
            count: _familyAssignments.length,
          ),
          const SizedBox(height: 14),
          ..._familyAssignments.map(_buildMissionCard),

          if (_history.isNotEmpty) ...[
            const SizedBox(height: 30),
            Text(
              strings.recentlyCompleted,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            ..._history.take(10).map(_buildHistoryCard),
          ],

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final strings = AppLocalizations.of(context)!;
    final currentUserId = _currentUserId;

    final userEarned = _history.fold<int>(
      0,
      (total, item) => total + (item.userEarnedReward ? item.reward : 0),
    );

    final userCompleted = _history.where((item) {
      if (item.scope == MissionScope.personal) {
        return item.userEarnedReward;
      }

      return currentUserId != null && item.userEarnedReward;
    }).length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.flag_circle_rounded,
            size: 58,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 14),
          Text(
            strings.doMoreTogether,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            strings.missionsHeaderDescription(
              _personalAssignments.length + _familyAssignments.length,
            ),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.secondaryTextColor),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _StatChip(
                icon: Icons.task_alt_rounded,
                text: strings.missionsCompletedCount(userCompleted),
              ),
              _StatChip(
                icon: Icons.monetization_on_rounded,
                text: strings.missionTokensEarnedCount(userEarned),
              ),
              _StatChip(
                icon: Icons.verified_rounded,
                text: strings.aiProofRequired,
              ),
            ],
          ),
          if (_isSaving) ...[
            const SizedBox(height: 18),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildMissionCard(_MissionAssignment assignment) {
    final strings = AppLocalizations.of(context)!;
    final mission = assignment.mission;
    final copy = LocalizedFamilyMissionCopy.forMission(strings, mission);

    final familyMission = mission.scope == MissionScope.family;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isSaving ? null : () => _openMission(assignment),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    _categoryIcon(mission.category),
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        copy.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        copy.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _SmallLabel(
                            text: familyMission
                                ? strings.profileFamilySection
                                : strings.personalLabel,
                          ),
                          _SmallLabel(
                            text: LocalizedFamilyMissionCopy.category(
                              strings,
                              mission.category,
                            ),
                          ),
                          _SmallLabel(
                            text: _difficultyLabel(mission.difficulty, strings),
                          ),
                          _SmallLabel(
                            text: strings.missionTokenReward(
                              mission.tokenReward,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(
                            Icons.verified_user_rounded,
                            size: 17,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              familyMission
                                  ? strings.aiProofFamilyReward
                                  : strings.aiProofPersonalReward,
                            ),
                          ),
                          Icon(
                            Directionality.of(context) == TextDirection.rtl
                                ? Icons.chevron_left_rounded
                                : Icons.chevron_right_rounded,
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
      ),
    );
  }

  Widget _buildHistoryCard(_MissionHistoryItem item) {
    final strings = AppLocalizations.of(context)!;
    final familyMission = item.scope == MissionScope.family;
    final catalogMission = FamilyMissionCatalog.byId(item.missionId);
    final title = catalogMission == null
        ? item.title
        : LocalizedFamilyMissionCopy.forMission(strings, catalogMission).title;

    String subtitle = strings.completedOn(_formatDate(item.completedAt));

    if (familyMission && item.participantNames.isNotEmpty) {
      subtitle +=
          '\n${strings.participantsLabel(item.participantNames.join(', '))}';
    }

    return Card(
      child: ListTile(
        isThreeLine: familyMission && item.participantNames.isNotEmpty,
        leading: CircleAvatar(
          child: Icon(
            familyMission ? Icons.groups_rounded : Icons.person_rounded,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: item.userEarnedReward
            ? Text(
                '+${item.reward}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              )
            : Text(strings.profileFamilySection),
      ),
    );
  }
}

class _MissionDetailsSheet extends StatelessWidget {
  const _MissionDetailsSheet({
    required this.assignment,
    required this.onSubmitProof,
  });

  final _MissionAssignment assignment;
  final VoidCallback onSubmitProof;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final mission = assignment.mission;
    final copy = LocalizedFamilyMissionCopy.forMission(strings, mission);

    final familyMission = mission.scope == MissionScope.family;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 26),
          Text(
            copy.title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(
            copy.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          Card(
            child: ListTile(
              leading: Icon(
                familyMission ? Icons.groups_rounded : Icons.person_rounded,
                color: AppTheme.primaryColor,
              ),
              title: Text(
                familyMission
                    ? strings.familyMissionLabel
                    : strings.personalMissionLabel,
              ),
              subtitle: Text(
                familyMission
                    ? strings.familyMissionDetailsReward(mission.tokenReward)
                    : strings.personalMissionDetailsReward(mission.tokenReward),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.camera_alt_rounded),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          strings.proofGuidance,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(copy.proofHint),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: ListTile(
              leading: const Icon(Icons.hourglass_bottom_rounded),
              title: Text(strings.cooldown),
              subtitle: Text(
                strings.missionCooldownDescription(mission.cooldownDays),
              ),
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: onSubmitProof,
            icon: const Icon(Icons.upload_rounded),
            label: Text(strings.submitProof),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.notYet),
          ),
        ],
      ),
    );
  }
}

class _MissionAssignment {
  const _MissionAssignment({
    required this.assignmentId,
    required this.mission,
    required this.assignedAt,
  });

  final String assignmentId;
  final FamilyMission mission;
  final DateTime assignedAt;

  Map<String, dynamic> toFirestore() {
    return {
      'assignmentId': assignmentId,
      'missionId': mission.id,
      'scope': mission.scope.name,
      'assignedAt': Timestamp.fromDate(assignedAt),
    };
  }
}

class _FamilyMember {
  const _FamilyMember({required this.id, required this.name});

  final String id;
  final String name;
}

class _MissionHistoryItem {
  const _MissionHistoryItem({
    required this.missionId,
    required this.title,
    required this.reward,
    required this.completedAt,
    required this.scope,
    required this.participantNames,
    required this.userEarnedReward,
  });

  final String missionId;
  final String title;
  final int reward;
  final DateTime completedAt;
  final MissionScope scope;
  final List<String> participantNames;
  final bool userEarnedReward;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallLabel extends StatelessWidget {
  const _SmallLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _AlreadyRewardedException implements Exception {
  const _AlreadyRewardedException();
}

enum _MissionLoadError { signInRequired, familyRequired, loadFailed }
