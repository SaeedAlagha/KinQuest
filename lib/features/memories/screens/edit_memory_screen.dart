import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;

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
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
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

    await FirebaseFirestore.instance
        .collection('families')
        .doc(widget.familyId)
        .collection('memories')
        .doc(widget.memoryId)
        .update({
      'title': title,
      'description': _descriptionController.text.trim(),
      'location': _locationController.text.trim(),
      'date': _selectedDate == null
          ? null
          : Timestamp.fromDate(_selectedDate!),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _selectedDate == null
        ? 'Choose date'
        : '${_selectedDate!.day.toString().padLeft(2, '0')}/'
              '${_selectedDate!.month.toString().padLeft(2, '0')}/'
              '${_selectedDate!.year}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Memory'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
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
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(formattedDate),
          ),

          const SizedBox(height: 28),

          FilledButton(
            onPressed: _isSaving ? null : _saveMemory,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}