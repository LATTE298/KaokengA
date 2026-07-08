import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../screens/child/mode_select_screen.dart';
import '../screens/child/module_a_screen.dart';
import '../screens/child/module_b_screen.dart';
import '../screens/child/memory_game_screen.dart';
import '../screens/child/family_game_screen.dart';
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

// GoRouter config (spec 02 §All Routes). Child routes and parent routes live
// side-by-side; the parent gate screen handles the transition between modes.
GoRouter buildAppRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: kRouteSplash,
    routes: [
      GoRoute(path: kRouteSplash, builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: kRouteModeSelect,
        builder: (_, __) => const ModeSelectScreen(),
      ),
      GoRoute(path: kRouteModuleA, builder: (_, __) => const ModuleAScreen()),
      GoRoute(
        // Child deep-route format: /module-a/game/:scenarioId
        path: '$kRouteScenarioGame/:scenarioId',
        builder:
            (_, state) => ScenarioGameScreen(
              scenarioId: state.pathParameters['scenarioId']!,
            ),
      ),
      GoRoute(path: kRouteModuleB, builder: (_, __) => const ModuleBScreen()),
      GoRoute(
        // Child deep-route format: /module-b/game/:packId (แพ็ค = หมวดคำศัพท์)
        path: '$kRouteMemoryGame/:packId',
        builder:
            (_, state) =>
                MemoryGameScreen(packId: state.pathParameters['packId']!),
      ),
      GoRoute(path: kRouteModuleC, builder: (_, __) => const ModuleCScreen()),
      GoRoute(
        path: kRouteSoundBoard,
        builder: (_, __) => const SoundBoardScreen(),
      ),
      GoRoute(
        path: kRouteVocabQuiz,
        builder: (_, __) => const VocabQuizSelectScreen(),
      ),
      GoRoute(
        // Child deep-route format: /module-c/quiz/:category (หมวดคำศัพท์)
        path: '$kRouteVocabQuiz/:category',
        builder:
            (_, state) =>
                VocabQuizScreen(category: state.pathParameters['category']!),
      ),
      GoRoute(
        path: kRouteFamilyGame,
        builder: (_, __) => const FamilyGameScreen(),
      ),
      GoRoute(
        path: kRouteParentGate,
        builder: (_, __) => const ParentGateScreen(),
      ),
      GoRoute(path: kRouteAuth, builder: (_, __) => const AuthScreen()),
      GoRoute(
        path: kRouteDashboard,
        builder: (_, __) => const DashboardScreen(),
      ),
      GoRoute(
        path: kRouteFamilyManager,
        builder: (_, __) => const FamilyManagerScreen(),
      ),
    ],
  );
}
