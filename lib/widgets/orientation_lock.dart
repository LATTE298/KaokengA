import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// RouteObserver กลาง — ผูกเข้า GoRouter (observers) เพื่อให้ OrientationLock รู้จังหวะที่
// หน้าถูกเปิดใหม่ (push) หรือถูกเผยอีกครั้งเมื่อหน้าบนถูกปิด (pop) แล้ว "ตั้งทิศจอซ้ำ" —
// แก้บั๊กจอไม่หมุนกลับเป็นแนวนอนเมื่อกดกลับจากโซนผู้ปกครอง (พบบน Android จริง 2026-07-12)
final RouteObserver<PageRoute<dynamic>> orientationRouteObserver =
    RouteObserver<PageRoute<dynamic>>();

// ล็อกทิศทางจอเฉพาะช่วงที่ widget นี้อยู่บนหน้าจอ — โซนผู้ปกครอง (login/dashboard/
// parent gate) ใช้แนวตั้ง ส่วนโซนเด็ก (เมนู/เกม) ใช้แนวนอน. main.dart ตั้งค่าเริ่มต้น
// แล้วแต่ละหน้าที่ครอบด้วย widget นี้จะสลับทิศตอน build ขึ้นมา + ตั้งซ้ำเมื่อถูกเผยอีกครั้ง
// ผ่าน RouteAware (กันเคสกลับมาหน้าเดิมที่ widget ไม่ถูกสร้างใหม่ initState จึงไม่ทำงาน)
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

class _OrientationLockState extends State<OrientationLock> with RouteAware {
  @override
  void initState() {
    super.initState();
    _apply();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      orientationRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didUpdateWidget(OrientationLock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.portrait != widget.portrait) _apply();
  }

  // หน้านี้ถูกเปิด (push)
  @override
  void didPush() => _apply();

  // หน้าบนถูกปิด (pop) แล้วหน้านี้ถูกเผยอีกครั้ง — เช่น กดกลับจากโซนผู้ปกครอง
  @override
  void didPopNext() => _apply();

  @override
  void dispose() {
    orientationRouteObserver.unsubscribe(this);
    super.dispose();
  }

  void _apply() {
    if (kIsWeb) return; // เบราว์เซอร์ล็อกทิศไม่ได้
    SystemChrome.setPreferredOrientations(
      widget.portrait
          ? const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
          : const [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ],
    );
    // โซนเด็ก (แนวนอน) = ซ่อนแถบสถานะ/แถบนำทาง แบบเกมมือถือ (immersive) → UI ชิดขอบบน
    // + พื้นหลังเต็มจอ (ไม่มี inset ให้ SafeArea หด). โซนผู้ปกครอง (แนวตั้ง) = โชว์แถบปกติ
    SystemChrome.setEnabledSystemUIMode(
      widget.portrait ? SystemUiMode.edgeToEdge : SystemUiMode.immersiveSticky,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
