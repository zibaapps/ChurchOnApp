import 'package:equatable/equatable.dart';

enum PublishStatus { draft, published }

class Announcement extends Equatable {
  const Announcement({
    required this.id,
    required this.churchId,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.publishedAt,
    this.authorName,
    this.createdAt,
    this.createdBy,
    this.status = PublishStatus.published,
  });

  final String id;
  final String churchId;
  final String title;
  final String body;
  final String? imageUrl;
  final DateTime publishedAt;
  final String? authorName;
  final DateTime? createdAt;
  final String? createdBy;
  final PublishStatus status;

  Map<String, dynamic> toMap() => {
        'churchId': churchId,
        'title': title,
        'body': body,
        'imageUrl': imageUrl,
        'publishedAt': publishedAt.toUtc().toIso8601String(),
        'authorName': authorName,
        'createdAt': createdAt?.toUtc().toIso8601String(),
        'createdBy': createdBy,
        'status': status.name,
      };

  factory Announcement.fromDoc(String id, Map<String, dynamic> map) => Announcement(
        id: id,
        churchId: map['churchId'] as String,
        title: map['title'] as String,
        body: map['body'] as String,
        imageUrl: map['imageUrl'] as String?,
        publishedAt: DateTime.tryParse(map['publishedAt'] as String? ?? '')?.toLocal() ?? DateTime.now(),
        authorName: map['authorName'] as String?,
        createdAt: (map['createdAt'] as String?) != null ? DateTime.tryParse(map['createdAt'] as String)?.toLocal() : null,
        createdBy: map['createdBy'] as String?,
        status: PublishStatus.values.firstWhere(
          (s) => s.name == (map['status'] as String? ?? 'published'),
          orElse: () => PublishStatus.published,
        ),
      );

  @override
  List<Object?> get props => [id, churchId, title, publishedAt, status];
}