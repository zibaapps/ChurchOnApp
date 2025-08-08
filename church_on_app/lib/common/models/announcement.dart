import 'package:equatable/equatable.dart';

class Announcement extends Equatable {
  const Announcement({
    required this.id,
    required this.churchId,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.publishedAt,
    this.authorName,
  });

  final String id;
  final String churchId;
  final String title;
  final String body;
  final String? imageUrl;
  final DateTime publishedAt;
  final String? authorName;

  Map<String, dynamic> toMap() => {
        'churchId': churchId,
        'title': title,
        'body': body,
        'imageUrl': imageUrl,
        'publishedAt': publishedAt.toUtc().toIso8601String(),
        'authorName': authorName,
      };

  factory Announcement.fromDoc(String id, Map<String, dynamic> map) => Announcement(
        id: id,
        churchId: map['churchId'] as String,
        title: map['title'] as String,
        body: map['body'] as String,
        imageUrl: map['imageUrl'] as String?,
        publishedAt: DateTime.tryParse(map['publishedAt'] as String? ?? '')?.toLocal() ?? DateTime.now(),
        authorName: map['authorName'] as String?,
      );

  @override
  List<Object?> get props => [id, churchId, title, publishedAt];
}