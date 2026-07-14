# CLAUDE.md — Kaokeng (ก้าวเก่ง)

> ไฟล์นี้เป็นบริบทหลักของโปรเจกต์สำหรับ Claude Code อ่านก่อนเริ่มงานทุกครั้ง
> เขียนขึ้นเพื่อส่งต่อบริบทจาก session งานก่อนหน้า (เฟส 1 ทั้งหมด + bug เสถียรภาพ/TTS + responsive B/C ทำเสร็จแล้ว — เหลือ asset 404 กับเฟส 2)

---

## 1. ภาพรวมโปรเจกต์

**Kaokeng (ก้าวเก่ง)** — แอปพลิเคชันช่วยเหลือเด็กพิเศษ (เน้นกลุ่มอาการดาวน์ซินโดรม) ในการเรียนรู้ทักษะการใช้ชีวิตประจำวันและการสื่อสาร ผ่านเกมแบบ Gamification + Visual/Interactive Learning

- **แพลตฟอร์มหลัก:** แท็บเล็ต/มือถือ Android (**ล็อกแนวนอนเสมอ** — landscape only)
- **สถานะ PC port:** พักไว้ก่อน โฟกัส Mobile/Tablet ให้เสถียร 100% ก่อน
- **เอกสารอ้างอิง:** ข้อเสนอโครงการการแข่งขันพัฒนาโปรแกรมคอมพิวเตอร์แห่งประเทศไทย (รหัส 28P22N00903) — ทีม 3 คน โรงเรียนยุพราชวิทยาลัย

### Tech Stack
- Flutter + Dart
- **Flame** (game engine — ใช้ใน Module A drag & drop)
- **Riverpod 2** (state management)
- **Freezed** + json_serializable (models)
- **go_router** (navigation)
- **Firebase** Auth (anonymous สำหรับเด็ก + email/password สำหรับผู้ปกครอง) + Firestore
- **just_audio** + Google Cloud TTS (เสียงพูดภาษาไทย) + **flutter_tts** (เสียงในเครื่อง — เครื่องเสียงสำรอง)

### โครงสร้าง lib/ (ย่อ)
```
lib/
├── main.dart
├── firebase_options.dart
├── features/
│   ├── memory/          # logic เกมจับคู่ (pure, testable)
│   ├── sessions/        # session recorder
│   └── usage_timer/     # ★ เฟส 1.4 — ตัวจับเวลาเตือนพัก
├── game/                # Flame components (Module A)
├── models/              # Freezed models
├── providers/           # Riverpod providers
├── routes/              # app_router.dart, app_routes.dart
├── screens/
│   ├── child/           # หน้าจอฝั่งเด็ก
│   └── parent/          # หน้าจอฝั่งผู้ปกครอง (dashboard)
├── services/            # tts, haptic, auth, content_repository
├── theme/               # ★ colors, spacing, typography, app_theme, responsive
├── widgets/             # ★ shared widgets
└── l10n/                # tts_strings_th.dart
```

### 3 โมดูลหลัก
- **Module A (ชีวิตประจำวัน):** drag & drop ผ่าน Flame — 3 สถานการณ์ 2 โหมด: ซื้อของเซเว่น = โจทย์สุ่มชิ้นเดียวลงตะกร้า / **คัดแยกขยะ 4 ถัง + จัดผลไม้ใส่ถ้วย = โหมด sort-all (2026-07-10)** ลากลงโซนของตัวเองจนครบ (JSON มี `zones` + `zone_id` ต่อชิ้น = sort-all, ไม่มี = โหมดเดิม; `pick_count: 2` = สุ่มโจทย์บางชิ้น เช่น ผลไม้สุ่ม 2 จาก 4 — ชิ้นนอกโจทย์ลงโซนแล้วโดนปฏิเสธ; `cover_fit: true` = พื้นหลังรักษาสัดส่วนไม่ยืด + `zones`/`start_pos` เป็น**สัดส่วน 0..1 ของรูป** ไม่ใช่ authoring 1920×1080 — ฉากผลไม้ใช้ ให้โซนล็อกกับภาพทุกจอ). Scoring: ถูกทุกครั้ง=10, ผิด1=8, ผิด2=6, >3=4
- **Module B (จับคู่ภาพ):** เลือกหมวดก่อน (6 หมวดจากคลังคำศัพท์) → memory game 4×4 สุ่ม 8 คู่จาก ~15 คู่/หมวด หน้าการ์ดเป็นรูปจริง. **เลือกระดับก่อนเล่น: ง่าย 4 แผ่น (2 คู่) / ปานกลาง 6 / ยาก 8 — กระดาน = คอลัมน์เท่าจำนวนคู่ × 2 แถว** (feedback ครู 2026-07-12). **Scoring เชิงบวก:** จับผิด 0=10, ≤จำนวนคู่=8, เกิน=6 (ขั้นต่ำ 6) → ดาวขั้นต่ำ 2 ดวงเสมอ (เลิกหักตาม flip ที่บั่นทอนกำลังใจ)
- **Module C (คำศัพท์):** hub 2 โหมด — **sound board** (แตะรูป→ฟังเสียง) + **เกมตอบคำถาม** (เลือกหมวดก่อน → โชว์รูปใหญ่→ถาม "นี่คือ...อะไร?"→เลือกปุ่ม ก/ข/ค) ✅ ตรง mockup ในเอกสารข้อเสนอแล้ว. Scoring: ตอบผิดรวม 0=10, 1=8, 2=6, ≥3=4. **เลือกแบบก่อนเล่น (feedback ครู 2026-07-12): "เลือกคำ" (โจทย์รูป→ช้อยส์คำ) หรือ "เลือกภาพ" (โจทย์คำ/เสียง→จิ้มรูป); ทุกช้อยส์มีปุ่มลำโพงกดฟังเสียงคำแยกจากการตอบ** (`imageChoices` flag ใน `_QuizBoard`)

---

## 2. งานที่ทำเสร็จแล้ว (เฟส 1.3 + 1.4 + bug เสถียรภาพ)

### เฟส 1.3 — ปรับ UI/UX สำหรับเด็กดาวน์ซินโดรม
แก้ที่ **ชั้น theme + widget กลาง** เพื่อให้กระทบทั้งแอปอัตโนมัติ:

- **`theme/colors.dart`** — ปรับ `kError` จากแดงสด → แดงอมส้ม (ลดความเครียด), เพิ่ม token: `kSuccessLight`, `kErrorLight`, `kPressOverlay`, `kDisabledSurface/Text`
- **`theme/spacing.dart`** — เพิ่ม `kTouchTargetMin = 64.0` (พื้นที่กดขั้นต่ำทั้งแอป, สูงกว่ามาตรฐานเพื่อรองรับ hypotonia), `kInteractiveGapMin = 24`, `kTapCooldown`
- **`theme/typography.dart`** — ขยายฟอนต์ทุกระดับ, เพิ่ม `kButtonLabel`. **จงใจไม่เพิ่ม letterSpacing** เพราะภาษาไทยมีสระ/วรรณยุกต์วางซ้อน ถ่างมากจะอ่านยากขึ้น
- **`theme/app_theme.dart`** — เพิ่ม FilledButton/OutlinedButton/TextButton theme กลาง (ทุกปุ่มได้ 64dp + สไตล์เดียวกันอัตโนมัติ ไม่ต้องเซ็ตซ้ำทุกหน้า)
- **`widgets/child/pressable_child_card.dart`** — building block กลาง เพิ่ม: บังคับ tap target 64dp, haptic รวมศูนย์, กันกดซ้ำ (cooldown), press feedback (scale + opacity)
- **`widgets/child_back_button.dart`** — 60→64dp + พื้นวงกลมให้เห็นชัด
- แก้หน้าจอที่ใช้ token ใหม่: `mode_select_screen`, `memory_game_screen`, `scenario_game_screen`, `module_a_screen`, `scenario_card`

