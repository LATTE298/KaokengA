import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../game/daily_life_game.dart';
import '../../models/scenario_config.dart';
import '../../models/session_record.dart';
import '../../providers/auth_provider.dart';
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
    final asyncConfig = ref.watch(scenarioConfigProvider(scenarioId));
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
        data: (ScenarioConfig config) {
          final startedAt = DateTime.now().toUtc();
          final game = DailyLifeGame(
            config: config,
            tts: tts,
            reduceMotion: reduceMotion,
            onComplete: (dragPath) async {
              final uid = ref.read(uidProvider);
              if (uid != null) {
                final endedAt = DateTime.now().toUtc();
                final targetId =
                    config.interactables.firstWhere((i) => i.isTarget).id;
                final record = SessionRecord(
                  sessionId: const Uuid().v4(),
                  uid: uid,
                  scenarioId: config.scenarioId,
                  module: 'daily_life',
                  startedAt: startedAt.toIso8601String(),
                  endedAt: endedAt.toIso8601String(),
                  durationMs: endedAt.difference(startedAt).inMilliseconds,
                  completed: true,
                  dragInteractions: [
                    DragInteraction(
                      interactionId: const Uuid().v4(),
                      objectId: targetId,
                      wasTarget: true,
                      wasSuccessful: true,
                      durationMs: endedAt.difference(startedAt).inMilliseconds,
                      straightnessScore: 0,
                      pathPoints: dragPath,
                    ),
                  ],
                );
                // Fire-and-forget: Firestore's offline cache handles retry.
                ref.read(sessionRepositoryProvider).writeSession(record);
              }
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
