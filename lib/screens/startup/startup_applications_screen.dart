import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/application.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/application_tile.dart';
import '../../widgets/status_filter_tabs.dart';

class StartupApplicationsScreen extends StatefulWidget {
  const StartupApplicationsScreen({super.key});

  @override
  State<StartupApplicationsScreen> createState() =>
      _StartupApplicationsScreenState();
}

class _StartupApplicationsScreenState
    extends State<StartupApplicationsScreen> {
  final _firestoreService = FirestoreService();
  String _statusFilter = 'All';
  final Set<String> _updating = {};

  static const _statusOptions = [
    'All',
    ApplicationStatus.pending,
    ApplicationStatus.accepted,
    ApplicationStatus.rejected,
  ];

  Future<void> _updateStatus(Application application, String status) async {
    setState(() => _updating.add(application.id));
    try {
      await _firestoreService.updateApplicationStatus(
        applicationId: application.id,
        status: status,
      );
    } finally {
      if (mounted) setState(() => _updating.remove(application.id));
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProvider>().profile;

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Applicants')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StatusFilterTabs(
              options: _statusOptions
                  .map((s) => s == 'All' ? s : _capitalize(s))
                  .toList(),
              selected: _statusFilter == 'All'
                  ? 'All'
                  : _capitalize(_statusFilter),
              onSelected: (label) {
                setState(() {
                  _statusFilter = label == 'All' ? 'All' : label.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<Application>>(
                stream:
                    _firestoreService.watchApplicationsForStartup(profile.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Could not load applicants.\n\n${snapshot.error}',
                          style: const TextStyle(color: AppColors.grey),
                        ),
                      ),
                    );
                  }
                  var items = snapshot.data ?? const [];
                  if (_statusFilter != 'All') {
                    items = items
                        .where((a) => a.status == _statusFilter)
                        .toList();
                  }
                  if (items.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Text(
                          'No applicants yet.',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 20, top: 4),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final a = items[i];
                      final isUpdating = _updating.contains(a.id);
                      final isPending = a.status == ApplicationStatus.pending;

                      return ApplicationTile(
                        application: a,
                        primaryLabel: a.studentName ?? 'Student',
                        secondaryLabel: a.opportunityTitle ?? '',
                        actions: isPending
                            ? Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: isUpdating
                                          ? null
                                          : () => _updateStatus(a,
                                              ApplicationStatus.rejected),
                                      icon: const Icon(Icons.close_rounded,
                                          size: 16, color: AppColors.rust),
                                      label: const Text('Reject'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.rust,
                                        side: const BorderSide(
                                            color: AppColors.rust),
                                        minimumSize: const Size(0, 40),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: isUpdating
                                          ? null
                                          : () => _updateStatus(a,
                                              ApplicationStatus.accepted),
                                      icon: const Icon(Icons.check_rounded,
                                          size: 16),
                                      label: const Text('Accept'),
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(0, 40),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
