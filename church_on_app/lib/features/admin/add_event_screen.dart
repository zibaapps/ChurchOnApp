import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/event.dart';
import '../../common/providers/auth_providers.dart';
import '../../common/providers/events_providers.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({super.key});

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _location = TextEditingController();
  DateTime _startAt = DateTime.now().add(const Duration(days: 1));
  DateTime _endAt = DateTime.now().add(const Duration(days: 1, hours: 2));

  Future<void> _pickDateTime(BuildContext context, bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startAt : _endAt,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _startAt : _endAt),
    );
    if (time == null) return;
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) {
        _startAt = dt;
      } else {
        _endAt = dt;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Add Event')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _location,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: Text('Start: $_startAt'),
              trailing: const Icon(Icons.edit),
              onTap: () => _pickDateTime(context, true),
            ),
            ListTile(
              title: Text('End: $_endAt'),
              trailing: const Icon(Icons.edit),
              onTap: () => _pickDateTime(context, false),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: user == null
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      final ev = EventItem(
                        id: 'new',
                        churchId: user.churchId!,
                        name: _name.text.trim(),
                        description: null,
                        startAt: _startAt,
                        endAt: _endAt,
                        location: _location.text.trim().isEmpty ? null : _location.text.trim(),
                        allowRsvp: true,
                        attendees: const {},
                        createdBy: user.uid,
                      );
                      await ref.read(eventsServiceProvider).addEvent(user.churchId!, ev);
                      if (mounted) Navigator.of(context).pop();
                    },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}