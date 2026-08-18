import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'games_screen.dart';

class QuickPlayPlayerSelectionScreen extends StatefulWidget {
  const QuickPlayPlayerSelectionScreen({
    super.key,
    this.developerPreview = false,
  });

  final bool developerPreview;

  @override
  State<QuickPlayPlayerSelectionScreen> createState() =>
      _QuickPlayPlayerSelectionScreenState();
}

class _QuickPlayPlayerSelectionScreenState
    extends State<QuickPlayPlayerSelectionScreen> {
  final List<_QuickPlayMember> _members = [];
  final Set<String> _selectedIds = {};

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    if (widget.developerPreview) {
      _loadPreview();
    } else {
      _loadFamilyMembers();
    }
  }

  void _loadPreview() {
    const members = [
      _QuickPlayMember(id: 'preview-1', name: 'Alex'),
      _QuickPlayMember(id: 'preview-2', name: 'Sam'),
      _QuickPlayMember(id: 'preview-3', name: 'Jordan'),
      _QuickPlayMember(id: 'preview-4', name: 'Taylor'),
    ];

    setState(() {
      _members
        ..clear()
        ..addAll(members);

      _selectedIds
        ..clear()
        ..addAll(members.map((member) => member.id));

      _isLoading = false;
    });
  }

  Future<void> _loadFamilyMembers() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please sign in before starting Quick Play.';
      });

      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;

      final userDoc = await firestore.collection('users').doc(user.uid).get();
      final familyId = userDoc.data()?['familyId']?.toString();

      if (familyId == null || familyId.isEmpty) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _errorMessage = 'Join or create a family before starting Quick Play.';
        });

        return;
      }

      final snapshot = await firestore
          .collection('users')
          .where('familyId', isEqualTo: familyId)
          .get();

      final members = snapshot.docs.map((document) {
        final data = document.data();

        final name = data['name']?.toString().trim();
        final email = data['email']?.toString().trim();

        return _QuickPlayMember(
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

      if (!mounted) return;

      setState(() {
        _members
          ..clear()
          ..addAll(members);

        _selectedIds
          ..clear()
          ..addAll(members.map((member) => member.id));

        _isLoading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load your family members.';
      });
    }
  }

  void _toggleMember(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _continueToGames() {
    if (_selectedIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quick Play needs at least 2 family members.'),
        ),
      );

      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GamesScreen(
          developerPreview: widget.developerPreview,
          participantIds: Set<String>.from(_selectedIds),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Players')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? _buildError()
            : _buildPlayerSelection(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.group_off_rounded, size: 64),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });

                _loadFamilyMembers();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerSelection() {
    if (_members.length < 2) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Quick Play needs at least 2 family members.',
            textAlign: TextAlign.center,
          ),
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
                'Who is playing?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose the family members who are together for this Quick Play session.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              ..._members.map((member) {
                final selected = _selectedIds.contains(member.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: CheckboxListTile(
                    value: selected,
                    onChanged: (_) => _toggleMember(member.id),
                    secondary: CircleAvatar(
                      child: Text(
                        member.name.isEmpty
                            ? '?'
                            : member.name[0].toUpperCase(),
                      ),
                    ),
                    title: Text(member.name),
                  ),
                );
              }),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${_selectedIds.length} players selected',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: _selectedIds.length >= 2 ? _continueToGames : null,
                  icon: const Icon(Icons.sports_esports_rounded),
                  label: const Text('Choose Game'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickPlayMember {
  const _QuickPlayMember({required this.id, required this.name});

  final String id;
  final String name;
}
