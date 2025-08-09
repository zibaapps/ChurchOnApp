import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ZipModeService {
  ZipModeService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  final StreamController<bool> _zipStream = StreamController<bool>.broadcast();

  Stream<bool> get zipEnabledStream => _zipStream.stream;
  bool _enabled = false;

  bool get isEnabled => _enabled;

  Future<void> enable({required String churchId, required String reason}) async {
    _enabled = true;
    _zipStream.add(true);
    await _firestore.collection('churches').doc(churchId).update({'zipMode': {'enabled': true, 'reason': reason, 'updatedAt': DateTime.now().toUtc().toIso8601String()}});
  }

  Future<void> disable({required String churchId}) async {
    _enabled = false;
    _zipStream.add(false);
    await _firestore.collection('churches').doc(churchId).update({'zipMode': {'enabled': false, 'updatedAt': DateTime.now().toUtc().toIso8601String()}});
  }

  Future<bool> isZipEnabled(String churchId) async {
    final doc = await _firestore.collection('churches').doc(churchId).get();
    return (doc.data()?['zipMode']?['enabled'] as bool?) ?? false;
  }

  Future<void> guardWrite(String churchId) async {
    if (await isZipEnabled(churchId)) {
      throw Exception('Zip Mode is active. This action is temporarily disabled.');
    }
  }
}

class ShakeSosService {
  StreamSubscription<AccelerometerEvent>? _sub;
  DateTime _lastTrigger = DateTime.fromMillisecondsSinceEpoch(0);

  void startListening({required Future<List<String>> Function() getEmergencyNumbers, required String defaultNumber}) {
    _sub?.cancel();
    _sub = accelerometerEventStream().listen((e) async {
      final magnitude = (e.x * e.x + e.y * e.y + e.z * e.z).sqrt();
      if (magnitude > 250) { // rough threshold
        final now = DateTime.now();
        if (now.difference(_lastTrigger).inSeconds < 10) return; // throttle
        _lastTrigger = now;
        try {
          final nums = await getEmergencyNumbers();
          final number = (nums.isNotEmpty ? nums.first : defaultNumber).replaceAll(' ', '');
          await _callNumber(number);
          await _sendSosSms(nums.isNotEmpty ? nums : [defaultNumber]);
          HapticFeedback.heavyImpact();
        } catch (_) {}
      }
    });
  }

  void stopListening() {
    _sub?.cancel();
    _sub = null;
  }

  Future<void> _callNumber(String number) async {
    final uri = Uri.parse('tel:$number');
    await launchUrl(uri);
  }

  Future<void> _sendSosSms(List<String> numbers) async {
    for (final n in numbers) {
      final uri = Uri.parse('sms:$n?body=${Uri.encodeComponent('SOS: I need help. Sent from Church On App') }');
      await launchUrl(uri);
    }
  }
}

extension on num {
  double sqrt() => MathSqrt.sqrt(this.toDouble());
}

class MathSqrt {
  static double sqrt(double x) => x <= 0 ? 0 : x.toDouble().sqrtApprox();
}

extension on double {
  double sqrtApprox() {
    double z = this;
    double x = this / 2.0 + 1.0;
    while ((x - z / x).abs() > 1e-3) {
      x = (x + z / x) / 2.0;
    }
    return x;
  }
}