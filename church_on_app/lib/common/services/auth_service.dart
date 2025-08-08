import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../models/app_user.dart';

class AuthService {
  AuthService({fb.FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<AppUser?> authUserStream() {
    return _auth.authStateChanges().asyncMap((fb.User? user) async {
      if (user == null) return null;
      final userRef = _firestore.collection('users').doc(user.uid);
      final snap = await userRef.get();
      if (!snap.exists) {
        final newUser = AppUser(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          role: AppRole.user,
          churchId: null,
          photoUrl: user.photoURL,
        );
        await userRef.set(newUser.toMap(), SetOptions(merge: true));
        return newUser;
      }
      return AppUser.fromMap(snap.data()!);
    });
  }

  Future<AppUser> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return _ensureUserDocument(credential.user!);
  }

  Future<AppUser> registerWithEmail(String email, String password, {String? displayName}) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (displayName != null && displayName.isNotEmpty) {
      await credential.user!.updateDisplayName(displayName);
    }
    return _ensureUserDocument(credential.user!);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> setUserChurch(String uid, String churchId) async {
    await _firestore.collection('users').doc(uid).set({'churchId': churchId}, SetOptions(merge: true));
  }

  Future<AppUser> _ensureUserDocument(fb.User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final snap = await userRef.get();
    if (!snap.exists) {
      final newUser = AppUser(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        role: AppRole.user,
        churchId: null,
        photoUrl: user.photoURL,
      );
      await userRef.set(newUser.toMap(), SetOptions(merge: true));
      return newUser;
    }
    return AppUser.fromMap(snap.data()!);
  }
}