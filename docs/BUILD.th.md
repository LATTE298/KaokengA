# คู่มือการบิลด์ (Build Guide)

_ตรวจสอบล่าสุด: 2026-04-29_

## ข้อกำหนดเบื้องต้น (Prerequisites)

| เครื่องมือ | เวอร์ชันขั้นต่ำ | หมายเหตุ |
|---|---|---|
| Flutter SDK | 3.29.2+ (รองรับ Dart ^3.7.2) | ติดตั้งผ่าน [flutter.dev](https://flutter.dev/docs/get-started/install) |
| Dart | 3.7.2+ | มาพร้อมกับ Flutter; ใน `pubspec.yaml` กำหนดค่า `sdk: ^3.7.2` |
| Android Studio | เวอร์ชัน stable ล่าสุด | จำเป็นสำหรับ Android emulator และเครื่องมือ SDK |
| JDK | 17+ | ต้องการโดย Android Gradle Plugin 8.7; สามารถใช้ JDK ที่มาพร้อมกับ Android Studio ได้ (ความเข้ากันได้ของ source/target ของแอปยังคงเป็น Java 11) |
| Android SDK | Android SDK ที่ตั้งค่าไว้ใน `flutter doctor` | กำหนด `minSdk` เป็น 23 (ข้อกำหนดของ Firebase Auth); ส่วน `compileSdk` จะมาจาก Flutter SDK ที่ติดตั้งไว้ |

ระบบ iOS **ไม่ได้**อยู่ในขอบเขตของ MVP ปัจจุบัน — รองรับเฉพาะแท็บเล็ต Android (ขนาด 10 นิ้ว, แนวนอน) เท่านั้น

## การติดตั้ง Dependencies

ตรวจสอบการตั้งค่า Flutter และ Android ในเครื่องก่อน:

```bash
flutter doctor -v
```

```bash
flutter pub get
```

หากคุณมีการเปลี่ยนแปลงโมเดล Freezed ใดๆ (`lib/models/*.dart`) หรือเพิ่มคลาส `@JsonSerializable` ใหม่ ให้รันคำสั่งสร้างโค้ดใหม่ (regenerate code):

```bash
dart run build_runner build --delete-conflicting-outputs
```

หากต้องการดูการเปลี่ยนแปลง (watch) แบบเรียลไทม์ระหว่างการพัฒนา:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## สภาพแวดล้อม / การตั้งค่า Firebase

แอปพลิเคชันนี้จำเป็นต้องใช้ Firebase โดยการตั้งค่า Firebase สำหรับ Android ในปัจจุบันถูกติดตาม (tracked) ไว้ใน Git ดังนี้:

- `android/app/google-services.json` — ไฟล์ตั้งค่า Firebase ของ Android สำหรับแพ็กเกจ `com.kaokeng.daily_life`
- `lib/firebase_options.dart` — ตัวเลือก Firebase SDK สำหรับโปรเจกต์ `tenacious-veld-453115-u8`

หากคุณต้องการเชื่อมต่อกับโปรเจกต์ Firebase อื่น ตรวจสอบให้แน่ใจว่าได้ติดตั้งและเข้าสู่ระบบ Firebase CLI แล้ว จากนั้นให้สร้างการตั้งค่า FlutterFire ใหม่:

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

ดาวน์โหลดไฟล์ `android/app/google-services.json` เพื่อมาแทนที่ได้จาก Firebase console ภายใต้เมนู **Project settings -> Your apps -> Android app** โปรเจกต์นี้ไม่จำเป็นต้องใช้ไฟล์ `.env` และ **ห้ามคอมมิต** ไฟล์ service-account ของ Firebase หรือไฟล์ admin SDK JSON ลงในระบบ (ไฟล์เหล่านี้ถูกยกเว้นไว้ใน `.gitignore` แล้ว)

## การรันโปรเจกต์บนเครื่อง (Run Locally)

เชื่อมต่ออุปกรณ์ Android หรือเปิด emulator จากนั้น:

```bash
flutter run
```

หากต้องการระบุอุปกรณ์ที่จะรัน:

```bash
flutter devices          # แสดงรายการอุปกรณ์ทั้งหมดที่มี
flutter run -d <device-id>
```

แอปถูกล็อกให้แสดงผลในแนวนอนเท่านั้น แนะนำให้รันบนแท็บเล็ต emulator (ขนาด 10 นิ้ว) เพื่อให้ได้เลย์เอาต์ตามที่ออกแบบไว้

## การบิลด์แอป Android (Android Build)

การบิลด์ Debug APK:

```bash
flutter build apk --debug
```

การบิลด์ Release APK:

```bash
flutter build apk --release
```

การบิลด์ Release App Bundle:

```bash
flutter build appbundle --release
```

ไฟล์ที่บิลด์เสร็จจะถูกเก็บไว้ที่ `build/app/outputs/` ยกตัวอย่างเช่น `build/app/outputs/flutter-apk/app-debug.apk`, `build/app/outputs/flutter-apk/app-release.apk` และ `build/app/outputs/bundle/release/app-release.aab`

ปัจจุบัน `android/app/build.gradle.kts` มีการเซ็นรับรอง (sign) บิลด์ประเภท release ด้วยการตั้งค่าของ debug เพื่อให้คำสั่งรัน release บนเครื่องสามารถทำงานได้ **กรุณาตั้งค่า release keystore ของจริง** ก่อนทำการแจกจ่ายไฟล์ APK หรืออัปโหลดไฟล์ AAB ขึ้น Play Store

## การทดสอบ (Tests)

รันชุดการทดสอบทั้งหมด:

```bash
flutter test
```

ขอบเขตการทดสอบ (Test coverage) ครอบคลุม:

- `test/models/` — การแปลงข้อมูลโมเดล (serialisation)
- `test/features/` — คอนโทรลเลอร์เกมความจำ, ระบบบันทึกเซสชัน
- `test/providers/` — ลอจิกของ Riverpod provider
- `test/services/` — เซอร์วิส TTS, ที่เก็บเนื้อหา (content repository)
- `test/game/` — การทดสอบการเรนเดอร์เกม Flame
- `test/widgets/` — การทดสอบวิดเจ็ตสำหรับเด็กและผู้ปกครอง
- `test/content/` — การตรวจสอบความถูกต้องของ asset manifest

## การแก้ปัญหาเบื้องต้น (Troubleshooting)

**ไม่พบไฟล์ `google-services.json`**
```text
FAILURE: Build failed with an exception.
...google-services plugin requires a google-services.json file
```
ดาวน์โหลดไฟล์จาก Firebase console และนำไปวางไว้ที่ `android/app/google-services.json`

**โค้ดของ Freezed / โค้ดที่สร้างขึ้น (generated code) ไม่อัปเดต**
```text
Error: The getter 'copyWith' isn't defined for the class '...'
```
ให้รันคำสั่ง `dart run build_runner build --delete-conflicting-outputs`

**เวอร์ชัน Gradle JDK ไม่ตรงกัน**
ตรวจสอบให้แน่ใจว่า Android Studio ใช้ JDK 17 หรือใหม่กว่า ไปที่ **File -> Project Structure -> SDK Location -> Gradle JDK** แล้วเลือก JDK ที่มาพร้อมกับ Android Studio หรือ JDK 17+ ตัวอื่นที่ติดตั้งไว้ในเครื่อง

**ไม่พบ Android SDK**
รันคำสั่ง `flutter doctor -v` หากคุณติดตั้ง Android SDK ไว้ในตำแหน่งอื่น (custom location) ให้รันคำสั่ง `flutter config --android-sdk <path-to-sdk>`

**คำสั่ง `flutter pub get` ล้มเหลวบน Windows เนื่องจากพาธ (path) ยาวเกินไป**
เปิดใช้งาน long paths ใน Windows โดยรัน `git config --system core.longpaths true` และเปิดใช้นโยบาย Windows long path ผ่าน Group Policy หรือ Registry

**ตรวจไม่พบ Emulator**
รันคำสั่ง `flutter doctor -v` เพื่อตรวจสอบการตั้งค่า Android SDK และ emulator ของคุณ ตรวจสอบให้แน่ใจว่าได้ตั้งค่าตัวแปรสภาพแวดล้อม `ANDROID_HOME` (หรือ `ANDROID_SDK_ROOT`) ไว้แล้วในระบบ หาก Flutter ไม่สามารถหา SDK พบ