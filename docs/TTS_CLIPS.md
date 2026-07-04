# รายการคลิปเสียงที่ต้องเจน (TTS Clips Checklist)

แอปเล่นเสียงตามลำดับ: **ไฟล์อัดล่วงหน้าใน `assets/tts/` → Cloud TTS (ถ้ามีคีย์) → เสียง engine ในเครื่อง**
ไฟล์ไหนยังไม่มี แอปใช้เสียงสำรองแทนอัตโนมัติ — **ทยอยเติมทีละไฟล์ได้ ไม่ต้องครบก่อน**

รายการทั้งหมด **211 คลิป** ตรงกับ [`assets/tts/tts_manifest.json`](../assets/tts/tts_manifest.json) แล้ว ไม่ต้องแก้ JSON ใดๆ — แค่วางไฟล์ให้ชื่อตรง (คำศัพท์อิงคลังคำจริง 6 หมวด 90 คำจาก zip "NSC คำศัพท์ + ภาพ") — ชุดบังคับจริงๆ คือ 121 คลิปแรก ส่วน `match_*` 90 คลิปอัดทีหลังได้

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
| `sys_quiz_ask_drinks` ★ | นี่คือเครื่องดื่มอะไร |
| `sys_quiz_ask_places` ★ | นี่คือที่ไหน |
| `sys_quiz_ask_occupations` ★ | นี่คืออาชีพอะไร |
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

### จับคู่สำเร็จ Module B (90) — ชื่อคู่ + คำชม เป็นประโยคเดียว

> ชุดนี้**อัดทีหลังได้** (ความสำคัญต่ำสุด): ประโยคไหนยังไม่มีไฟล์ แอปใช้เสียงสำรอง
> ในเครื่องพูดแทนเฉพาะประโยคนั้น เกมเล่นได้ปกติ

