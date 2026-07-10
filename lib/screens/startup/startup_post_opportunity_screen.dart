import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/opportunity.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// The startup's "Discover" tab doubles as their opportunity-creation
/// form per the spec: startups don't browse opportunities, they post them.
class StartupPostOpportunityScreen extends StatefulWidget {
  const StartupPostOpportunityScreen({super.key});

  @override
  State<StartupPostOpportunityScreen> createState() =>
      _StartupPostOpportunityScreenState();
}

class _StartupPostOpportunityScreenState
    extends State<StartupPostOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _commitmentController = TextEditingController();
  final _skillsController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _category = OpportunityCategory.other;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _commitmentController.dispose();
    _skillsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final profile = context.read<UserProvider>().profile;
    if (profile == null) return;

    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    try {
      final skills = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final opportunity = Opportunity(
        id: '',
        title: _titleController.text.trim(),
        companyName: profile.companyName,
        startupId: profile.uid,
        verified: false,
        createdAt: null,
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        skillsRequired: skills,
        category: _category,
        commitment: _commitmentController.text.trim(),
      );

      await _firestoreService.postOpportunity(opportunity);

      if (!mounted) return;
      _titleController.clear();
      _descriptionController.clear();
      _locationController.clear();
      _commitmentController.clear();
      _skillsController.clear();
      _imageUrlController.clear();
      setState(() {
        _category = OpportunityCategory.other;
        _submitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Opportunity posted! It will appear to students once verified.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not post opportunity. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Post Opportunity')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'New opportunity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Fill in the details below — your posting will be reviewed before it goes live to students.',
                style: TextStyle(color: AppColors.grey, fontSize: 12.5),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'e.g. Flutter Developer Intern',
                prefixIcon: Icons.work_outline,
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'What will the intern work on?',
                maxLines: 5,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter a description'
                    : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Category',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.charcoal),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: OpportunityCategory.all.map((c) {
                  final selected = c == _category;
                  return ChoiceChip(
                    label: Text(c),
                    selected: selected,
                    onSelected: (_) => setState(() => _category = c),
                    selectedColor: AppColors.maroon,
                    backgroundColor: AppColors.lightGrey.withOpacity(0.4),
                    labelStyle: TextStyle(
                      color: selected ? AppColors.white : AppColors.charcoal,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide.none,
                    ),
                    showCheckmark: false,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _commitmentController,
                label: 'Commitment',
                hint: 'e.g. Part-time (8–10 hrs/week)',
                prefixIcon: Icons.schedule_outlined,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _locationController,
                label: 'Location',
                hint: 'e.g. Remote, or On-campus',
                prefixIcon: Icons.place_outlined,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _skillsController,
                label: 'Skills required',
                hint: 'Comma-separated, e.g. Flutter, Dart, Firebase',
                prefixIcon: Icons.bolt_outlined,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _imageUrlController,
                label: 'Logo image URL (optional)',
                hint: 'https://...',
                prefixIcon: Icons.image_outlined,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Post Opportunity',
                isLoading: _submitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
