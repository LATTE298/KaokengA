import 'package:firebase_auth/firebase_auth.dart';

// Child app runs as an anonymous Firebase user so session writes satisfy
// /sessions/{uid}/records rules. Parent email+password login will later link
// credentials to the same UID via User.linkWithCredential, preserving history.
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  String? get currentUid => _auth.currentUser?.uid;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<User> signInAnonymouslyIfNeeded() async {
    final existing = _auth.currentUser;
    if (existing != null) return existing;
    final cred = await _auth.signInAnonymously();
    return cred.user!;
  }
}
