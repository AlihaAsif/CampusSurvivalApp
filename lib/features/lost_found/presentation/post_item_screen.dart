import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/storage/image_storage.dart';
import '../../../core/theme/app_spacing.dart';
import '../../profile/presentation/profile_providers.dart';
import '../domain/lost_item.dart';
import 'lost_found_providers.dart';

class PostItemScreen extends ConsumerStatefulWidget {
  const PostItemScreen({super.key});

  @override
  ConsumerState<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends ConsumerState<PostItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();

  LostKind _kind = LostKind.lost;
  ItemCategory _category = ItemCategory.other;
  File? _image;

  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 90,
    );
    if (picked != null) setState(() => _image = File(picked.path));
  }

  void _showImageOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_image != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() => _image = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final profile = ref.read(profileProvider).value;
    if (profile == null) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    String? imageUrl;

    // Upload first, but never let a failed photo lose the post.
    if (_image != null) {
      try {
        imageUrl = await ImageStorage.upload(
          file: _image!,
          folder: 'items',
        );
      } catch (e) {
        imageUrl = null;
      }
    }

    try {
      await ref.read(lostFoundRepositoryProvider).addItem(
        LostItem(
          id: '',
          kind: _kind,
          category: _category,
          title: _titleController.text,
          location: _locationController.text,
          postedAt: DateTime.now(),
          postedByName: profile.name,
          postedByUid: profile.uid,
          imageUrl: imageUrl,
          contactNote: _contactController.text.trim().isEmpty
              ? null
              : _contactController.text,
        ),
      );

      if (!mounted) return;

      if (_image != null && imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Photo didn't upload. The item was saved "
                'without it.'),
          ),
        );
      }

      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not post. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Post an item')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenH),
          children: [
            SegmentedButton<LostKind>(
              segments: const [
                ButtonSegment(
                  value: LostKind.lost,
                  label: Text('I lost something'),
                ),
                ButtonSegment(
                  value: LostKind.found,
                  label: Text('I found something'),
                ),
              ],
              selected: {_kind},
              onSelectionChanged: (selection) =>
                  setState(() => _kind = selection.first),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ---------- Photo ----------
            InkWell(
              onTap: _showImageOptions,
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(
                    color: scheme.outlineVariant,
                    style: _image == null
                        ? BorderStyle.solid
                        : BorderStyle.none,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _image == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: 32,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Add a photo (optional)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                )
                    : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_image!, fit: BoxFit.cover),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor:
                        Colors.black.withValues(alpha: 0.5),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'What is it?',
                hintText: 'Casio fx-991EX calculator',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) return 'Enter a title';
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            TextFormField(
              controller: _locationController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Where?',
                hintText: 'Lab 3, near the window seat',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Enter a location';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            Text(
              'Category',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: ItemCategory.values.map((category) {
                return ChoiceChip(
                  label: Text(category.label),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.lg),

            TextFormField(
              controller: _contactController,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'How can people reach you? (optional)',
                hintText: 'WhatsApp 0300-1234567',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onErrorContainer,
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),

            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}