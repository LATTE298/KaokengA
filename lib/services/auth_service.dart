import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  /// เข้าสู่ระบบด้วยบัญชี Google (ผูกกับ anonymous child ถ้ามีเพื่อเก็บประวัติ)
  Future<void> signInWithGoogle();

  /// ส่งอีเมลรีเซ็ตรหัสผ่าน (ปุ่ม "ลืมรหัสผ่าน")
  Future<void> sendPasswordReset(String email);

  Future<void> signOutParent();

  /// ลบข้อมูลทั้งหมดของผู้ใช้ปัจจุบัน (PDPA/สิทธิ์ในการลบ): Firestore ทุก collection
  /// ที่ผูกกับ uid + บัญชี Auth. uid ของเด็ก (anonymous) กับผู้ปกครองเป็นตัวเดียวกัน
  /// (link) จึงลบครบทั้งประวัติเด็กและบัญชีผู้ปกครองในครั้งเดียว
  Future<void> deleteAccountAndData();
}

// Child app runs as an anonymous Firebase user so session writes satisfy
// /sessions/{uid}/records rules. Parent email+password login will later link
// credentials to the same UID via User.linkWithCredential, preserving history.
class AuthService implements ParentAuthService {
  AuthService(this._auth, [this._firestore, GoogleSignIn? googleSignIn])
    : _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final FirebaseFirestore? _firestore;
  final GoogleSignIn _googleSignIn;

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
  Future<void> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // ผู้ใช้กดยกเลิกหน้าเลือกบัญชี — ไม่ใช่ error จริง แต่โยนเพื่อหยุด flow เงียบๆ
      throw FirebaseAuthException(
        code: 'sign-in-cancelled',
        message: 'ยกเลิกการเข้าสู่ระบบ',
      );
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final currentUser = _auth.currentUser;
    late final User user;
    // เด็กเล่นแบบ anonymous อยู่ → ผูก Google เข้ากับ uid เดิมเพื่อเก็บประวัติ
    if (currentUser != null && currentUser.isAnonymous) {
      try {
        final linked = await currentUser.linkWithCredential(credential);
        user = linked.user!;
      } on FirebaseAuthException catch (e) {
        // บัญชี Google นี้เคยสมัครไว้แล้ว → เข้าสู่ระบบด้วยบัญชีนั้นแทน
        if (e.code == 'credential-already-in-use' ||
            e.code == 'email-already-in-use') {
          final signedIn = await _auth.signInWithCredential(credential);
          user = signedIn.user!;
        } else {
          rethrow;
        }
      }
    } else {
      final signedIn = await _auth.signInWithCredential(credential);
      user = signedIn.user!;
    }
    await _upsertUserDoc(user);
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> signOutParent() async {
    // Firebase signOut สำคัญสุด — ทำก่อนและต้องไม่ถูกบล็อก. (เดิมเรียก Google ก่อน
    // แต่บนเว็บที่ล็อกอินด้วยอีเมล/รหัสผ่าน googleSignIn.signOut() โยน error ทำให้
    // _auth.signOut() ไม่ถูกเรียก → กลับมายังเป็นบัญชีเดิม)
    await _auth.signOut();
    // ออกจาก Google ด้วย (กันครั้งหน้าเด้งบัญชีเดิมตอนล็อกอิน Google บน Android)
    // best-effort: ไม่มี session Google หรือเว็บยังไม่ตั้ง clientId ก็ข้ามไป
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // เงียบไว้ — ผู้ใช้อาจล็อกอินด้วยอีเมล/รหัสผ่าน ไม่มี session Google ให้ออก
    }
  }

  @override
  Future<void> deleteAccountAndData() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final uid = user.uid;
    final firestore = _firestore;

    if (firestore != null) {
      // subcollection ไม่ถูกลบอัตโนมัติเมื่อลบ parent doc — ต้อง query + ลบเองเป็น batch
      await _deleteCollectionBatched(
        firestore.collection('sessions').doc(uid).collection('records'),
      );
      await _deleteCollectionBatched(
        firestore
            .collection('scenario_settings')
            .doc(uid)
            .collection('overrides'),
      );
      await firestore.collection('users').doc(uid).delete();
    }

    // ลบบัญชี Auth ท้ายสุด (ต้องเพิ่งล็อกอิน — ไม่งั้น requires-recent-login)
    await user.delete();
  }

  // ลบทุก doc ใน collection ทีละชุด (Firestore batch จำกัด 500 ต่อครั้ง)
  Future<void> _deleteCollectionBatched(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    final firestore = _firestore!;
    while (true) {
      final snapshot = await collection.limit(400).get();
      if (snapshot.docs.isEmpty) break;
      final batch = firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      if (snapshot.docs.length < 400) break;
    }
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
      'requires-recent-login' =>
        'เพื่อความปลอดภัย กรุณาออกจากระบบแล้วเข้าสู่ระบบใหม่ ก่อนลบบัญชี',
      'sign-in-cancelled' => 'ยกเลิกการเข้าสู่ระบบ',
      'account-exists-with-different-credential' =>
        'อีเมลนี้เคยสมัครด้วยวิธีอื่น กรุณาเข้าสู่ระบบด้วยอีเมล/รหัสผ่าน',
      'network-request-failed' => 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต',
      'weak-password' => 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร',
      'invalid-email' => 'รูปแบบอีเมลไม่ถูกต้อง',
      _ => 'เกิดข้อผิดพลาด กรุณาลองใหม่',
    };
  }
  return 'เกิดข้อผิดพลาด กรุณาลองใหม่';
}
