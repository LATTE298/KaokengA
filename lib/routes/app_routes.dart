// Named route constants (spec 02 §All Routes). Shared between GoRouter config
// and callsites — never hardcode paths elsewhere.

// Child routes
const String kRouteSplash = '/';
const String kRouteHome =
    '/home'; // หน้าเริ่ม (แนวตั้ง) ปุ่ม Play ก่อนเข้าเลือกโหมด
const String kRouteModeSelect = '/mode-select';
const String kRouteModuleA = '/module-a';
const String kRouteScenarioGame = '/module-a/game';
const String kRouteModuleB = '/module-b';
const String kRouteMemoryGame = '/module-b/game';
const String kRouteModuleC = '/module-c';
const String kRouteSoundBoard = '/module-c/sound-board';
const String kRouteVocabQuiz = '/module-c/quiz';
const String kRouteFamilyGame = '/family-game';

// Parent routes
const String kRouteParentGate = '/parent-gate';
const String kRouteAuth = '/parent/auth';
const String kRouteDashboard = '/parent/dashboard';
const String kRouteActivityLog = '/parent/log';
const String kRouteProgress = '/parent/progress';
const String kRouteScenarios = '/parent/scenarios';
const String kRouteFamilyManager = '/parent/family';

// index แท็บ "ความก้าวหน้า" ใน DashboardScreen (0=บันทึกการเล่น, 1=ความก้าวหน้า,
// 2=ตั้งค่าสถานการณ์) — ใช้ล็อกแท็บเมื่อเปิด dashboard แบบ `?view=progress`
// (เมนู "ความคืบหน้า" ฝั่งเด็ก เปิดดูได้แค่หน้านี้ สลับแท็บอื่นไม่ได้)
const int kDashboardProgressTab = 1;
