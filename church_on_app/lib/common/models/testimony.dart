import 'package:equatable/equatable.dart';

enum TestimonyStatus { pending, approved, rejected }

class Testimony extends Equatable {
  const Testimony({
    required this.id,
    required this.churchId,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    this.status = TestimonyStatus.approved,
    this.likes = 0,
  });

  final String id;
  final String churchId;
  final String userId;
  final String title;
  final String body;
  final DateTime createdAt;
  final TestimonyStatus status;
  final int likes;

  Map<String, dynamic> toMap() => {
        'churchId': churchId,
        'userId': userId,
        'title': title,
        'body': body,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'status': status.name,
        'likes': likes,
      };

  factory Testimony.fromDoc(String id, Map<String, dynamic> map) => Testimony(
        id: id,
        churchId: map['churchId'] as String? ?? '',
        userId: map['userId'] as String? ?? '',
        title: map['title'] as String? ?? '',
        body: map['body'] as String? ?? '',
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '')?.toLocal() ?? DateTime.now(),
        status: TestimonyStatus.values.firstWhere((s) => s.name == (map['status'] as String? ?? 'approved'), orElse: () => TestimonyStatus.approved),
        likes: (map['likes'] as num?)?.toInt() ?? 0,
      );

  @override
  List<Object?> get props => [id, churchId, userId, title, createdAt, status, likes];
}