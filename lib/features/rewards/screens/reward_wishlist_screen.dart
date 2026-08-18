import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RewardWishlistScreen extends StatefulWidget {
  const RewardWishlistScreen({super.key});

  @override
  State<RewardWishlistScreen> createState() => _RewardWishlistScreenState();
}

class _RewardWishlistScreenState extends State<RewardWishlistScreen> {
  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  bool _isSaving = false;
  String? _familyId;

  @override
  void initState() {
    super.initState();
    _loadFamilyId();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadFamilyId() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!mounted) return;

    setState(() {
      _familyId = userDoc.data()?['familyId']?.toString().trim();
    });
  }

  Future<void> _addSuggestion() async {
    final user = FirebaseAuth.instance.currentUser;
    final familyId = _familyId;

    if (user == null || familyId == null || familyId.isEmpty || _isSaving) {
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a reward idea with at least 3 characters.'),
        ),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = userDoc.data();

      final name = data?['name']?.toString().trim();

      final email = data?['email']?.toString().trim();

      final displayName = name != null && name.isNotEmpty
          ? name
          : email ?? 'Family Member';

      await FirebaseFirestore.instance
          .collection('families')
          .doc(familyId)
          .collection('rewardWishlist')
          .add({
            'title': title,
            'description': description,
            'suggestedBy': user.uid,
            'suggestedByName': displayName,
            'createdAt': FieldValue.serverTimestamp(),
          });

      _titleController.clear();
      _descriptionController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reward idea added to the wishlist.')),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not add the reward idea.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteSuggestion(String documentId) async {
    final familyId = _familyId;

    if (familyId == null) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('families')
          .doc(familyId)
          .collection('rewardWishlist')
          .doc(documentId)
          .delete();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not remove the wishlist item.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Reward Wishlist')),
      body: SafeArea(
        child: _familyId == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Suggest a Reward',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Share a reward you would like your family to add.',
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Reward idea',
                        hintText: 'Example: Choose Friday\'s movie',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        hintText: 'Explain your reward idea.',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    FilledButton.icon(
                      onPressed: _isSaving ? null : _addSuggestion,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_rounded),
                      label: Text(_isSaving ? 'Adding...' : 'Add to Wishlist'),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      'Family Wishlist',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('families')
                          .doc(_familyId)
                          .collection('rewardWishlist')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Text('Could not load the wishlist.');
                        }

                        final items = snapshot.data?.docs ?? [];

                        items.sort((a, b) {
                          final aTime = a.data()['createdAt'] as Timestamp?;

                          final bTime = b.data()['createdAt'] as Timestamp?;

                          return (bTime?.millisecondsSinceEpoch ?? 0).compareTo(
                            aTime?.millisecondsSinceEpoch ?? 0,
                          );
                        });

                        if (items.isEmpty) {
                          return const Card(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'No reward ideas yet.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: items.map((document) {
                            final data = document.data();

                            final title =
                                data['title']?.toString() ?? 'Reward Idea';

                            final description =
                                data['description']?.toString() ?? '';

                            final suggestedBy =
                                data['suggestedByName']?.toString() ??
                                'Family Member';

                            final ownerId = data['suggestedBy']?.toString();

                            final isMine = ownerId == user?.uid;

                            return Card(
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.lightbulb_outline),
                                ),
                                title: Text(title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (description.trim().isNotEmpty)
                                      Text(description),

                                    const SizedBox(height: 4),

                                    Text('Suggested by $suggestedBy'),
                                  ],
                                ),
                                trailing: isMine
                                    ? IconButton(
                                        onPressed: () {
                                          _deleteSuggestion(document.id);
                                        },
                                        tooltip: 'Remove suggestion',
                                        icon: const Icon(Icons.delete_outline),
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