### เฟส 1.4 — Time-Limiter (เตือนพักสายตา) ✅ เสร็จสมบูรณ์
เตือนพักทุก 15 นาทีของการเล่นต่อเนื่อง

**สถาปัตยกรรม 3 ชั้น (แยก concern — สำคัญ):**
1. **`features/usage_timer/usage_timer_notifier.dart`** — pure state (ไม่ผูก BuildContext/Navigator), นับเวลาจาก `DateTime` จริง ทนต่อ pause/resume ถี่ๆ บน web
2. **`widgets/usage_timer_gate.dart`** — สะพานเข้าโลกจริง: ผูก `WidgetsBindingObserver` (pause เมื่อ background) + เปิด dialog ผ่าน `rootNavigatorKey`
3. **`widgets/break_reminder_dialog.dart`** — UI popup (responsive, ไม่มี scroll, พอดีจอแนวนอนทุกขนาด)

**จุดที่แก้ยากและต้องระวังถ้าแตะโค้ดนี้:**
- Gate อยู่ที่ `MaterialApp.router(builder:)` ซึ่ง **context อยู่เหนือ Navigator** → ต้องเปิด dialog ผ่าน `rootNavigatorKey.currentContext` (ผูก key ไว้ใน `app_router.dart` แล้ว) ห้ามใช้ context ของ gate ตรงๆ
- นับเวลาจาก wall-clock ไม่ใช่นับ tick → ห้ามเปลี่ยนกลับไปนับจำนวนรอบ Timer
- pause ต้องเก็บ elapsed สะสมไว้ ห้ามรีเซ็ตเป็น 0

**การทดสอบโดยไม่รอ 15 นาที (ไม่แตะโค้ด):** เลื่อนเวลาเครื่องไปข้างหน้า 16 นาทีระหว่างแอปเปิดอยู่ → popup เด้งใน 5 วิ (ระวัง Firebase token หมดอายุ — ปรับเวลากลับแล้ว reload)
**หรือ (แตะโค้ดชั่วคราว):** override `usageTimerLimitProvider` ใน `ProviderScope` เป็น `Duration(seconds: 30)`

### แก้ bug เสถียรภาพ 4.1 + 4.2 ✅ เสร็จ (2026-07-03, commit 091e357 / e72a2b7 / 8078a34)
- **bug 4.1 เดิม — crash ตอนเปิดโดยไม่มีเน็ต:** `main.dart` ไม่ `rethrow` แล้ว — ล็อกอิน anonymous ล้มเหลว → เปิดแอปแบบ **guest** (uid = null ซึ่งทุกจุดรองรับอยู่แล้ว: `SessionRecorder` ข้ามการเขียน, provider ฝั่ง parent คืน stream ว่าง) แล้ว **retry เบื้องหลังแบบ backoff** (5 วิ → เพดาน 5 นาที) จนสำเร็จเมื่อเน็ตกลับมา. ปลอดภัยต่อการเรียกซ้ำเพราะ `signInAnonymouslyIfNeeded` คืน user เดิมถ้ามี — ไม่ทับบัญชีผู้ปกครองที่ login ระหว่างรอ
- **bug 4.2 เดิม — session cache ซ้ำ:** `activeSessionProvider` เป็น `Provider.autoDispose.family` แล้ว — เล่นเนื้อหาเดิมซ้ำได้ `sessionId`/`startedAt` ใหม่ทุกรอบ ไม่เขียนทับ doc เก่า. **ห้ามถอด `autoDispose` ออก** — มี regression test คุมใน `session_provider_test.dart`
- **test suite กลับมาเขียวครบ (60 ตัว):** test 3 ไฟล์คอมไพล์ไม่ผ่านค้างมาจาก API เปลี่ยนช่วงเฟส 1.1–1.3 แก้แล้ว: เติม `score`/`stars` (DailyLifeCompletedEvent), ลายเซ็น `onComplete(dragPath, score, stars)`, ส่ง `cardHeight`/`cardWidth` + ตรึงจอ test 900×600 + `pump(kTapCooldown)` หลัง tap (ไม่งั้น timer cooldown ของ `PressableChildCard` ค้าง → "A Timer is still pending"). render test นับ `PlaceholderComponent` ตาม placeholder manifest จริงแล้ว (ฉากเซเว่นมีรูปจริง → เป็น Sprite)

### แก้ TTS ซ้อน + responsive B/C + เอกสาร TTS key ✅ เสร็จ (2026-07-03, commit 90a78da / 6832cc4 / 343afb6)
- **TTS พูดซ้อน:** กติกาใหม่ — **หนึ่งเหตุการณ์พูดครั้งเดียว** เพราะ `speak()` ตัดเสียงก่อนหน้าเสมอ. จับคู่สำเร็จใช้ `ttsMemoryMatchNamed(pairName)` รวมชื่อคู่+คำชมเป็น utterance เดียว ("แมว จับคู่ได้แล้ว!"), จบเกมพูดเฉพาะ `kTtsMemoryComplete` ใน `_onComplete`, และตัด `speak(kTtsMemoryStart)` ตอนกดการ์ดใน `module_b_screen` (หน้าเกมประกาศเองอยู่แล้ว — สองที่ติดกันทำให้เสียงกระตุก). **ห้ามยิง speak สองครั้งติดกันในเหตุการณ์เดียว** — ถ้าต้องพูดสองอย่าง ให้รวมเป็นประโยคเดียวใน `l10n/tts_strings_th.dart`
- **responsive Module B:** การ์ดแพ็คใน `module_b_screen` คิดสูง 85% ของพื้นที่จริง (clamp 200–320) กว้าง/ไอคอนตามสัดส่วน — เลิก fix 260×320
- **responsive Module C:** `vocab_card` ย่อไอคอน/ฟอนต์ตามขนาดช่อง grid จริง + `FittedBox` scaleDown กันคำยาวโดนตัด (เดิมล้น 71px เมื่อช่อง < ~100px — มี regression test ช่อง 80×80 คุมแล้ว) และขยับ padding ซ้าย grid 48→80 ให้พ้นปุ่มย้อนกลับที่ลอยทับมุมการ์ดคอลัมน์แรก
- **เอกสาร BUILD (EN+TH):** เพิ่ม section คีย์ `GOOGLE_TTS_API_KEY` แบบเต็ม + Troubleshooting "แอปรันได้แต่ไม่มีเสียง" — ตัว fallback เงียบใน `ttsClientProvider` ยังอยู่เหมือนเดิม (อาจเพิ่ม warning ตอน debug ทีหลังได้ แต่เอกสารครอบคลุมแล้ว)

### คลังคำศัพท์จริง 6 หมวด 90 คำ + รูปครบ ✅ เสร็จ (2026-07-04)
แทนที่ vocabulary ชุด scaffold (30 คำ 5 หมวด ไม่มีรูป) ด้วยของจริงจากทีม (zip "NSC คำศัพท์ + ภาพ" จาก Google Drive):

- **คลังคำ:** `vocabulary.json` = 6 หมวด × 15 คำ (`animals, food, drinks, places, occupations, everyday`) — ตรงเอกสารข้อเสนอ ปิดช่องว่างข้อ 5.3
- **รูปจริง 90 ใบ:** ย่อ+บีบอัดจากต้นฉบับ ~114MB เหลือ **2.23MB** (max 512px, JPEG q80, พื้นโปร่งใส→ขาว) อยู่ที่ `assets/images/vocab/<id>.jpg` — sound board (`VocabCard` โชว์รูปแล้ว) และเกมตอบคำถามได้ภาพเต็มอัตโนมัติ
- **เครื่องมือ import ใช้ซ้ำได้:** mapping ชื่อไทย→id อยู่ที่ scratchpad `vocab_mapping.json` + `import_vocab.ps1` (สร้างรูป+vocabulary.json+tts_manifest.json+ตาราง checklist จากแหล่งเดียว กันข้อมูลไม่ตรงกัน) — ถ้าทีมส่งรูป/คำเพิ่ม ให้แก้ mapping แล้วรันใหม่
- **TTS checklist ขยายเป็น 132 คลิป** (words 93 + match 8 + sc 9 + sys 22) — คำถาม quiz ตามหมวดใหม่: สัตว์/อาหาร/เครื่องดื่ม/ที่ไหน/อาชีพ/กลางๆ
- **ยังไม่ได้ใช้จาก zip:** โฟลเดอร์ "ภาพเกมชีวิตประจำวัน" (การ์ดขยะ 4 ประเภท+ถัง, ผลไม้ 5 ชนิด+ถ้วย — สำหรับอัปเกรด Module A) และรูปหน้าจอ mockup (ใส่เอกสารเฉยๆ ไม่ใช่ asset แอป). ต้นฉบับแตกไว้ที่ scratchpad `nsc_assets/`

