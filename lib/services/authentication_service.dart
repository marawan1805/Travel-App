import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthenticationService {
  final auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthenticationService(this._firebaseAuth, this._firestore);

  Stream<auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> updateUserImage(String userId, String imageURL) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .set({'imageURL': imageURL}, SetOptions(merge: true));
  }

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

  Future<String> signIn(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return "Signed in";
    } on auth.FirebaseAuthException catch (e) {
      return e.message!;
    }
  }

  Future<String> signUp(
      {required String email,
      required String password,
      required String displayName}) async {
    try {
      final auth.UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

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

  Future<User> getCurrentUser() async {
    final auth.User? currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      try {
        final DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();

        if (userDoc.exists) {
          return User(
            id: currentUser.uid,
            email: currentUser.email!,
            displayName: currentUser.displayName!,
            imageURL: userDoc['imageURL']
          );
        } else {
          return User(
            id: currentUser.uid,
            email: currentUser.email!,
            displayName: currentUser.displayName!,
            imageURL: 'https://kingstonplaza.com/wp-content/uploads/2015/07/generic-avatar.png',
          );
        }
      } catch (e) {
        throw Exception('Failed to get user profile');
      }
    } else {
      throw Exception('No user is currently signed in');
    }
  }
}
