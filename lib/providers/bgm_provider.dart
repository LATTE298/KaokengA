import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../services/bgm_service.dart';
import 'streak_provider.dart' show kAppPrefsBoxName;

/// เพลงธีมของแอป (singleton ตลอดอายุแอป) — เก็บสถานะเปิด/ปิด+เสียงใน box app_prefs
final bgmServiceProvider = Provider<BgmService>((ref) {
  // box อาจยังไม่เปิดใน widget test → ส่ง null (BgmService ใช้ค่า default ได้)
  final box =
      Hive.isBoxOpen(kAppPrefsBoxName)
          ? Hive.box<dynamic>(kAppPrefsBoxName)
          : null;
  final service = BgmService(box);
  ref.onDispose(service.dispose);
  return service;
});