### ระบบ login จริง + Google Sign-In (2026-07-05)
หน้า login/สมัครสมาชิกใช้งานได้จริง (เดิม UI เรียบ) — redesign ตาม mockup แต่คงแบรนด์ก้าวเก่ง:
- **`auth_screen.dart` redesign**: การ์ดเดียว + โลโก้ก้าวเก่ง (gradient) + email/password + ลืมรหัสผ่าน + ปุ่ม gradient + Google + สลับโหมด signup/login ด้วยลิงก์ล่าง (ไม่ใช่แท็บ). ทุก Row ใช้ Flexible กัน overflow
- **`AuthService` เพิ่ม**: `signInWithGoogle()` (google_sign_in 6.x — ผูก Google เข้า anonymous child เก็บประวัติ, เจอ credential ซ้ำ→signIn), `sendPasswordReset()`. signOut ออกจากทั้ง Firebase+Google
- **ต้องพึ่ง Firebase Console (ดูข้อ 7):** เปิด Email/Password + Google provider + SHA-1 — โค้ดพร้อม แต่ login ไม่ทำงานจนกว่าจะ setup. **ตัด Facebook ออกตามที่ผู้ใช้เลือก** (Android เป็นหลัก)
- test +3 (google/reset delegate, toggle mode) รวม 103 ผ่าน

### Dashboard พัฒนาการผู้ปกครอง (เฟส 2.2) ✅ เสร็จ (2026-07-05)
ปิดช่องว่างเอกสารข้อ 5.2 — หน้า "ความก้าวหน้า" ใน parent dashboard ทำครบตาม mockup เอกสาร:

- **logic แยก testable:** `features/dashboard/skill_progress.dart` (`computeDashboardSummary` — pure, รับ `now` เป็น param ห้ามเรียก DateTime.now() ในนั้น) แปลง `List<SessionRecord>` → ภาพรวม % / 4 ด้าน / trend 14 วัน / เกมล่าสุด / คำแนะนำ. **มี test 9 เคส**
- **เกณฑ์คะแนน:** เปอร์เซ็นต์ = คะแนนเกม (0-10) ×10 เฉลี่ย. ระดับ: ≥85 ดีมาก / ≥70 ดี / ≥50 พอใช้ / <50 ควรฝึกเพิ่ม
- **จับคู่ module → 4 ด้าน** (`kModuleSkillMap`): memory→ความจำ, dailyLife→การใช้ชีวิตประจำวัน, **vocab→ทั้งการสังเกต+การสื่อสาร** (เกมคำศัพท์ฝึก 2 ด้าน จึงให้ค่าเท่ากันทั้งคู่ — ตั้งใจ ไม่ใช่บั๊ก). ด้านที่ยังไม่มีข้อมูล → percent = null แสดง "ยังไม่มีข้อมูล"
- **UI:** `screens/parent/progress_dashboard.dart` — 2 คอลัมน์เมื่อจอกว้าง ≥900 (เนื้อหา | คำแนะนำ), กราฟ trend เป็น `CustomPaint` (`_TrendPainter`), วงกลม 4 ด้านใช้ `CircularProgressIndicator`. สีประจำด้านเป็น palette เฉพาะ dashboard (data viz — ยกเว้นจากกฎห้าม hardcode สี)
- **หมายเหตุ:** mockup มีชื่อเด็ก+อายุ แต่เด็กเป็น anonymous ไม่มีข้อมูลนั้น → header แสดง "พัฒนาการของเด็ก" + จำนวนครั้งเล่น + เวลาเล่นล่าสุดแทน. sound board ไม่บันทึก session จึงไม่นับในคะแนน (เฉพาะ 3 เกมที่มี score)

### รูปจริงเข้าเกม Module A + แก้ manifest เสียงให้ตรงประโยคที่พูดจริง ✅ เสร็จ (2026-07-04)
- **ฉากแยกขยะ:** ไอเทมเป็นรูปจริง (ขวดพลาสติก/เศษอาหาร/กระดาษ — id `banana_peel` เดิมเปลี่ยนเป็น `food_waste` ตามรูปที่ทีมส่ง), thumbnail ใช้ภาพปกจากทีม. **ฉากจัดจานผลไม้:** ผลไม้จริง 4 ชิ้น (กล้วย/ส้ม/แอปเปิ้ล/องุ่น — เพิ่มองุ่นเป็นชิ้นที่ 4, ตัด toothbrush/pencil ที่ไม่เข้ากับครัวทิ้ง). ตัด cutout ด้วย pipeline เดิม (`process_module_a.ps1` + `module_a_images.json` ใน scratchpad)
- **placeholder_manifest เหลือ 2 บรรทัด** (bg_home, bg_kitchen) — ที่เหลือเป็นรูปจริงหมด
- **พบ+แก้ manifest เสียงผิด:** `_randomizeTarget` ประกอบประโยคสั่ง/ใบ้สดจากชื่อไอเทม ("น้องช่วยหยิบXใส่ตะกร้าให้หน่อยนะครับ") — key แบบประโยคใน JSON ฉากจึง**ไม่เคยถูกพูดจริง** → เปลี่ยนเป็น `sc_ask_<id>`/`sc_hint_<id>`. **เพิ่ม id ไอเทมใหม่ในฉากโหมดเดิม (เซเว่น) เมื่อไหร่ต้องเพิ่มใน `_thaiNameFor` + คู่คลิป sc_ask/sc_hint เสมอ** — ฉาก sort-all (ขยะ/ผลไม้ ตั้งแต่ 2026-07-10) ไม่ใช้ ask/hint รายชิ้นแล้ว — ขยะใช้ประโยคฉากจาก JSON, ผลไม้ประกอบสดจากคู่ที่สุ่ม (`ttsFruitPickAsk` ใน l10n, 6 คู่ = 6 คลิป, มี test คุมว่าทุกคู่มีใน manifest) (รวม 219 คลิป)

