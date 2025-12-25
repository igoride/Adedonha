import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static Future<User> signInAnonymously() async {
    final result = await _auth.signInAnonymously();
    return result.user!;
  }

  static User get currentUser => _auth.currentUser!;
}
