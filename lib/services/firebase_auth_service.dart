import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('This email is already in use. Please try another email.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is invalid.');
      } else if (e.code == 'weak-password') {
        throw Exception('The password is too weak. Please use a stronger password.');
      } else {
        throw Exception('Registration failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error occurred: ${e.toString()}');
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.verifyBeforeUpdateEmail(newEmail);
        await user.reload(); // Reload to sync changes
      } else {
        throw Exception("No user is currently signed in.");
      }
    } catch (e) {
      throw Exception("Error updating email: $e");
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      } else {
        throw Exception("No user is currently signed in.");
      }
    } catch (e) {
      throw Exception("Error updating password: $e");
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
