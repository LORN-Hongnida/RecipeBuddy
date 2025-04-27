import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math'; // for random username

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _realtimeDb = FirebaseDatabase.instance;

  User? get currentUser => _auth.currentUser;

  Future<String?> signUpWithEmailAndPassword(String name, String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Update display name
      await result.user?.updateDisplayName(name);

      // Create user in Realtime Database
      await _createUserInDatabase(result.user, fullName: name);

      return null;
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (e) {
      return 'sign-up-failed';
    }
  }

  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // After sign-in, check/create user data
      await _createUserInDatabase(result.user);

      return null;
    } on FirebaseAuthException catch (e) {
      print('Firebase Sign In Error: ${e.code}');
      return e.code;
    } catch (e) {
      print('Sign In Error: $e');
      return 'sign-in-failed';
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
    } catch (e) {
      print('Password Reset Error: $e');
    }
  }

  Future<void> _createUserInDatabase(User? user, {String? fullName}) async {
    if (user == null) return;

    final uid = user.uid;
    final email = user.email ?? "";
    final displayName = fullName ?? user.displayName ?? "New User"; // use fullName if given, otherwise user's displayName

    final userRef = _realtimeDb.ref('users/$uid');

    final snapshot = await userRef.get();
    if (!snapshot.exists) {
      final generatedUsername = _generateUsername();

      await userRef.set({
        'uid': uid,
        'email': email,
        'name': displayName,
        'username': generatedUsername,
        'bio': 'This is my bio!',
        'createdAt': DateTime.now().toIso8601String(),
      });

      print('✅ User created in Realtime Database');
    } else {
      print('ℹ️ User already exists in Realtime Database');
    }
  }

  String _generateUsername() {
    final random = Random();
    final randomNumber = random.nextInt(10000);
    return 'user$randomNumber';
  }
}
