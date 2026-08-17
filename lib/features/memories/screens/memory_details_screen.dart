import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'edit_memory_screen.dart';

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
    final strings = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.deleteMemoryQuestion),
          content: Text(strings.deleteMemoryWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(strings.delete),
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

  Widget _buildMemoryImage(BuildContext context, Map<String, dynamic> data) {
    Uint8List? imageBytes;

    final imageData = data['imageData'];

    if (imageData is Blob) {
      imageBytes = imageData.bytes;
    }

    final imageUrl = data['imageUrl'] as String?;

    if (imageBytes != null && imageBytes.isNotEmpty) {
      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 220,
      );
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 220,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.broken_image_outlined,
            size: 90,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          );
        },
      );
    }

    return Icon(
      Icons.photo_library_outlined,
      size: 90,
      color: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final memoryRef = FirebaseFirestore.instance
        .collection('families')
        .doc(familyId)
        .collection('memories')
        .doc(memoryId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: memoryRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: Text(strings.memoryTitleGeneric)),
            body: Center(child: Text(strings.memoryNotFound)),
          );
        }

        final data = snapshot.data!.data()!;

        final title = data['title'] as String? ?? strings.memoryTitleGeneric;
        final description = data['description'] as String? ?? '';
        final location = data['location'] as String? ?? '';

        final timestamp = data['date'] as Timestamp?;
        final date = timestamp?.toDate();

        final formattedDate = date == null
            ? strings.noDate
            : '${date.day.toString().padLeft(2, '0')}/'
                  '${date.month.toString().padLeft(2, '0')}/'
                  '${date.year}';

        return Scaffold(
          appBar: AppBar(
            title: Text(strings.memoryTitleGeneric),
            actions: [
              IconButton(
                onPressed: () async {
                  await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditMemoryScreen(
                        memoryId: memoryId,
                        familyId: familyId,
                        memoryData: data,
                      ),
                    ),
                  );
                },
                tooltip: strings.editMemoryTooltip,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: () => _deleteMemory(context),
                tooltip: strings.deleteMemoryTooltip,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildMemoryImage(context, data),
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
                _DetailRow(icon: Icons.location_on_outlined, text: location),
              ],
              if (description.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text(
                  strings.storyLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}
