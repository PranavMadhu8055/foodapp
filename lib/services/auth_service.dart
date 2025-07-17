import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodapp/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for FirebaseException

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password, {bool rememberMe = true}) async {
    try {
      // Set session persistence based on the "Remember Me" choice.
      // LOCAL: User stays signed in. SESSION: User is signed out on app close.
      await _auth.setPersistence(rememberMe ? Persistence.LOCAL : Persistence.SESSION);
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error (Sign In): ${e.message}');
      rethrow; // Re-throw the specific FirebaseAuthException
    } catch (e) {
      debugPrint('General Error (Sign In): $e');
      throw Exception('An unexpected error occurred during sign in.');
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(
      String name, String email, String password) async {
    User? user;
    try {
      UserCredential result =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
      user = result.user;

      if (user != null) {
        // Update the user's profile display name in Firebase Auth
        await user.updateDisplayName(name);
        // Create a new document for the user with the uid in Firestore
        await DatabaseService(uid: user.uid).createUserData(name, email);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error (Register): ${e.message}');
      rethrow;
    } on FirebaseException catch (e) {
      // This will catch Firestore-specific errors, like the connection issue.
      debugPrint('Firestore Error (Register): ${e.message}');
      // If user was created but Firestore failed, delete the user to allow re-registration.
      await user?.delete();
      throw Exception('Failed to save user profile. Please try again.');
    } catch (e) {
      debugPrint('General Error (Register): $e');
      throw Exception('An unexpected error occurred during registration.');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error (Password Reset): ${e.message}');
      rethrow; // Re-throw the specific FirebaseAuthException
    } catch (e) {
      debugPrint('General Error (Password Reset): $e');
      throw Exception('An unexpected error occurred during password reset.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      throw Exception('An error occurred during sign out.');
    }
  }

  // Get current user stream
  Stream<User?> get user {
    return _auth.authStateChanges();
  }
}