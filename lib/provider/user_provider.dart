// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hackathonpro/models/user_model.dart';

// class UserProvider with ChangeNotifier {
//   UserModel? _user;
//   UserModel? get user => _user;
//   Future<void> fetchUser() async {
//     try {
//       DocumentSnapshot snapshot = await FirebaseFirestore.instance
//           .collection('Usercredential')
//           .doc('XSW1yblCKtU4JvSIm3GL') // your doc ID
//           .get();

//       if (snapshot.exists) {
//         _user = UserModel.fromMap(
//           snapshot.data() as Map<String, dynamic>,
//           snapshot,
//         );
//         notifyListeners();
//       }
//     } catch (e) {
//       debugPrint("Error fetching user: $e");
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hackathonpro/models/user_model.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  UserModel? get user => _user;

  // Create user doc at Usercredential/{uid} after sign up
  Future<void> createUserDoc({
    required String uid,
    required String firstname,
    required String lastname,
    required String email,
    String token = '0',
    String rating = '0',
    String education = '',
    String stream = '',
    String info = '',
    int totalprojects = 0,
    int completedprojects = 0,
    List<String> skills = const [],
  }) async {
    final data = {
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'token': token,
      'rating': rating,
      'education': education,
      'stream': stream,
      'info': info,
      'totalprojects': totalprojects,
      'completedprojects': completedprojects,
      'skills': skills,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('Usercredential').doc(uid).set(data);
    // Optionally load it into provider
    await fetchUser(uid);
  }

  // Fetch user doc; if uid is null, uses currently signed in user
  // Future<void> fetchUser({String? uid}) async {
  //   try {
  //     final userId = uid ?? _auth.currentUser?.uid;
  //     if (userId == null) {
  //       debugPrint('No authenticated user to fetch.');
  //       return;
  //     }

  //     final snap = await _firestore
  //         .collection('Usercredential')
  //         .doc(userId)
  //         .get();

  //     if (snap.exists) {
  //       _user = UserModel.fromMap(snap.data() as Map<String, dynamic>, snap);
  //       notifyListeners();
  //     } else {
  //       debugPrint('User doc not found for uid: $userId');
  //     }
  //   } catch (e) {
  //     debugPrint('Error fetching user: $e');
  //   }
  // }
  Future<void> fetchUser(String uid) async {
  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Usercredential')
        .doc(uid)
        .get();

    if (snapshot.exists) {
      _user = UserModel.fromMap(
        snapshot.data() as Map<String, dynamic>,
        snapshot,
      );
      notifyListeners();
    }
  } catch (e) {
    debugPrint("Error fetching user: $e");
  }
}

  // Example update function
  Future<void> updateTokens(String newToken) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('Usercredential').doc(uid).update({
      'token': newToken,
    });
    await fetchUser(uid);
  }
}
