import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static Future<User> signInAnonymously() async {
    final result = await _auth.signInAnonymously();
    return result.user!;
  }

  static Future<User> signUpWithEmail(String email, String password) async {
    final currentUser = _auth.currentUser;
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    User user;

    if (currentUser != null && currentUser.isAnonymous) {
      final ressult = await currentUser.linkWithCredential(credential);
      user = ressult.user!;
    } else {
      final result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      user = result.user!;
    }

    await user.sendEmailVerification();
    return user;
  }

  static Future<User> signInWithEmail(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
    );
    final user = result.user!;
    await user.reload();

    if (!user.emailVerified) {
      throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Confirme seu email antes de entrar.'
      );
    }

    return user;
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  static Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  static Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;

  static bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  static User get currentUser => _auth.currentUser!;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

}
