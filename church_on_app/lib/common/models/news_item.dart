import 'package:equatable/equatable.dart';

class NewsItem extends Equatable {
  const NewsItem({
    required this.id,
    required this.churchId,
    required this.headline,
    required this.body,
    this.imageUrl,
    required this.publishedAt,
    this.source,
  });

  final String id;
  final String churchId;
  final String headline;
  final String body;
  final String? imageUrl;
  final DateTime publishedAt;
  final String? source;

  Map<String, dynamic> toMap() => {
        'churchId': churchId,
        'headline': headline,
        'body': body,
        'imageUrl': imageUrl,
        'publishedAt': publishedAt.toUtc().toIso8601String(),
        'source': source,
      };

  factory NewsItem.fromDoc(String id, Map<String, dynamic> map) => NewsItem(
        id: id,
        churchId: map['churchId'] as String,
        headline: map['headline'] as String,
        body: map['body'] as String,
        imageUrl: map['imageUrl'] as String?,
        publishedAt: DateTime.tryParse(map['publishedAt'] as String? ?? '')?.toLocal() ?? DateTime.now(),
        source: map['source'] as String?,
      );

  @override
  List<Object?> get props => [id, churchId, headline, publishedAt];
}