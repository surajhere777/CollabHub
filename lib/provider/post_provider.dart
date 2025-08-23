import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> get posts => _posts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  PostProvider() {
    fetchPosts();
  }

  /// Fetch all posts and listen for real-time updates
  void fetchPosts() {
    _isLoading = true;
    notifyListeners();

    _firestore.collection('posts').snapshots().listen((snapshot) {
      _posts = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      _isLoading = false;
      notifyListeners();
    });
  }

  /// Add a new post
  Future<void> addPost(Map<String, dynamic> postData) async {
    await _firestore.collection('posts').add(postData);
  }

  /// Update an existing post
  Future<void> updatePost(String id, Map<String, dynamic> updatedData) async {
    await _firestore.collection('posts').doc(id).update(updatedData);
  }

  /// Delete a post
  Future<void> deletePost(String id) async {
    await _firestore.collection('posts').doc(id).delete();
  }
}
