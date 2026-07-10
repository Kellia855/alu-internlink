import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = [
    (
      'How does verification work?',
      'New startup accounts start unverified. Once our team reviews the account, opportunities you post become visible to students. Students are verified automatically at signup.',
    ),
    (
      'Can I apply to the same opportunity twice?',
      "No — once you've applied, the Apply button switches to \"Applied\" and you can track its status from the Applications tab.",
    ),
    (
      'How do I remove a saved opportunity?',
      'Tap the bookmark icon again on the opportunity card or its detail page to unsave it.',
    ),
    (
      'Who can see my profile?',
      'Only you can read or edit your own profile document — other users only ever see the display name and company info attached to opportunities and applications.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Help & support')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.support_agent_rounded, color: AppColors.white, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Need a hand? We're happy to help.",
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Frequently asked questions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          ..._faqs.map(
            (faq) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 4),
                childrenPadding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
                shape: const Border(),
                title: Text(
                  faq.$1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    color: AppColors.charcoal,
                  ),
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      faq.$2,
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 12.5,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            'Contact us',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 10),
          const _ContactRow(icon: Icons.mail_outline_rounded, label: 'support@internlink.app'),
          const _ContactRow(icon: Icons.chat_bubble_outline_rounded, label: 'Live chat, Mon–Fri 9am–5pm'),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.navy),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: AppColors.charcoal, fontSize: 13)),
        ],
      ),
    );
  }
}
