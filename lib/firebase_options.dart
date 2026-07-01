import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        return windows;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAigZt2TR83hkK25VC8JZ0AXQsm96PfBxc',
    appId: '1:175850117633:web:f434df1e0134a5c245fe00',
    messagingSenderId: '175850117633',
    projectId: 'invictus-mun-management',
    authDomain: 'invictus-mun-management.firebaseapp.com',
    storageBucket: 'invictus-mun-management.firebasestorage.app',
    measurementId: 'G-FNNNFM6V55',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD8birF6JFyYPyYTX_0ySRRKxj0wXjJ1OU',
    appId: '1:175850117633:android:6b80eb0272fbe76145fe00',
    messagingSenderId: '175850117633',
    projectId: 'invictus-mun-management',
    storageBucket: 'invictus-mun-management.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBViWn3N-C2eSc971_B64xVCO1Grl3VufI',
    appId: '1:175850117633:ios:ec8123d78db18aa345fe00',
    messagingSenderId: '175850117633',
    projectId: 'invictus-mun-management',
    storageBucket: 'invictus-mun-management.firebasestorage.app',
    iosBundleId: 'com.example.invictusMunManagement',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBViWn3N-C2eSc971_B64xVCO1Grl3VufI',
    appId: '1:175850117633:ios:ec8123d78db18aa345fe00',
    messagingSenderId: '175850117633',
    projectId: 'invictus-mun-management',
    storageBucket: 'invictus-mun-management.firebasestorage.app',
    iosBundleId: 'com.example.invictusMunManagement',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAigZt2TR83hkK25VC8JZ0AXQsm96PfBxc',
    appId: '1:175850117633:web:bcb343f8c25cac9945fe00',
    messagingSenderId: '175850117633',
    projectId: 'invictus-mun-management',
    authDomain: 'invictus-mun-management.firebaseapp.com',
    storageBucket: 'invictus-mun-management.firebasestorage.app',
    measurementId: 'G-3VL3NTGBF5',
  );
  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'YOUR_LINUX_API_KEY',
    appId: 'YOUR_LINUX_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_FIREBASE_PROJECT_ID',
    authDomain: 'YOUR_FIREBASE_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_FIREBASE_PROJECT_ID.appspot.com',
  );
}
