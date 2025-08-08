import 'package:equatable/equatable.dart';

class Sermon extends Equatable {
  const Sermon({
    required this.id,
    required this.churchId,
    required this.title,
    this.description,
    required this.mediaType,
    required this.mediaUrl,
    this.thumbnailUrl,
    this.categories = const <String>[],
    required this.publishedAt,
    this.durationSec,
    this.isFeatured = false,
    this.downloadAllowed = false,
  });

  final String id;
  final String churchId;
  final String title;
  final String? description;
  final String mediaType; // 'audio' | 'video'
  final String mediaUrl;
  final String? thumbnailUrl;
  final List<String> categories;
  final DateTime publishedAt;
  final int? durationSec;
  final bool isFeatured;
  final bool downloadAllowed;

  Sermon copyWith({
    String? id,
    String? churchId,
    String? title,
    String? description,
    String? mediaType,
    String? mediaUrl,
    String? thumbnailUrl,
    List<String>? categories,
    DateTime? publishedAt,
    int? durationSec,
    bool? isFeatured,
    bool? downloadAllowed,
  }) {
    return Sermon(
      id: id ?? this.id,
      churchId: churchId ?? this.churchId,
      title: title ?? this.title,
      description: description ?? this.description,
      mediaType: mediaType ?? this.mediaType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      categories: categories ?? this.categories,
      publishedAt: publishedAt ?? this.publishedAt,
      durationSec: durationSec ?? this.durationSec,
      isFeatured: isFeatured ?? this.isFeatured,
      downloadAllowed: downloadAllowed ?? this.downloadAllowed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'churchId': churchId,
      'title': title,
      'description': description,
      'mediaType': mediaType,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'categories': categories,
      'publishedAt': publishedAt.toUtc().toIso8601String(),
      'durationSec': durationSec,
      'isFeatured': isFeatured,
      'downloadAllowed': downloadAllowed,
    };
  }

  factory Sermon.fromDoc(String id, Map<String, dynamic> map) {
    return Sermon(
      id: id,
      churchId: map['churchId'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      mediaType: map['mediaType'] as String,
      mediaUrl: map['mediaUrl'] as String,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      categories: (map['categories'] as List?)?.cast<String>() ?? const <String>[],
      publishedAt: DateTime.tryParse(map['publishedAt'] as String? ?? '')?.toLocal() ?? DateTime.now(),
      durationSec: map['durationSec'] as int?,
      isFeatured: (map['isFeatured'] as bool?) ?? false,
      downloadAllowed: (map['downloadAllowed'] as bool?) ?? false,
    );
  }

  @override
  List<Object?> get props => [id, churchId, title, mediaType, mediaUrl, publishedAt, isFeatured];
}