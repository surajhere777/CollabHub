import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> get posts => _posts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _currentUserId;
  Set<String> _biddedProjects = {}; // Track projects user has bid on
  Set<String> get biddedProjects => _biddedProjects;

  PostProvider() {
    _initializeCurrentUser();
  }

  /// Initialize current user and fetch posts
  void _initializeCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      _fetchUserBids(); // Fetch user's bids first
      fetchPosts();
    }
  }

  /// Update current user ID and refetch posts
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    _fetchUserBids(); // Fetch user's bids first
    fetchPosts();
  }

  /// Fetch all projects the current user has bid on
  Future<void> _fetchUserBids() async {
    if (_currentUserId == null) return;

    try {
      // Get all posts
      QuerySnapshot postsSnapshot = await _firestore.collection('posts').get();

      Set<String> biddedProjectIds = {};

      // Check each post for user's bids
      for (QueryDocumentSnapshot postDoc in postsSnapshot.docs) {
        QuerySnapshot bidsSnapshot = await _firestore
            .collection('posts')
            .doc(postDoc.id)
            .collection('bids')
            .where('bidderId', isEqualTo: _currentUserId)
            .get();

        if (bidsSnapshot.docs.isNotEmpty) {
          biddedProjectIds.add(postDoc.id);
        }
      }

      _biddedProjects = biddedProjectIds;
      notifyListeners();
    } catch (e) {
      print('Error fetching user bids: $e');
    }
  }

  /// Check if current user has bid on a specific project
  bool hasBidOnProject(String projectId) {
    return _biddedProjects.contains(projectId);
  }

  /// Fetch all posts except current user's posts with real-time updates
  void fetchPosts() {
    if (_currentUserId == null) {
      print('Warning: Current user ID is null, cannot fetch posts');
      return;
    }

    _isLoading = true;
    notifyListeners();

    _firestore
        .collection('posts')
        .where(
          'ownerId',
          isNotEqualTo: _currentUserId,
        ) // Exclude current user's posts
        .snapshots()
        .listen(
          (snapshot) {
            _posts = snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'title': data['title'] ?? '',
                'description': data['description'] ?? '',
                'tokens': data['tokens'] ?? 0,
                'deadline': data['deadline'] ?? '',
                'skills': List<String>.from(data['skills'] ?? []),
                'bids': data['bids'] ?? 0,
                'category': data['category'] ?? '',
                'postedTime': data['postedTime']?.toString() ?? '',
                'difficulty': data['difficulty'] ?? 'Beginner',
                'urgency': data['urgency'] ?? 'Normal',
                'ownerId': data['ownerId'] ?? '',
                'notes': data['notes'] ?? '',
                'attachments': List<String>.from(data['attachments'] ?? []),
                'isUrgent': data['isUrgent'] ?? false,
              };
            }).toList();

            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            print('Error fetching posts: $error');
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  /// Fetch posts by current user (for profile/my posts page)
  Stream<QuerySnapshot> getCurrentUserPosts() {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('posts')
        .where('ownerId', isEqualTo: _currentUserId)
        .orderBy('postedTime', descending: true)
        .snapshots();
  }

  /// Fetch posts by category (excluding current user)
  Stream<QuerySnapshot> getPostsByCategory(String category) {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('posts')
        .where('ownerId', isNotEqualTo: _currentUserId)
        .where('category', isEqualTo: category)
        .orderBy('postedTime', descending: true)
        .snapshots();
  }

  /// Search posts by title or description (excluding current user)
  Stream<QuerySnapshot> searchPosts(String searchTerm) {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('posts')
        .where('ownerId', isNotEqualTo: _currentUserId)
        .where('title', isGreaterThanOrEqualTo: searchTerm)
        .where('title', isLessThanOrEqualTo: searchTerm + '\uf8ff')
        .snapshots();
  }

  /// Update an existing post (only if current user is owner)
  Future<void> updatePost(String id, Map<String, dynamic> updatedData) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Check if current user owns the post
    DocumentSnapshot doc = await _firestore.collection('posts').doc(id).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['ownerId'] != _currentUserId) {
        throw Exception('You can only update your own posts');
      }
    }

    await _firestore.collection('posts').doc(id).update(updatedData);
  }

  /// Delete a post (only if current user is owner)
  Future<void> deletePost(String id) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Check if current user owns the post
    DocumentSnapshot doc = await _firestore.collection('posts').doc(id).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['ownerId'] != _currentUserId) {
        throw Exception('You can only delete your own posts');
      }
    }

    await _firestore.collection('posts').doc(id).delete();
  }

  /// Submit a bid to a project
  Future<void> submitBid({
    required String projectId,
    required String bidderId,
    required String bidderName,
    required String bidderEmail,
    required int bidAmount,
    required String message,
  }) async {
    try {
      // Check if user is trying to bid on their own project
      DocumentSnapshot projectDoc = await _firestore
          .collection('posts')
          .doc(projectId)
          .get();
      if (projectDoc.exists) {
        Map<String, dynamic> projectData =
            projectDoc.data() as Map<String, dynamic>;
        if (projectData['ownerId'] == bidderId) {
          throw Exception('You cannot bid on your own project');
        }
      }

      // Check if user has already bid on this project
      QuerySnapshot existingBids = await _firestore
          .collection('posts')
          .doc(projectId)
          .collection('bids')
          .where('bidderId', isEqualTo: bidderId)
          .get();

      if (existingBids.docs.isNotEmpty) {
        throw Exception('You have already bid on this project');
      }

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

      // Add to bidded projects set
      _biddedProjects.add(projectId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to submit bid: $e');
    }
  }

  /// Get all bids for a specific project (only if current user owns the project)
  Stream<QuerySnapshot> getBidsForProject(String projectId) {
    return _firestore
        .collection('posts')
        .doc(projectId)
        .collection('bids')
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  /// Accept a bid (only if current user owns the project)
  Future<void> acceptBid(
    String projectId,
    String bidId, {
    required BuildContext context,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Check if current user owns the project
      DocumentSnapshot doc = await _firestore
          .collection('posts')
          .doc(projectId)
          .get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['ownerId'] != _currentUserId) {
          throw Exception('You can only accept bids on your own projects');
        }
      }

      // Get the bid details to get the bidder ID
      DocumentSnapshot bidDoc = await _firestore
          .collection('posts')
          .doc(projectId)
          .collection('bids')
          .doc(bidId)
          .get();

      if (!bidDoc.exists) {
        throw Exception('Bid not found');
      }

      Map<String, dynamic> bidData = bidDoc.data() as Map<String, dynamic>;
      String bidderId = bidData['bidderId'];

      await _firestore
          .collection('posts')
          .doc(projectId)
          .collection('bids')
          .doc(bidId)
          .update({'status': 'accepted'});

      // Update project status and assign to bidder
      await _firestore.collection('posts').doc(projectId).update({
        'status': 'assigned',
        'assignedTo': bidderId,
        'assignedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to accept bid: $e');
    }
  }

  /// Reject a bid (only if current user owns the project)
  Future<void> rejectBid(String projectId, String bidId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Check if current user owns the project
      DocumentSnapshot doc = await _firestore
          .collection('posts')
          .doc(projectId)
          .get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['ownerId'] != _currentUserId) {
          throw Exception('You can only reject bids on your own projects');
        }
      }

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

  /// Refresh posts manually
  void refreshPosts() {
    fetchPosts();
  }

  /// Clear posts (useful for logout)
  void clearPosts() {
    _posts.clear();
    _biddedProjects.clear();
    _currentUserId = null;
    notifyListeners();
  }

  /// Get user's bid details for a specific project
  Future<Map<String, dynamic>?> getUserBidForProject(String projectId) async {
    if (_currentUserId == null) return null;

    try {
      QuerySnapshot bidsSnapshot = await _firestore
          .collection('posts')
          .doc(projectId)
          .collection('bids')
          .where('bidderId', isEqualTo: _currentUserId)
          .get();

      if (bidsSnapshot.docs.isNotEmpty) {
        return bidsSnapshot.docs.first.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching user bid: $e');
      return null;
    }
  }

  /// Complete a project and handle all related updates
  Future<void> completeProject({
    required String projectId,
    required String bidId,
    required String userId,
    required int tokensEarned,
    String? completionNote,
  }) async {
    try {
      WriteBatch batch = _firestore.batch();

      // Update project status
      DocumentReference projectRef = _firestore
          .collection('posts')
          .doc(projectId);
      batch.update(projectRef, {
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'completedBy': userId,
        'completionNote': completionNote,
        'assignedTo': userId,
      });

      // Update bid status
      DocumentReference bidRef = _firestore
          .collection('posts')
          .doc(projectId)
          .collection('bids')
          .doc(bidId);

      batch.update(bidRef, {
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

      // *** KEY FIX: Update user's token balance ***
      DocumentReference userRef = _firestore
          .collection('Usercredential')
          .doc(userId);

      // Get current token value
      DocumentSnapshot userDoc = await userRef.get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String currentTokensStr = userData['token']?.toString() ?? '0';
        int currentTokens = int.tryParse(currentTokensStr) ?? 0;
        int newTokens = currentTokens + tokensEarned;

        batch.update(userRef, {
          'token': newTokens.toString(),
          'completedprojects': FieldValue.increment(1),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // Refresh posts
      fetchPosts();
    } catch (e) {
      throw Exception('Failed to complete project: $e');
    }
  }

  Future<void> completeProjectWithTokens({
    required String projectId,
    required String bidId,
    required String userId,
    required int tokensEarned,
    String? completionNote,
  }) async {
    await completeProject(
      projectId: projectId,
      bidId: bidId,
      userId: userId,
      tokensEarned: tokensEarned,
      completionNote: completionNote,
    );
  }

  /// Mark project as in progress
  Future<void> markProjectInProgress({
    required String projectId,
    required String bidId,
    required String userId,
    String? progressNote,
  }) async {
    try {
      WriteBatch batch = _firestore.batch();

      // Update project status
      DocumentReference projectRef = _firestore
          .collection('posts')
          .doc(projectId);
      batch.update(projectRef, {
        'status': 'in_progress',
        'startedAt': FieldValue.serverTimestamp(),
        'progressNote': progressNote,
        'assignedTo': userId,
      });

      // Update bid status
      DocumentReference bidRef = _firestore
          .collection('posts')
          .doc(projectId)
          .collection('bids')
          .doc(bidId);

      batch.update(bidRef, {
        'status': 'in_progress',
        'startedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // Refresh posts
      fetchPosts();
    } catch (e) {
      throw Exception('Failed to mark project in progress: $e');
    }
  }

  /// Update post creation to increment total projects for user
  /// Add a new post and update user's total projects
  Future<void> addPost(Map<String, dynamic> postData) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Ensure the current user is set as owner
    postData['ownerId'] = _currentUserId;
    postData['postedTime'] = FieldValue.serverTimestamp();
    postData['status'] = 'active'; // Set initial status

    // Add post
    await _firestore.collection('posts').add(postData);

    // Increment total projects count for the user
    await _firestore.collection('Usercredential').doc(_currentUserId).update({
      'totalprojects': FieldValue.increment(1),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Get project statistics for a user
  Future<Map<String, int>> getUserProjectStats(String userId) async {
    try {
      // Get all projects posted by user
      QuerySnapshot postedProjects = await _firestore
          .collection('posts')
          .where('ownerId', isEqualTo: userId)
          .get();

      // Get all completed projects assigned to user
      QuerySnapshot completedProjects = await _firestore
          .collection('posts')
          .where('assignedTo', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .get();

      // Get all in-progress projects assigned to user
      QuerySnapshot inProgressProjects = await _firestore
          .collection('posts')
          .where('assignedTo', isEqualTo: userId)
          .where('status', isEqualTo: 'in_progress')
          .get();

      return {
        'posted': postedProjects.docs.length,
        'completed': completedProjects.docs.length,
        'inProgress': inProgressProjects.docs.length,
      };
    } catch (e) {
      print('Error getting user project stats: $e');
      return {'posted': 0, 'completed': 0, 'inProgress': 0};
    }
  }
}
