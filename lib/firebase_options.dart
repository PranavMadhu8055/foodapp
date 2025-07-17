import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBlNfH7UZERs7icpLGhmmcBc3J9iaSKco4',
    appId: '1:720142203360:web:c36b30618d60eb1dc9d385',
    messagingSenderId: '720142203360',
    projectId: 'teaworld-3172d',
    authDomain: 'teaworld-3172d.firebaseapp.com',
    databaseURL: 'https://teaworld-3172d-default-rtdb.firebaseio.com',
    storageBucket: 'teaworld-3172d.appspot.com',
    measurementId: 'G-EPHKP929Q7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBlNfH7UZERs7icpLGhmmcBc3J9iaSKco4',
    appId: '1:720142203360:android:c36b30618d60eb1dc9d385', // Note: This App ID is a placeholder from web.
    messagingSenderId: '720142203360',
    projectId: 'teaworld-3172d',
    databaseURL: 'https://teaworld-3172d-default-rtdb.firebaseio.com',
    storageBucket: 'teaworld-3172d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBlNfH7UZERs7icpLGhmmcBc3J9iaSKco4',
    appId: '1:720142203360:ios:c36b30618d60eb1dc9d385', // Note: This App ID is a placeholder from web.
    messagingSenderId: '720142203360',
    projectId: 'teaworld-3172d',
    databaseURL: 'https://teaworld-3172d-default-rtdb.firebaseio.com',
    storageBucket: 'teaworld-3172d.appspot.com',
    iosBundleId: 'com.example.foodapp', // Note: Please update with your actual bundle ID.
  );
}