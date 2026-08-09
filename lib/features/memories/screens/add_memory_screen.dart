import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/validation/form_validators.dart';

class AddMemoryScreen extends StatefulWidget {
  const AddMemoryScreen({super.key});

  @override
  State<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends State<AddMemoryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = selectedDate;
      _dateController.text =
          '${selectedDate.day.toString().padLeft(2, '0')}/'
          '${selectedDate.month.toString().padLeft(2, '0')}/'
          '${selectedDate.year}';
    });
  }

  String? _validateDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Memory date is required.';
    }

    if (_selectedDate == null) {
      return 'Select a valid memory date.';
    }

    return null;
  }

  Future<void> _saveMemory() async {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be signed in to save a memory.'),
        ),
      );
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final familyId = userDoc.data()?['familyId'] as String?;

      if (familyId == null || familyId.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Join or create a family before adding memories.'),
          ),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('families')
          .doc(familyId)
          .collection('memories')
          .add({
            'title': _titleController.text.trim(),
            'description': _descriptionController.text.trim(),
            'date': Timestamp.fromDate(_selectedDate!),
            'location': _locationController.text.trim(),
            'createdBy': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Memory saved successfully.')),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save the memory. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Memory')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Capture a family moment',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add details now. Photos and videos will be connected later.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  height: 170,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Photo and video selection will be added later.',
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 52),
                        SizedBox(height: 10),
                        Text('Add Photos or Videos'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  maxLength: 60,
                  validator: FormValidators.validateMemoryTitle,
                  decoration: const InputDecoration(
                    labelText: 'Memory title',
                    hintText: 'Day at the Zoo',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 300,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Tell the story behind this memory',
                    prefixIcon: Icon(Icons.notes_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _selectDate,
                  validator: _validateDate,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    hintText: 'DD/MM/YYYY',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _locationController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Location (optional)',
                    hintText: 'Al Ain Zoo',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saveMemory,
                    child: const Text('Save Memory'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
