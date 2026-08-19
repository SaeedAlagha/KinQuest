import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'games_screen.dart';

enum _QuickPlayLoadError { signedOut, noFamily, loadFailed }

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
  _QuickPlayLoadError? _loadError;

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
        _loadError = _QuickPlayLoadError.signedOut;
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
          _loadError = _QuickPlayLoadError.noFamily;
        });

        return;
      }

      final snapshot = await firestore
          .collection('users')
          .where('familyId', isEqualTo: familyId)
          .get();

      if (!mounted) return;

      final strings = AppLocalizations.of(context)!;
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
              : strings.familyMemberFallback,
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
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadError = _QuickPlayLoadError.loadFailed;
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
    final strings = AppLocalizations.of(context)!;
    if (_selectedIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.minimumFamilyMembersForGame(strings.quickPlay, 2),
          ),
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
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(strings.choosePlayers)),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
            ? _buildError()
            : _buildPlayerSelection(),
      ),
    );
  }

  Widget _buildError() {
    final strings = AppLocalizations.of(context)!;
    final message = switch (_loadError!) {
      _QuickPlayLoadError.signedOut => strings.mustBeLoggedInToPlay,
      _QuickPlayLoadError.noFamily => strings.joinOrCreateFamilyBeforeGame(
        strings.quickPlay,
      ),
      _QuickPlayLoadError.loadFailed => strings.couldNotLoadFamilyMembers,
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.group_off_rounded, size: 64),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _loadError = null;
                });

                _loadFamilyMembers();
              },
              child: Text(strings.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerSelection() {
    final strings = AppLocalizations.of(context)!;
    if (_members.length < 2) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            strings.minimumFamilyMembersForGame(strings.quickPlay, 2),
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
                strings.whoIsPlaying,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.chooseQuickPlayMembers,
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
                  strings.selectedPlayersCount(_selectedIds.length),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: _selectedIds.length >= 2 ? _continueToGames : null,
                  icon: const Icon(Icons.sports_esports_rounded),
                  label: Text(strings.chooseGame),
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
