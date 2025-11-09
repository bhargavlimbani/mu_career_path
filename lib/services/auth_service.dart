// lib/services/auth_service.dart
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // --------------------------------------------------------------------------
  // 🟢 REGISTER NEW STUDENT
  // --------------------------------------------------------------------------
  Future<User?> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String course,
    required String year,
  }) async {
    try {
      // Create account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw Exception("User registration failed.");

      // Default structure for Firestore user document
      final userData = {
        'uid': user.uid,
        'email': email.trim(),
        'name': name.trim(),
        'photoUrl': '',
        'contact': '',
        'course': course.trim(),
        'year': year.trim(),
        'cgpa': '',
        'careerGoal': '',
        'skills': <String>[],
        'linkedin': '',
        'github': '',
        'resumeLink': '',
        'portfolioLink': '',
        'achievements': <String>[],
        'languagesKnown': <String>[],
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(user.uid).set(userData);
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseError(e));
    } catch (e) {
      throw Exception("Registration error: $e");
    }
  }

  // --------------------------------------------------------------------------
  // 🟡 LOGIN USER
  // --------------------------------------------------------------------------
  Future<User?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseError(e));
    } catch (e) {
      throw Exception("Login error: $e");
    }
  }

  // --------------------------------------------------------------------------
  // 🟣 FETCH CURRENT USER DATA
  // --------------------------------------------------------------------------
  Future<Map<String, dynamic>?> fetchUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }

  // --------------------------------------------------------------------------
  // 🔵 UPDATE PROFILE (All Fields)
  // --------------------------------------------------------------------------
  Future<void> updateUserProfile({
    required Map<String, dynamic> updatedData,
    File? newPhotoFile,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No logged-in user found.");

    // Upload new profile photo if provided
    if (newPhotoFile != null) {
      final ref = _storage.ref().child('profile_photos/${user.uid}.jpg');
      await ref.putFile(newPhotoFile);
      final photoUrl = await ref.getDownloadURL();
      updatedData['photoUrl'] = photoUrl;
    }

    // Update password (if provided)
    if (updatedData.containsKey('password') &&
        updatedData['password'] != null &&
        updatedData['password'].toString().isNotEmpty) {
      await user.updatePassword(updatedData['password']);
      updatedData.remove('password'); // don't store in Firestore
    }

    // Ensure lists are stored correctly
    if (updatedData['skills'] is String) {
      updatedData['skills'] =
          updatedData['skills'].split(',').map((e) => e.trim()).toList();
    }
    if (updatedData['achievements'] is String) {
      updatedData['achievements'] =
          updatedData['achievements'].split(',').map((e) => e.trim()).toList();
    }
    if (updatedData['languagesKnown'] is String) {
      updatedData['languagesKnown'] =
          updatedData['languagesKnown'].split(',').map((e) => e.trim()).toList();
    }

    // Update Firestore
    updatedData['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('users').doc(user.uid).update(updatedData);
  }

  // --------------------------------------------------------------------------
  // ✳️ UPDATE SINGLE FIELD (Utility)
  // --------------------------------------------------------------------------
  Future<void> updateUserField(String field, dynamic value) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No logged-in user found.");
    await _firestore.collection('users').doc(user.uid).update({
      field: value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // --------------------------------------------------------------------------
  // 🚪 LOGOUT
  // --------------------------------------------------------------------------
  Future<void> logout() async {
    await _auth.signOut();
  }

  // --------------------------------------------------------------------------
  // 🔁 RELOAD USER INSTANCE
  // --------------------------------------------------------------------------
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // --------------------------------------------------------------------------
  // 🟤 GET CURRENT USER
  // --------------------------------------------------------------------------
  User? get currentUser => _auth.currentUser;

  // --------------------------------------------------------------------------
  // ⚙️ HANDLE FIREBASE ERRORS
  // --------------------------------------------------------------------------
  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'requires-recent-login':
        return 'Please log in again to update your password.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }
}