import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RewardApproversScreen extends StatefulWidget {
  const RewardApproversScreen({super.key});

  @override
  State<RewardApproversScreen> createState() => _RewardApproversScreenState();
}

class _RewardApproversScreenState extends State<RewardApproversScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  String? _error;
  String? _familyId;
  String? _ownerId;

  final List<_ApproverMember> _members = [];
  final Set<String> _selectedApproverIds = {};

  @override
  void initState() {
    super.initState();
    _loadFamily();
  }

  Future<void> _loadFamily() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _error = 'No user is signed in.';
      });
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final familyId = userDoc.data()?['familyId']?.toString().trim();

      if (familyId == null || familyId.isEmpty) {
        throw Exception('Join a family first.');
      }

      final familyRef = FirebaseFirestore.instance
          .collection('families')
          .doc(familyId);

      final familyDoc = await familyRef.get();

      if (!familyDoc.exists) {
        throw Exception('Family not found.');
      }

      final familyData = familyDoc.data()!;

      final ownerId = familyData['ownerId']?.toString();

      if (ownerId != user.uid) {
        throw Exception('Only the Family Admin can manage reward approvers.');
      }

      final memberIds = List<String>.from(
        familyData['members'] ?? const <String>[],
      );

      final approverIds = List<String>.from(
        familyData['rewardApproverIds'] ?? const <String>[],
      );

      final members = <_ApproverMember>[];

      for (final memberId in memberIds) {
        final memberDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(memberId)
            .get();

        final data = memberDoc.data();

        final name = data?['name']?.toString().trim();
        final email = data?['email']?.toString().trim();

        members.add(
          _ApproverMember(
            id: memberId,
            name: name != null && name.isNotEmpty
                ? name
                : email ?? 'Family Member',
          ),
        );
      }

      members.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      if (!mounted) return;

      setState(() {
        _familyId = familyId;
        _ownerId = ownerId;

        _members
          ..clear()
          ..addAll(members);

        _selectedApproverIds
          ..clear()
          ..addAll(approverIds);

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = _messageFromError(error);
      });
    }
  }

  String _messageFromError(Object error) {
    final text = error.toString();

    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
    }

    return 'Something went wrong. Please try again.';
  }

  void _toggleApprover(String memberId) {
    if (memberId == _ownerId) {
      return;
    }

    setState(() {
      if (_selectedApproverIds.contains(memberId)) {
        _selectedApproverIds.remove(memberId);
      } else {
        _selectedApproverIds.add(memberId);
      }
    });
  }

  Future<void> _saveApprovers() async {
    if (_isSaving || _familyId == null) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.uid != _ownerId) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final approverIds = _selectedApproverIds
          .where((id) => id != _ownerId)
          .toList();

      await FirebaseFirestore.instance
          .collection('families')
          .doc(_familyId)
          .update({
            'rewardApproverIds': approverIds,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reward approvers updated.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_messageFromError(error))));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reward Approvers')),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Choose Reward Approvers',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Approvers can approve or decline real-life Family Reward requests.',
              ),

              const SizedBox(height: 24),

              ..._members.map((member) {
                final isOwner = member.id == _ownerId;

                final selected =
                    isOwner || _selectedApproverIds.contains(member.id);

                return Card(
                  child: CheckboxListTile(
                    value: selected,
                    onChanged: isOwner
                        ? null
                        : (_) {
                            _toggleApprover(member.id);
                          },
                    secondary: CircleAvatar(
                      child: isOwner
                          ? const Icon(Icons.workspace_premium_rounded)
                          : Text(
                              member.name.isEmpty
                                  ? '?'
                                  : member.name[0].toUpperCase(),
                            ),
                    ),
                    title: Text(
                      member.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: isOwner
                        ? const Text('Family Owner • Always an approver')
                        : selected
                        ? const Text('Reward Approver')
                        : const Text('Family Member'),
                  ),
                );
              }),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _saveApprovers,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(_isSaving ? 'Saving...' : 'Save Approvers'),
            ),
          ),
        ),
      ],
    );
  }
}

class _ApproverMember {
  const _ApproverMember({required this.id, required this.name});

  final String id;
  final String name;
}
