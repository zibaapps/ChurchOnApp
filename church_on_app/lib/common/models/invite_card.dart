import 'package:equatable/equatable.dart';

class InviteCard extends Equatable {
  const InviteCard({
    required this.id,
    required this.churchId,
    required this.title,
    required this.message,
    required this.qrData,
    this.bannerUrl,
    this.serviceTime,
    this.location,
    this.isOnline = false,
    this.createdAt,
  });

  final String id;
  final String churchId;
  final String title;
  final String message;
  final String qrData;
  final String? bannerUrl;
  final String? serviceTime;
  final String? location;
  final bool isOnline;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        'churchId': churchId,
        'title': title,
        'message': message,
        'qrData': qrData,
        'bannerUrl': bannerUrl,
        'serviceTime': serviceTime,
        'location': location,
        'isOnline': isOnline,
        'createdAt': createdAt?.toUtc().toIso8601String(),
      };

  factory InviteCard.fromDoc(String id, Map<String, dynamic> map) => InviteCard(
        id: id,
        churchId: map['churchId'] as String,
        title: map['title'] as String,
        message: map['message'] as String,
        qrData: map['qrData'] as String,
        bannerUrl: map['bannerUrl'] as String?,
        serviceTime: map['serviceTime'] as String?,
        location: map['location'] as String?,
        isOnline: (map['isOnline'] as bool?) ?? false,
        createdAt: (map['createdAt'] as String?) != null ? DateTime.tryParse(map['createdAt'] as String)?.toLocal() : null,
      );

  @override
  List<Object?> get props => [id, churchId, title, qrData, isOnline];
}