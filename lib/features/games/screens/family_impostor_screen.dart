import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FamilyImpostorScreen extends StatefulWidget {
  const FamilyImpostorScreen({super.key});

  @override
  State<FamilyImpostorScreen> createState() => _FamilyImpostorScreenState();
}

class _FamilyImpostorScreenState extends State<FamilyImpostorScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  final List<_FamilyPlayer> _familyMembers = [];
  final Set<String> _selectedPlayerIds = {};

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  Future<void> _loadFamilyMembers() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'You must be logged in to play.';
      });
      return;
    }

    try {
      final userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final familyId = userDocument.data()?['familyId'] as String?;

      if (familyId == null || familyId.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Join or create a family before playing.';
        });
        return;
      }

      final membersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('familyId', isEqualTo: familyId)
          .get();

      final members = membersSnapshot.docs.map((document) {
        final data = document.data();

        final name = data['name'] as String?;
        final email = data['email'] as String?;

        return _FamilyPlayer(
          id: document.id,
          name: name?.trim().isNotEmpty == true
              ? name!
              : email ?? 'Family Member',
        );
      }).toList();

      members.sort(
        (a, b) => a.name.toLowerCase().compareTo(
              b.name.toLowerCase(),
            ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _familyMembers
          ..clear()
          ..addAll(members);

        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load your family members.';
      });
    }
  }

  void _togglePlayer(_FamilyPlayer player) {
    setState(() {
      if (_selectedPlayerIds.contains(player.id)) {
        _selectedPlayerIds.remove(player.id);
      } else {
        _selectedPlayerIds.add(player.id);
      }
    });
  }

  void _startGame() {
    if (_selectedPlayerIds.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Family Impostor needs at least 3 players.',
          ),
        ),
      );
      return;
    }

    final selectedPlayers = _familyMembers
        .where(
          (player) => _selectedPlayerIds.contains(player.id),
        )
        .toList();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ready to play with ${selectedPlayers.length} family members.',
        ),
      ),
    );

    // Step 2 will start the real game here.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Impostor'),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
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

    if (_familyMembers.length < 3) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Family Impostor needs at least 3 family members.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Who is playing?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose at least 3 family members who are together with you.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView.separated(
              itemCount: _familyMembers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final player = _familyMembers[index];
                final selected = _selectedPlayerIds.contains(player.id);

                return Card(
                  margin: EdgeInsets.zero,
                  child: CheckboxListTile(
                    value: selected,
                    onChanged: (_) => _togglePlayer(player),
                    secondary: CircleAvatar(
                      child: Text(
                        player.name.isEmpty
                            ? '?'
                            : player.name[0].toUpperCase(),
                      ),
                    ),
                    title: Text(
                      player.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          Text(
            '${_selectedPlayerIds.length} selected',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          FilledButton.icon(
            onPressed:
                _selectedPlayerIds.length >= 3 ? _startGame : null,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Game'),
          ),
        ],
      ),
    );
  }
}

class _FamilyPlayer {
  const _FamilyPlayer({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}