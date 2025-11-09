// lib/services/auth_service.dart
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // -------------------- USER REGISTRATION --------------------
  /// ✅ Register new student user and save extra info in Firestore
  Future<User?> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String course,
    required String year,
  }) async {
    try {
      // Create auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw Exception("User registration failed.");

      // Save basic profile info in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'name': name,
        'course': course,
        'year': year,
        'contact': '',
        'linkedin': '',
        'github': '',
        'photoUrl': '',
        'role': 'student', // default role
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseError(e));
    } catch (e) {
      throw Exception("Registration error: $e");
    }
  }

  // -------------------- USER LOGIN --------------------
  /// 🟡 Login with email & password
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

  // -------------------- FETCH USER DATA --------------------
  /// 🟣 Get current user data from Firestore
  Future<Map<String, dynamic>?> fetchUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }

  // -------------------- UPDATE PROFILE --------------------
  /// ✅ Update user profile (Firestore + optional photo + optional password)
  Future<void> updateUserProfile({
    required Map<String, dynamic> updatedData,
    File? newPhotoFile,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No logged-in user found.");

    // Upload profile photo if provided
    if (newPhotoFile != null) {
      final ref = _storage.ref().child('profile_photos/${user.uid}.jpg');
      await ref.putFile(newPhotoFile);
      final photoUrl = await ref.getDownloadURL();
      updatedData['photoUrl'] = photoUrl;
    }

    // Update password if provided
    if (updatedData.containsKey('password') &&
        updatedData['password'] != null &&
        updatedData['password'].toString().isNotEmpty) {
      await user.updatePassword(updatedData['password']);
      updatedData.remove('password'); // don’t store in Firestore
    }

    // Update Firestore fields
    updatedData['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('users').doc(user.uid).update(updatedData);
  }

  // -------------------- UPDATE USER FIELD (Utility) --------------------
  /// ✳️ Update specific Firestore fields (e.g., LinkedIn or contact)
  Future<void> updateUserField(String field, dynamic value) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No logged-in user found.");
    await _firestore.collection('users').doc(user.uid).update({
      field: value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // -------------------- LOGOUT --------------------
  /// 🚪 Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }

  // -------------------- REFRESH USER --------------------
  /// 🔁 Reload Firebase User instance
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // -------------------- UTILITY --------------------
  User? get currentUser => _auth.currentUser;

  // -------------------- FIREBASE ERROR HANDLER --------------------
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