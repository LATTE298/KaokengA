// All Thai TTS strings used by the app. Kept separate from UI strings (spec 08).
// These text values are hashed to form the TTS audio cache key – do not edit
// casually without bumping the scenario version (spec 08 §Caching Strategy).

// --- System / Navigation ---------------------------------------------------

const String kTtsSplashGreeting = 'สวัสดีครับ';
const String kTtsModuleADesc = 'มาลองทำกิจกรรมในชีวิตประจำวันกันนะครับ';
const String kTtsModuleBDesc = 'มาเล่นเกมจับคู่ภาพกันนะครับ';
const String kTtsModuleCDesc = 'มาเรียนรู้คำศัพท์ใหม่กันนะครับ';
const String kTtsMemoryStart = 'มาจับคู่รูปภาพกันนะครับ';
const String kTtsSoundBoardStart = 'มาเรียนรู้คำศัพท์กันนะครับ';

// --- Celebrations (randomised per success) --------------------------------

const String kTtsCelebration1 = 'เก่งมากเลยนะครับ! น้องทำได้แล้ว!';
const String kTtsCelebration2 = 'ดีมากเลยครับ! เยี่ยมมากเลย!';
const String kTtsCelebration3 = 'น้องทำได้ดีมากครับ! เก่งมากๆ!';

const List<String> kTtsCelebrations = [
  kTtsCelebration1,
  kTtsCelebration2,
  kTtsCelebration3,
];

// --- Memory game ----------------------------------------------------------

const String kTtsMemoryMatch = 'จับคู่ได้แล้ว!';
const String kTtsMemoryComplete = 'เก่งมากเลย! จับคู่ได้ครบแล้ว!';

// ชื่อคู่ + คำชมต้องรวมเป็น utterance เดียว (เช่น "แมว จับคู่ได้แล้ว!") ห้ามแยก speak
// สองครั้งติดกัน — speak ครั้งใหม่ตัดเสียงก่อนหน้าเสมอ ชื่อคู่จะโดนตัดก่อนพูดจบ
String ttsMemoryMatchNamed(String pairName) => '$pairName $kTtsMemoryMatch';

// --- Vocab quiz (Module C — เกมตอบคำถามตามเอกสารข้อเสนอ) -------------------
// รูปแบบตาม mockup ในเอกสาร: โชว์รูปใหญ่ → พูด/โชว์คำถามตามหมวด → เลือก ก/ข/ค
// ห้ามพูด "คำตอบ" ตอนตั้งโจทย์ (จะเฉลยทันที) — พูดประโยคคำถามตามหมวดแทน

const String kTtsQuizStart = 'ดูรูปแล้วเลือกคำตอบที่ถูกต้องนะครับ';
const String kTtsQuizCorrect = 'ถูกต้องครับ เก่งมาก!';
const String kTtsQuizRetry = 'ยังไม่ใช่ ลองใหม่อีกครั้งนะครับ';
const String kTtsQuizComplete = 'เก่งมากเลย! ตอบครบทุกข้อแล้ว!';

const String kTtsQuizAskAnimals = 'นี่คือสัตว์อะไร';
const String kTtsQuizAskFood = 'นี่คืออาหารอะไร';
const String kTtsQuizAskDrinks = 'นี่คือเครื่องดื่มอะไร';
const String kTtsQuizAskPlaces = 'นี่คือที่ไหน';
const String kTtsQuizAskOccupations = 'นี่คืออาชีพอะไร';
const String kTtsQuizAskGeneric = 'นี่คืออะไร';

// เกมหมวดครอบครัว (เฟส 2.1) — ถามว่ารูปคนในครอบครัวรูปนี้คือใคร
const String kTtsFamilyAsk = 'นี่คือใคร';

/// ประโยคคำถามตามหมวดคำศัพท์ (หมวดตรงกับ vocabulary.json ชุดจริง 6 หมวดของทีม)
/// — UI เอาไปเติม "?" ตอนแสดงผลเองได้ แต่ตัว TTS ใช้ข้อความนี้ตรงๆ (เป็น key
/// ของคลิปใน manifest). หมวด everyday ปนคำกริยา/ความรู้สึก จึงใช้คำถามกลางๆ
String ttsQuizQuestion(String category) {
  return switch (category) {
    'animals' => kTtsQuizAskAnimals,
    'food' => kTtsQuizAskFood,
    'drinks' => kTtsQuizAskDrinks,
    'places' => kTtsQuizAskPlaces,
    'occupations' => kTtsQuizAskOccupations,
    _ => kTtsQuizAskGeneric,
  };
}

