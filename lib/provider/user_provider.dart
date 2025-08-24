import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hackathonpro/models/user_model.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Create user doc at Usercredential/{uid} after sign up
  Future<void> createUserDoc({
    required String uid,
    required String firstname,
    required String lastname,
    required String email,
    String token = '80', // Keep as string
    String rating = '0.0', // Keep as string
    String education = '',
    String stream = '',
    String info = '',
    int totalprojects = 0,
    int completedprojects = 0,
    List<String> skills = const [],
  }) async {
    try {
      final data = {
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'token': token, // String
        'rating': rating, // String
        'education': education,
        'stream': stream,
        'info': info,
        'totalprojects': totalprojects,
        'completedprojects': completedprojects,
        'skills': skills,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('Usercredential').doc(uid).set(data);
      await fetchUser(uid);
    } catch (e) {
      debugPrint('Error creating user doc: $e');
      throw Exception('Failed to create user profile: $e');
    }
  }

  // Fetch user doc
  Future<void> fetchUser(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      DocumentSnapshot snapshot = await _firestore
          .collection('Usercredential')
          .doc(uid)
          .get();

      if (snapshot.exists) {
        _user = UserModel.fromMap(
          snapshot.data() as Map<String, dynamic>,
          snapshot,
        );
      } else {
        debugPrint('User document not found for uid: $uid');
      }
    } catch (e) {
      debugPrint("Error fetching user: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to get token as int
  int getTokenAsInt() {
    if (_user?.token == null) return 0;
    return int.tryParse(_user!.token) ?? 0;
  }

  // Helper method to get rating as double
  double getRatingAsDouble() {
    if (_user?.rating == null) return 0.0;
    return double.tryParse(_user!.rating) ?? 0.0;
  }

  // Update tokens (for project completion)
  Future<void> updateTokens(int tokenAmount) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      // Get current token value and add the new amount
      int currentTokens = getTokenAsInt();
      int newTokenAmount = currentTokens + tokenAmount;

      // Get current total earnings

      await _firestore.collection('Usercredential').doc(uid).update({
        'token': newTokenAmount.toString(), // Convert back to string
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await fetchUser(uid);
    } catch (e) {
      debugPrint('Error updating tokens: $e');
      throw Exception('Failed to update tokens: $e');
    }
  }

  // Update project counts (when completing projects)
  Future<void> incrementCompletedProjects() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('Usercredential').doc(uid).update({
        'completedprojects': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await fetchUser(uid);
    } catch (e) {
      debugPrint('Error updating completed projects: $e');
      throw Exception('Failed to update completed projects: $e');
    }
  }

  // Update project counts (when posting new projects)
  Future<void> incrementTotalProjects() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('Usercredential').doc(uid).update({
        'totalprojects': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await fetchUser(uid);
    } catch (e) {
      debugPrint('Error updating total projects: $e');
      throw Exception('Failed to update total projects: $e');
    }
  }

  // Update user rating based on success rate
  Future<void> updateRating() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || _user == null) return;

    try {
      final completedProjects = _user!.completedprojects;
      final totalProjects = _user!.totalprojects;

      // Calculate new rating based on success rate
      double successRate = totalProjects > 0
          ? (completedProjects / totalProjects)
          : 0;
      double newRating = 3.0 + (successRate * 2.0); // Base 3.0, up to 5.0

      // Ensure rating is between 0 and 5
      newRating = newRating.clamp(0.0, 5.0);

      await _firestore.collection('Usercredential').doc(uid).update({
        'rating': newRating.toStringAsFixed(
          1,
        ), // Convert to string with 1 decimal
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await fetchUser(uid);
    } catch (e) {
      debugPrint('Error updating rating: $e');
      throw Exception('Failed to update rating: $e');
    }
  }

  // Update user profile information
  Future<void> updateProfile({
    String? firstname,
    String? lastname,
    String? education,
    String? stream,
    String? info,
    List<String>? skills,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      Map<String, dynamic> updateData = {
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      if (firstname != null) updateData['firstname'] = firstname;
      if (lastname != null) updateData['lastname'] = lastname;
      if (education != null) updateData['education'] = education;
      if (stream != null) updateData['stream'] = stream;
      if (info != null) updateData['info'] = info;
      if (skills != null) updateData['skills'] = skills;

      await _firestore.collection('Usercredential').doc(uid).update(updateData);
      await fetchUser(uid);
    } catch (e) {
      debugPrint('Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  // Complete project and update all related stats
  Future<void> completeProject(int tokensEarned) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      // Get current values
      int currentTokens = getTokenAsInt();

      // Calculate new values
      int newTokens = currentTokens + tokensEarned;

      await _firestore.collection('Usercredential').doc(uid).update({
        'token': newTokens.toString(), // Convert to string
        'completedprojects': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Update rating after completing project
      await fetchUser(uid);
      await updateRating();
    } catch (e) {
      debugPrint('Error completing project: $e');
      throw Exception('Failed to complete project: $e');
    }
  }

  // Get user's success rate as percentage
  double getSuccessRate() {
    if (_user == null || _user!.totalprojects == 0) return 0.0;
    return (_user!.completedprojects / _user!.totalprojects) * 100;
  }

  // Check if user has enough tokens for bidding
  bool hasEnoughTokens(int requiredTokens) {
    return getTokenAsInt() >= requiredTokens;
  }

  // Deduct tokens (for posting projects or other features)
  Future<void> deductTokens(int amount) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || _user == null) return;

    int currentTokens = getTokenAsInt();
    if (currentTokens < amount) {
      throw Exception('Insufficient tokens');
    }

    try {
      int newTokenAmount = currentTokens - amount;

      await _firestore.collection('Usercredential').doc(uid).update({
        'token': newTokenAmount.toString(), // Convert back to string
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await fetchUser(uid);
    } catch (e) {
      debugPrint('Error deducting tokens: $e');
      throw Exception('Failed to deduct tokens: $e');
    }
  }

  // Clear user data (for logout)
  void clearUser() {
    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  // Real-time user data listener
  Stream<DocumentSnapshot> getUserStream(String uid) {
    return _firestore.collection('Usercredential').doc(uid).snapshots();
  }
}
