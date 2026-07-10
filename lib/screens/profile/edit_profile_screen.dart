import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
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
      appBar: const AppBar(title: Text('My profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
