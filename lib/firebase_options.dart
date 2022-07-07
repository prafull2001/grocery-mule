// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyAKf8jFE0k7IrXzLlZvVVTFdSMWXX-DiUo',
    appId: '1:656233033461:web:4cd14a897609a0dd0fdfbc',
    messagingSenderId: '656233033461',
    projectId: 'grocerymule-51aab',
    authDomain: 'grocerymule-51aab.firebaseapp.com',
    storageBucket: 'grocerymule-51aab.appspot.com',
    measurementId: 'G-36PCS14GLS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDrxzWQkv1JvwyEV1Gz2mnn9dl3kXPWzo0',
    appId: '1:656233033461:android:9069abd9214a46df0fdfbc',
    messagingSenderId: '656233033461',
    projectId: 'grocerymule-51aab',
    storageBucket: 'grocerymule-51aab.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB_oa6OnlimIROhDdWbNZiPwtU6q7TssMM',
    appId: '1:656233033461:ios:e6e2f750a924b3230fdfbc',
    messagingSenderId: '656233033461',
    projectId: 'grocerymule-51aab',
    storageBucket: 'grocerymule-51aab.appspot.com',
    androidClientId: '656233033461-0psv12jk151bv0es1m8og6e35tpr8to0.apps.googleusercontent.com',
    iosClientId: '656233033461-5dtsf0a3ii5204gu52j8kt6kjnprrur2.apps.googleusercontent.com',
    iosBundleId: 'net.prafullsharma.grocerymule',
  );
}
