
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;


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


  Future<Map<String, dynamic>?> fetchUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }

  Future<void> updateUserProfile({
    required Map<String, dynamic> updatedData,
    File? newPhotoFile,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No logged-in user found.");

   
    if (newPhotoFile != null) {
      final ref = _storage.ref().child('profile_photos/${user.uid}.jpg');
      await ref.putFile(newPhotoFile);
      final photoUrl = await ref.getDownloadURL();
      updatedData['photoUrl'] = photoUrl;
    }


    if (updatedData.containsKey('password') &&
        updatedData['password'] != null &&
        updatedData['password'].toString().isNotEmpty) {
      await user.updatePassword(updatedData['password']);
      updatedData.remove('password'); 
    }

    
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

 
    updatedData['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('users').doc(user.uid).update(updatedData);
  }


  Future<void> updateUserField(String field, dynamic value) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No logged-in user found.");
    await _firestore.collection('users').doc(user.uid).update({
      field: value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }


  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }


  User? get currentUser => _auth.currentUser;


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