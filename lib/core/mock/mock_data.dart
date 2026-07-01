import 'package:flutter/material.dart';
import '../../models/opportunity.dart';
import '../../models/company.dart';
import '../constants/app_colors.dart';

const bool useMockData = true;

List<Opportunity> mockOpportunities() {
  return [
    Opportunity(
      id: '1',
      startupId: 'vertex',
      title: 'Frontend Developer',
      description:
          'Join our core growth team to help shape the future of wealth management tools. You will work on user research, wireframing, and prototyping for our mobile and web platforms.',
      skillsRequired: ['React', 'Tailwind CSS', 'TypeScript'],
      duration: '3 months',
      location: 'Nairobi, Kenya',
      deadline: DateTime(2024, 3, 15),
      status: 'open',
      companyName: 'Vertex Systems',
      compensation: '\$400 - \$600 / mo',
      isVerified: true,
      workType: 'REMOTE',
    ),
    Opportunity(
      id: '2',
      startupId: 'nexus',
      title: 'Product Design Intern',
      description:
          'Nexus is a fast-growing fintech startup revolutionizing how people manage their wealth. As a Product Design Intern, you will join our core growth team to help shape the future of our mobile and web platforms.\n\nYou will work closely with product managers and engineers to conduct user research, create wireframes, and build high-fidelity prototypes.',
      skillsRequired: ['Figma', 'UX Research', 'Prototyping'],
      duration: '3 months',
      location: 'London, UK (Remote Friendly)',
      deadline: DateTime(2024, 4, 1),
      status: 'open',
      companyName: 'Nexus Fintech Solutions',
      compensation: 'Equity + Stipend',
      isVerified: false,
      imageUrl:
          'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800',
    ),
    Opportunity(
      id: '3',
      startupId: 'solar',
      title: 'Growth Marketer',
      description:
          'Solar Energy is looking for a Growth Marketer to drive user acquisition and brand awareness across African markets.',
      skillsRequired: ['Marketing', 'Analytics', 'Social Media'],
      duration: '4 months',
      location: 'Remote',
      deadline: DateTime(2024, 3, 30),
      status: 'open',
      companyName: 'Solar Energy',
      compensation: '\$350 - \$500 / mo',
      isVerified: false,
      workType: 'REMOTE',
    ),
    Opportunity(
      id: '4',
      startupId: 'vertex',
      title: 'Technical Writer',
      description:
          'Help document our APIs and create developer-friendly guides for our growing platform.',
      skillsRequired: ['Technical Writing', 'Markdown', 'API Docs'],
      duration: '4 months',
      location: 'Kigali, Rwanda',
      deadline: DateTime(2024, 4, 15),
      status: 'open',
      companyName: 'Vertex Systems',
      compensation: '\$300 - \$450 / mo',
      isVerified: true,
      workType: 'PART-TIME',
    ),
  ];
}

Company mockVertexCompany() {
  return Company(
    id: 'vertex',
    name: 'Vertex Systems',
    description:
        'Vertex Systems is an ALU student-led software development house focused on building scalable SaaS solutions for the African market. We believe in empowering the next generation of tech leaders through hands-on internship experiences.',
    verified: true,
    location: 'Nairobi, Kenya',
    logoUrl:
        'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=200',
    tagline: 'Scaling student innovation through robust software',
    tags: ['SaaS', 'FinTech', 'ALU Community', 'Software Architecture'],
    projectsShipped: 12,
    openInternships: 4,
    teamMembers: const [
      TeamMember(
        name: 'Kofi Mensah',
        role: 'CEO & Fullstack Lead',
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
      ),
      TeamMember(
        name: 'Amina Uwase',
        role: 'Product Designer (UX/UI)',
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
      ),
      TeamMember(
        name: 'Chinonso Okoro',
        role: 'Backend Engineer',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
      ),
      TeamMember(
        name: 'Sara Tesfaye',
        role: 'DevOps & Cloud Ops',
        avatarUrl: 'https://i.pravatar.cc/150?img=9',
      ),
    ],
  );
}

class MockApplication {
  final String companyName;
  final String role;
  final String appliedDate;
  final String status;
  final String statusLabel;
  final int? currentStep;
  final int? totalSteps;
  final String logoUrl;

  const MockApplication({
    required this.companyName,
    required this.role,
    required this.appliedDate,
    required this.status,
    required this.statusLabel,
    this.currentStep,
    this.totalSteps,
    required this.logoUrl,
  });
}

List<MockApplication> mockApplications() {
  return const [
    MockApplication(
      companyName: 'Stellar Systems',
      role: 'Software Engineering Intern',
      appliedDate: 'Applied Jan 12, 2024',
      status: 'under_review',
      statusLabel: 'Under Review',
      logoUrl: 'https://i.pravatar.cc/150?img=11',
    ),
    MockApplication(
      companyName: 'Nova Design Hub',
      role: 'Product Design Intern',
      appliedDate: 'Applied Jan 8, 2024',
      status: 'interviewing',
      statusLabel: 'Interviewing',
      currentStep: 2,
      totalSteps: 3,
      logoUrl: 'https://i.pravatar.cc/150?img=15',
    ),
    MockApplication(
      companyName: 'Quant Analytics',
      role: 'Data Science Intern',
      appliedDate: 'Applied Dec 20, 2023',
      status: 'closed',
      statusLabel: 'Closed',
      logoUrl: 'https://i.pravatar.cc/150?img=20',
    ),
  ];
}

