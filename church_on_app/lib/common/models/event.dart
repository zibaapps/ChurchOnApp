import 'package:equatable/equatable.dart';

class EventItem extends Equatable {
  const EventItem({
    required this.id,
    required this.churchId,
    required this.name,
    this.description,
    required this.startAt,
    required this.endAt,
    this.location,
    this.allowRsvp = true,
    this.attendees = const <String, bool>{},
    this.createdBy,
  });

  final String id;
  final String churchId;
  final String name;
  final String? description;
  final DateTime startAt;
  final DateTime endAt;
  final String? location;
  final bool allowRsvp;
  final Map<String, bool> attendees; // uid -> true
  final String? createdBy;

  int get rsvpCount => attendees.values.where((v) => v).length;

  Map<String, dynamic> toMap() {
    return {
      'churchId': churchId,
      'name': name,
      'description': description,
      'startAt': startAt.toUtc().toIso8601String(),
      'endAt': endAt.toUtc().toIso8601String(),
      'location': location,
      'allowRsvp': allowRsvp,
      'attendees': attendees,
      'createdBy': createdBy,
    };
  }

  factory EventItem.fromDoc(String id, Map<String, dynamic> map) {
    return EventItem(
      id: id,
      churchId: map['churchId'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      startAt: DateTime.tryParse(map['startAt'] as String? ?? '')?.toLocal() ?? DateTime.now(),
      endAt: DateTime.tryParse(map['endAt'] as String? ?? '')?.toLocal() ?? DateTime.now(),
      location: map['location'] as String?,
      allowRsvp: (map['allowRsvp'] as bool?) ?? true,
      attendees: (map['attendees'] as Map?)?.map((k, v) => MapEntry(k.toString(), v as bool)) ?? const <String, bool>{},
      createdBy: map['createdBy'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, churchId, name, startAt, endAt];
}