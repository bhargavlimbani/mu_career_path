import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// ✅ Register new user with extra info (name, course, year)
  Future<User?> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String course,
    required String year,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
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
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'student',
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseError(e));
    }
  }

  /// 🟡 Login user
  Future<User?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleFirebaseError(e));
    }
  }

  /// 🟣 Fetch user data from Firestore
  Future<Map<String, dynamic>?> fetchUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }

  /// ✅ Update user profile (Firestore + optional password + optional photo)
  Future<void> updateUserProfile({
    required Map<String, dynamic> updatedData,
    File? photoFile,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in.");

    String? photoUrl;

    // Upload new profile photo if provided
    if (photoFile != null) {
      final ref = _storage.ref().child('profile_images/${user.uid}.jpg');
      await ref.putFile(photoFile);
      photoUrl = await ref.getDownloadURL();
      updatedData['photoUrl'] = photoUrl;
    }

    // Update password if provided
    if (updatedData.containsKey('password') &&
        updatedData['password'] != null &&
        updatedData['password'].toString().isNotEmpty) {
      await user.updatePassword(updatedData['password']);
      updatedData.remove('password'); // prevent storing in Firestore
    }

    // Save data to Firestore
    await _firestore.collection('users').doc(user.uid).update(updatedData);
  }

  /// 🔁 Refresh Firebase user instance
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  /// 🚪 Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// 🧾 Get current Firebase user
  User? get currentUser => _auth.currentUser;

  /// ⚙️ Handle Firebase Auth errors
  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'requires-recent-login':
        return 'Please log in again to update your password.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
