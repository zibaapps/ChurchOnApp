import 'package:equatable/equatable.dart';

class ChatThread extends Equatable {
  const ChatThread({
    required this.id,
    required this.churchId,
    required this.title,
    required this.memberUids,
    this.lastMessage,
    this.updatedAt,
    this.isGroup = false,
  });

  final String id;
  final String churchId;
  final String title;
  final List<String> memberUids;
  final String? lastMessage;
  final DateTime? updatedAt;
  final bool isGroup;

  Map<String, dynamic> toMap() => {
        'churchId': churchId,
        'title': title,
        'memberUids': memberUids,
        'lastMessage': lastMessage,
        'updatedAt': updatedAt?.toUtc().toIso8601String(),
        'isGroup': isGroup,
      };

  factory ChatThread.fromDoc(String id, Map<String, dynamic> map) => ChatThread(
        id: id,
        churchId: map['churchId'] as String,
        title: map['title'] as String,
        memberUids: (map['memberUids'] as List?)?.cast<String>() ?? const <String>[],
        lastMessage: map['lastMessage'] as String?,
        updatedAt: (map['updatedAt'] as String?) != null ? DateTime.tryParse(map['updatedAt'] as String)?.toLocal() : null,
        isGroup: (map['isGroup'] as bool?) ?? false,
      );

  @override
  List<Object?> get props => [id, churchId, title, memberUids, lastMessage, updatedAt, isGroup];
}

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.senderUid,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final String senderUid;
  final String text;
  final DateTime sentAt;

  Map<String, dynamic> toMap() => {
        'senderUid': senderUid,
        'text': text,
        'sentAt': sentAt.toUtc().toIso8601String(),
      };

  factory ChatMessage.fromDoc(String id, Map<String, dynamic> map) => ChatMessage(
        id: id,
        senderUid: map['senderUid'] as String,
        text: map['text'] as String,
        sentAt: DateTime.tryParse(map['sentAt'] as String? ?? '')?.toLocal() ?? DateTime.now(),
      );

  @override
  List<Object?> get props => [id, senderUid, text, sentAt];
}