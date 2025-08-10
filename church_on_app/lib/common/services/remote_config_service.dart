import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  RemoteConfigService({FirebaseRemoteConfig? rc}) : _rc = rc ?? FirebaseRemoteConfig.instance;
  final FirebaseRemoteConfig _rc;

  Future<void> initialize() async {
    await _rc.setDefaults(const {
      'domain': 'churchapp.cloud',
      'supportEmail': 'support@churchapp.cloud',
      'supportPhone': '+260955202036',
      'themeSeed': '#212F4C',
      'pro_enable_live_stream': true,
      'pro_enable_nft_tokens': false,
      'pro_enable_global_leaderboard': true,
    });
    await _rc.fetchAndActivate();
  }

  String get domain => _rc.getString('domain');
  String get supportEmail => _rc.getString('supportEmail');
  String get supportPhone => _rc.getString('supportPhone');
  String get themeSeed => _rc.getString('themeSeed');

  bool get proLiveStream => _rc.getBool('pro_enable_live_stream');
  bool get proNftTokens => _rc.getBool('pro_enable_nft_tokens');
  bool get proGlobalLeaderboard => _rc.getBool('pro_enable_global_leaderboard');
}