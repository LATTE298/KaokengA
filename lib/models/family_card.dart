import 'dart:typed_data';

// การ์ดคำถาม "หมวดครอบครัว" ที่ผู้ปกครองสร้างเอง (เฟส 2.1) — เก็บใน Hive local
// box `family_cards` เป็น Map (ไม่ใช้ TypeAdapter เพราะ hive_generator ชนเวอร์ชัน
// analyzer กับ freezed) — Hive เก็บ Uint8List/List/primitives ใน Map ได้ในตัว
//
// เด็กจะเห็น: รูป (imageBytes) + ตัวเลือก แล้วเลือกว่ารูปนี้คือใคร (ตอบถูก = answer)
// ตัวลวงมาจาก 2 ทาง: (1) randomChoices=false → ใช้ distractors ที่ผู้ปกครองกรอกเอง
// (2) randomChoices=true → สุ่มจากคำตอบของสมาชิกครอบครัวคนอื่นตอนเริ่มเล่น
class FamilyCard {
  const FamilyCard({
    required this.id,
    required this.imageBytes,
    required this.answer,
    required this.distractors,
    required this.randomChoices,
    required this.createdAt,
  });

  final String id;
  final Uint8List imageBytes; // รูปคนในครอบครัว (resize แล้ว ~600px JPEG)
  final String answer; // คำตอบที่ถูก (เช่น "แม่")
  final List<String>
  distractors; // ตัวลวงที่กรอกเอง (ใช้เมื่อ randomChoices=false)
  final bool randomChoices; // true = สุ่มตัวลวงจากคำตอบการ์ดอื่นตอนเล่น
  final int createdAt; // epoch ms — ใช้เรียงลำดับการ์ด

  Map<String, dynamic> toMap() => {
    'id': id,
    'imageBytes': imageBytes,
    'answer': answer,
    'distractors': distractors,
    'randomChoices': randomChoices,
    'createdAt': createdAt,
  };

  factory FamilyCard.fromMap(Map<dynamic, dynamic> map) => FamilyCard(
    id: map['id'] as String,
    imageBytes: map['imageBytes'] as Uint8List,
    answer: map['answer'] as String,
    distractors: (map['distractors'] as List).cast<String>(),
    randomChoices:
        map['randomChoices'] as bool? ?? false, // การ์ดเก่า = ไม่สุ่ม
    createdAt: map['createdAt'] as int,
  );
}
