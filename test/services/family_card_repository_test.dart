import 'dart:io';
import 'dart:typed_data';

import 'package:daily_life/services/family_card_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:image/image.dart' as img;

void main() {
  late Directory dir;
  late Box<dynamic> box;
  late FamilyCardRepository repo;

  setUpAll(() {
    dir = Directory.systemTemp.createTempSync('family_hive_test');
    Hive.init(dir.path);
  });

  setUp(() async {
    box = await Hive.openBox<dynamic>('family_test_box');
    await box.clear();
    repo = FamilyCardRepository(box);
  });

  tearDown(() async {
    await box.close();
  });

  tearDownAll(() {
    dir.deleteSync(recursive: true);
  });

  test('addCard แล้ว listCards เห็นการ์ดพร้อมข้อมูลครบ', () async {
    await repo.addCard(
      imageBytes: Uint8List.fromList([1, 2, 3]),
      answer: 'แม่',
      distractors: ['พ่อ', 'พี่'],
    );
    final cards = repo.listCards();
    expect(cards, hasLength(1));
    expect(cards.first.answer, 'แม่');
    expect(cards.first.distractors, ['พ่อ', 'พี่']);
    expect(cards.first.imageBytes, [1, 2, 3]);
  });

  test('deleteCard ลบการ์ดที่ระบุออก', () async {
    await repo.addCard(
      imageBytes: Uint8List.fromList([1]),
      answer: 'แม่',
      distractors: ['พ่อ', 'พี่'],
    );
    await repo.deleteCard(repo.listCards().first.id);
    expect(repo.listCards(), isEmpty);
  });

  test('resizeImage ย่อด้านยาวสุดเหลือ 600px', () {
    final big = img.Image(width: 1200, height: 900);
    final bytes = Uint8List.fromList(img.encodePng(big));
    final resized = FamilyCardRepository.resizeImage(bytes);
    final decoded = img.decodeImage(resized)!;
    expect(decoded.width, 600);
    expect(decoded.height, lessThanOrEqualTo(600));
  });
}
