import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/opportunity.dart';

class PostOpportunityScreen extends StatefulWidget {
  const PostOpportunityScreen({super.key});

  @override
  State<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends State<PostOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skillsController = TextEditingController();
  final _durationController = TextEditingController();
  final _locationController = TextEditingController();
  final _deadlineController = TextEditingController();

  bool _loading = false;

  Future<void> _postOpportunity() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final opp = Opportunity(
        id: '',
        startupId: "demoStartup123", // TODO: replace with actual startup UID
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        skillsRequired: _skillsController.text.split(',').map((s) => s.trim()).toList(),
        duration: _durationController.text.trim(),
        location: _locationController.text.trim(),
        deadline: DateTime.parse(_deadlineController.text.trim()),
        status: "open",
      );

      await FirebaseFirestore.instance.collection('opportunities').add(opp.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Opportunity posted successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Opportunity")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Create a New Role",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (val) => val!.isEmpty ? "Enter a title" : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
                validator: (val) => val!.isEmpty ? "Enter a description" : null,
              ),
              TextFormField(
                controller: _skillsController,
                decoration: const InputDecoration(
                  labelText: "Skills (comma separated)",
                  hintText: "e.g. Flutter, UI Design",
                ),
              ),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: "Duration"),
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "Location"),
              ),
              TextFormField(
                controller: _deadlineController,
                decoration: const InputDecoration(
                  labelText: "Deadline (YYYY-MM-DD)",
                ),
              ),
              const SizedBox(height: 20),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _postOpportunity,
                      child: const Text("Post Opportunity"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
