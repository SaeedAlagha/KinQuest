import 'package:flutter/material.dart';

import 'add_memory_screen.dart';

class MemoriesScreen extends StatelessWidget {
  const MemoriesScreen({super.key});

  void _openAddMemory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddMemoryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memories'),
      ),
      body: SafeArea(
        child: Padding(
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
                Text(
                  'Save photos, videos, and stories from your family moments.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddMemory(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}