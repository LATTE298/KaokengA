import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// ล็อกทิศทางจอเฉพาะช่วงที่ widget นี้อยู่บนหน้าจอ — โซนผู้ปกครอง (login/dashboard/
// parent gate) ใช้แนวตั้งเพื่อความสะดวกในการกรอกฟอร์ม/อ่านข้อมูล ส่วนโซนเด็ก
// (เมนู/เกม) ใช้แนวนอน. main.dart ตั้งค่าเริ่มต้นเป็นแนวนอน แล้วแต่ละหน้าที่ครอบด้วย
// widget นี้จะสลับทิศตอน build ขึ้นมา
//
// จงใจไม่คืนค่าทิศเดิมใน dispose — เพื่อเลี่ยงการหมุนจอแวบเดียวตอนสลับระหว่างสองหน้า
// ที่ล็อกทิศเดียวกัน (เช่น login → dashboard ต่างก็แนวตั้ง). หน้าถัดไปรับผิดชอบตั้งทิศ
// ของตัวเอง: เมนูเด็ก (mode select) ครอบด้วย portrait:false เพื่อคืนเป็นแนวนอนเมื่อ
// ผู้ปกครองกดกลับ. ข้ามบนเว็บ (kIsWeb) เพราะเบราว์เซอร์ไม่รองรับการล็อกทิศ
class OrientationLock extends StatefulWidget {
  const OrientationLock({
    required this.portrait,
    required this.child,
    super.key,
  });

  final bool portrait;
  final Widget child;

  @override
  State<OrientationLock> createState() => _OrientationLockState();
}

class _OrientationLockState extends State<OrientationLock> {
  @override
  void initState() {
    super.initState();
    _apply();
  }

  @override
  void didUpdateWidget(OrientationLock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.portrait != widget.portrait) _apply();
  }

  void _apply() {
    if (kIsWeb) return;
    SystemChrome.setPreferredOrientations(
      widget.portrait
          ? const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
          : const [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ],
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