// --- Module A: ชื่อไอเทมในฉาก + โจทย์สุ่มผลไม้ 2 ชนิด ----------------------
// ชื่อไทยของ interactable ทุกฉาก — ใช้ทั้งประกอบประโยค TTS และหัวข้อโจทย์บนจอ
// ⚠️ เพิ่ม id ใหม่ในไฟล์ฉากเมื่อไหร่ต้องเพิ่มที่นี่ + คลิปเสียงที่เกี่ยวใน manifest
const Map<String, String> kScenarioItemNamesTh = {
  'milk_carton_blue': 'นมกล่องสีน้ำเงิน',
  'bread_loaf': 'ขนมปัง',
  'potato_chips': 'ขนมกรุบกรอบ',
  'plastic_bottle': 'ขวดพลาสติก',
  'food_waste': 'เศษอาหาร',
  'paper_ball': 'กระดาษ',
  'battery': 'ถ่านไฟฉาย',
  'banana': 'กล้วย',
  'orange': 'ส้ม',
  'apple': 'แอปเปิ้ล',
  'grapes': 'องุ่น',
};

/// ชื่อไทยของไอเทมในฉาก Module A (fallback = id ถ้ายังไม่ลงทะเบียน)
String scenarioItemNameTh(String id) => kScenarioItemNamesTh[id] ?? id;

/// โจทย์เกมจัดผลไม้โหมดสุ่ม 2 ชนิด — ประโยคเดียวบอกครบทั้งคู่ (กติกา TTS:
/// หนึ่งเหตุการณ์พูดครั้งเดียว). เป็น key คลิปใน manifest — เรียงชื่อตามลำดับ
/// ไอเทมใน JSON ฉากเสมอ (6 คู่ = 6 คลิป sc_fruit_pick_*)
String ttsFruitPickAsk(String nameA, String nameB) =>
    'น้องช่วยหยิบ$nameAกับ$nameBใส่ถ้วยให้หน่อยนะครับ';

// --- Time-Limiter / Break reminder (spec 1.4) -----------------------------
// ข้อความ TTS เตือนพักสายตา — โทนนุ่มนวล เหมือนเพื่อนเตือน ไม่ใช่ครู/พ่อแม่สั่งห้าม
const String kTtsBreakReminder = 'น้องเล่นมานานแล้วนะครับ มาพักสายตาก่อนนะ';

// --- Module titles (child-facing labels, also spoken) ---------------------

const String kLabelModuleA = 'ชีวิตประจำวัน';
const String kLabelModuleB = 'จับคู่ภาพ';
const String kLabelModuleC = 'คำศัพท์';

// --- Parent (not spoken, but Thai UI copy lives here for one-stop lookup) -

const String kParentGateTitle = 'ส่วนนี้สำหรับผู้ปกครอง';
const String kParentGateEnter = 'เข้าสู่ส่วนผู้ปกครอง';
const String kParentRegisterBtn = 'สร้างบัญชี';
const String kParentLoginBtn = 'เข้าสู่ระบบ';
const String kParentLogoutBtn = 'ออกจากระบบ';
const String kParentEmptyLog =
    'ยังไม่มีข้อมูลการเล่น เริ่มเล่นกับน้องเลยนะครับ';
const String kLoadMore = 'โหลดเพิ่มเติม';

// --- Break reminder dialog UI copy (not spoken) ---------------------------
const String kBreakReminderTitle = 'พักสายตาก่อนนะ';
const String kBreakReminderBody =
    'น้องเล่นมานานแล้ว มาพักหลับตา หรือมองออกไปไกลๆสักครู่นะครับ';
const String kBreakReminderContinue = 'พักเสร็จแล้ว เล่นต่อ';
const String kBreakReminderExit = 'ออกไปก่อน';
