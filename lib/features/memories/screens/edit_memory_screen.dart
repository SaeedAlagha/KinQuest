import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditMemoryScreen extends StatefulWidget {
  const EditMemoryScreen({
    super.key,
    required this.memoryId,
    required this.familyId,
    required this.memoryData,
  });

  final String memoryId;
  final String familyId;
  final Map<String, dynamic> memoryData;

  @override
  State<EditMemoryScreen> createState() => _EditMemoryScreenState();
}

class _EditMemoryScreenState extends State<EditMemoryScreen> {
  static const int _maxImageBytes = 700 * 1024;

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;

  final ImagePicker _imagePicker = ImagePicker();

  Uint8List? _selectedImageBytes;
  Uint8List? _existingImageBytes;

  DateTime? _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.memoryData['title'] as String? ?? '',
    );

    _descriptionController = TextEditingController(
      text: widget.memoryData['description'] as String? ?? '',
    );

    _locationController = TextEditingController(
      text: widget.memoryData['location'] as String? ?? '',
    );

    final timestamp = widget.memoryData['date'] as Timestamp?;
    _selectedDate = timestamp?.toDate();

    final existingBlob = widget.memoryData['imageData'];

    if (existingBlob is Blob) {
      _existingImageBytes = existingBlob.bytes;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 45,
      maxWidth: 720,
      maxHeight: 720,
    );

    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();

    if (!mounted) return;

    if (bytes.lengthInBytes > _maxImageBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'That photo is still too large. Please choose another photo.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _selectedImageBytes = bytes;
    });
  }

  Future<void> _saveMemory() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a title for the memory.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updateData = <String, dynamic>{
        'title': title,
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'date': _selectedDate == null
            ? null
            : Timestamp.fromDate(_selectedDate!),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_selectedImageBytes != null) {
        updateData['imageData'] = Blob(_selectedImageBytes!);
        updateData['imageUrl'] = null;
      }

      await FirebaseFirestore.instance
          .collection('families')
          .doc(widget.familyId)
          .collection('memories')
          .doc(widget.memoryId)
          .update(updateData);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error, stackTrace) {
      debugPrint('EDIT MEMORY ERROR: $error');
      debugPrintStack(label: 'EDIT MEMORY STACK TRACE', stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save changes: $error'),
          duration: const Duration(seconds: 8),
        ),
      );
    }
  }

  Widget _buildPhoto() {
    final oldImageUrl = widget.memoryData['imageUrl'] as String?;

    if (_selectedImageBytes != null) {
      return Image.memory(
        _selectedImageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 180,
      );
    }

    if (_existingImageBytes != null) {
      return Image.memory(
        _existingImageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 180,
      );
    }

    if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
      return Image.network(
        oldImageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 180,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.broken_image_outlined, size: 52),
          );
        },
      );
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined, size: 52),
          SizedBox(height: 8),
          Text('Add Photo'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _selectedDate == null
        ? 'Choose date'
        : '${_selectedDate!.day.toString().padLeft(2, '0')}/'
              '${_selectedDate!.month.toString().padLeft(2, '0')}/'
              '${_selectedDate!.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Memory')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _isSaving ? null : _pickImage,
              child: _buildPhoto(),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              prefixIcon: Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Story',
              prefixIcon: Icon(Icons.notes),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _isSaving ? null : _pickDate,
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(formattedDate),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _isSaving ? null : _saveMemory,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}
