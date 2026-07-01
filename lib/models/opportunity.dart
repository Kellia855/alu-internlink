import 'package:cloud_firestore/cloud_firestore.dart';

class Opportunity {
  final String id;
  final String startupId;
  final String title;
  final String description;
  final List<String> skillsRequired;
  final String duration;
  final String location;
  final DateTime deadline;
  final String status;
  final String companyName;
  final String compensation;
  final bool isVerified;
  final String? imageUrl;
  final String workType;

  Opportunity({
    required this.id,
    required this.startupId,
    required this.title,
    required this.description,
    required this.skillsRequired,
    required this.duration,
    required this.location,
    required this.deadline,
    required this.status,
    this.companyName = '',
    this.compensation = '',
    this.isVerified = false,
    this.imageUrl,
    this.workType = '',
  });

  factory Opportunity.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Opportunity(
      id: doc.id,
      startupId: data['startupId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      skillsRequired: List<String>.from(data['skillsRequired'] ?? []),
      duration: data['duration'] ?? '',
      location: data['location'] ?? '',
      deadline: (data['deadline'] as Timestamp).toDate(),
      status: data['status'] ?? 'open',
      companyName: data['companyName'] ?? '',
      compensation: data['compensation'] ?? '',
      isVerified: data['isVerified'] ?? false,
      imageUrl: data['imageUrl'],
      workType: data['workType'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startupId': startupId,
      'title': title,
      'description': description,
      'skillsRequired': skillsRequired,
      'duration': duration,
      'location': location,
      'deadline': deadline,
      'status': status,
      'companyName': companyName,
      'compensation': compensation,
      'isVerified': isVerified,
      'imageUrl': imageUrl,
      'workType': workType,
    };
  }
}
