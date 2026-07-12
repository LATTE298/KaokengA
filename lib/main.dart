import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'providers/sfx_provider.dart';
import 'providers/streak_provider.dart';
import 'routes/app_router.dart';
import 'services/auth_service.dart';
import 'services/family_card_repository.dart';
import 'services/sfx_player.dart';
import 'theme/app_theme.dart';
import 'widgets/bgm_gate.dart';
import 'widgets/usage_timer_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive local storage (เฟส 2.1 — คลังการ์ดหมวดครอบครัวของผู้ปกครอง เก็บ offline)
  await Hive.initFlutter();
  await Hive.openBox<dynamic>(FamilyCardRepository.boxName);
  // ค่าตั้งต้นเล็กๆ ฝั่งเด็ก เช่น สตรีคเข้าเล่นต่อเนื่อง (หน้าเลือกเล่น)
  await Hive.openBox<dynamic>(kAppPrefsBoxName);

  // เปิดแอปด้วยแนวตั้ง (หน้าแรก = splash ล็อกแนวตั้ง) กันแวบแนวนอนตอนบูต —
  // แต่ละหน้าจากนั้นตั้งทิศเองผ่าน OrientationLock (เมนู/เกมเด็ก = แนวนอน). ข้ามบนเว็บ
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Anonymous identity for session writes under /sessions/{uid}/records.
  // Parent email+password login (MVP item #2) will later link to this UID.
  // ล็อกอินล้มเหลว (เช่น network-request-failed ตอนเปิดแอปโดยไม่มีเน็ต) ต้องไม่ crash:
  // เปิดแอปแบบ guest ไปก่อน — uid เป็น null แล้ว SessionRecorder จะข้ามการเขียน Firestore
  // เอง (ดู session_recorder.dart) — แล้ว retry เบื้องหลังจนกว่าจะสำเร็จเมื่อเน็ตกลับมา
  final authService = AuthService(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );
  try {
    await authService.ensureAnonymousChildSession();
  } catch (e) {
    debugPrint('Anonymous sign-in failed, starting as guest: $e');
    unawaited(_retryAnonymousSignIn(authService));
  }

  runApp(const ProviderScope(child: DailyLifeApp()));
}

// Retry แบบ backoff (5 วิ → เพดาน 5 นาที) ไม่หยุดจนกว่าจะสำเร็จ — แท็บเล็ตบ้าน/โรงเรียน
// มักได้เน็ตหลังเปิดแอปไปแล้วหลายนาที. เรียกซ้ำได้ปลอดภัย: signInAnonymouslyIfNeeded
// คืน user เดิมทันทีถ้ามีการล็อกอินสำเร็จไปก่อนแล้ว (เช่น ผู้ปกครอง login เอง) จึงไม่ทับบัญชี
Future<void> _retryAnonymousSignIn(AuthService authService) async {
  var delay = const Duration(seconds: 5);
  const maxDelay = Duration(minutes: 5);
  while (true) {
    await Future<void>.delayed(delay);
    try {
      await authService.ensureAnonymousChildSession();
      return;
    } catch (e) {
      debugPrint('Anonymous sign-in retry failed: $e');
      delay *= 2;
      if (delay > maxDelay) delay = maxDelay;
    }
  }
}

class DailyLifeApp extends ConsumerStatefulWidget {
  const DailyLifeApp({super.key});

  @override
  ConsumerState<DailyLifeApp> createState() => _DailyLifeAppState();
}

class _DailyLifeAppState extends ConsumerState<DailyLifeApp> {
  // สร้าง router ครั้งเดียว (ไม่รีเซ็ตทุก build) — observers เล่นเสียงเปลี่ยนหน้า
  final _router = buildAppRouter();

  @override
  void initState() {
    super.initState();
    // ต่อ player เสียง UI (คลิกปุ่ม/เปลี่ยนหน้า) เข้ากับ hook กลางใน sfx_player
    setUiSfxPlayer(ref.read(sfxPlayerProvider));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Daily Life',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: _router,
      // ครอบทุกหน้าด้วย UsageTimerGate (spec 1.4 — เตือนพักสายตาทุก 15 นาที)
      // ตั้งที่ระดับ MaterialApp.router(builder:) เพื่อให้ gate อยู่เหนือ Navigator แต่อยู่
      // ใต้ MaterialApp — มี Theme/Localizations/Overlay ให้ showDialog ใช้ได้ และ state ของ
      // gate ไม่ถูกทำลายเมื่อเปลี่ยนเส้นทาง (route)
      builder:
          (context, child) => BgmGate(
            child: UsageTimerGate(child: child ?? const SizedBox.shrink()),
          ),
    );
  }
}