class MockUserProfile {
  final String name;
  final String degree;
  final String location;
  final String bio;
  final List<String> skills;
  final String avatarUrl;

  const MockUserProfile({
    required this.name,
    required this.degree,
    required this.location,
    required this.bio,
    required this.skills,
    required this.avatarUrl,
  });
}

MockUserProfile mockUserProfile() {
  return const MockUserProfile(
    name: 'Alex Chen',
    degree: 'B.S. Computer Science, 2025',
    location: 'San Francisco, CA',
    bio:
        'Passionate software engineer with a focus on distributed systems and full-stack development. Currently seeking Summer 2024 internships in high-growth tech environments.',
    skills: [
      'TypeScript',
      'React',
      'Node.js',
      'Python',
      'AWS',
      'PostgreSQL',
      'UX Principles',
    ],
    avatarUrl: 'https://i.pravatar.cc/300?img=12',
  );
}

class MockNotification {
  final String typeLabel;
  final String timeAgo;
  final String message;
  final Color typeColor;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final List<String>? tags;
  final String? actionLabel;
  final String? nestedPreview;
  final String? nestedSender;

  const MockNotification({
    required this.typeLabel,
    required this.timeAgo,
    required this.message,
    required this.typeColor,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.tags,
    this.actionLabel,
    this.nestedPreview,
    this.nestedSender,
  });
}

List<MockNotification> mockNotifications() {
  return const [
    MockNotification(
      typeLabel: 'APPLICATION STATUS',
      timeAgo: '2h ago',
      message:
          'Your application for Frontend Developer at Vertex Systems is now Under Review.',
      typeColor: AppColors.accentPeach,
      icon: Icons.assignment_turned_in_outlined,
      iconBg: Color(0xFF3D1515),
      iconColor: Colors.white,
      actionLabel: 'View Details',
    ),
    MockNotification(
      typeLabel: 'NEW OPPORTUNITY',
      timeAgo: '5h ago',
      message:
          'Solar Energy is looking for a Growth Marketer. This matches your skill profile.',
      typeColor: AppColors.accentPeach,
      icon: Icons.work_outline,
      iconBg: Color(0xFF3D3A55),
      iconColor: AppColors.accentPeach,
      tags: ['Marketing', 'Remote'],
    ),
    MockNotification(
      typeLabel: 'MESSAGE',
      timeAgo: '1d ago',
      message:
          'You have a new message from Bloom Learning regarding your technical assessment.',
      typeColor: AppColors.accentPeach,
      icon: Icons.chat_bubble_outline,
      iconBg: Color(0xFF2A2A2A),
      iconColor: AppColors.textSecondary,
      nestedSender: 'Bloom Learning',
      nestedPreview: "Hi Alex, we've reviewed your...",
    ),
    MockNotification(
      typeLabel: 'SUCCESS',
      timeAgo: '1d ago',
      message:
          'Congratulations! Your application for Product Design Intern at Pulse AI has been accepted.',
      typeColor: AppColors.success,
      icon: Icons.check_circle_outline,
      iconBg: Color(0xFF1B3D1F),
      iconColor: AppColors.success,
    ),
  ];
}

class MockMessage {
  final String text;
  final String time;
  final bool isSent;
  final String avatarUrl;

  const MockMessage({
    required this.text,
    required this.time,
    required this.isSent,
    required this.avatarUrl,
  });
}

List<MockMessage> mockChatMessages() {
  return const [
    MockMessage(
      text:
          "Hi Alex! Thanks for applying to the AI Research Intern role at Nexus AI. We've reviewed your profile and we'd love to move forward.",
      time: '10:20 AM',
      isSent: false,
      avatarUrl: 'https://i.pravatar.cc/150?img=47',
    ),
    MockMessage(
      text:
          "Could you share your availability for a 30-minute technical chat this Thursday or Friday?",
      time: '10:21 AM',
      isSent: false,
      avatarUrl: 'https://i.pravatar.cc/150?img=47',
    ),
    MockMessage(
      text:
          "Hi Sarah! Thank you so much for reaching out. I'm very excited about the opportunity. Thursday at 2 PM works perfectly for me.",
      time: '10:22 AM',
      isSent: true,
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
    ),
  ];
}

class MockRecommendation {
  final String title;
  final String company;
  final String description;
  final String tag;
  final List<Color> gradient;
  final IconData icon;

  const MockRecommendation({
    required this.title,
    required this.company,
    required this.description,
    required this.tag,
    required this.gradient,
    required this.icon,
  });
}

List<MockRecommendation> mockRecommendations() {
  return const [
    MockRecommendation(
      title: 'UX Research Intern',
      company: 'Stripe',
      description:
          'Stripe is looking for researchers to join their EMEA team for the summer cohort.',
      tag: 'High Match',
      gradient: [Color(0xFF4A0E0E), Color(0xFF2A0808)],
      icon: Icons.rocket_launch_outlined,
    ),
    MockRecommendation(
      title: 'DevOps Associate',
      company: 'Cloud9 Infrastructure',
      description:
          'Cloud9 Infrastructure is hiring for junior DevOps roles in Lagos and Nairobi.',
      tag: 'Hot Job',
      gradient: [Color(0xFF3D3A55), Color(0xFF2A2840)],
      icon: Icons.cloud_outlined,
    ),
  ];
}
