import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

class DomainService {
  DomainService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  Future<String?> resolveChurchIdFromHost() async {
    if (!kIsWeb) return null;
    final host = html.window.location.host.toLowerCase();
    if (host.isEmpty) return null;
    final snap = await _firestore.collection('domains').doc(host).get();
    if (!snap.exists) return null;
    final data = snap.data() as Map<String, dynamic>;
    return data['churchId'] as String?;
  }
}