### จับคู่ภาพแยกหมวด + ตัดพื้นหลังรูปคำศัพท์ ✅ เสร็จ (2026-07-04)
- **Module B แยกหมวดแล้ว:** hub เป็นตารางเลือก 6 หมวด → เกมสุ่ม 8 คู่จาก ~15 คู่ของหมวด (เล่นซ้ำไม่เจอหน้าเดิม) หน้าการ์ดเป็น**รูปจริง**แทนอิโมจิ. แพ็คสร้างจาก `vocabulary.json` ตรงๆ ใน `memoryPacksProvider` (**ไม่มีไฟล์แพ็ค JSON แยกแล้ว** — `assets/memory_packs/` + `fetchDefaultMemoryPack` ถูกถอดทิ้ง เพิ่มคำใหม่ในคลังเดียวแล้วได้ทั้ง 3 เกม). route: `/module-b/game/:packId` (packId = `memory_<category>`)
- **ตัดพื้นหลังรูป:** flood-fill จากขอบภาพแบบไล่ gradient (C# ฝังใน `import_vocab2.ps1` — ไม่ต้องพึ่ง Python/rembg) ผลลัพธ์ 60 ภาพการ์ตูน = PNG โปร่งใส, **หมวดน้ำ (ภาพถ่าย แก้วใสโดนกัดทะลุ) + หมวดสถานที่ (ภาพฉากเต็มเฟรม) = คงภาพเต็ม JPG** ผ่าน flag `noCutout` ใน `vocab_mapping.json`. รวม 9.96MB. **ห้ามรัน cutout กับสองหมวดนี้** จนกว่าทีมจะส่งภาพการ์ตูนพื้นขาวมาแทน
- **TTS checklist = 211 คลิป** (words 90 + sys 22 + sc 9 + match 90 ที่เป็น optional — เสียงสำรองพูดแทนได้) — คำ ช้าง/ลิง/ควาย ของแพ็คเก่าถูกถอดออก

### เกมตอบคำถาม Module C (recall-quiz) ✅ เสร็จ (2026-07-04)
ปิดช่องว่างเอกสารข้อเสนอที่ใหญ่ที่สุด (ข้อ 5.1) — Module C เป็น **hub 2 โหมด** แล้ว: ฟังเสียงคำศัพท์ (sound board เดิม ย้ายไป `sound_board_screen.dart`) + เกมตอบคำถาม

- **โครงสร้าง:** เลือกหมวดที่ `vocab_quiz_select_screen.dart` (ใช้ `CategorySelectGrid` ตัวเดียวกับหน้าเลือกแพ็คของ Module B — route `/module-c/quiz/:category`) → `features/vocab_quiz/vocab_quiz_controller.dart` (logic ล้วน testable) สุ่ม 5 ข้อจาก ~15 คำของหมวด, ตัวเลือก 3 ตัวหมวดเดียวกัน, ตอบผิด → ล็อกปุ่มนั้นแล้วลองต่อจนถูก (ไม่มี "แพ้"). UI ที่ `vocab_quiz_screen.dart` **ตาม mockup เอกสาร**: ซ้าย=รูปโจทย์ใหญ่ (แตะฟังคำถามซ้ำ), ขวา=ปุ่ม ก/ข/ค. session บันทึกแยกหมวด (scenarioId = `quiz_<หมวด>`)
- **คะแนน:** นับตอบผิดรวมทั้งเกม 0/1/2/≥3 → 10/8/6/4 + ดาว 3/2/1/0 (เกณฑ์เดียวกับ Module A/B). popup ผลใช้ `widgets/child/game_result_dialog.dart` — **extract จาก memory game มาใช้ร่วมกันแล้ว** (แก้ dialog ที่เดียวได้ทั้งสองเกม)
- **ข้อมูลให้เฟส 2.2:** ทุกการตอบบันทึกเป็น `MatchEvent(pairId = คำที่ถูกถาม, matched = ถูก/ผิด)` ใน SessionRecord ของ module `vocab` (`recordVocabQuizCompleted` — reuse model เดิม ไม่ต้อง regen Freezed)
- **TTS:** โจทย์พูด "ประโยคคำถามตามหมวด" (`ttsQuizQuestion` — **ห้ามพูดคำตอบตอนตั้งโจทย์** เดี๋ยวเฉลย) + เสียงระบบ `sys_quiz_*` 10 คลิป → checklist รวมเป็น 71 คลิป
- **รูปภาพ:** โจทย์/ปุ่มใช้ `Image.asset` ตาม path ใน vocabulary.json พร้อม `errorBuilder` fallback เป็นไอคอนหมวด — **รูปจริง 30 ไฟล์ยังไม่มา (bug asset 404)** ทีมเจนภาพประกอบ (เช่นจาก AI แบบ mockup) วางใน `assets/images/` ตามชื่อไฟล์ใน vocabulary.json แล้วหน้าจอจะเป็นภาพเต็มเองโดยไม่ต้องแก้โค้ด (อย่าลืมเอาชื่อไฟล์ออกจาก `placeholder_manifest.json` — มี test คุมว่า manifest ต้องไม่มีไฟล์ที่มีจริง)

### เสียงในเครื่องเป็นเครื่องเสียงสำรอง (flutter_tts) ✅ เสร็จ (2026-07-03)
ปิด bug "TTS เงียบถ้าลืม dart-define" ถาวร — **แอปมีเสียงเสมอ** ไม่ว่า build ยังไง/เน็ตเป็นยังไง:

- **สถาปัตยกรรม:** interface กลาง `TtsSpeaker` (speak/cancel/dispose อยู่ใน `tts_service.dart`) มี 2 implementation: `TtsService` (orchestrator, มี `fallback` เสริม) และ `DeviceTtsService` (`services/device_tts_service.dart` — ครอบ flutter_tts). ทุกจุดในแอปเรียกผ่าน `ttsServiceProvider` ซึ่งเป็น `Provider<TtsSpeaker>`
- **ลำดับการหาเสียงต่อประโยค (ใน `tts_provider.dart`):** cache → **คลิปอัดล่วงหน้าใน `assets/tts/`** (`BundledTtsClient` + `tts_manifest.json` — key คือข้อความตรงเป๊ะ) → Cloud TTS (เฉพาะมีคีย์) → เสียง engine ในเครื่อง. คลิปอัดไว้ = คุณภาพดีสุด+เร็วสุด+ฟรี; manifest ครบ 61 ประโยคแล้ว ทีมแค่เจนเสียงมาวางตามชื่อไฟล์ (**ดู `docs/TTS_CLIPS.md`** — เจนจาก Google AI Studio แล้วรัน `tool/convert_tts_clips.ps1`) ไฟล์ไหนยังไม่มีจะตกไปเสียงถัดไปเอง ไม่พัง. **แก้ TTS string เมื่อไหร่ต้องอัปเดต key ใน manifest + เจนคลิปใหม่**
- **กติกาที่ต้องรักษา:** `DeviceTtsService` **ห้าม throw ออกไปหาผู้เรียก** (เครื่องไม่มีเสียงไทย → เงียบ+log เท่านั้น), speak ใหม่/cancel ของ `TtsService` ต้องสั่ง `fallback.cancel()` ด้วยเสมอ (กันเสียงค้าง — มี test คุม), และ fallback ที่ล้มเหลวหลังโดน cancel ห้ามแทรกกลับมาพูด (generation guard — มี test คุม)
- **⚠️ quirk ของ flutter_tts บนเว็บ (ตรวจจากซอร์ส 4.2.5 — โค้ดใน `device_tts_service.dart` ชดเชยไว้แล้ว อย่าถอด):** (1) สเกล rate ต่างกัน: เว็บส่งตรง utterance.rate (1.0=ปกติ) แต่ Android คูณ 2 (0.5=ปกติ) → ตั้งแยกแพลตฟอร์ม (2) เว็บ "ทิ้ง" speak เงียบๆ ถ้าสถานะภายในยังเป็น playing และ stop ไม่รีเซ็ตสถานะทันที (รอ event async) → ต้อง stop เอง + หน่วง ~80ms ก่อน speak + generation guard (3) ต้อง setVoice ไทยตรงๆ (lang อย่างเดียวเบราว์เซอร์ไม่เลือกให้) โดยเลือกชื่อมี Natural/Neural ก่อน (4) เสียง online ของ Edge มี latency ~0.5-1.5 วิ/ประโยคและต้องต่อเน็ต — เป็นข้อจำกัดของเบราว์เซอร์ ไม่ใช่ bug; บน Android engine ในเครื่องไม่มีปัญหานี้
- **Android manifest:** เพิ่ม `<queries>` intent `android.intent.action.TTS_SERVICE` (package visibility บน Android 11+)
- **ยังไม่ได้ทดสอบบนเครื่องจริง:** เครื่อง dev นี้ไม่มี Android SDK — build APK + ลองฟังเสียงบนแท็บเล็ตจริงเป็นงานของทีม (เช็คว่าเครื่องมี Google Speech Services ภาษาไทย)

---

## 3. หลักการ Responsive (ต้องใช้กับทุกหน้าจอใหม่)

**ปัญหาที่เจอซ้ำ:** การ์ด/องค์ประกอบใช้ค่า pixel ตายตัว → พอดีบน iPhone 12 Pro แต่ล้นบน Samsung S8+ (จอเตี้ยกว่า) การไล่ขยับตัวเลขทีละเครื่องไม่มีวันจบ

**กฎเหล็ก:** อย่า hardcode ขนาด pixel ตายตัวกับองค์ประกอบที่ต้องพอดีจอ ให้ **วัดพื้นที่จริงด้วย `LayoutBuilder` แล้วคำนวณขนาดเป็นสัดส่วน**

**ตัวอย่างที่ทำแล้ว (ใช้เป็นแม่แบบ):**
- `memory_game_screen.dart` `_MemoryBoard` — คำนวณขนาด tile จาก constraints จริง (ดีที่สุด ใช้อ้างอิงได้)
- `mode_select_screen.dart` — แบ่งความกว้างจอ /3 ให้การ์ด (แก้ overflow 186px)
- `module_a_screen.dart` + `scenario_card.dart` — รับ `cardHeight` จาก LayoutBuilder แล้วแบ่งสัดส่วนรูป:ข้อความ = 62:38

**helper กลาง:** `theme/responsive.dart` — มี `Breakpoints`, `context.deviceSize`, `context.responsive(phone: x, tablet: y)` ใช้เลือกค่าตามประเภทจอได้สั้นๆ

**หมายเหตุ dialog:** แอปล็อกแนวนอน → dialog ต้อง "พอดีจอครั้งเดียว ไม่มี scroll" ห้ามพึ่ง `SingleChildScrollView` เป็น fallback (มันโผล่ scrollbar มาแม้จอปกติ) ให้ตรวจ `screenHeight` แล้วสลับ compact layout แทน (ดู `break_reminder_dialog.dart`)

---

## 4. ⚠️ Bug/ความเสี่ยงที่ต้องรู้ (พบตอนรีวิว ยังไม่ได้แก้)

bug เดิมข้อ crash ไม่มีเน็ต / session cache / TTS ซ้อน / TTS เงียบถ้าลืมคีย์ **แก้เสร็จหมดแล้ว** (ดูข้อ 2) เหลือ:

1. ~~asset 404~~ ✅ **ปิดสนิทแล้ว (2026-07-04)**: พื้นหลัง 2 ฉากสุดท้าย (bg_home/bg_kitchen) + กระดาษยับสีน้ำตาลได้จากผู้ใช้เจนผ่าน Gemini แล้ว — `placeholder_manifest.json` **ว่างเปล่า ทุกภาพในแอปเป็นของจริง 100%**. ระบบ placeholder ยังอยู่เผื่อคอนเทนต์ใหม่ในอนาคต

2. **เสียงสำรองในเครื่องยังไม่ถูกลองบนแท็บเล็ตจริง** — เครื่อง dev ไม่มี Android SDK. ให้ทีม build APK แล้วลองฟัง 2 โหมด: ไม่ใส่คีย์ (ต้องได้เสียง engine ในเครื่อง) และใส่คีย์แต่ปิดเน็ต (ประโยคที่ไม่เคยแคชต้องตกมาเสียงในเครื่อง). ถ้าเครื่องไม่มีเสียงไทย ให้ติดตั้ง Google Speech Services

3. **คลิปเสียงอัดล่วงหน้ายังไม่ได้เจน (132 ไฟล์)** — โครงโค้ด+manifest พร้อมแล้ว เหลือทีมเจนเสียงจาก Google AI Studio ตาม checklist ใน `docs/TTS_CLIPS.md` แล้ววางไฟล์ .opus ใน `assets/tts/` (ผ่าน `tool/convert_tts_clips.ps1`) — ระหว่างที่ยังไม่มีไฟล์ แอปใช้เสียงสำรองในเครื่องไปก่อน

4. ~~รูปเกม Module A จาก zip~~ ✅ **ต่อเข้าเกมแล้ว (2026-07-04)** — ดูข้อ 2. ของที่ตัดทิ้ง: ภาพผลิตภัณฑ์เคมี (มีแบรนด์จริง Windex/Tide ไม่เหมาะแอปประกวด) และภาพถังสี่ใบ (รอไว้ใช้เมื่อทำ mechanic แยกขยะ 4 ถังจริงในอนาคต)

---

## 5. ความไม่ตรงกันระหว่างเอกสารข้อเสนอ vs โค้ดจริง

สำคัญเพราะเป็นเอกสารประกอบการแข่งขัน — ต้องตัดสินใจว่าจะแก้โค้ดตามเอกสาร หรือแก้เอกสารตามโค้ด:

1. **Module C** — ✅ **ปิดแล้ว (2026-07-04)**: มีเกมตอบคำถามพร้อมคะแนนครบ (ดูข้อ 2). ต่างจากเอกสารแค่รายละเอียด: ตัวเลือกเป็นการ์ดรูป+คำ 3 ใบ แทนตัวอักษร ก/ข/ค (เหมาะกับเด็กที่ยังไม่อ่านหนังสือมากกว่า — ควรอัปเดตเอกสารตามโค้ด)
2. **Dashboard พัฒนาการ** — ✅ **ปิดแล้ว (2026-07-05)**: มี skill breakdown 4 ด้าน (วงกลม %) + กราฟแนวโน้ม 14 วัน + คำแนะนำ + เกมที่เล่นล่าสุด ครบตาม mockup เอกสาร (ดูข้อ 2)
3. **หมวดคำศัพท์** — ✅ **ปิดแล้ว (2026-07-04)**: ใช้คลังคำจริงของทีม 6 หมวด 90 คำ (`animals, food, drinks, places, occupations, everyday`) พร้อมรูปจริงครบทุกคำ (ดูข้อ 2)
4. **จับคู่ภาพ** — เอกสารบอก 20 ใบ (10 คู่) โค้ดจริง 16 ใบ (8 คู่, 4×4)
5. **Firebase Storage** — diagram เอกสารมี แต่โค้ดตัดออกแล้ว (ใช้ bundled assets เพราะ Storage ต้องใช้แพลน Blaze)

---

## 6. แผนพัฒนา 3 เฟส (จาก session ก่อน)

**เฟส 1:**
- 1.1 จับคู่การ์ด — ✅ เสร็จ (มี scoring + test)
- 1.2 ชีวิตประจำวัน — ✅ เสร็จ (drag เด้งกลับเมื่อวางผิด zone)
- 1.3 UI/UX เฉพาะทาง — ✅ เสร็จ (ดูข้อ 2)
- 1.4 Time-Limiter — ✅ เสร็จ (ดูข้อ 2)

**เฟส 2:**
- 2.1 คลังคำศัพท์คัสตอม (ผู้ปกครองเพิ่มรูป+เสียงเอง) — 🔴 ยังไม่มี. **ต้องตัดสินใจ:** local DB (sqflite มีเป็น transitive dep แล้ว / Hive ยังไม่มี), image_picker (ต้องเพิ่ม + permission). ส่วน **TTS on-device: flutter_tts เพิ่มเข้ามาแล้ว** (เป็นเครื่องเสียงสำรอง — ดูข้อ 2) คำศัพท์คัสตอมใช้ `DeviceTtsService` พูดคำที่ผู้ปกครองพิมพ์ได้เลยโดยไม่เสียค่า API
- 2.2 Dashboard + เกณฑ์คะแนน — ✅ **เสร็จ (ดูข้อ 2)**: skill breakdown 4 ด้าน + กราฟ 14 วัน + คำแนะนำ + เกมล่าสุด
- 2.3 Data Anonymization + ปุ่มลบบัญชี — ✅ **เสร็จ (2026-07-05)**: เด็ก anonymous + **ปุ่มลบบัญชี/ข้อมูล** ใน logout sheet → ยืนยัน 2 ชั้น → `deleteAccountAndData()` ลบ Firestore (sessions/scenario_settings subcollection แบบ batch + users doc) + Auth user. requires-recent-login → แจ้งให้ login ใหม่

**เฟส 3:**
- 3.1 มาสคอต (น้องก้าว/น้องเก่ง) — 🟡 data/เสียงมีแล้ว (tts_celebration, starRating), เหลือ asset ภาพ + provider รวมดาวสะสม
- 3.2 Consent Form — เอกสาร ไม่ใช่โค้ด

---

## 7. งานค้าง (Pending — ทำต่อได้เลย)

**แกนหลักเสร็จหมดแล้ว** (2026-07-05): เกม 3 โมดูล + รูปจริง + แยกหมวด + Dashboard เฟส 2.2 + TTS 3 ชั้น + เสถียรภาพ. **97 tests เขียว**. ที่เหลือเรียงตามลำดับแนะนำ:

**งานโค้ด (ทำต่อได้เลย):**
1. **Polish** — ลูกศรใบ้ Module A หลัง 15 วิ (มีแค่ TTS), จับคู่ภาพ 8→10 คู่ (ปรับ `pairCount` ให้ตรงเอกสาร ข้อ 5.4)
2. **เฟส 3.1 มาสคอต + ดาวสะสม** — ⏸ **พักไว้ก่อน (ยังดีไซน์ไม่เสร็จ — ผู้ใช้แจ้ง 2026-07-05)**. data/เสียงมี เหลือ asset ภาพ + provider รวมดาว
3. **เฟส 2.1 คลังคำศัพท์คัสตอม** — ใหญ่สุด ต้อง design ก่อน (local DB + image_picker + permission; TTS ใช้ `DeviceTtsService` พูดคำที่พิมพ์ได้เลย)

**งาน asset/build/decision (พึ่งทีม):**
- เจนเสียง **219 คลิป** (ดู `docs/TTS_CLIPS.md` — ตัวเลข 225/215/65 เก่าแล้ว: sort-all ถอน ask/hint รายชิ้น 14, เพิ่มประโยคฉากขยะ 2 + คู่ผลไม้สุ่ม 6)
- หมวดน้ำ 15 ภาพเป็นการ์ตูน (ตอนนี้ภาพถ่าย ตัดพื้นไม่ได้)
- **รูปถ่านไฟฉายการ์ตูน** — `assets/images/trash_battery.png` ตอนนี้เป็นภาพถ่ายมีแบรนด์ Energizer (เคสเดียวกับ Windex/Tide ที่เคยตัดทิ้ง) เจนใหม่แล้ววางทับได้เลยไม่ต้องแก้โค้ด
- build APK + ทดสอบ Android จริง (เครื่อง dev ไม่มี Android SDK)
- **✅ เชื่อม Firebase project ใหม่ `kaokeng-app` (2026-07-07) — เชื่อมครบ + web login ผ่านแล้ว, เหลือทดสอบบน Android:**
  บริบท: project เดิม `tenacious-veld-453115-u8` เป็นของเพื่อนที่ลาออก เข้า console ไม่ได้ → สร้าง `kaokeng-app` ใหม่ (บัญชี latteyen2@gmail.com, Spark/ฟรี, project number 305078404807, location asia-southeast1)
  ✅ **เสร็จแล้ว:** ติดตั้ง firebase-tools + flutterfire_cli · `firebase login` · สร้าง project + add Firebase (ผ่าน console, ต้อง accept ToS ครั้งแรกไม่งั้น addFirebase 403) · `flutterfire configure --platforms=android,web` (register app, gen `firebase_options.dart` + `google-services.json` ชี้ kaokeng-app, ล้าง tenacious ออกหมด รวม web getter) · SHA-1 `2B:6F:C9:F2:52:BD:13:EB:22:D8:63:01:36:76:82:BD:6A:BE:41:F5` เพิ่มผ่าน CLI (`firebase apps:android:sha:create`) · เปิด Email/Password + Google provider (console) · **`oauth_client` มีครบ 2 ตัว** (client_type 1 ผูก SHA-1 + type 3 web — Google Sign-In พร้อม, idToken ไม่ null แล้ว)
  ✅ **ขั้น 6 เสร็จ (2026-07-07):** Firestore database `(default)` สร้างแล้ว (asia-southeast1) + `firebase deploy --only firestore:rules,firestore:indexes` สำเร็จ (rules compiled + indexes deployed, API เปิดอัตโนมัติ) — **Firebase backend พร้อม 100%**
  ✅ **ขั้น 7 (web) ผ่าน:** `flutter run -d chrome` → สมัคร/login email/password สำเร็จ เข้า dashboard ได้ = Firebase เชื่อม end-to-end จริง (เขียน `users` ลง Firestore). ต่อด้วย: แก้ 2 bug dashboard (ปุ่ม back กลับหน้าเล่นเกม + logout sheet `isScrollControlled` กัน overflow) · ปรับสี login เข้าธีม (พื้นครีม kWarmWhite + ปุ่มเหลือง kYellowPrimary + ลิงก์ kBlueDark) · เพิ่ม `widgets/orientation_lock.dart` — login/dashboard/parent_gate = portrait, mode_select = landscape, เว็บข้าม
  ✅ **ต่อมา (2026-07-09) session ยาว:** logout fix (signOut Firebase ก่อน Google กัน error บนเว็บ) + ปุ่ม back หน้า login · **เฟส 2.1 เกม "หมวดครอบครัว"** (quiz คัสตอม: ผู้ปกครองใส่รูปคนในบ้าน+กำหนดคำตอบ/ตัวลวงเอง หรือกดลูกเต๋าเปิดโหมดสุ่มตัวลวงจากสมาชิกคนอื่น; เก็บ Hive offline — `models/family_card.dart`, `services/family_card_repository.dart`, `features/family_quiz/`, `screens/parent/family_manager_screen.dart`, `screens/child/family_game_screen.dart`; เข้าเกมจากการ์ดที่ 4 ในเมนูเด็ก, จัดการจาก dashboard ไอคอน 👪; **hive_generator เลี่ยงเพราะชน freezed → เก็บเป็น Map**) · **animation polish** (`widgets/fade_slide_in.dart` + โลโก้กดค้าง wiggle + fade page transition ใน `app_router.dart`) · **กราฟฟิกเกมจับคู่ใหม่** (รูป cover เต็มการ์ด, พลิก 3D rotateY, การ์ดคว่ำ gradient+ดาว) — รวม **111 tests เขียว**
  ✅ **ต่อมา (2026-07-10):** แก้ dashboard เกมครอบครัว (skill map family→ความจำ+การสื่อสาร, label "ครอบครัว" ในเล่นล่าสุด, โหมดสุ่มเติมคำญาติพื้นฐานเมื่อการ์ด<3 — `basicFamilyWords`) + **Module A โหมด sort-all ตาม mockup ทีม**: แยกขยะ = ถัง 4 ประเภท (พื้นหลังฉากเต็มจาก zip, เพิ่มไอเทมถ่านไฟฉาย, เฉลยตามชื่อไฟล์ทีม: ขวด→รีไซเคิล กระดาษ→ทั่วไป เศษอาหาร→ย่อยสลาย ถ่าน→อันตราย), จัดผลไม้ = **สุ่มโจทย์ 2 จาก 4** (`pick_count: 2` — feedback ผู้ใช้ "ใส่หมดทุกชิ้นไม่ท้าทาย+มั่ว") ลงถ้วยไม้ (ชื่อฉาก "ช่วยจัดผลไม้ใส่ถ้วย") — schema เพิ่ม `zones`/`zone_id`/`pick_count` (backward compatible, เซเว่นไม่แตะ), engine รับหลายโซน+หลายชิ้น+โจทย์สุ่ม (`wantedIds` เรียงตามลำดับ JSON ให้ตรง key คลิป), **UI polish รอบ 2 หลัง feedback**: trim ขอบโปร่งใสรูปไอเทม 8 ไฟล์ (เดิมเนื้อรูปแค่ 17-44%), sprite contain-fit ไม่ยืดเบี้ยว, ไอเทมใหญ่ตามจอ (20% สูงจอ clamp 100-170; โหมดเดิมคง 120), การ์ดขาวรองหลังไอเทม+ถาดรองแถวล่าง (`item_tray_component.dart`), แถบโจทย์บนโชว์รูป+ชื่อ 2 ชิ้นที่สุ่มได้, ชื่อไอเทมย้ายไป `kScenarioItemNamesTh` ใน l10n (แหล่งเดียว)
  ✅ **ต่อมา (2026-07-11) ขัดเกลาฉากผลไม้ตาม feedback ผู้ใช้:** (a) **drop ไม่ติดตอนโหลด** — Flame ยิง collision เฟรมแรกทำให้ผลไม้บางชิ้นถูกวางลงถ้วยเอง → แก้ให้ settle เฉพาะตอน "ลากจริง" (`_isBeingDragged`) + เช็กโซนคาบเกี่ยวตอนปล่อยใน `onDragEnd` (`interactable_component.dart`, มี regression test) (b) **พื้นหลัง cover-fit ไม่ยืด** (`background_component.dart` + flag `cover_fit`) — iPad/แท็บเล็ตไม่เพี้ยน (c) **โซนถ้วยผูกพิกัดรูป** (สัดส่วน 0..1 ผ่าน transform เดียวกับพื้นหลัง) → drop ตรงถ้วยทุกจอ · asset `bg_fruit_bowl.jpg` ครอปจาก `ถ้วยใหม่.jpg` (Pictures) ให้ถ้วยกึ่งกลางแนวตั้ง (d) **ถาด+ไอเทมยึดขอบล่างจอ (viewport auto-layout)** ไม่ผูกการครอปรูป → จอโทรศัพท์เตี้ยก็เห็นครบไม่หลุดล่าง (e) **polish**: การ์ดเล็กลง (0.13×กว้างจอ) + มุมโค้ง + เงานุ่ม + ขอบบาง, ถาดเงานุ่ม, ผลไม้ scale-in ไล่ทีละใบตอนเข้าฉาก (`entryDelay`, subtle, ข้ามถ้า reduce-motion) — **120 tests เขียว**
  ✅ **ต่อมา (2026-07-11/12) session ยาว — ฉากถังขยะ + เสียง + หน้าเลือกเล่นธีมใหม่:** (a) **ฉากแยกขยะ cover_fit** เหมือนผลไม้ (asset ใหม่ `bg_trash_bins.jpg` ฉากสวน 4 ถังมีป้าย, 4 โซนผูกพิกัดรูป — วาด debug overlay เช็คตรงถังแล้ว) (b) **โหมด "ดูดหายเข้าถัง"** (`swallow_items` flag): วางถูกถัง → ขยะพุ่งเข้าปากถังหดหาย (`consumeInZone`) + **ระบบ SFX ใหม่** (`SfxPlayer` native/web แยกจากเสียงพูด — `services/sfx_*`, `providers/sfx_provider`, `assets/sfx/`): เสียงทิ้งขยะ `trash_drop.wav` (สังเคราะห์), **เสียงถูก `right.mp3`=Right02 + ผิด `wrong.mp3`=Wrong01** (asset จริงทีม) ใส่ทุกเกม **ยกเว้นจับคู่ภาพใส่แค่เสียงถูก** (ผิดบ่อยโดยธรรมชาติ กันเด็กกดดัน — ผู้ใช้กำหนด) (c) **หน้าเลือกเล่นธีมใหม่** (`mode_select_screen.dart` เขียนใหม่ตาม mockup): แถบบนโปรไฟล์+สตรีค+ปุ่มไอคอน, การ์ด 4 โหมดมีรูปปกจริง (`mode_{daily,memory,vocab,family}.jpg` จากโฟลเดอร์ "การ์ดก้าวเก่ง"), เมนูล่าง 3 ไอคอน, **พื้นหลังวิดีโอลูป** (`video_player` + `assets/video/kaokeng_bg.mp4` 1.6MB + ภาพนิ่งสำรอง `home_bg.jpg`, ปิดเมื่อ reduce-motion), **การ์ดลอย** (`_FloatingCard` sine subtle), กันล้นทุกจอด้วย FittedBox, ปุ่มขวาเกาะมุม (d) **สตรีคจริง** (`features/streak/streak_tracker.dart` + `streakProvider` เก็บ Hive box `app_prefs` — เข้าเล่นต่อเนื่อง +1/วัน, มี 4 tests) (e) **web/index.html เพิ่ม meta `google-signin-client_id`** (client_type 3) แก้ error Google Sign-In บนเว็บ — **126 tests เขียว**
  ✅ **ต่อมา (2026-07-12) พื้นหลังกระดาษ + เพลง BGM + ปุ่มลัด:** (f) **พื้นหลังกระดาษครีม** (`widgets/child/paper_background.dart` + `assets/images/paper_bg.jpg`) เสียบชั้นล่าง 8 หน้าเกม/เมนูเด็ก (จับคู่ภาพ/คำศัพท์ quiz+select+soundboard/ครอบครัว/เมนู A-B-C) — เว้น Module A (ฉากลากของ) + mode-select (วิดีโอ) ที่มีพื้นหลังเอง (g) **เพลงธีม BGM** `Kaokeng BGM(Boba date)` → `assets/sfx/bgm.mp3` (ลูป+fade-in): `BgmService` (คุมสถานะ/fade, เก็บเปิดปิด+เสียงใน Hive `app_prefs`) + `BgmPlayer` **แยกแพลตฟอร์ม** (`bgm_io`=just_audio / `bgm_web`=AudioElement ดิบ — just_audio-web flaky เรื่อง autoplay) preload ตั้งแต่เปิดแอป + fade ตอนเล่นจริง (event onPlaying) · `BgmGate` ครอบ app root ใน main.dart (Android เล่น+fade เอง, **web เล่นตอนแตะครั้งแรก** ตามนโยบาย autoplay) · **ปุ่ม ⚙️ ขวาบนหน้าเลือกเล่น = แผงตั้งค่าเพลง** (สวิตช์เปิด/ปิด + สไลเดอร์เสียง) — ⚠️ ⚙️ เดิมเข้า parent gate, ตอนนี้เข้าส่วนผู้ปกครองใช้ปุ่ม 👥 เมนูล่างแทน (h) **เกมครอบครัว empty state เพิ่มปุ่ม "เพิ่มคนในครอบครัว"** → push `kRouteFamilyManager` ตรง (ไม่มี gate — เปลี่ยนเป็น `kRouteParentGate` ได้ถ้าอยากกั้น) — **126 tests เขียว**
  ✅ **ต่อมา (2026-07-12) ต่อ provider หน้าเลือกเล่น (เลิก placeholder ชื่อเด็ก/ดาว):** `providers/child_profile_provider.dart` — `childNameProvider` + `totalStarsProvider` เก็บ Hive `app_prefs` (กล่องเดียวกับสตรีค, กัน "box ยังไม่เปิด" ใน widget test → no-op ไม่ crash; มี `resolveChildName` pure). **ดาวสะสม** บวก `starRating` (0-3) ทุกครั้งจบเกมที่ 4 จุด completion (memory/vocab/family/dailyLife screens) — ออฟไลน์/ไม่ต้องล็อกอิน. **ชื่อเด็ก** ผู้ปกครองตั้งจากปุ่ม 🎫 badge ใน AppBar dashboard → dialog เก็บ Hive (ว่าง = ค่าเริ่มต้น `หนูน้อย`). **เมนู "ความคืบหน้า"** ฝั่งเด็กเปิด dashboard แบบ **"ดูอย่างเดียว"** (`kRouteDashboard?view=progress` → `DashboardScreen(progressOnly: true)`): ล็อกที่แท็บความก้าวหน้า (`kDashboardProgressTab`) + **ซ่อนปุ่มสลับแท็บ/บัญชี/ตั้งค่า/ครอบครัวทั้งหมด** (actions=null, bottomNav=null) กันเด็กเข้าส่วนผู้ปกครองอื่น — ต่างจากเข้าทางผู้ปกครองปกติที่สลับแท็บได้ครบ. dashboard กันตัวเองด้วยล็อกอินอยู่แล้ว (ไม่ล็อกอินเห็นแค่ปุ่มเข้าระบบ). **เมนู "รางวัล" คงไว้ coming-soon** (ผูกเฟส 3.1 พักรอ design). +7 tests (`test/providers/child_profile_test.dart` +6, และ progress-lock ใน `parent_widgets_test.dart` +1) → **133 เขียว**. **Google Sign-In บนเว็บเจอ `origin_mismatch`** = ปัญหา config ไม่ใช่โค้ด: `flutter run -d chrome` สุ่ม port ทุกครั้ง → ต้องรัน **port คงที่** (`flutter run -d web-server --web-port=5555 --web-hostname=localhost`) แล้วเพิ่ม `http://localhost:5555` (+`http://localhost`) ใน **Authorized JavaScript origins** ของ OAuth Web client (`...mr716eeg96...`) ที่ [Cloud Console Credentials](https://console.cloud.google.com/apis/credentials) โปรเจกต์ kaokeng-app — เป็นงานผู้ใช้ทำใน console. เว็บล็อกอิน email/password ใช้ได้ปกติ; Android จริงใช้ OAuth client type 1 (SHA-1) ไม่เจอปัญหานี้
  ✅ **ต่อมา (2026-07-14) ระบบรางวัล (A+C) + สลับรูปกาแฟ/สถานที่:** (a) **สลับ asset** — `coffee.jpg`=กาแฟNOBG, หมวดสถานที่ 15 รูปด้วย asset ใหม่ (ทับไฟล์ชื่อเดิม ไม่แตะ vocabulary.json — Flutter อ่าน PNG ในไฟล์ .jpg ได้) (b) **ระบบรางวัลฝั่งเด็ก** เข้าจากปุ่ม 🏆 ขวาบนหน้าเลือกเล่น (เลิก coming-soon) → `RewardsScreen` (ล็อกแนวนอน) 2 ส่วน: **สมุดสะสมสติกเกอร์** (ดาวสะสม `totalStarsProvider` ปลดทีละใบ ทุก `kStarsPerSticker`=10 ดาว, 24 ใบ emoji — ทีมสลับเป็นภาพวาดจริงได้โดยแก้แค่ `features/rewards/rewards_catalog.dart`) + **เหรียญความสำเร็จ 10 เหรียญ** (ปลดอัตโนมัติ: ดาว 10/50/100/200, เล่นเกมแรก, เล่น 10/50 ครั้ง, ครบทุกเกม 4 module, สตรีค 3/7 วัน — เหรียญยังไม่ได้โชว์แถบ x/y). **ปรัชญา: สะสมอย่างเดียว ไม่มีวันเสีย** (ไม่มีเอาดาวไปแลก) เหมาะกลุ่มเป้าหมาย (c) **โครง:** `features/rewards/rewards_catalog.dart` (pure: StickerDef/MedalDef + `stickersUnlockedCount`/`starsToNextSticker`/`medalUnlocked` — testable), `providers/rewards_provider.dart` (`rewardsStatsProvider` เก็บ `games_completed`+`modules_played` ใน Hive `app_prefs`, กัน box ปิด=no-op), ทุกเกม 4 จุด completion เรียก `recordCompletion(kModuleX)` คู่กับ award ดาว, **`best_streak`** เก็บใน `streakProvider` (เหรียญสตรีคไม่ล็อกกลับเมื่อขาดวัน) (d) **tests +19** (catalog 14 + provider 4 + widget render 1) → **157 เขียว**. ⚠️ **widget test สถานะ "ปลดล็อก" เทสต์ไม่ได้ใน flutter_tester** เพราะการ์ดปลดล็อกโชว์ emoji (🐱🏆) ที่ test runner ไม่มีฟอนต์ emoji สี → `pumpWidget`/`pumpAndSettle` **ค้าง 10 นาที** (Android จริงมี NotoColorEmoji ปกติ ไม่ใช่บั๊กแอป) — จึงคุมเฉพาะ logic ด้วย unit test + render สถานะว่าง. **บทเรียน: widget test ทุกตัวต้องตั้ง `GoogleFonts.config.allowRuntimeFetching = false` ใน setUpAll ไม่งั้น google_fonts โหลดเน็ตค้าง; และเลี่ยง emoji ใน widget ที่จะ pump ในเทสต์** (e) push ขึ้น main แล้ว (commit `31494d4` images + `ad9cd51` rewards)
  🔜 **RESUME (เหลือ):** (1) **ทดสอบบน Android จริง** — Google Sign-In เต็มรูปแบบ + orientation (เครื่อง dev ไม่มี SDK; web meta ใส่แล้ว) (2) **asset** — เจนเสียง 219 คลิป, หมวดน้ำรูปการ์ตูน, รูปถ่านการ์ตูนแทน Energizer, **avatar หน้าเลือกเล่น `home_avatar.png`** (ตอนนี้ fallback ไอคอน) (3) ✅ **ต่อ provider หน้าเลือกเล่นแล้ว (2026-07-12)** — ชื่อเด็ก/ดาวสะสม/ความคืบหน้าเป็นของจริง เหลือแค่เมนู "รางวัล" ที่ยัง coming-soon (ผูกเฟส 3.1 พักรอ design) + avatar `home_avatar.png` ยัง fallback ไอคอน (4) การ์ดครอบครัวโหมดสุ่มโชว์ "ตัวเลือก: " ว่าง (gap 3 ใน memory) (5) **วิดีโอพื้นหลัง `kaokeng_bg.mp4` = 4.45MB (BackgroundAnimated5, สลับ 2026-07-12)** — สลับได้โดยเขียนทับไฟล์ชื่อเดิม ไม่ต้องแก้โค้ด (loop/fallback/BGM คงเดิม); เครื่องนี้ไม่มี ffmpeg ถ้าจะบีบต้องใช้เครื่องอื่น
  📌 local main = `d647c34` (BGM+ปุ่มครอบครัว commit แล้ว) · **งาน child-profile 2026-07-12 ยังไม่ commit (working tree)** — push main ผู้ใช้สั่ง `git push origin main` เอง
  - keytool: `C:\Program Files\Java\jre-1.8\bin` · flutterfire: `%LOCALAPPDATA%\Pub\Cache\bin` (เพิ่ม User PATH ถาวรแล้ว) · CWD ของ tool เพี้ยนเป็น `Kokeng01` (parent) บางครั้ง → Set-Location `...\Kokeng01\Kaokeng` ก่อนรันคำสั่ง

---

## 8. คำสั่งที่ใช้บ่อย

```bash
flutter run -d chrome              # รันบน web (debug UI เร็ว)
flutter run                        # รันบน emulator/device
flutter run --dart-define=GOOGLE_TTS_API_KEY=xxx   # ★ ใส่ key = เสียง Neural2 / ไม่ใส่ = เสียง engine ในเครื่อง (สำรอง)
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # regen Freezed/json
flutter test
```

**Convention:** ห้าม hardcode สี/ขนาด/ระยะห่าง ใช้ token จาก `theme/` เสมอ. ห้าม hardcode route path ใช้ค่าคงที่จาก `app_routes.dart`. TTS string ทั้งหมดอยู่ใน `l10n/tts_strings_th.dart` (แก้แล้วต้อง bump scenario version เพราะใช้ hash เป็น cache key)
