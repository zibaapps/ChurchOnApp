import 'package:equatable/equatable.dart';

enum LivePlatform { youtube, facebook, googleMeet, other }

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
    this.isLive = false,
    this.livePlatform,
    this.liveUrl,
    this.scheduledAt,
    this.viewCount = 0,
    this.recordingUrl,
    this.rtmpUrl,
    this.streamKey,
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
  final bool isLive;
  final LivePlatform? livePlatform;
  final String? liveUrl;
  final DateTime? scheduledAt;
  final int viewCount;
  final String? recordingUrl; // VOD link after live
  final String? rtmpUrl; // external camera ingest URL
  final String? streamKey; // external stream key

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
    bool? isLive,
    LivePlatform? livePlatform,
    String? liveUrl,
    DateTime? scheduledAt,
    int? viewCount,
    String? recordingUrl,
    String? rtmpUrl,
    String? streamKey,
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
      isLive: isLive ?? this.isLive,
      livePlatform: livePlatform ?? this.livePlatform,
      liveUrl: liveUrl ?? this.liveUrl,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      viewCount: viewCount ?? this.viewCount,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      rtmpUrl: rtmpUrl ?? this.rtmpUrl,
      streamKey: streamKey ?? this.streamKey,
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
      'isLive': isLive,
      'livePlatform': livePlatform?.name,
      'liveUrl': liveUrl,
      'scheduledAt': scheduledAt?.toUtc().toIso8601String(),
      'viewCount': viewCount,
      'recordingUrl': recordingUrl,
      'rtmpUrl': rtmpUrl,
      'streamKey': streamKey,
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
      isLive: (map['isLive'] as bool?) ?? false,
      livePlatform: (map['livePlatform'] as String?) != null
          ? LivePlatform.values.firstWhere(
              (p) => p.name == map['livePlatform'] as String,
              orElse: () => LivePlatform.other,
            )
          : null,
      liveUrl: map['liveUrl'] as String?,
      scheduledAt: (map['scheduledAt'] as String?) != null
          ? DateTime.tryParse(map['scheduledAt'] as String)?.toLocal()
          : null,
      viewCount: (map['viewCount'] as num?)?.toInt() ?? 0,
      recordingUrl: map['recordingUrl'] as String?,
      rtmpUrl: map['rtmpUrl'] as String?,
      streamKey: map['streamKey'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, churchId, title, mediaType, mediaUrl, publishedAt, isFeatured, isLive, livePlatform, liveUrl, viewCount, recordingUrl, rtmpUrl, streamKey];
}