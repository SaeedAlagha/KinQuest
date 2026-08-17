import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_memory_screen.dart';
import 'memory_details_screen.dart';
import 'dart:typed_data';

class MemoriesScreen extends StatelessWidget {
  const MemoriesScreen({super.key, this.developerPreview = false});

  final bool developerPreview;

  void _openAddMemory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMemoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (developerPreview) {
      return const _DeveloperMemoriesView();
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: Text('No user is currently signed in.')),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Memories')),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final userData = userSnapshot.data?.data();
            final familyId = userData?['familyId'] as String?;

            if (familyId == null || familyId.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Join or create a family to view memories.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('families')
                  .doc(familyId)
                  .collection('memories')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, memorySnapshot) {
                if (memorySnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (memorySnapshot.hasError) {
                  return const Center(child: Text('Could not load memories.'));
                }

                final memories = memorySnapshot.data?.docs ?? [];

                if (memories.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 82,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'No memories yet',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Save photos, videos, and stories from your family moments.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          FilledButton.icon(
                            onPressed: () => _openAddMemory(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Your First Memory'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: memories.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final data = memories[index].data();
                    final memoryId = memories[index].id;
                    final title = data['title'] as String? ?? 'Memory';
                    final description = data['description'] as String? ?? '';
                    final location = data['location'] as String? ?? '';
                    final imageData = data['imageData'];
                    final imageUrl = data['imageUrl'] as String?;

                    Uint8List? imageBytes;

                    if (imageData is Blob) {
                      imageBytes = imageData.bytes;
                    }
                    final timestamp = data['date'] as Timestamp?;
                    final date = timestamp?.toDate();

                    final formattedDate = date == null
                        ? ''
                        : '${date.day.toString().padLeft(2, '0')}/'
                              '${date.month.toString().padLeft(2, '0')}/'
                              '${date.year}';

                    return Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MemoryDetailsScreen(
                                memoryData: data,
                                memoryId: memoryId,
                                familyId: familyId,
                              ),
                            ),
                          );
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: imageBytes != null && imageBytes.isNotEmpty
                                ? Image.memory(
                                    imageBytes,
                                    fit: BoxFit.cover,
                                    gaplessPlayback: true,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.broken_image_outlined,
                                        ),
                                      );
                                    },
                                  )
                                : imageUrl != null && imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.broken_image_outlined,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.photo_outlined),
                                  ),
                          ),
                        ),
                        title: Text(title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (description.isNotEmpty) Text(description),
                            if (formattedDate.isNotEmpty) Text(formattedDate),
                            if (location.isNotEmpty) Text(location),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddMemory(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DeveloperMemoriesView extends StatelessWidget {
  const _DeveloperMemoriesView();

  static const _memories = [
    _PreviewMemory(
      icon: Icons.park_rounded,
      title: 'Family picnic at Mushrif Park',
      description: 'A sunny afternoon full of games, stories, and laughter.',
      details: '02/08/2026 • Dubai',
    ),
    _PreviewMemory(
      icon: Icons.restaurant_rounded,
      title: 'Friday lunch together',
      description: 'Grandma shared her favorite family recipe with everyone.',
      details: '31/07/2026 • Home',
    ),
    _PreviewMemory(
      icon: Icons.beach_access_rounded,
      title: 'Sunset walk',
      description: 'We watched the sunset and planned our next family day.',
      details: '25/07/2026 • Abu Dhabi Corniche',
    ),
  ];

  void _showReadOnlyNotice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Developer preview is read-only. No data was changed.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Memories')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: _memories.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Developer Family memories',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sample moments for reviewing the experience. They are not stored in Firebase.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            final memory = _memories[index - 1];

            return Card(
              child: ListTile(
                onTap: () => _showReadOnlyNotice(context),
                contentPadding: const EdgeInsets.all(14),
                leading: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    memory.icon,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(memory.title),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('${memory.description}\n${memory.details}'),
                ),
                isThreeLine: true,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReadOnlyNotice(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Memory'),
      ),
    );
  }
}

class _PreviewMemory {
  const _PreviewMemory({
    required this.icon,
    required this.title,
    required this.description,
    required this.details,
  });

  final IconData icon;
  final String title;
  final String description;
  final String details;
}
