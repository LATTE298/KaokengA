import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';

final authServiceProvider = Provider<ParentAuthService>((ref) {
  return AuthService(FirebaseAuth.instance, FirebaseFirestore.instance);
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

final uidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).asData?.value?.uid;
});

final parentAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return user != null && !user.isAnonymous;
});

final currentUserProvider = Provider<User>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user ?? (throw const ParentAuthRequiredException()),
    loading: () => throw const ParentAuthLoadingException(),
    error: (error, _) => throw error,
  );
});

final parentAuthControllerProvider =
    AsyncNotifierProvider<ParentAuthController, void>(ParentAuthController.new);

class ParentAuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authServiceProvider)
          .createParentAccount(email: email, password: password);
    });
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authServiceProvider)
          .signInParent(email: email, password: password);
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).signOutParent(),
    );
  }
}

class ParentAuthRequiredException implements Exception {
  const ParentAuthRequiredException();
}

class ParentAuthLoadingException implements Exception {
  const ParentAuthLoadingException();
}
