import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final _subject = TextEditingController();
  final _details = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report a problem')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _subject, decoration: const InputDecoration(labelText: 'Subject')),
            const SizedBox(height: 12),
            Expanded(child: TextField(controller: _details, maxLines: null, expands: true, decoration: const InputDecoration(labelText: 'Details & steps to reproduce'))),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                final subj = _subject.text.trim();
                final body = _details.text.trim();
                if (subj.isEmpty || body.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill subject and details')));
                  return;
                }
                await FirebaseFirestore.instance.collection('support_reports').add({
                  'subject': subj,
                  'details': body,
                  'createdAt': DateTime.now().toUtc().toIso8601String(),
                });
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks! We will look into it.')));
                Navigator.of(context).pop();
              },
              child: const Text('Send'),
            )
          ],
        ),
      ),
    );
  }
}