import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_memory_screen.dart';
import 'memory_details_screen.dart';
class MemoriesScreen extends StatelessWidget {
  const MemoriesScreen({super.key});

  void _openAddMemory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMemoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
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

                    final title = data['title'] as String? ?? 'Memory';
                    final description = data['description'] as String? ?? '';
                    final location = data['location'] as String? ?? '';

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
          ),
        ),
      );
    },
    leading: const CircleAvatar(
      child: Icon(Icons.photo_outlined),
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
