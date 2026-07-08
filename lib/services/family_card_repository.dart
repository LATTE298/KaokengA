import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/family_card.dart';

// อ่าน/เขียนการ์ดหมวดครอบครัวใน Hive box `family_cards` (offline ในเครื่อง)
// + จัดการรูป: เลือกจากแกลเลอรีแล้ว resize ก่อนเก็บ ไม่ให้ box บวมจากรูปเต็มความละเอียด
class FamilyCardRepository {
  FamilyCardRepository(this._box, {ImagePicker? picker, Uuid? uuid})
    : _picker = picker ?? ImagePicker(),
      _uuid = uuid ?? const Uuid();

  static const String boxName = 'family_cards';

  final Box<dynamic> _box;
  final ImagePicker _picker;
  final Uuid _uuid;

  List<FamilyCard> listCards() {
    final cards = _box.values.map((v) => FamilyCard.fromMap(v as Map)).toList();
    cards.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return cards;
  }

  Future<void> addCard({
    required Uint8List imageBytes,
    required String answer,
    required List<String> distractors,
    bool randomChoices = false,
  }) async {
    final id = _uuid.v4();
    final card = FamilyCard(
      id: id,
      imageBytes: imageBytes,
      answer: answer,
      distractors: distractors,
      randomChoices: randomChoices,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _box.put(id, card.toMap());
  }

  Future<void> deleteCard(String id) => _box.delete(id);

  /// เลือกรูปจากแกลเลอรี แล้ว resize — คืน null ถ้าผู้ใช้ยกเลิก
  Future<Uint8List?> pickAndResizeImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    return resizeImage(bytes);
  }

  /// ย่อให้ด้านยาวสุด ~600px + encode JPEG q80 (คุมขนาด ~50-100KB/รูป)
  /// static เพื่อให้ unit test เรียกได้ตรงๆ ไม่ต้องมี ImagePicker
  static Uint8List resizeImage(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return bytes; // ถอดรหัสไม่ได้ (เช่น format แปลก) — เก็บดิบ
    }
    final resized =
        decoded.width >= decoded.height
            ? img.copyResize(decoded, width: 600)
            : img.copyResize(decoded, height: 600);
    return Uint8List.fromList(img.encodeJpg(resized, quality: 80));
  }
}
