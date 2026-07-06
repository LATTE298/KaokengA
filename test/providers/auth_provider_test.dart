import 'package:daily_life/providers/auth_provider.dart';
import 'package:daily_life/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ParentAuthController', () {
    test('register delegates to auth service', () async {
      final auth = _FakeParentAuthService();
      final container = ProviderContainer(
        overrides: [authServiceProvider.overrideWithValue(auth)],
      );
      addTearDown(container.dispose);

      await container
          .read(parentAuthControllerProvider.notifier)
          .register(email: 'parent@example.com', password: 'password1');

      expect(auth.registers.single, ('parent@example.com', 'password1'));
      expect(container.read(parentAuthControllerProvider).hasError, isFalse);
    });

    test('login exposes Firebase auth errors', () async {
      final auth =
          _FakeParentAuthService()
            ..loginError = FirebaseAuthException(code: 'wrong-password');
      final container = ProviderContainer(
        overrides: [authServiceProvider.overrideWithValue(auth)],
      );
      addTearDown(container.dispose);

      await container
          .read(parentAuthControllerProvider.notifier)
          .login(email: 'parent@example.com', password: 'password1');

      expect(container.read(parentAuthControllerProvider).hasError, isTrue);
      expect(
        parentAuthErrorMessage(
          container.read(parentAuthControllerProvider).error!,
        ),
        'รหัสผ่านไม่ถูกต้อง',
      );
    });

    test('logout delegates to auth service', () async {
      final auth = _FakeParentAuthService();
      final container = ProviderContainer(
        overrides: [authServiceProvider.overrideWithValue(auth)],
      );
      addTearDown(container.dispose);

      await container.read(parentAuthControllerProvider.notifier).logout();

      expect(auth.logoutCount, 1);
    });

    test('signInWithGoogle delegates to auth service', () async {
      final auth = _FakeParentAuthService();
      final container = ProviderContainer(
        overrides: [authServiceProvider.overrideWithValue(auth)],
      );
      addTearDown(container.dispose);

      await container
          .read(parentAuthControllerProvider.notifier)
          .signInWithGoogle();

      expect(auth.googleCount, 1);
    });

    test('sendPasswordReset delegates to auth service', () async {
      final auth = _FakeParentAuthService();
      final container = ProviderContainer(
        overrides: [authServiceProvider.overrideWithValue(auth)],
      );
      addTearDown(container.dispose);

      await container
          .read(parentAuthControllerProvider.notifier)
          .sendPasswordReset('parent@example.com');

      expect(auth.resets.single, 'parent@example.com');
    });

    test('deleteAccount delegates to auth service', () async {
      final auth = _FakeParentAuthService();
      final container = ProviderContainer(
        overrides: [authServiceProvider.overrideWithValue(auth)],
      );
      addTearDown(container.dispose);

      await container
          .read(parentAuthControllerProvider.notifier)
          .deleteAccount();

      expect(auth.deleteCount, 1);
    });

    test('deleteAccount rethrows service errors (e.g. recent-login)', () async {
      final auth =
          _FakeParentAuthService()
            ..deleteError = FirebaseAuthException(
              code: 'requires-recent-login',
            );
      final container = ProviderContainer(
        overrides: [authServiceProvider.overrideWithValue(auth)],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(parentAuthControllerProvider.notifier).deleteAccount(),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });
}

class _FakeParentAuthService implements ParentAuthService {
  final registers = <(String email, String password)>[];
  final logins = <(String email, String password)>[];
  final resets = <String>[];
  Object? loginError;
  Object? deleteError;
  Object? googleError;
  var logoutCount = 0;
  var deleteCount = 0;
  var googleCount = 0;

  @override
  String? get currentUid => 'uid-1';

  @override
  Stream<User?> authStateChanges() => Stream.value(null);

  @override
  Future<void> createParentAccount({
    required String email,
    required String password,
  }) async {
    registers.add((email, password));
  }

  @override
  Future<void> signInParent({
    required String email,
    required String password,
  }) async {
    logins.add((email, password));
    final error = loginError;
    if (error != null) throw error;
  }

  @override
  Future<User> ensureAnonymousChildSession() {
    throw UnimplementedError();
  }

  @override
  Future<User> signInAnonymouslyIfNeeded() {
    throw UnimplementedError();
  }

  @override
  Future<void> signOutParent() async {
    logoutCount++;
  }

  @override
  Future<void> signInWithGoogle() async {
    googleCount++;
    final error = googleError;
    if (error != null) throw error;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    resets.add(email);
  }

  @override
  Future<void> deleteAccountAndData() async {
    deleteCount++;
    final error = deleteError;
    if (error != null) throw error;
  }
}
