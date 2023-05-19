import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/user.dart';

class AuthenticationService {
  final auth.FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  Stream<auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return "Signed in";
    } on auth.FirebaseAuthException catch (e) {
      return e.message!;
    }
  }

  Future<String> signUp({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      return "Signed up";
    } on auth.FirebaseAuthException catch (e) {
      return e.message!;
    }
  }
}
