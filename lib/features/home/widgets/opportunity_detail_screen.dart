import 'package:flutter/material.dart';
import '../../../models/opportunity.dart';

class OpportunityDetailScreen extends StatelessWidget {
  final Opportunity opportunity;

  const OpportunityDetailScreen({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(opportunity.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(opportunity.description,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 10),
            Text("Skills Required: ${opportunity.skillsRequired.join(', ')}"),
            const SizedBox(height: 10),
            Text("Duration: ${opportunity.duration}"),
            Text("Location: ${opportunity.location}"),
            Text("Deadline: ${opportunity.deadline.toLocal()}"),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement application submission
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Application submitted!")),
                );
              },
              child: const Text("Apply Now"),
            ),
          ],
        ),
      ),
    );
  }
}
