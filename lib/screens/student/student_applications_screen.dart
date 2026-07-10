import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/application.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/application_tile.dart';
import '../../widgets/status_filter_tabs.dart';

class StudentApplicationsScreen extends StatefulWidget {
  const StudentApplicationsScreen({super.key});

  @override
  State<StudentApplicationsScreen> createState() =>
      _StudentApplicationsScreenState();
}

class _StudentApplicationsScreenState
    extends State<StudentApplicationsScreen> {
  final _firestoreService = FirestoreService();
  String _statusFilter = 'All';

  static const _statusOptions = [
    'All',
    ApplicationStatus.pending,
    ApplicationStatus.accepted,
    ApplicationStatus.rejected,
  ];

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProvider>().profile;

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Applications')),
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
                    _firestoreService.watchApplicationsForStudent(profile.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Could not load applications.',
                        style: TextStyle(color: AppColors.grey),
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
                          "You haven't applied to anything yet.",
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
                      return ApplicationTile(
                        application: a,
                        primaryLabel: a.opportunityTitle ?? 'Opportunity',
                        secondaryLabel: a.companyName ?? '',
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

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
