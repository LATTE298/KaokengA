import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../game/daily_life_game.dart';
import '../../features/sessions/session_recorder.dart';
import '../../models/app_types.dart';
import '../../models/loaded_scenario_config.dart';
import '../../providers/content_providers.dart';
import '../../providers/session_provider.dart';
import '../../providers/tts_provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/child_back_button.dart';

// Full-screen Flame canvas hosting DailyLifeGame (spec 02 §ScenarioGameScreen).
// The scenario id arrives via a GoRouter route `extra` payload.
class ScenarioGameScreen extends ConsumerWidget {
  const ScenarioGameScreen({super.key, required this.scenarioId});

  final String scenarioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncConfig = ref.watch(loadedScenarioConfigProvider(scenarioId));
    final tts = ref.watch(ttsServiceProvider);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: kWarmWhite,
      body: asyncConfig.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'โหลดสถานการณ์ไม่สำเร็จ',
                  style: kTextLg,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        data: (LoadedScenarioConfig loadedScenario) {
          final config = loadedScenario.config;
          final session = ref.watch(
            activeSessionProvider(
              ActiveSessionKey(
                module: kModuleDailyLife,
                contentId: config.scenarioId,
              ),
            ),
          );
          final game = DailyLifeGame(
            loadedScenario: loadedScenario,
            tts: tts,
            reduceMotion: reduceMotion,
            onComplete: (dragPath) async {
              // Fire-and-forget: Firestore's offline cache handles retry.
              ref
                  .read(sessionRecorderProvider)
                  .recordDailyLifeCompleted(
                    DailyLifeCompletedEvent(
                      session: session,
                      config: config,
                      dragPath: dragPath,
                    ),
                  );
              if (context.mounted && context.canPop()) context.pop();
            },
          );
          return Stack(
            children: [
              Positioned.fill(child: GameWidget(game: game)),
              const Positioned(top: 8, left: 8, child: ChildBackButton()),
            ],
          );
        },
      ),
    );
  }
}
