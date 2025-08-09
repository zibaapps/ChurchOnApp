import 'package:equatable/equatable.dart';

enum AnnotationType { bookmark, highlight, note }

class BibleAnnotation extends Equatable {
  const BibleAnnotation({
    required this.id,
    required this.userId,
    required this.version,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.type,
    this.colorHex,
    this.text,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String version;
  final String book;
  final int chapter;
  final int verse;
  final AnnotationType type;
  final String? colorHex; // for highlight
  final String? text; // for note
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'version': version,
        'book': book,
        'chapter': chapter,
        'verse': verse,
        'type': type.name,
        'colorHex': colorHex,
        'text': text,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  factory BibleAnnotation.fromDoc(String id, Map<String, dynamic> map) => BibleAnnotation(
        id: id,
        userId: map['userId'] as String,
        version: map['version'] as String? ?? 'web',
        book: map['book'] as String,
        chapter: (map['chapter'] as num).toInt(),
        verse: (map['verse'] as num).toInt(),
        type: AnnotationType.values.firstWhere((t) => t.name == (map['type'] as String? ?? 'bookmark'), orElse: () => AnnotationType.bookmark),
        colorHex: map['colorHex'] as String?,
        text: map['text'] as String?,
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '')?.toLocal() ?? DateTime.now(),
      );

  @override
  List<Object?> get props => [id, userId, version, book, chapter, verse, type, colorHex, text, createdAt];
}