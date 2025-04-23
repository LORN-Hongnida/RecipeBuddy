// auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<String?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // Sign up successful, return null for no error
    } on FirebaseAuthException catch (e) {
      print('Firebase Sign Up Error: ${e.code}');
      return e.code; // Return the Firebase error code
    } catch (e) {
      print('Sign Up Error: $e');
      return 'sign-up-failed'; // Generic error code for other exceptions
    }
  }

  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // Sign in successful, return null for no error
    } on FirebaseAuthException catch (e) {
      print('Firebase Sign In Error: ${e.code}');
      return e.code; // Return the Firebase error code
    } catch (e) {
      print('Sign In Error: $e');
      return 'sign-in-failed'; // Generic error code for other exceptions
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('User signed out');
    } catch (e) {
      print('Sign Out Error: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      print('Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      print('Firebase Password Reset Error: $e');
      // Handle specific errors
    } catch (e) {
      print('Password Reset Error: $e');
    }
  }
}