import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/company.dart';
import '../../../models/opportunity.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/tag_chip.dart';
import '../../../core/constants/app_colors.dart';
import 'opportunity_detail_screen.dart';

class CompanyProfileScreen extends StatelessWidget {
  final String companyId;

  const CompanyProfileScreen({super.key, required this.companyId});

  Future<Company?> _fetchCompany() async {
    if (useMockData) return mockVertexCompany();
    final doc = await FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
        .get();
    if (doc.exists) return Company.fromDoc(doc);
    return null;
  }

  List<Opportunity> _companyOpportunities() {
    return mockOpportunities()
        .where((o) => o.startupId == companyId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 1,
      body: SafeArea(
        child: FutureBuilder<Company?>(
          future: _fetchCompany(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('Company not found'));
            }
            final company = snapshot.data!;
            final openings = useMockData
                ? _companyOpportunities()
                : <Opportunity>[];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppHeader(),
                  _CompanyHero(company: company),
                  const SizedBox(height: 20),
                  _AboutSection(company: company),
                  const SizedBox(height: 12),
                  _TeamSection(company: company),
                  const SizedBox(height: 12),
                  _ImpactStats(company: company),
                  const SizedBox(height: 20),
                  _OpeningsSection(
                    openings: openings,
                    totalCount: company.openInternships,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CompanyHero extends StatelessWidget {
  final Company company;

  const _CompanyHero({required this.company});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF5A1010), Color(0xFF2A0808)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: SizedBox()),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    company.logoUrl ??
                        'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=200',
                    width: 100,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            company.name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          if (company.verified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.maroonDark.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, size: 14, color: AppColors.accentPeach),
                  SizedBox(width: 4),
                  Text(
                    'Verified Startup',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Text(
            company.tagline,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPeach,
                    foregroundColor: AppColors.textOnPeach,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text('Follow', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.share_outlined, size: 20, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  final Company company;

  const _AboutSection({required this.company});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About ${company.name}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.accentPeach,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              company.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: company.tags.map((t) => TagChip(t)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamSection extends StatelessWidget {
  final Company company;

  const _TeamSection({required this.company});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Founding Team',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentPeach,
                  ),
                ),
                Text(
                  '${company.teamMembers.length} Members',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...company.teamMembers.map(
              (member) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(member.avatarUrl),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          member.role,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImpactStats extends StatelessWidget {
  final Company company;

  const _ImpactStats({required this.company});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.impactRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'IMPACT STATS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${company.projectsShipped}+',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: AppColors.surface,
              ),
            ),
            const Text(
              'Projects Shipped',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              company.openInternships.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: AppColors.surface,
              ),
            ),
            const Text(
              'Open Internships',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpeningsSection extends StatelessWidget {
  final List<Opportunity> openings;
  final int totalCount;

  const _OpeningsSection({
    required this.openings,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Openings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...openings.take(2).map(
                (opp) => _OpeningCard(opportunity: opp),
              ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.border, style: BorderStyle.solid),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {},
              child: Text(
                'View all $totalCount opportunities',
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpeningCard extends StatelessWidget {
  final Opportunity opportunity;

  const _OpeningCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  opportunity.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              if (opportunity.workType.isNotEmpty)
                TagChip(
                  opportunity.workType,
                  backgroundColor: opportunity.workType == 'REMOTE'
                      ? AppColors.accentBlueLight
                      : AppColors.cardGrey,
                  textColor: opportunity.workType == 'REMOTE'
                      ? AppColors.accentBlue
                      : AppColors.textSecondary,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            opportunity.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.schedule, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                opportunity.duration,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        OpportunityDetailScreen(opportunity: opportunity),
                  ),
                ),
                child: const Text(
                  'Apply →',
                  style: TextStyle(
                    color: AppColors.accentPeach,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
