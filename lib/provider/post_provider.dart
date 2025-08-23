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
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? '', // ✅ fallback to empty string
          'description': data['description'] ?? '',
          'tokens': data['tokens'] ?? 0,
          'deadline': data['deadline'] ?? '',
          'skills': List<String>.from(data['skills'] ?? []),
          'bids': data['bids'] ?? 0,
          'category': data['category'] ?? '',
          'postedTime': data['postedTime'].toString(),
          'difficulty': data['difficulty'] ?? 'Beginner',
          'urgency': data['urgency'] ?? 'Normal',
          // 'ownerId': data['ownerId'] ?? '',
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

  Future<void> submitBid({
    required String projectId,
    required String bidderId,
    required String bidderName,
    required String bidderEmail,
    required int bidAmount,
    required String message,
  }) async {
    try {
      Map<String, dynamic> bidData = {
        'bidderId': bidderId,
        'bidderName': bidderName,
        'bidderEmail': bidderEmail,
        'bidAmount': bidAmount,
        'message': message,
        'submittedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      };

      // Add bid to subcollection
      await _firestore
          .collection('posts')
          .doc(projectId)
          .collection('bids')
          .add(bidData);

      // Update bid count
      await _firestore.collection('posts').doc(projectId).update({
        'bids': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to submit bid: $e');
    }
  }

  /// Get all bids for a specific project
  Stream<QuerySnapshot> getBidsForProject(String projectId) {
    return _firestore
        .collection('posts')
        .doc(projectId)
        .collection('bids')
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  /// Accept a bid
  Future<void> acceptBid(String projectId, String bidId) async {
    try {
      await _firestore
          .collection('posts')
          .doc(projectId)
          .collection('bids')
          .doc(bidId)
          .update({'status': 'accepted'});

      // Optionally update project status
      await _firestore.collection('posts').doc(projectId).update({
        'status': 'assigned',
      });
    } catch (e) {
      throw Exception('Failed to accept bid: $e');
    }
  }

  /// Reject a bid
  Future<void> rejectBid(String projectId, String bidId) async {
    try {
      await _firestore
          .collection('posts')
          .doc(projectId)
          .collection('bids')
          .doc(bidId)
          .update({'status': 'rejected'});
    } catch (e) {
      throw Exception('Failed to reject bid: $e');
    }
  }
}
