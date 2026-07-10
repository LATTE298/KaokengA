# MVP Progress Tracker

> Single source of truth for build progress.
> **Legend:** [x] done · [~] partial · [ ] not started

**Last audited:** 2026-07-05 · **Overall:** ~92%

---

## Module A — Daily Life (ชีวิตประจำวัน)
- [x] 3 สถานการณ์: ซื้อของเซเว่น / คัดแยกขยะ / จัดผลไม้ใส่ถ้วย (JSON ใน `assets/scenarios/`)
- [x] Flame drag & drop + สุ่ม target ใหม่ทุกรอบ (ฉากเซเว่น — โหมดโจทย์ชิ้นเดียว)
- [x] **โหมด sort-all ตาม mockup ทีม (2026-07-10)**: แยกขยะ = ลากขยะ 4 ชิ้นลงถัง 4 ประเภท (เพิ่มถ่านไฟฉาย), จัดผลไม้ = **สุ่มโจทย์ 2 จาก 4** (`pick_count`) ลงถ้วยไม้ ชิ้นนอกโจทย์โดนปฏิเสธ — พื้นหลังฉากจริงจาก zip ทีม, ชมทีละชิ้น/ปลอบเมื่อผิด
- [x] **UI polish (2026-07-10)**: trim รูปไอเทม (เนื้อรูปเต็มกรอบ ไม่ยืดเบี้ยว), ไอเทมใหญ่ตามจอ, การ์ดขาว+ถาดรองแถวไอเทม, แถบโจทย์โชว์รูป+ชื่อผลไม้ที่สุ่มได้
- [x] Return tween เมื่อวางผิด zone
- [x] Success overlay + TTS celebration + haptic
- [x] Idle re-prompt (TTS) หลัง 8 วิ
- [x] Scoring 10/8/6/4 ตามจำนวนวางผิด + session logging
- [x] **รูปจริงครบทุกฉาก** (ขยะ/ผลไม้ตัดพื้นหลัง + พื้นหลัง + thumbnail)
- [x] **ลูกศรใบ้เด้งเหนือของที่ต้องหยิบ** (คู่กับ TTS เมื่อนิ่งนาน, หายเมื่อเริ่มลาก; โหมด sort-all ชี้ชิ้นแรกที่ยังไม่เก็บ)
- [ ] รูปถ่านไฟฉายเป็นภาพถ่ายมีแบรนด์ Energizer — ควรให้ทีมเจนภาพการ์ตูนแทน (วางทับ `assets/images/trash_battery.png` ได้เลย)

## Module B — Memory (จับคู่ภาพ)
- [x] **เลือกหมวดก่อนเล่น** (6 หมวดจากคลังคำศัพท์จริง)
- [x] กระดาน 4×4 สุ่ม 8 คู่จาก ~15 คู่/หมวด (เล่นซ้ำไม่เจอหน้าเดิม)
- [x] **หน้าการ์ดเป็นรูปจริง** (แทนอิโมจิเดิม)
- [x] Flip / match detection / no-match return / completion dialog
- [x] Scoring ≤30 flips=10 … + session logging
- [ ] เอกสารเสนอ 10 คู่ — โค้ดสุ่ม 8 คู่/รอบ (ปรับ pairCount ได้)

## Module C — Vocabulary (คำศัพท์)
- [x] **Hub 2 โหมด**: ฟังเสียงคำศัพท์ (sound board) + เกมตอบคำถาม
- [x] **เกมตอบคำถาม (recall-quiz)**: เลือกหมวด → โชว์รูป → ถามตามหมวด → เลือก ก/ข/ค → คะแนน
- [x] **คลังคำจริง 6 หมวด × 15 = 90 คำ** พร้อมรูปจริงทุกคำ
- [x] ตัวลวงหมวดเดียวกัน, ตอบผิดล็อกปุ่มแล้วลองต่อ (ไม่มี "แพ้")
- [x] บันทึกถูก/ผิดรายคำ (MatchEvent) แยกหมวด → ป้อน Dashboard

