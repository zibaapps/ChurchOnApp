import 'package:equatable/equatable.dart';

import 'app_user.dart';

class Membership extends Equatable {
  const Membership({
    required this.churchId,
    required this.role,
    required this.joinedAt,
  });

  final String churchId;
  final AppRole role;
  final DateTime joinedAt;

  Map<String, dynamic> toMap() => {
        'churchId': churchId,
        'role': role.name,
        'joinedAt': joinedAt.toUtc().toIso8601String(),
      };

  factory Membership.fromMap(Map<String, dynamic> map) => Membership(
        churchId: map['churchId'] as String,
        role: AppRole.values.firstWhere(
          (r) => r.name == (map['role'] as String? ?? 'user'),
          orElse: () => AppRole.user,
        ),
        joinedAt: DateTime.tryParse(map['joinedAt'] as String? ?? '')?.toLocal() ?? DateTime.now(),
      );

  @override
  List<Object?> get props => [churchId, role, joinedAt];
}