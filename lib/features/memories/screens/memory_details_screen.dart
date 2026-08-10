import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MemoryDetailsScreen extends StatelessWidget {
 const MemoryDetailsScreen({
  super.key,
  required this.memoryData,
  required this.memoryId,
  required this.familyId,
});

final Map<String, dynamic> memoryData;
final String memoryId;
final String familyId;
Future<void> _deleteMemory(BuildContext context) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete memory?'),
        content: const Text(
          'This memory will be permanently removed from your family memories.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (shouldDelete != true) {
    return;
  }

  await FirebaseFirestore.instance
      .collection('families')
      .doc(familyId)
      .collection('memories')
      .doc(memoryId)
      .delete();

  if (context.mounted) {
    Navigator.pop(context);
  }
}
  @override
  Widget build(BuildContext context) {
    final title = memoryData['title'] as String? ?? 'Memory';
    final description = memoryData['description'] as String? ?? '';
    final location = memoryData['location'] as String? ?? '';

    final timestamp = memoryData['date'] as Timestamp?;
    final date = timestamp?.toDate();

    final formattedDate = date == null
        ? 'No date'
        : '${date.day.toString().padLeft(2, '0')}/'
              '${date.month.toString().padLeft(2, '0')}/'
              '${date.year}';

    return Scaffold(
     appBar: AppBar(
  title: const Text('Memory'),
  actions: [
    IconButton(
      onPressed: () => _deleteMemory(context),
      tooltip: 'Delete memory',
      icon: const Icon(Icons.delete_outline),
    ),
  ],
),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.photo_library_outlined,
              size: 90,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 20),

          _DetailRow(
            icon: Icons.calendar_today_outlined,
            text: formattedDate,
          ),

          if (location.isNotEmpty) ...[
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.location_on_outlined,
              text: location,
            ),
          ],

          if (description.isNotEmpty) ...[
            const SizedBox(height: 28),
            Text(
              'Story',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}