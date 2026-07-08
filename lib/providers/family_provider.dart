import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/family_card.dart';
import '../services/family_card_repository.dart';

// box ถูกเปิดไว้แล้วใน main.dart ก่อน runApp — provider แค่หยิบมาใช้
final familyCardRepositoryProvider = Provider<FamilyCardRepository>((ref) {
  return FamilyCardRepository(Hive.box(FamilyCardRepository.boxName));
});

// รายการการ์ดที่ผู้ปกครองสร้าง — รีเฟรชอัตโนมัติเมื่อ box เปลี่ยน (เพิ่ม/ลบการ์ด)
// เพื่อให้ทั้งหน้าจัดการของผู้ปกครองและเกมของเด็กเห็นข้อมูลตรงกันเสมอ
final familyCardsProvider = StreamProvider<List<FamilyCard>>((ref) async* {
  final repo = ref.watch(familyCardRepositoryProvider);
  yield repo.listCards();
  await for (final _ in Hive.box(FamilyCardRepository.boxName).watch()) {
    yield repo.listCards();
  }
});
