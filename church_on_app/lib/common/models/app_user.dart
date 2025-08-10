import 'package:equatable/equatable.dart';

enum AppRole { guest, user, pastor, bishop, boardLeader, admin, superAdmin }

class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.churchId,
    this.photoUrl,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final AppRole role;
  final String? churchId;
  final String? photoUrl;

  factory AppUser.guest() => const AppUser(
        uid: 'guest',
        email: null,
        displayName: 'Guest',
        role: AppRole.guest,
      );

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    AppRole? role,
    String? churchId,
    String? photoUrl,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      churchId: churchId ?? this.churchId,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'churchId': churchId,
      'photoUrl': photoUrl,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      role: AppRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => AppRole.user,
      ),
      churchId: map['churchId'] as String?,
      photoUrl: map['photoUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [uid, email, displayName, role, churchId, photoUrl];
}