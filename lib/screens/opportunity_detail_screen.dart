import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/application.dart';
import '../models/opportunity.dart';
import '../models/user_profile.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/time_ago.dart';

/// Full-detail view of a single opportunity. Reached by tapping a card
/// from the student's Home or Discover screens. Students can submit an
/// application from here; the button reflects "Applied" once submitted
/// or if they already applied previously.
class OpportunityDetailScreen extends StatefulWidget {
  const OpportunityDetailScreen({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  State<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  final _firestoreService = FirestoreService();
  bool _checking = true;
  bool _alreadyApplied = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _checkApplied();
  }

  Future<void> _checkApplied() async {
    final profile = context.read<UserProvider>().profile;
    if (profile == null || !profile.isStudent) {
      setState(() => _checking = false);
      return;
    }

    try {
      final applied = await _firestoreService.hasApplied(
        studentId: profile.uid,
        opportunityId: widget.opportunity.id,
      );
      if (!mounted) return;
      setState(() {
        _alreadyApplied = applied;
        _checking = false;
      });
    } catch (e) {
      if (!mounted) return;
      // Prevent the UI from getting stuck forever if Firestore
      // read fails due to permissions/auth timing.
      setState(() => _checking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not check application status.'),
        ),
      );
    }
  }


  Future<void> _apply() async {
    final profile = context.read<UserProvider>().profile;
    if (profile == null) return;

    setState(() => _submitting = true);
    try {
      final application = Application(
        id: '',
        opportunityId: widget.opportunity.id,
        studentId: profile.uid,
        status: ApplicationStatus.pending,
        createdAt: null,
        startupId: widget.opportunity.startupId,
        opportunityTitle: widget.opportunity.title,
        companyName: widget.opportunity.companyName,
        studentName: profile.name,
      );
      await _firestoreService.submitApplication(application);
      if (!mounted) return;
      setState(() {
        _alreadyApplied = true;
        _submitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted!')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not submit application. Try again.')),
      );
    }
  }

  Future<void> _toggleSave(UserProfile profile) async {
    final saved = profile.hasSaved(widget.opportunity.id);
    try {
      await _firestoreService.toggleSavedOpportunity(
        uid: profile.uid,
        opportunityId: widget.opportunity.id,
        currentlySaved: saved,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update saved opportunities.')),
      );
    }
  }

  void _share() {
    final opp = widget.opportunity;
    Share.share(
      '${opp.title} at ${opp.companyName} — found this on InternLink.\n\n'
      '${opp.description}',
      subject: opp.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final opp = widget.opportunity;
    final profile = context.watch<UserProvider>().profile;
    final isStudent = profile?.role == UserRole.student;
    final isSaved = profile?.hasSaved(opp.id) ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Opportunity Details'),
        actions: [
          if (profile != null)
            IconButton(
              icon: Icon(
                isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              ),
              tooltip: isSaved ? 'Remove from saved' : 'Save opportunity',
              onPressed: () => _toggleSave(profile),
            ),
          IconButton(
            icon: const Icon(Icons.ios_share_rounded),
            tooltip: 'Share',
            onPressed: _share,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: (opp.imageUrl != null && opp.imageUrl!.isNotEmpty)
                      ? Image.network(opp.imageUrl!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.business, color: AppColors.white))
                      : const Icon(Icons.business, color: AppColors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opp.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        opp.companyName,
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (opp.skillsRequired.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: opp.skillsRequired
                    .take(4)
                    .map((s) => _NeutralChip(label: s))
                    .toList(),
              ),
            ],
            const SizedBox(height: 20),
            _InfoRow(
              icon: Icons.schedule_outlined,
              label: opp.commitment.isNotEmpty ? opp.commitment : 'Flexible commitment',
            ),
            if (opp.location != null && opp.location!.isNotEmpty)
              _InfoRow(icon: Icons.place_outlined, label: opp.location!),
            if (opp.category.isNotEmpty)
              _InfoRow(icon: Icons.category_outlined, label: opp.category),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Posted ${timeAgo(opp.createdAt)}',
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'About',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              opp.description.isNotEmpty
                  ? opp.description
                  : 'No description provided.',
              style: const TextStyle(
                color: AppColors.charcoal,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (opp.skillsRequired.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Skills required',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: opp.skillsRequired
                    .map((s) => _TintChip(label: s))
                    .toList(),
              ),
            ],
            const SizedBox(height: 32),
            if (isStudent)
              _checking
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      label: _alreadyApplied ? 'Applied ✓' : 'Apply Now',
                      isLoading: _submitting,
                      onPressed: _alreadyApplied ? null : _apply,
                    ),
          ],
        ),
      ),
    );
  }
}

/// Neutral bordered pill — mirrors the "Flutter · Dart · Firebase" tags
/// directly under the title in the reference design.
class _NeutralChip extends StatelessWidget {
  const _NeutralChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.charcoal,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Tinted pill — used for the "Skills required" section further down.
class _TintChip extends StatelessWidget {
  const _TintChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, size: 13, color: AppColors.blue),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.blue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.grey),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: AppColors.charcoal, fontSize: 13.5),
          ),
        ],
      ),
    );
  }
}
