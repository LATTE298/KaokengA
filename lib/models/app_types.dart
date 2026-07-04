const kModuleDailyLife = 'daily_life';
const kModuleMemory = 'memory';
const kModuleVocab = 'vocab';

// contentId ของเกมตอบคำถามคำศัพท์ (Module C ใช้คลังคำจาก vocabulary.json ชุดเดียว)
const kVocabQuizContentId = 'vocabulary_001';

// หมวดคำศัพท์ 6 หมวดตาม vocabulary.json (คลังคำจริงของทีม) — ลำดับนี้ใช้เรียง
// การ์ดเลือกหมวดในเกมจับคู่ภาพ และเป็นชุด key ที่ ttsQuizQuestion รู้จัก
const List<String> kVocabCategories = [
  'animals',
  'food',
  'drinks',
  'places',
  'occupations',
  'everyday',
];

const Map<String, String> kVocabCategoryTitles = {
  'animals': 'สัตว์',
  'food': 'อาหาร',
  'drinks': 'เครื่องดื่ม',
  'places': 'สถานที่',
  'occupations': 'อาชีพ',
  'everyday': 'ชีวิตประจำวัน',
};
