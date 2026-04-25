# 13 — State Management (Riverpod)

> **Version:** 0.1-MVP | **Status:** Planning
> All app state is owned by a Riverpod provider. No setState except inside Flame components.
> Every provider listed here has exactly one responsibility.

---

## Provider Graph

```
authStateProvider
  └── currentUserProvider
        └── scenarioSettingsProvider    (reads uid)
        └── activityLogProvider         (reads uid)

scenarioListProvider                    (reads Firestore content collection)
  └── enabledScenariosProvider          (filters by scenarioSettingsProvider)

activeTtsProvider                       (singleton service)
activeSessionProvider                   (ephemeral; reset per game)
```

---

## Auth Providers

```dart
// Emits: AsyncValue<User?>
// Source: Firebase Auth stream
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Emits: User | throws if unauthenticated
// Usage: parent dashboard reads this; throws redirect to AuthScreen
final currentUserProvider = Provider<User>((ref) {
  final auth = ref.watch(authStateProvider);
  return auth.when(
    data: (user) => user ?? (throw const Unauthenticated()),
    loading: () => throw const Loading(),
    error: (e, _) => throw e,
  );
});
```

---

## Scenario Providers

```dart
// Emits: AsyncValue<List<ScenarioSummary>>
// Source: Firestore /content/scenarios where published == true
final scenarioListProvider = StreamProvider<List<ScenarioSummary>>((ref) {
  return FirestoreService.scenariosStream();
});

// Emits: AsyncValue<Map<String, bool>>
// Source: Firestore /scenario_settings/{uid}/overrides
// Key: scenario_id, Value: enabled
final scenarioSettingsProvider = StreamProvider<Map<String, bool>>((ref) {
  final user = ref.watch(currentUserProvider);
  return FirestoreService.scenarioSettingsStream(user.uid);
});

// Emits: AsyncValue<List<ScenarioSummary>>
// Derived: scenarioList filtered by settings (default: all enabled)
final enabledScenariosProvider = Provider<AsyncValue<List<ScenarioSummary>>>((ref) {
  final scenarios = ref.watch(scenarioListProvider);
  final settings = ref.watch(scenarioSettingsProvider);
  return scenarios.whenData((list) {
    final overrides = settings.valueOrNull ?? {};
    return list.where((s) => overrides[s.scenarioId] != false).toList();
  });
});

// Notifier: parent dashboard writes enable/disable
// Writes to Firestore with optimistic UI
final scenarioToggleProvider = AsyncNotifierProvider
    .family<ScenarioToggleNotifier, void, String>(
  ScenarioToggleNotifier.new,
);
```

---

## Content Providers

```dart
// Emits: AsyncValue<ScenarioConfig>
// Source: HTTP fetch + local cache (flutter_cache_manager)
// Parameterised by scenario_id
final scenarioConfigProvider = FutureProvider.family<ScenarioConfig, String>(
  (ref, scenarioId) async {
    final summary = await ref.watch(
      scenarioListProvider.selectAsync(
        (list) => list.firstWhere((s) => s.scenarioId == scenarioId),
      ),
    );
    return ScenarioRepository.fetchConfig(summary.configUrl);
  },
);

// Emits: AsyncValue<List<VocabularyItem>>
// Loaded once at Module C entry, cached
final vocabularyProvider = FutureProvider<List<VocabularyItem>>((ref) {
  return ContentRepository.fetchVocabulary();
});

// Emits: AsyncValue<MemoryPack>
// MVP: single pack; family by pack_id post-MVP
final memoryPackProvider = FutureProvider<MemoryPack>((ref) {
  return ContentRepository.fetchDefaultMemoryPack();
});
```

---

## Session Providers (Ephemeral)

```dart
// Active game session — reset on every game start
// Tracks: start time, drag interactions, completion
@riverpod
class ActiveSession extends _$ActiveSession {
  @override
  SessionState build() => SessionState.empty();

  void startSession(String scenarioId) {
    state = SessionState(
      scenarioId: scenarioId,
      startedAt: DateTime.now(),
      interactions: [],
      completed: false,
    );
  }

  void recordInteraction(DragInteraction interaction) {
    state = state.copyWith(
      interactions: [...state.interactions, interaction],
    );
  }

  void completeSession() {
    state = state.copyWith(
      completed: true,
      endedAt: DateTime.now(),
    );
    // Side effect: write to Firestore
    ref.read(sessionLoggerProvider).log(state);
  }
}
```

---

## TTS Provider

```dart
// Singleton service wrapper — never recreated
final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(service.dispose);
  return service;
});

// Usage:
// ref.read(ttsServiceProvider).speak(text);
// ref.read(ttsServiceProvider).cancel();
```

---

## Activity Log Provider (Parent Dashboard)

```dart
// Emits: AsyncValue<List<SessionRecord>>
// Source: Firestore /sessions/{uid}/records, newest first, page 20
final activityLogProvider = StreamProvider<List<SessionRecord>>((ref) {
  final user = ref.watch(currentUserProvider);
  return FirestoreService.sessionsStream(user.uid, limit: 20);
});

// Notifier for pagination
@riverpod
class ActivityLogPagination extends _$ActivityLogPagination {
  @override
  int build() => 20;  // current limit

  void loadMore() => state += 20;
}
```

---

## Rules for Every Provider

1. **One responsibility.** If a provider does two things, split it.
2. **No side effects in build().** Side effects (write to Firestore, play TTS) go in Notifier methods.
3. **AsyncValue everywhere** for any remote data. Never cast to `.value` without handling loading and error.
4. **family providers** for parameterised data. Never pass params via global variables.
5. **ref.watch vs ref.read:** `watch` inside build (reactive), `read` inside event handlers (one-shot).
6. **No provider depends on another via ref.read inside build.** Use `ref.watch` for reactive dependencies.

---

## Error Handling

```dart
// All AsyncValue consumers use this pattern:
scenarioListProvider.when(
  loading: () => const ShimmerLoader(),
  error:   (e, _) => ErrorCard(message: e.toThaiMessage()),
  data:    (list) => ScenarioGrid(scenarios: list),
);

// Extension for user-facing Thai error messages:
extension AppErrorX on Object {
  String toThaiMessage() => switch (this) {
    FirebaseException(:final code) when code == 'permission-denied' =>
      'ไม่มีสิทธิ์เข้าถึงข้อมูล',
    FirebaseException(:final code) when code == 'unavailable' =>
      'ไม่มีการเชื่อมต่ออินเทอร์เน็ต',
    _ => 'เกิดข้อผิดพลาด กรุณาลองใหม่',
  };
}
```
