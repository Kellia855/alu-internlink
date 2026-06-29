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
  final String status; // "open" or "closed"

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
    };
  }
}
