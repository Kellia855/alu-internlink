import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
import '../../services/profile_photo_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Shared "My Profile" / "Skills & Interests" editor. Students see a
/// name field plus a skills chip editor; startups see just the company
/// name (their profile has no skills concept).
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, this.focusSkills = false});

  /// When opened from the "Skills & Interests" menu row, scroll straight
  /// to (and emphasize) the skills editor.
  final bool focusSkills;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  final _skillController = TextEditingController();
  late List<String> _skills;
  bool _saving = false;

  bool _uploadingPhoto = false;
  final _photoService = ProfilePhotoService();


  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProvider>().profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _skills = List<String>.from(profile?.skills ?? const []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final value = _skillController.text.trim();
    if (value.isEmpty || _skills.contains(value)) {
      _skillController.clear();
      return;
    }
    setState(() {
      _skills.add(value);
      _skillController.clear();
    });
  }

  Future<void> _pickAndUploadPhoto() async {
    final userProvider = context.read<UserProvider>();
    final profile = userProvider.profile;
    if (profile == null) return;

    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xfile == null) return;

    // `putData` upload approach requires bytes instead of File.
    final bytes = await xfile.readAsBytes();
    final ext = xfile.name.split('.').last;

    setState(() => _uploadingPhoto = true);
    try {
      final downloadUrl = await _photoService.uploadProfilePhotoBytes(
        uid: profile.uid,
        bytes: bytes,
        fileExtension: ext,
      );

      if (downloadUrl == null || !mounted) return;

      await userProvider.authService.uploadAndSetProfilePhoto(
        uid: profile.uid,
        photoDownloadUrl: downloadUrl,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not upload photo. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _save() async {
    final userProvider = context.read<UserProvider>();
    final profile = userProvider.profile;
    if (profile == null) return;


    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(profile.isStartup ? 'Enter a company name' : 'Enter your name')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await userProvider.authService.updateProfile(
        uid: profile.uid,
        name: name,
        skills: profile.isStudent ? _skills : null,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save changes. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProvider>().profile;
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final isStartup = profile.role == UserRole.startup;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My profile')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.navy,
                        backgroundImage:
                            (profile.photoUrl != null && profile.photoUrl!.isNotEmpty)
                                ? NetworkImage(profile.photoUrl!)
                                : null,
                        child: (profile.photoUrl == null || profile.photoUrl!.isEmpty)
                            ? Text(
                                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _uploadingPhoto ? null : _pickAndUploadPhoto,
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.maroon,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: _uploadingPhoto
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                : const Icon(Icons.camera_alt_rounded,
                                    color: AppColors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tap the camera to upload a profile photo',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.grey, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            CustomTextField(
              controller: _nameController,
              label: isStartup ? 'Company name' : 'Full name',
              prefixIcon: isStartup ? Icons.business_outlined : Icons.person_outline,
              textCapitalization: TextCapitalization.words,
            ),
            if (!isStartup) ...[
              const SizedBox(height: 28),
              const Text(
                'Skills & interests',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Add skills so startups can find opportunities that fit you.',
                style: TextStyle(color: AppColors.grey, fontSize: 12.5),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _skillController,
                      label: 'Add a skill',
                      hint: 'e.g. Flutter',
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _addSkill,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.maroon,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_rounded, color: AppColors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _skills.isEmpty
                  ? const Text(
                      'No skills added yet.',
                      style: TextStyle(color: AppColors.grey, fontSize: 13),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _skills
                          .map(
                            (s) => Chip(
                              label: Text(s),
                              onDeleted: () => setState(() => _skills.remove(s)),
                              backgroundColor: AppColors.blue.withOpacity(0.08),
                              labelStyle: const TextStyle(
                                color: AppColors.blue,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              deleteIconColor: AppColors.blue,
                              side: BorderSide.none,
                            ),
                          )
                          .toList(),
                    ),
            ],
            const SizedBox(height: 32),
            CustomButton(label: 'Save changes', isLoading: _saving, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
