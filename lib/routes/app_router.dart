import 'package:go_router/go_router.dart';

import '../screens/child/mode_select_screen.dart';
import '../screens/child/module_a_screen.dart';
import '../screens/child/module_b_screen.dart';
import '../screens/child/memory_game_screen.dart';
import '../screens/child/module_c_screen.dart';
import '../screens/child/scenario_game_screen.dart';
import '../screens/child/splash_screen.dart';
import '../screens/parent/auth_screen.dart';
import '../screens/parent/dashboard_screen.dart';
import '../screens/parent/parent_gate_screen.dart';
import 'app_routes.dart';

// GoRouter config (spec 02 §All Routes). Child routes and parent routes live
// side-by-side; the parent gate screen handles the transition between modes.
GoRouter buildAppRouter() {
  return GoRouter(
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
        path: kRouteMemoryGame,
        builder: (_, __) => const MemoryGameScreen(),
      ),
      GoRoute(path: kRouteModuleC, builder: (_, __) => const ModuleCScreen()),
      GoRoute(
        path: kRouteParentGate,
        builder: (_, __) => const ParentGateScreen(),
      ),
      GoRoute(path: kRouteAuth, builder: (_, __) => const AuthScreen()),
      GoRoute(
        path: kRouteDashboard,
        builder: (_, __) => const DashboardScreen(),
      ),
    ],
  );
}
