import 'package:equatable/equatable.dart';

enum ReportType { secretary, usher, treasurer, pastor, other }

class ChurchReport extends Equatable {
  const ChurchReport({
    required this.id,
    required this.churchId,
    required this.type,
    required this.title,
    required this.content,
    this.attachmentUrl,
    this.periodStart,
    this.periodEnd,
    required this.createdAt,
    this.createdBy,
  });

  final String id;
  final String churchId;
  final ReportType type;
  final String title;
  final String content;
  final String? attachmentUrl;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final DateTime createdAt;
  final String? createdBy;

  Map<String, dynamic> toMap() => {
        'churchId': churchId,
        'type': type.name,
        'title': title,
        'content': content,
        'attachmentUrl': attachmentUrl,
        'periodStart': periodStart?.toUtc().toIso8601String(),
        'periodEnd': periodEnd?.toUtc().toIso8601String(),
        'createdAt': createdAt.toUtc().toIso8601String(),
        'createdBy': createdBy,
      };

  factory ChurchReport.fromDoc(String id, Map<String, dynamic> map) => ChurchReport(
        id: id,
        churchId: map['churchId'] as String,
        type: ReportType.values.firstWhere(
          (t) => t.name == (map['type'] as String? ?? 'other'),
          orElse: () => ReportType.other,
        ),
        title: map['title'] as String,
        content: map['content'] as String,
        attachmentUrl: map['attachmentUrl'] as String?,
        periodStart: (map['periodStart'] as String?) != null ? (DateTime.tryParse(map['periodStart'] as String)?.toLocal()) : null,
        periodEnd: (map['periodEnd'] as String?) != null ? (DateTime.tryParse(map['periodEnd'] as String)?.toLocal()) : null,
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '')?.toLocal() ?? DateTime.now(),
        createdBy: map['createdBy'] as String?,
      );

  @override
  List<Object?> get props => [id, churchId, type, title, createdAt];
}