import 'package:equatable/equatable.dart';

enum PublishStatus { draft, published }

class NewsItem extends Equatable {
  const NewsItem({
    required this.id,
    required this.churchId,
    required this.headline,
    required this.body,
    this.imageUrl,
    required this.publishedAt,
    this.source,
    this.createdAt,
    this.createdBy,
    this.status = PublishStatus.published,
  });

  final String id;
  final String churchId;
  final String headline;
  final String body;
  final String? imageUrl;
  final DateTime publishedAt;
  final String? source;
  final DateTime? createdAt;
  final String? createdBy;
  final PublishStatus status;

  Map<String, dynamic> toMap() => {
        'churchId': churchId,
        'headline': headline,
        'body': body,
        'imageUrl': imageUrl,
        'publishedAt': publishedAt.toUtc().toIso8601String(),
        'source': source,
        'createdAt': createdAt?.toUtc().toIso8601String(),
        'createdBy': createdBy,
        'status': status.name,
      };

  factory NewsItem.fromDoc(String id, Map<String, dynamic> map) => NewsItem(
        id: id,
        churchId: map['churchId'] as String,
        headline: map['headline'] as String,
        body: map['body'] as String,
        imageUrl: map['imageUrl'] as String?,
        publishedAt: DateTime.tryParse(map['publishedAt'] as String? ?? '')?.toLocal() ?? DateTime.now(),
        source: map['source'] as String?,
        createdAt: (map['createdAt'] as String?) != null ? DateTime.tryParse(map['createdAt'] as String)?.toLocal() : null,
        createdBy: map['createdBy'] as String?,
        status: PublishStatus.values.firstWhere(
          (s) => s.name == (map['status'] as String? ?? 'published'),
          orElse: () => PublishStatus.published,
        ),
      );

  @override
  List<Object?> get props => [id, churchId, headline, publishedAt, status];
}