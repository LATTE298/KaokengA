import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../screens/child/family_game_screen.dart';
import '../screens/child/memory_game_screen.dart';
import '../screens/child/mode_select_screen.dart';
import '../screens/child/module_a_screen.dart';
import '../screens/child/module_b_screen.dart';
import '../screens/child/module_c_screen.dart';
import '../screens/child/scenario_game_screen.dart';
import '../screens/child/sound_board_screen.dart';
import '../screens/child/splash_screen.dart';
import '../screens/child/vocab_quiz_screen.dart';
import '../screens/child/vocab_quiz_select_screen.dart';
import '../screens/parent/auth_screen.dart';
import '../screens/parent/dashboard_screen.dart';
import '../screens/parent/family_manager_screen.dart';
import '../screens/parent/parent_gate_screen.dart';
import 'app_routes.dart';

// Global navigator key ของ root navigator — ผูกเข้า GoRouter ด้านล่าง
// ใช้โดย UsageTimerGate เพื่อเปิด popup เตือนพัก (spec 1.4) จาก context ที่รับประกันว่า
// อยู่ "ใต้" Navigator เสมอ
//
// เหตุผล: UsageTimerGate ถูกวางไว้ที่ MaterialApp.router(builder:) ซึ่ง context ตรงนั้น
// อยู่ "เหนือ" Navigator ทำให้เรียก showDialog(context: ...) ตรงๆไม่ได้ (error: Navigator
// operation requested with a context that does not include a Navigator) การมี key กลางที่
// ชี้ไป Navigator โดยตรงจึงเป็นทางแก้ที่สะอาดที่สุด โดยไม่ต้องย้ายตำแหน่ง gate
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

// หน้าเปลี่ยนแบบจางนุ่มๆ (fade) แทน slide มาตรฐาน — ให้ทั้งแอปรู้สึก smooth ขึ้น
// ระยะสั้น (250ms) curve นุ่ม เลี่ยงการเลื่อน/กระตุกที่กระตุ้นสายตาเด็กกลุ่มดาวน์ซินโดรม
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
    child: child,
  );
}

// GoRouter config (spec 02 §All Routes). Child routes and parent routes live
// side-by-side; the parent gate screen handles the transition between modes.
GoRouter buildAppRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: kRouteSplash,
    routes: [
      GoRoute(
        path: kRouteSplash,
        pageBuilder: (_, state) => _fadePage(state, const SplashScreen()),
      ),
      GoRoute(
        path: kRouteModeSelect,
        pageBuilder: (_, state) => _fadePage(state, const ModeSelectScreen()),
      ),
      GoRoute(
        path: kRouteModuleA,
        pageBuilder: (_, state) => _fadePage(state, const ModuleAScreen()),
      ),
      GoRoute(
        // Child deep-route format: /module-a/game/:scenarioId
        path: '$kRouteScenarioGame/:scenarioId',
        pageBuilder:
            (_, state) => _fadePage(
              state,
              ScenarioGameScreen(
                scenarioId: state.pathParameters['scenarioId']!,
              ),
            ),
      ),
      GoRoute(
        path: kRouteModuleB,
        pageBuilder: (_, state) => _fadePage(state, const ModuleBScreen()),
      ),
      GoRoute(
        // Child deep-route format: /module-b/game/:packId (แพ็ค = หมวดคำศัพท์)
        path: '$kRouteMemoryGame/:packId',
        pageBuilder:
            (_, state) => _fadePage(
              state,
              MemoryGameScreen(packId: state.pathParameters['packId']!),
            ),
      ),
      GoRoute(
        path: kRouteModuleC,
        pageBuilder: (_, state) => _fadePage(state, const ModuleCScreen()),
      ),
      GoRoute(
        path: kRouteSoundBoard,
        pageBuilder: (_, state) => _fadePage(state, const SoundBoardScreen()),
      ),
      GoRoute(
        path: kRouteVocabQuiz,
        pageBuilder:
            (_, state) => _fadePage(state, const VocabQuizSelectScreen()),
      ),
      GoRoute(
        // Child deep-route format: /module-c/quiz/:category (หมวดคำศัพท์)
        path: '$kRouteVocabQuiz/:category',
        pageBuilder:
            (_, state) => _fadePage(
              state,
              VocabQuizScreen(category: state.pathParameters['category']!),
            ),
      ),
      GoRoute(
        path: kRouteFamilyGame,
        pageBuilder: (_, state) => _fadePage(state, const FamilyGameScreen()),
      ),
      GoRoute(
        path: kRouteParentGate,
        pageBuilder: (_, state) => _fadePage(state, const ParentGateScreen()),
      ),
      GoRoute(
        path: kRouteAuth,
        pageBuilder: (_, state) => _fadePage(state, const AuthScreen()),
      ),
      GoRoute(
        path: kRouteDashboard,
        pageBuilder: (_, state) => _fadePage(state, const DashboardScreen()),
      ),
      GoRoute(
        path: kRouteFamilyManager,
        pageBuilder:
            (_, state) => _fadePage(state, const FamilyManagerScreen()),
      ),
    ],
  );
}
