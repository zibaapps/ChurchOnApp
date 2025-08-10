import 'package:flutter/material.dart';

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
                // TODO: Send to Firestore or support email/Cloud Function
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