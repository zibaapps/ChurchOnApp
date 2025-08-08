// ignore_for_file: constant_identifier_names

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError('No Firebase options configured for this platform. Provide mobile configs or run on web.');
  }

  // Web options from user-provided config
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB-lqd2ZufKPNBnYnIA7cl5vn-D7uaAw6k',
    appId: '1:390897506707:web:13304ad0a19d5159f07066',
    messagingSenderId: '390897506707',
    projectId: 'church-on-app',
    storageBucket: 'church-on-app.firebasestorage.app',
    authDomain: 'church-on-app.firebaseapp.com',
    measurementId: 'G-J92J7P7T5L',
  );
}