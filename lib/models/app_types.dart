const kModuleDailyLife = 'daily_life';
const kModuleMemory = 'memory';
const kModuleVocab = 'vocab';
const kModuleFamily = 'family';

// หมวดคำศัพท์ 6 หมวดตาม vocabulary.json (คลังคำจริงของทีม) — ลำดับนี้ใช้เรียง
// การ์ดเลือกหมวดทั้งในเกมจับคู่ภาพและเกมตอบคำถาม และเป็นชุด key ที่
// ttsQuizQuestion รู้จัก. contentId ของ session: memory_<หมวด> / quiz_<หมวด>
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
