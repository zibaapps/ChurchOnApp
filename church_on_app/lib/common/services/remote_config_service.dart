import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  RemoteConfigService({FirebaseRemoteConfig? remoteConfig}) : _rc = remoteConfig ?? FirebaseRemoteConfig.instance;
  final FirebaseRemoteConfig _rc;

  Future<void> initialize() async {
    await _rc.setDefaults(const {
      'domain': 'churchapp.cloud',
      'supportEmail': 'support@churchapp.cloud',
      'supportPhone': '+260968551110',
    });
    await _rc.fetchAndActivate();
  }

  String get domain => _rc.getString('domain');
  String get supportEmail => _rc.getString('supportEmail');
  String get supportPhone => _rc.getString('supportPhone');
}