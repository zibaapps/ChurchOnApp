import 'package:equatable/equatable.dart';

class InterchurchEvent extends Equatable {
  const InterchurchEvent({
    required this.id,
    required this.name,
    required this.date,
    this.location,
    this.participatingChurchIds = const <String>[],
    this.description,
  });
  final String id;
  final String name;
  final DateTime date;
  final String? location;
  final List<String> participatingChurchIds;
  final String? description;
  Map<String, dynamic> toMap() => {
        'name': name,
        'date': date.toUtc().toIso8601String(),
        'location': location,
        'participatingChurchIds': participatingChurchIds,
        'description': description,
      };
  factory InterchurchEvent.fromDoc(String id, Map<String, dynamic> map) => InterchurchEvent(
        id: id,
        name: map['name'] as String,
        date: DateTime.tryParse(map['date'] as String? ?? '')?.toLocal() ?? DateTime.now(),
        location: map['location'] as String?,
        participatingChurchIds: (map['participatingChurchIds'] as List?)?.cast<String>() ?? const <String>[],
        description: map['description'] as String?,
      );
  @override
  List<Object?> get props => [id, name, date];
}

class InterchurchProject extends Equatable {
  const InterchurchProject({
    required this.id,
    required this.title,
    this.description,
    this.totalGiving = 0,
    this.participatingChurchIds = const <String>[],
  });
  final String id;
  final String title;
  final String? description;
  final double totalGiving;
  final List<String> participatingChurchIds;
  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'totalGiving': totalGiving,
        'participatingChurchIds': participatingChurchIds,
      };
  factory InterchurchProject.fromDoc(String id, Map<String, dynamic> map) => InterchurchProject(
        id: id,
        title: map['title'] as String,
        description: map['description'] as String?,
        totalGiving: (map['totalGiving'] as num?)?.toDouble() ?? 0,
        participatingChurchIds: (map['participatingChurchIds'] as List?)?.cast<String>() ?? const <String>[],
      );
  @override
  List<Object?> get props => [id, title, totalGiving];
}

class YearProgram extends Equatable {
  const YearProgram({
    required this.id,
    required this.churchId,
    required this.year,
    required this.items,
  });
  final String id;
  final String churchId;
  final int year;
  final List<Map<String, dynamic>> items; // [{date,title,desc}]
  Map<String, dynamic> toMap() => {
        'churchId': churchId,
        'year': year,
        'items': items,
      };
  factory YearProgram.fromDoc(String id, Map<String, dynamic> map) => YearProgram(
        id: id,
        churchId: map['churchId'] as String,
        year: (map['year'] as num).toInt(),
        items: ((map['items'] as List?) ?? const <dynamic>[]).cast<Map<String, dynamic>>(),
      );
  @override
  List<Object?> get props => [id, churchId, year];
}

enum ActivityType { event, project, program }

enum ProgramStatus { draft, published, cancelled }

enum ActivityStatus { planning, active, completed, cancelled }

enum VisibilityLevel { participants, public }

