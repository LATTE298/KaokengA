import 'dart:typed_data';

// การ์ดคำถาม "หมวดครอบครัว" ที่ผู้ปกครองสร้างเอง (เฟส 2.1) — เก็บใน Hive local
// box `family_cards` เป็น Map (ไม่ใช้ TypeAdapter เพราะ hive_generator ชนเวอร์ชัน
// analyzer กับ freezed) — Hive เก็บ Uint8List/List/primitives ใน Map ได้ในตัว
//
// เด็กจะเห็น: รูป (imageBytes) + ตัวเลือก = สลับลำดับของ [answer, ...distractors]
// แล้วเลือกว่ารูปนี้คือใคร — ตอบถูกเมื่อเลือกตรงกับ answer
class FamilyCard {
  const FamilyCard({
    required this.id,
    required this.imageBytes,
    required this.answer,
    required this.distractors,
    required this.createdAt,
  });

  final String id;
  final Uint8List imageBytes; // รูปคนในครอบครัว (resize แล้ว ~600px JPEG)
  final String answer; // คำตอบที่ถูก (เช่น "แม่")
  final List<String>
  distractors; // ตัวลวงที่ผู้ปกครองกำหนด (เช่น ["พ่อ", "พี่"])
  final int createdAt; // epoch ms — ใช้เรียงลำดับการ์ด

  Map<String, dynamic> toMap() => {
    'id': id,
    'imageBytes': imageBytes,
    'answer': answer,
    'distractors': distractors,
    'createdAt': createdAt,
  };

  factory FamilyCard.fromMap(Map<dynamic, dynamic> map) => FamilyCard(
    id: map['id'] as String,
    imageBytes: map['imageBytes'] as Uint8List,
    answer: map['answer'] as String,
    distractors: (map['distractors'] as List).cast<String>(),
    createdAt: map['createdAt'] as int,
  );
}
