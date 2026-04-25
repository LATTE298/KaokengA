import 'package:flutter/services.dart';

// Haptic feedback per spec 08 §Haptic Feedback Map.
// A MethodChannel is used for the success double-buzz because Flutter's
// HapticFeedback API has no delay primitive.
class HapticService {
  static const MethodChannel _channel = MethodChannel('dailylife/haptic');

  static Future<void> grab() => HapticFeedback.selectionClick();

  static Future<void> tapLight() => HapticFeedback.selectionClick();

  static Future<void> memoryMatch() => HapticFeedback.mediumImpact();

  static Future<void> parentGateComplete() => HapticFeedback.mediumImpact();

  /// Success sequence: two 40ms buzzes with an 80ms gap.
  /// Falls back to a single heavyImpact if the native channel is absent
  /// (release build on a platform that hasn't been wired up yet).
  static Future<void> success() async {
    try {
      await _channel.invokeMethod('doubleBuzz', {'delay': 80});
    } on MissingPluginException {
      await HapticFeedback.heavyImpact();
    } on PlatformException {
      await HapticFeedback.heavyImpact();
    }
  }
}