class InterchurchActivity extends Equatable {
  const InterchurchActivity({
    required this.id,
    required this.activityType,
    required this.title,
    required this.leadChurchId,
    required this.participants,
    required this.participantStatuses,
    this.description,
    this.startAt,
    this.endAt,
    this.location,
    this.visibility = VisibilityLevel.participants,
    this.streams = const <String, String>{},
    this.rsvpEnabled = false,
    this.volunteerEnabled = false,
    this.status = ActivityStatus.planning,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final ActivityType activityType;
  final String title;
  final String? description;
  final String leadChurchId;
  final List<String> participants; // must include lead
  final Map<String, String> participantStatuses; // churchId -> invited/accepted/declined
  final DateTime? startAt;
  final DateTime? endAt;
  final String? location;
  final VisibilityLevel visibility;
  final Map<String, String> streams; // youtubeUrl/facebookUrl/meetUrl
  final bool rsvpEnabled;
  final bool volunteerEnabled;
  final ActivityStatus status;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toMap() => {
        'activityType': activityType.name,
        'title': title,
        'description': description,
        'leadChurchId': leadChurchId,
        'participants': participants,
        'participantStatuses': participantStatuses,
        'startAt': startAt?.toUtc().toIso8601String(),
        'endAt': endAt?.toUtc().toIso8601String(),
        'location': location,
        'visibility': visibility.name,
        'streams': streams,
        'rsvpEnabled': rsvpEnabled,
        'volunteerEnabled': volunteerEnabled,
        'status': status.name,
        'createdBy': createdBy,
        'createdAt': createdAt?.toUtc().toIso8601String(),
        'updatedAt': updatedAt?.toUtc().toIso8601String(),
      };

  factory InterchurchActivity.fromDoc(String id, Map<String, dynamic> map) => InterchurchActivity(
        id: id,
        activityType: _parseActivityType(map['activityType'] as String?),
        title: map['title'] as String? ?? '',
        description: map['description'] as String?,
        leadChurchId: map['leadChurchId'] as String? ?? '',
        participants: (map['participants'] as List?)?.cast<String>() ?? const <String>[],
        participantStatuses: Map<String, String>.from((map['participantStatuses'] as Map?)?.map((k, v) => MapEntry(k.toString(), (v ?? '').toString())) ?? <String, String>{}),
        startAt: DateTime.tryParse(map['startAt'] as String? ?? ''),
        endAt: DateTime.tryParse(map['endAt'] as String? ?? ''),
        location: map['location'] as String?,
        visibility: _parseVisibility(map['visibility'] as String?),
        streams: Map<String, String>.from(map['streams'] as Map? ?? <String, String>{}),
        rsvpEnabled: map['rsvpEnabled'] as bool? ?? false,
        volunteerEnabled: map['volunteerEnabled'] as bool? ?? false,
        status: _parseActivityStatus(map['status'] as String?),
        createdBy: map['createdBy'] as String?,
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
        updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? ''),
      );

  static ActivityType _parseActivityType(String? s) {
    switch (s) {
      case 'event':
        return ActivityType.event;
      case 'project':
        return ActivityType.project;
      case 'program':
        return ActivityType.program;
      default:
        return ActivityType.event;
    }
  }

  static ActivityStatus _parseActivityStatus(String? s) {
    switch (s) {
      case 'planning':
        return ActivityStatus.planning;
      case 'active':
        return ActivityStatus.active;
      case 'completed':
        return ActivityStatus.completed;
      case 'cancelled':
        return ActivityStatus.cancelled;
      default:
        return ActivityStatus.planning;
    }
  }

  static VisibilityLevel _parseVisibility(String? s) {
    switch (s) {
      case 'public':
        return VisibilityLevel.public;
      case 'participants':
      default:
        return VisibilityLevel.participants;
    }
  }

  @override
  List<Object?> get props => [id, activityType, title, leadChurchId];
}

class YearProgramEntry extends Equatable {
  const YearProgramEntry({
    required this.id,
    required this.churchId,
    required this.title,
    this.description,
    this.category,
    this.startAt,
    this.endAt,
    this.location,
    this.tags = const <String>[],
    this.isInterchurch = false,
    this.interchurchActivityId,
    this.leadChurchId,
    this.participants = const <String>[],
    this.status = ProgramStatus.published,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String churchId; // owner
  final String title;
  final String? description;
  final String? category; // service/outreach/conference/etc
  final DateTime? startAt;
  final DateTime? endAt;
  final String? location;
  final List<String> tags;
  final bool isInterchurch;
  final String? interchurchActivityId;
  final String? leadChurchId;
  final List<String> participants; // churchIds
  final ProgramStatus status;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toMap() => {
        'churchId': churchId,
        'title': title,
        'description': description,
        'category': category,
        'startAt': startAt?.toUtc().toIso8601String(),
        'endAt': endAt?.toUtc().toIso8601String(),
        'location': location,
        'tags': tags,
        'isInterchurch': isInterchurch,
        'interchurchActivityId': interchurchActivityId,
        'leadChurchId': leadChurchId,
        'participants': participants,
        'status': status.name,
        'createdBy': createdBy,
        'createdAt': createdAt?.toUtc().toIso8601String(),
        'updatedAt': updatedAt?.toUtc().toIso8601String(),
      };

  factory YearProgramEntry.fromDoc(String id, Map<String, dynamic> map) => YearProgramEntry(
        id: id,
        churchId: map['churchId'] as String? ?? '',
        title: map['title'] as String? ?? '',
        description: map['description'] as String?,
        category: map['category'] as String?,
        startAt: DateTime.tryParse(map['startAt'] as String? ?? ''),
        endAt: DateTime.tryParse(map['endAt'] as String? ?? ''),
        location: map['location'] as String?,
        tags: (map['tags'] as List?)?.cast<String>() ?? const <String>[],
        isInterchurch: map['isInterchurch'] as bool? ?? false,
        interchurchActivityId: map['interchurchActivityId'] as String?,
        leadChurchId: map['leadChurchId'] as String?,
        participants: (map['participants'] as List?)?.cast<String>() ?? const <String>[],
        status: _parseProgramStatus(map['status'] as String?),
        createdBy: map['createdBy'] as String?,
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
        updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? ''),
      );

  static ProgramStatus _parseProgramStatus(String? s) {
    switch (s) {
      case 'draft':
        return ProgramStatus.draft;
      case 'published':
        return ProgramStatus.published;
      case 'cancelled':
        return ProgramStatus.cancelled;
      default:
        return ProgramStatus.published;
    }
  }

  @override
  List<Object?> get props => [id, churchId, title, isInterchurch];
}