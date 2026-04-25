import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ParentAuthService {
  String? get currentUid;

  Stream<User?> authStateChanges();

  Future<User> ensureAnonymousChildSession();

  Future<User> signInAnonymouslyIfNeeded();

  Future<void> createParentAccount({
    required String email,
    required String password,
  });

  Future<void> signInParent({required String email, required String password});

  Future<void> signOutParent();
}

// Child app runs as an anonymous Firebase user so session writes satisfy
// /sessions/{uid}/records rules. Parent email+password login will later link
// credentials to the same UID via User.linkWithCredential, preserving history.
class AuthService implements ParentAuthService {
  AuthService(this._auth, [this._firestore]);

  final FirebaseAuth _auth;
  final FirebaseFirestore? _firestore;

  @override
  String? get currentUid => _auth.currentUser?.uid;

  @override
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  @override
  Future<User> ensureAnonymousChildSession() => signInAnonymouslyIfNeeded();

  @override
  Future<User> signInAnonymouslyIfNeeded() async {
    final existing = _auth.currentUser;
    if (existing != null) return existing;
    final cred = await _auth.signInAnonymously();
    return cred.user!;
  }

  @override
  Future<User> createParentAccount({
    required String email,
    required String password,
  }) async {
    final credential = EmailAuthProvider.credential(
      email: email.trim(),
      password: password,
    );
    final currentUser = _auth.currentUser;
    final User user;
    if (currentUser != null && currentUser.isAnonymous) {
      final linked = await currentUser.linkWithCredential(credential);
      user = linked.user!;
    } else {
      final created = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      user = created.user!;
    }
    await _upsertUserDoc(user);
    return user;
  }

  @override
  Future<User> signInParent({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user!;
    await _upsertUserDoc(user, mergeCreatedAt: false);
    return user;
  }

  @override
  Future<void> signOutParent() {
    return _auth.signOut();
  }

  Future<void> _upsertUserDoc(User user, {bool mergeCreatedAt = true}) async {
    final firestore = _firestore;
    if (firestore == null) return;
    final data = <String, Object?>{
      'uid': user.uid,
      'email': user.email,
      'display_name': user.displayName,
    };
    if (mergeCreatedAt) {
      data['created_at'] = DateTime.now().toUtc().toIso8601String();
    }
    await firestore
        .collection('users')
        .doc(user.uid)
        .set(data, SetOptions(merge: true));
  }
}

String parentAuthErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'email-already-in-use' => 'อีเมลนี้มีบัญชีแล้ว กรุณาเข้าสู่ระบบ',
      'wrong-password' || 'invalid-credential' => 'รหัสผ่านไม่ถูกต้อง',
      'user-not-found' => 'ไม่พบบัญชีนี้ กรุณาสร้างบัญชีใหม่',
      'network-request-failed' => 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต',
      'weak-password' => 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร',
      'invalid-email' => 'รูปแบบอีเมลไม่ถูกต้อง',
      _ => 'เกิดข้อผิดพลาด กรุณาลองใหม่',
    };
  }
  return 'เกิดข้อผิดพลาด กรุณาลองใหม่';
}