## Parent Dashboard (ส่วนผู้ปกครอง)
- [x] Firebase Auth (email/password + **Google Sign-In** + ลิงก์บัญชี anonymous + ลืมรหัสผ่าน)
- [x] **หน้า login/สมัคร redesign** (การ์ด + โลโก้ก้าวเก่ง + Google + สลับโหมดในการ์ดเดียว)
- [x] แท็บบันทึกการเล่น (20 ล่าสุด + load more)
- [x] แท็บตั้งค่าสถานการณ์ (เปิด/ปิด Module A)
- [x] **แท็บความก้าวหน้า = Dashboard เต็ม**: ภาพรวม % + พัฒนาการ 4 ด้าน (วงกลม) + กราฟแนวโน้ม 14 วัน + คำแนะนำ (carousel ปัดซ้าย-ขวา) + เกมล่าสุด
- [x] Responsive: มือถือแนวนอน = เลย์เอาต์แน่นเห็นครบไม่ scroll (ซ่อนเมนูล่าง ย้ายแท็บไป AppBar) / จอสูง = scroll
- [x] Logout flow
- [x] **ปุ่มลบบัญชี/ข้อมูล (เฟส 2.3, PDPA)** — ลบ Firestore ทุก collection (sessions/settings/users) + Auth user, ยืนยัน 2 ชั้น

## TTS (เสียงพูดไทย)
- [x] **3 ชั้น**: คลิปอัดล่วงหน้า (`assets/tts/` + manifest) → Cloud Neural2 (มีคีย์) → เสียงในเครื่อง (`flutter_tts`)
- [x] แอปมีเสียงเสมอ ไม่ว่า build ยังไง/ออนไลน์หรือไม่
- [x] Local SHA-256 cache + cancellable playback + กันพูดซ้อน
- [ ] เจนคลิปเสียง 219 ไฟล์ (ดู `docs/TTS_CLIPS.md` — ฉาก sort-all เลิกใช้ ask/hint รายชิ้น, เพิ่มคู่ผลไม้สุ่ม 6) ← งาน asset

## Infrastructure / Design
- [x] Firestore end-to-end (anonymous auth, `/sessions/{uid}/records`)
- [x] fallback เป็น guest + retry เมื่อไม่มีเน็ต (ไม่ crash)
- [x] `activeSessionProvider` autoDispose (ไม่เขียนทับ record)
- [x] Riverpod + Flame + Freezed + go_router
- [x] Time-Limiter เตือนพักทุก 15 นาที
- [x] ธีม Yellow+Blue, Sarabun, haptic, tap target 64dp
- [x] pipeline ตัดพื้นหลังรูป (flood-fill C# ใน PowerShell) → `tool/cutout_images.ps1` (generic, reusable)
- [~] Firebase Storage (ต้อง Blaze — ใช้ bundled assets แทน)

---

## Priority Queue (Next Up)
1. Polish — ลูกศรใบ้ Module A (15 วิ), จับคู่ภาพ 8→10 คู่
2. เฟส 3.1 — มาสคอต + ระบบดาวสะสม (⏸ พักไว้ก่อน รอ design)
3. ✅ เฟส 2.1 — เกม "หมวดครอบครัว" (quiz คัสตอมผู้ปกครองสร้างเอง + โหมดลูกเต๋าสุ่ม, Hive offline) เสร็จ 2026-07-09 · + animation polish + กราฟฟิกเกมจับคู่ใหม่
4. งาน asset/build: เจนเสียง 219 คลิป, หมวดน้ำการ์ตูน, รูปถ่านการ์ตูน (แทน Energizer), build APK ทดสอบ Android จริง

## How to Use
- Tick กล่องทันทีที่ feature ขึ้น `main`
- Sync กับ `CLAUDE.md` (บริบทงานละเอียด) และ `specs/14-mvp-scope.md` (นิยาม scope)
