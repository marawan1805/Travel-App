import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/user.dart';

class AuthenticationService {
  final auth.FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  Stream<auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  String getCurrentUserId() {
    final auth.User? currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      return currentUser.uid;
    } else {
      throw Exception('No user is currently signed in');
    }
  }

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

  Future<String> signUp({required String email, required String password, required String displayName}) async {
    try {
      final auth.UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      
      // Create user profile
      await _updateUserProfile(userCredential.user!, displayName);
      
      return "Signed up";
    } on auth.FirebaseAuthException catch (e) {
      return e.message!;
    }
  }

  Future<void> _updateUserProfile(auth.User user, String displayName) async {
    await user.updateDisplayName(displayName);
    await user.reload();
  }

  Future<void> updateUserProfile(String displayName) async {
    final auth.User? currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      await _updateUserProfile(currentUser, displayName);
    } else {
      throw Exception('No user is currently signed in');
    }
  }

  User? getCurrentUser() {
    final auth.User? currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      return User(
        id: currentUser.uid,
        email: currentUser.email!,
        displayName: currentUser.displayName!,
      );
    } else {
      return null;
    }
  }
}