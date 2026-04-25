// Generated from Firebase MCP `firebase_get_sdk_config` (Android only).
// Regenerate via `flutterfire configure` when iOS / Web targets are added.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // For testing on web, use web config (same Firebase project).
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'FirebaseOptions for ${defaultTargetPlatform.name} are not configured yet — '
          'Android is the MVP target (spec 01 §Platform Targets).',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC0-G72WvA9_tg8xcWjt96bwKyAM7dXRLQ',
    appId: '1:865042115500:android:3eb4414ab11d2739b22809',
    messagingSenderId: '865042115500',
    projectId: 'tenacious-veld-453115-u8',
    storageBucket: 'tenacious-veld-453115-u8.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC0-G72WvA9_tg8xcWjt96bwKyAM7dXRLQ',
    appId: '1:865042115500:web:8f1c5e7e9a2b3c4d5e6f7g8h',
    messagingSenderId: '865042115500',
    projectId: 'tenacious-veld-453115-u8',
    storageBucket: 'tenacious-veld-453115-u8.firebasestorage.app',
  );
}
