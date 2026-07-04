# รายการคลิปเสียงที่ต้องเจน (TTS Clips Checklist)

แอปเล่นเสียงตามลำดับ: **ไฟล์อัดล่วงหน้าใน `assets/tts/` → Cloud TTS (ถ้ามีคีย์) → เสียง engine ในเครื่อง**
ไฟล์ไหนยังไม่มี แอปใช้เสียงสำรองแทนอัตโนมัติ — **ทยอยเติมทีละไฟล์ได้ ไม่ต้องครบก่อน**

รายการทั้งหมด **71 คลิป** ตรงกับ [`assets/tts/tts_manifest.json`](../assets/tts/tts_manifest.json) แล้ว ไม่ต้องแก้ JSON ใดๆ — แค่วางไฟล์ให้ชื่อตรง

## วิธีทำ

1. เปิด [Google AI Studio](https://aistudio.google.com) → เลือกโหมด **Generate speech** (Gemini TTS)
2. **เลือกเสียงเดียวใช้ทุกคลิป** (โทนจะได้สม่ำเสมอทั้งแอป — แนะนำลองเสียงผู้ชายนุ่มๆ ให้เข้ากับสรรพนาม "ครับ")
3. วางข้อความจากตาราง **ให้ตรงเป๊ะทุกตัวอักษร** (ห้ามเติม/ตัดคำ ไม่ต้องใส่คำสั่งอื่น)
4. ดาวน์โหลดไฟล์เสียง (ได้ .wav) → **ตั้งชื่อไฟล์ตามคอลัมน์ "ไฟล์"** (เช่น `word_cat.wav`)
5. เอาไฟล์ .wav ทั้งหมดใส่โฟลเดอร์ `tts_raw/` ที่ root ของโปรเจกต์ (โฟลเดอร์นี้ไม่ถูก commit)
6. รันสคริปต์แปลงเป็น .opus (ไฟล์เล็กลง ~10 เท่า) — ต้องมี [ffmpeg](https://ffmpeg.org) (`winget install Gyan.FFmpeg`):
   ```powershell
   ./tool/convert_tts_clips.ps1
   ```
   ไฟล์ .opus จะไปลง `assets/tts/` ให้เอง แล้ว build/รันแอปได้เลย

> [!IMPORTANT]
> ถ้าแก้ข้อความใน `lib/l10n/tts_strings_th.dart` หรือใน JSON (vocabulary/scenarios/memory_packs) เมื่อไหร่
> ต้องอัปเดต key ใน `tts_manifest.json` ให้ตรง + เจนคลิปนั้นใหม่ ไม่งั้นประโยคนั้นจะตกไปใช้เสียงสำรอง

## ตารางคลิป

### ระบบ / นำทาง (22)

| ไฟล์ | ข้อความ |
|---|---|
| `sys_splash` | สวัสดีครับ |
| `sys_module_a_desc` | มาลองทำกิจกรรมในชีวิตประจำวันกันนะครับ |
| `sys_module_b_desc` | มาเล่นเกมจับคู่ภาพกันนะครับ |
| `sys_module_c_desc` | มาเรียนรู้คำศัพท์ใหม่กันนะครับ |
| `sys_memory_start` | มาจับคู่รูปภาพกันนะครับ |
| `sys_soundboard_start` | มาเรียนรู้คำศัพท์กันนะครับ |
| `sys_memory_match` | จับคู่ได้แล้ว! |
| `sys_memory_complete` | เก่งมากเลย! จับคู่ได้ครบแล้ว! |
| `sys_break_reminder` | น้องเล่นมานานแล้วนะครับ มาพักสายตาก่อนนะ |
| `sys_celebration_1` | เก่งมากเลยนะครับ! น้องทำได้แล้ว! |
| `sys_celebration_2` | ดีมากเลยครับ! เยี่ยมมากเลย! |
| `sys_celebration_3` | น้องทำได้ดีมากครับ! เก่งมากๆ! |
| `sys_quiz_start` ★ | ดูรูปแล้วเลือกคำตอบที่ถูกต้องนะครับ |
| `sys_quiz_correct` ★ | ถูกต้องครับ เก่งมาก! |
| `sys_quiz_retry` ★ | ยังไม่ใช่ ลองใหม่อีกครั้งนะครับ |
| `sys_quiz_complete` ★ | เก่งมากเลย! ตอบครบทุกข้อแล้ว! |
| `sys_quiz_ask_animals` ★ | นี่คือสัตว์อะไร |
| `sys_quiz_ask_food` ★ | นี่คืออาหารอะไร |
| `sys_quiz_ask_colours` ★ | นี่คือสีอะไร |
| `sys_quiz_ask_body` ★ | นี่คืออวัยวะอะไร |
| `sys_quiz_ask_household` ★ | นี่คือของใช้อะไร |
| `sys_quiz_ask_generic` ★ | นี่คืออะไร |

★ = เพิ่มเข้ามาพร้อมเกมตอบคำถาม Module C

### สถานการณ์ Module A (9)

| ไฟล์ | ข้อความ |
|---|---|
| `sc_711_milk_title` | ช่วยหยิบของที่เซเว่น |
| `sc_711_milk_instruction` | น้องช่วยหยิบนมกล่องสีน้ำเงินใส่ตะกร้าให้หน่อยนะครับ |
| `sc_711_milk_hint` | ลองหยิบนมกล่องสีน้ำเงินนะครับ |
| `sc_trash_sort_title` | ช่วยแยกขยะให้ถูกถัง |
| `sc_trash_sort_instruction` | น้องช่วยทิ้งขวดพลาสติกลงในถังรีไซเคิลให้หน่อยนะครับ |
| `sc_trash_sort_hint` | ลองหยิบขวดพลาสติกใส่ถังสีเขียวนะครับ |
| `sc_food_prep_title` | ช่วยจัดผลไม้ใส่จาน |
| `sc_food_prep_instruction` | น้องช่วยวางกล้วยลงบนจานให้หน่อยนะครับ |
| `sc_food_prep_hint` | ลองหยิบกล้วยใส่จานนะครับ |

หมายเหตุ: `tts_celebration` ในไฟล์ฉากยังไม่ถูกใช้จริง (เกมสุ่มจากคำชมกลาง `sys_celebration_1-3`) จึงไม่ต้องอัด

### จับคู่สำเร็จ Module B (8) — ชื่อคู่ + คำชม เป็นประโยคเดียว

| ไฟล์ | ข้อความ |
|---|---|
| `match_elephant` | ช้าง จับคู่ได้แล้ว! |
| `match_tiger` | เสือ จับคู่ได้แล้ว! |
| `match_cat` | แมว จับคู่ได้แล้ว! |
| `match_dog` | หมา จับคู่ได้แล้ว! |
| `match_fish` | ปลา จับคู่ได้แล้ว! |
| `match_bird` | นก จับคู่ได้แล้ว! |
| `match_monkey` | ลิง จับคู่ได้แล้ว! |
| `match_buffalo` | ควาย จับคู่ได้แล้ว! |

### คำศัพท์ (32) — ใช้ทั้ง Module B (ชื่อคู่) และ Module C (sound board)

| ไฟล์ | ข้อความ | | ไฟล์ | ข้อความ |
|---|---|---|---|---|
| `word_cat` | แมว | | `word_red` | สีแดง |
| `word_dog` | หมา | | `word_blue` | สีน้ำเงิน |
| `word_elephant` | ช้าง | | `word_yellow` | สีเหลือง |
| `word_tiger` | เสือ | | `word_green` | สีเขียว |
| `word_fish` | ปลา | | `word_white` | สีขาว |
| `word_bird` | นก | | `word_black` | สีดำ |
| `word_monkey` | ลิง | | `word_hand` | มือ |
| `word_buffalo` | ควาย | | `word_foot` | เท้า |
| `word_rice` | ข้าว | | `word_eye` | ตา |
| `word_banana` | กล้วย | | `word_ear` | หู |
| `word_milk` | นม | | `word_mouth` | ปาก |
| `word_water` | น้ำ | | `word_nose` | จมูก |
| `word_mango` | มะม่วง | | `word_chair` | เก้าอี้ |
| `word_egg` | ไข่ | | `word_table` | โต๊ะ |
| | | | `word_bed` | เตียง |
| | | | `word_door` | ประตู |
| | | | `word_window` | หน้าต่าง |
| | | | `word_lamp` | โคมไฟ |

## ลำดับที่แนะนำ (ถ้าไม่อยากเจนรวดเดียว)

1. `word_*` 32 ไฟล์ — ได้ยินบ่อยสุด (ทุกครั้งที่แตะการ์ด)
2. `match_*` + `sys_memory_*` — เกมจับคู่ครบเสียง
3. `sc_*` — Module A ครบเสียง
4. `sys_*` ที่เหลือ — เสียงต้อนรับ/เตือนพัก
