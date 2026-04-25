// All Thai TTS strings used by the app. Kept separate from UI strings (spec 08).
// These text values are hashed to form the TTS audio cache key — do not edit
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
