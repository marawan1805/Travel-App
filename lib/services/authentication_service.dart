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

  Future<User> getUser(String userId) async {
    try {
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      print(userDoc.data());
      if (userDoc.exists) {
        return User(
            id: userId,
            email: userDoc['email'],
            displayName: userDoc['displayName'],
            imageURL: userDoc['imageURL']);
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      throw Exception('Failed to get user profile');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String> signIn(
      {required String emailOrPass, required String password}) async {
    try {
      if (emailOrPass.contains('@')) {
        await _firebaseAuth.signInWithEmailAndPassword(
            email: emailOrPass, password: password);
        return "Signed in";
      } else {
        //check if display name exists, and if it does, get the email, and sign in with email and password
        final QuerySnapshot result = await _firestore
            .collection('userDisplayNames')
            .where('displayName', isEqualTo: emailOrPass)
            .get();
        if (result.docs.isEmpty) {
          return 'Display name does not exist';
        }
        final String email = result.docs.first['email'];
        await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);
        return "Signed in";
      }
    } on auth.FirebaseAuthException catch (e) {
      return e.message!;
    }
  }

  Future<bool> isDisplayNameUnique(String displayName) async {
    final QuerySnapshot result = await _firestore
        .collection('userDisplayNames')
        .where('displayName', isEqualTo: displayName)
        .get();

    return result.docs.isEmpty;
  }

  Future<void> addDisplayName(String displayName, String email) async {
    await _firestore.collection('userDisplayNames').add({
      'displayName': displayName,
      'email': email,
    });
  }

  Future<String> signUp(
      {required String email,
      required String password,
      required String displayName}) async {
    try {
      if (!(await isDisplayNameUnique(displayName))) {
        return 'Display Name is not unique';
      }
      if (displayName.contains('@')) {
        return 'Display Name cannot contain @';
      }

      final auth.UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create user profile
      await _updateUserProfile(userCredential.user!, displayName);

      // Add display name to the list
      await addDisplayName(displayName, email);

      // Save user to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'displayName': displayName,
        'imageURL':
            'https://kingstonplaza.com/wp-content/uploads/2015/07/generic-avatar.png', //default image URL
      });

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
              imageURL: userDoc['imageURL']);
        } else {
          return User(
            id: currentUser.uid,
            email: currentUser.email!,
            displayName: currentUser.displayName!,
            imageURL:
                'https://kingstonplaza.com/wp-content/uploads/2015/07/generic-avatar.png',
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
