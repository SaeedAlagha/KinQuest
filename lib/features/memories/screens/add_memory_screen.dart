import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/validation/form_validators.dart';
import '../../../l10n/app_localizations.dart';

class AddMemoryScreen extends StatefulWidget {
  const AddMemoryScreen({super.key});

  @override
  State<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends State<AddMemoryScreen> {
  static const int _maxImageBytes = 700 * 1024;

  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  DateTime? _selectedDate;
  Uint8List? _selectedImageBytes;

  bool _isSaving = false;

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
      _dateController.text = MaterialLocalizations.of(
        context,
      ).formatMediumDate(selectedDate);
    });
  }

  void _removePhoto() {
    setState(() {
      _selectedImageBytes = null;
    });
  }

  String? _validateDate(String? value) {
    final strings = AppLocalizations.of(context)!;

    if (value == null || value.trim().isEmpty) {
      return strings.memoryDateRequired;
    }

    if (_selectedDate == null) {
      return strings.selectValidMemoryDate;
    }

    return null;
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

    if (!mounted) {
      return;
    }

    if (bytes.lengthInBytes > _maxImageBytes) {
      final strings = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.photoTooLarge)));
      return;
    }

    setState(() {
      _selectedImageBytes = bytes;
    });
  }

  Future<void> _saveMemory() async {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      final strings = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.saveMemorySignInRequired)));
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

      final familyId = userDoc.data()?['familyId'] as String?;

      if (familyId == null || familyId.isEmpty) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.addMemoryFamilyRequired,
            ),
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
            'imageData': _selectedImageBytes == null
                ? null
                : Blob(_selectedImageBytes!),
            'imageUrl': null,
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.memorySaved)),
      );

      Navigator.pop(context);
    } catch (error, stackTrace) {
      debugPrint('ADD MEMORY ERROR: $error');
      debugPrintStack(label: 'ADD MEMORY STACK TRACE', stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.couldNotSaveMemoryTryAgain,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final validators = LocalizedFormValidators(strings);

    return Scaffold(
      appBar: AppBar(title: Text(strings.addMemoryTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.captureFamilyMoment,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  strings.addMemoryScreenDescription,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  height: 190,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _isSaving ? null : _pickImage,
                    child: _selectedImageBytes == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 52,
                              ),
                              const SizedBox(height: 10),
                              Text(strings.addPhoto),
                            ],
                          )
                        : Image.memory(
                            _selectedImageBytes!,
                            width: double.infinity,
                            height: 190,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                if (_selectedImageBytes != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(
                      onPressed: _isSaving ? null : _removePhoto,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: Text(strings.removePhoto),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  maxLength: 60,
                  validator: validators.validateMemoryTitle,
                  decoration: InputDecoration(
                    labelText: strings.memoryTitleLabel,
                    hintText: strings.memoryTitleHint,
                    prefixIcon: const Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 300,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: strings.memoryDescriptionLabel,
                    hintText: strings.memoryDescriptionHint,
                    prefixIcon: const Icon(Icons.notes_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _selectDate,
                  validator: _validateDate,
                  decoration: InputDecoration(
                    labelText: strings.memoryDateLabel,
                    hintText: strings.memoryDateHint,
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _locationController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: strings.memoryLocationOptional,
                    hintText: strings.memoryLocationHint,
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _saveMemory,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(strings.saveMemory),
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
