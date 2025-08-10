import 'package:equatable/equatable.dart';

enum IssueType { audio, video, cable, network, power, lighting, streaming, other }
enum IssueSeverity { low, medium, high }
enum IssueStatus { open, inProgress, resolved }

class ServiceIssue extends Equatable {
  const ServiceIssue({
    required this.id,
    required this.churchId,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    this.status = IssueStatus.open,
    required this.createdAt,
    this.createdBy,
    this.location,
    this.eventId,
  });

  final String id;
  final String churchId;
  final String title;
  final String description;
  final IssueType type;
  final IssueSeverity severity;
  final IssueStatus status;
  final DateTime createdAt;
  final String? createdBy;
  final String? location;
  final String? eventId;

  Map<String, dynamic> toMap() => {
        'churchId': churchId,
        'title': title,
        'description': description,
        'type': type.name,
        'severity': severity.name,
        'status': status.name,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'createdBy': createdBy,
        'location': location,
        'eventId': eventId,
      };

  factory ServiceIssue.fromDoc(String id, Map<String, dynamic> map) => ServiceIssue(
        id: id,
        churchId: map['churchId'] as String,
        title: map['title'] as String? ?? '',
        description: map['description'] as String? ?? '',
        type: IssueType.values.firstWhere((t) => t.name == (map['type'] as String? ?? 'other'), orElse: () => IssueType.other),
        severity: IssueSeverity.values.firstWhere((s) => s.name == (map['severity'] as String? ?? 'low'), orElse: () => IssueSeverity.low),
        status: IssueStatus.values.firstWhere((s) => s.name == (map['status'] as String? ?? 'open'), orElse: () => IssueStatus.open),
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '')?.toLocal() ?? DateTime.now(),
        createdBy: map['createdBy'] as String?,
        location: map['location'] as String?,
        eventId: map['eventId'] as String?,
      );

  @override
  List<Object?> get props => [id, churchId, title, type, severity, status, createdAt];
}