| ไฟล์ | ข้อความ |
|---|---|
| `match_shrimp` | กุ้ง จับคู่ได้แล้ว! |
| `match_bird` | นก จับคู่ได้แล้ว! |
| `match_fish` | ปลา จับคู่ได้แล้ว! |
| `match_crab` | ปู จับคู่ได้แล้ว! |
| `match_ant` | มด จับคู่ได้แล้ว! |
| `match_horse` | ม้า จับคู่ได้แล้ว! |
| `match_cow` | วัว จับคู่ได้แล้ว! |
| `match_mouse` | หนู จับคู่ได้แล้ว! |
| `match_dog` | หมา จับคู่ได้แล้ว! |
| `match_bear` | หมี จับคู่ได้แล้ว! |
| `match_pig` | หมู จับคู่ได้แล้ว! |
| `match_tiger` | เสือ จับคู่ได้แล้ว! |
| `match_sheep` | แกะ จับคู่ได้แล้ว! |
| `match_cat` | แมว จับคู่ได้แล้ว! |
| `match_chicken` | ไก่ จับคู่ได้แล้ว! |
| `match_rice` | ข้าว จับคู่ได้แล้ว! |
| `match_fried_rice` | ข้าวผัด จับคู่ได้แล้ว! |
| `match_soup` | ซุป จับคู่ได้แล้ว! |
| `match_clear_soup` | ต้มจืด จับคู่ได้แล้ว! |
| `match_pad_thai` | ผัดไทย จับคู่ได้แล้ว! |
| `match_pie` | พาย จับคู่ได้แล้ว! |
| `match_pizza` | พิซซ่า จับคู่ได้แล้ว! |
| `match_candy` | ลูกอม จับคู่ได้แล้ว! |
| `match_suki` | สุกี้ จับคู่ได้แล้ว! |
| `match_som_tam` | ส้มตำ จับคู่ได้แล้ว! |
| `match_fried_pork` | หมูทอด จับคู่ได้แล้ว! |
| `match_burger` | เบอร์เกอร์ จับคู่ได้แล้ว! |
| `match_congee` | โจ๊ก จับคู่ได้แล้ว! |
| `match_fried_chicken` | ไก่ทอด จับคู่ได้แล้ว! |
| `match_omelet` | ไข่เจียว จับคู่ได้แล้ว! |
| `match_coffee` | กาแฟ จับคู่ได้แล้ว! |
| `match_tea` | ชา จับคู่ได้แล้ว! |
| `match_milk_tea` | ชานม จับคู่ได้แล้ว! |
| `match_iced_tea` | ชาเย็น จับคู่ได้แล้ว! |
| `match_thai_tea` | ชาไทย จับคู่ได้แล้ว! |
| `match_milk` | นม จับคู่ได้แล้ว! |
| `match_milk_shake` | นมปั่น จับคู่ได้แล้ว! |
| `match_lemonade` | น้ำมะนาว จับคู่ได้แล้ว! |
| `match_orange_juice` | น้ำส้ม จับคู่ได้แล้ว! |
| `match_water` | น้ำเปล่า จับคู่ได้แล้ว! |
| `match_ice` | น้ำแข็ง จับคู่ได้แล้ว! |
| `match_red_drink` | น้ำแดง จับคู่ได้แล้ว! |
| `match_cocoa` | โกโก้ จับคู่ได้แล้ว! |
| `match_cola` | โคล่า จับคู่ได้แล้ว! |
| `match_soda` | โซดา จับคู่ได้แล้ว! |
| `match_market` | ตลาด จับคู่ได้แล้ว! |
| `match_road` | ถนน จับคู่ได้แล้ว! |
| `match_sea` | ทะเล จับคู่ได้แล้ว! |
| `match_home` | บ้าน จับคู่ได้แล้ว! |
| `match_forest` | ป่า จับคู่ได้แล้ว! |
| `match_mountain` | ภูเขา จับคู่ได้แล้ว! |
| `match_shop` | ร้านค้า จับคู่ได้แล้ว! |
| `match_temple` | วัด จับคู่ได้แล้ว! |
| `match_garden` | สวน จับคู่ได้แล้ว! |
| `match_zoo` | สวนสัตว์ จับคู่ได้แล้ว! |
| `match_kitchen` | ห้องครัว จับคู่ได้แล้ว! |
| `match_bedroom` | ห้องนอน จับคู่ได้แล้ว! |
| `match_bathroom` | ห้องน้ำ จับคู่ได้แล้ว! |
| `match_hospital` | โรงพยาบาล จับคู่ได้แล้ว! |
| `match_school` | โรงเรียน จับคู่ได้แล้ว! |
| `match_teacher` | คุณครู จับคู่ได้แล้ว! |
| `match_farmer` | ชาวนา จับคู่ได้แล้ว! |
| `match_barber` | ช่างตัดผม จับคู่ได้แล้ว! |
| `match_police` | ตำรวจ จับคู่ได้แล้ว! |
| `match_soldier` | ทหาร จับคู่ได้แล้ว! |
| `match_firefighter` | นักดับเพลิง จับคู่ได้แล้ว! |
| `match_singer` | นักร้อง จับคู่ได้แล้ว! |
| `match_artist` | นักวาด จับคู่ได้แล้ว! |
| `match_student` | นักเรียน จับคู่ได้แล้ว! |
| `match_nurse` | พยาบาล จับคู่ได้แล้ว! |
| `match_vendor` | พ่อค้าแม่ค้า จับคู่ได้แล้ว! |
| `match_doctor` | หมอ จับคู่ได้แล้ว! |
| `match_dentist` | หมอฟัน จับคู่ได้แล้ว! |
| `match_vet` | สัตวแพทย์ จับคู่ได้แล้ว! |
| `match_chef` | เชฟ จับคู่ได้แล้ว! |
| `match_scared` | กลัว จับคู่ได้แล้ว! |
| `match_eat` | กินข้าว จับคู่ได้แล้ว! |
| `match_happy` | ดีใจ จับคู่ได้แล้ว! |
| `match_drink` | ดื่มน้ำ จับคู่ได้แล้ว! |
| `match_sleep` | นอน จับคู่ได้แล้ว! |
| `match_sit` | นั่ง จับคู่ได้แล้ว! |
| `match_run` | วิ่ง จับคู่ได้แล้ว! |
| `match_hungry` | หิว จับคู่ได้แล้ว! |
| `match_read` | อ่าน จับคู่ได้แล้ว! |
| `match_hurt` | เจ็บ จับคู่ได้แล้ว! |
| `match_sad` | เสียใจ จับคู่ได้แล้ว! |
| `match_brush_teeth` | แปรงฟัน จับคู่ได้แล้ว! |
| `match_angry` | โกรธ จับคู่ได้แล้ว! |
| `match_yes` | ใช่ จับคู่ได้แล้ว! |
| `match_no` | ไม่ใช่ จับคู่ได้แล้ว! |

### คำศัพท์ (90) — คลังคำจริง 6 หมวด (ใช้ใน sound board + เกมตอบคำถาม + จับคู่ภาพ)

#### สัตว์ (15)

| ไฟล์ | ข้อความ |
|---|---|
| `word_shrimp` | กุ้ง |
| `word_bird` | นก |
| `word_fish` | ปลา |
| `word_crab` | ปู |
| `word_ant` | มด |
| `word_horse` | ม้า |
| `word_cow` | วัว |
| `word_mouse` | หนู |
| `word_dog` | หมา |
| `word_bear` | หมี |
| `word_pig` | หมู |
| `word_tiger` | เสือ |
| `word_sheep` | แกะ |
| `word_cat` | แมว |
| `word_chicken` | ไก่ |

#### อาหาร (15)

| ไฟล์ | ข้อความ |
|---|---|
| `word_rice` | ข้าว |
| `word_fried_rice` | ข้าวผัด |
| `word_soup` | ซุป |
| `word_clear_soup` | ต้มจืด |
| `word_pad_thai` | ผัดไทย |
| `word_pie` | พาย |
| `word_pizza` | พิซซ่า |
| `word_candy` | ลูกอม |
| `word_suki` | สุกี้ |
| `word_som_tam` | ส้มตำ |
| `word_fried_pork` | หมูทอด |
| `word_burger` | เบอร์เกอร์ |
| `word_congee` | โจ๊ก |
| `word_fried_chicken` | ไก่ทอด |
| `word_omelet` | ไข่เจียว |

#### น้ำ (15)

| ไฟล์ | ข้อความ |
|---|---|
| `word_coffee` | กาแฟ |
| `word_tea` | ชา |
| `word_milk_tea` | ชานม |
| `word_iced_tea` | ชาเย็น |
| `word_thai_tea` | ชาไทย |
| `word_milk` | นม |
| `word_milk_shake` | นมปั่น |
| `word_lemonade` | น้ำมะนาว |
| `word_orange_juice` | น้ำส้ม |
| `word_water` | น้ำเปล่า |
| `word_ice` | น้ำแข็ง |
| `word_red_drink` | น้ำแดง |
| `word_cocoa` | โกโก้ |
| `word_cola` | โคล่า |
| `word_soda` | โซดา |

#### สถานที่ (15)

| ไฟล์ | ข้อความ |
|---|---|
| `word_market` | ตลาด |
| `word_road` | ถนน |
| `word_sea` | ทะเล |
| `word_home` | บ้าน |
| `word_forest` | ป่า |
| `word_mountain` | ภูเขา |
| `word_shop` | ร้านค้า |
| `word_temple` | วัด |
| `word_garden` | สวน |
| `word_zoo` | สวนสัตว์ |
| `word_kitchen` | ห้องครัว |
| `word_bedroom` | ห้องนอน |
| `word_bathroom` | ห้องน้ำ |
| `word_hospital` | โรงพยาบาล |
| `word_school` | โรงเรียน |

#### อาชีพ (15)

| ไฟล์ | ข้อความ |
|---|---|
| `word_teacher` | คุณครู |
| `word_farmer` | ชาวนา |
| `word_barber` | ช่างตัดผม |
| `word_police` | ตำรวจ |
| `word_soldier` | ทหาร |
| `word_firefighter` | นักดับเพลิง |
| `word_singer` | นักร้อง |
| `word_artist` | นักวาด |
| `word_student` | นักเรียน |
| `word_nurse` | พยาบาล |
| `word_vendor` | พ่อค้าแม่ค้า |
| `word_doctor` | หมอ |
| `word_dentist` | หมอฟัน |
| `word_vet` | สัตวแพทย์ |
| `word_chef` | เชฟ |

#### คำในชีวิตประจำวัน (15)

| ไฟล์ | ข้อความ |
|---|---|
| `word_scared` | กลัว |
| `word_eat` | กินข้าว |
| `word_happy` | ดีใจ |
| `word_drink` | ดื่มน้ำ |
| `word_sleep` | นอน |
| `word_sit` | นั่ง |
| `word_run` | วิ่ง |
| `word_hungry` | หิว |
| `word_read` | อ่าน |
| `word_hurt` | เจ็บ |
| `word_sad` | เสียใจ |
| `word_brush_teeth` | แปรงฟัน |
| `word_angry` | โกรธ |
| `word_yes` | ใช่ |
| `word_no` | ไม่ใช่ |


## ลำดับที่แนะนำ (ถ้าไม่อยากเจนรวดเดียว)

1. `sys_quiz_*` 10 ไฟล์ + `word_*` หมวดสัตว์/อาหาร — เกมตอบคำถามได้เสียงครบก่อน
2. `word_*` ที่เหลือ (รวม 93 ไฟล์) — sound board ครบเสียง
3. `match_*` + `sys_memory_*` — เกมจับคู่ครบเสียง
4. `sc_*` — Module A ครบเสียง
5. `sys_*` ที่เหลือ — เสียงต้อนรับ/เตือนพัก
