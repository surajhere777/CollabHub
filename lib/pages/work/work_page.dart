import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hackathonpro/pages/work/project_bid.dart';
// import 'package:provider/provider.dart';
// import 'package:hackathonpro/provider/post_provider.dart';
// import 'package:hackathonpro/provider/user_provider.dart';

class MyWorkPage extends StatefulWidget {
  @override
  _MyWorkPageState createState() => _MyWorkPageState();
}

class _MyWorkPageState extends State<MyWorkPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  // Firebase data streams
  List<Map<String, dynamic>> myProjects = [];
  List<Map<String, dynamic>> myBids = [];
  bool isLoadingProjects = true;
  bool isLoadingBids = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchMyData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  // Fetch user's projects and bids from Firebase
  void _fetchMyData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _fetchMyProjects(user.uid);
      _fetchMyBids(user.uid);
    }
  }

  // Fetch projects posted by the current user
  void _fetchMyProjects(String userId) {
    FirebaseFirestore.instance
        .collection('posts')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
          setState(() {
            myProjects = snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'title': data['title'] ?? '',
                'tokens': data['tokens'] ?? 0,
                'bids': data['bids'] ?? 0,
                'status': data['status'] ?? 'active',
                'posted': _formatDate(data['postedTime']),
                'deadline': data['deadline'] ?? '',
                'category': data['category'] ?? '',
                'description': data['description'] ?? '',
                'assignedTo': data['assignedTo'],
                'completedDate': data['completedDate'],
              };
            }).toList();
            isLoadingProjects = false;
          });
        });
  }

  // Fetch bids placed by the current user
  void _fetchMyBids(String userId) async {
    try {
      // Get all posts first
      QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .get();

      List<Map<String, dynamic>> userBids = [];

      // For each post, check if user has placed a bid
      for (QueryDocumentSnapshot postDoc in postsSnapshot.docs) {
        QuerySnapshot bidsSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .doc(postDoc.id)
            .collection('bids')
            .where('bidderId', isEqualTo: userId)
            .get();

        for (QueryDocumentSnapshot bidDoc in bidsSnapshot.docs) {
          final postData = postDoc.data() as Map<String, dynamic>;
          final bidData = bidDoc.data() as Map<String, dynamic>;

          userBids.add({
            'bidId': bidDoc.id,
            'projectId': postDoc.id,
            'title': postData['title'] ?? '',
            'myBid': bidData['bidAmount'] ?? 0,
            'totalBids': postData['bids'] ?? 0,
            'status': bidData['status'] ?? 'pending',
            'bidDate': _formatDate(bidData['submittedAt']),
            'deadline': postData['deadline'] ?? '',
            'client': bidData['clientName'] ?? 'Unknown Client',
            'message': bidData['message'] ?? '',
          });
        }
      }

      setState(() {
        myBids = userBids;
        isLoadingBids = false;
      });
    } catch (e) {
      print('Error fetching bids: $e');
      setState(() {
        isLoadingBids = false;
      });
    }
  }

  // Format timestamp for display
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';

    try {
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        return 'Unknown';
      }

      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 7) {
        return '${difference.inDays ~/ 7} week${difference.inDays ~/ 7 > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'My Work',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue[600],
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Colors.blue[600],
          tabs: [
            Tab(
              text: 'My Projects',
              icon: Badge(
                label: Text('${myProjects.length}'),
                child: Icon(Icons.work_outline),
              ),
            ),
            Tab(
              text: 'My Bids',
              icon: Badge(
                label: Text('${myBids.length}'),
                child: Icon(Icons.gavel),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMyProjects(), _buildMyBids()],
      ),
    );
  }

  Widget _buildMyProjects() {
    if (isLoadingProjects) {
      return Center(child: CircularProgressIndicator());
    }

    if (myProjects.isEmpty) {
      return _buildEmptyState(
        'No Projects Yet',
        'Start by posting your first project',
        Icons.work_outline,
        'Post Project',
        () {
          Navigator.pushNamed(context, '/post-project');
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _fetchMyData();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: myProjects.length,
        itemBuilder: (context, index) {
          return _buildProjectCard(myProjects[index]);
        },
      ),
    );
  }

  Widget _buildMyBids() {
    if (isLoadingBids) {
      return Center(child: CircularProgressIndicator());
    }

    if (myBids.isEmpty) {
      return _buildEmptyState(
        'No Bids Yet',
        'Browse projects and place your first bid',
        Icons.gavel,
        'Browse Projects',
        () {
          Navigator.pushNamed(context, '/browse-projects');
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _fetchMyData();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: myBids.length,
        itemBuilder: (context, index) {
          return _buildBidCard(myBids[index]);
        },
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  project['title'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              _buildStatusChip(project['status']),
            ],
          ),
          SizedBox(height: 12),

          Row(
            children: [
              _buildInfoItem(
                Icons.monetization_on,
                '${project['tokens']} tokens',
                Colors.green,
              ),
              SizedBox(width: 16),
              _buildInfoItem(
                Icons.people,
                '${project['bids']} bids',
                Colors.blue,
              ),
              SizedBox(width: 16),
              _buildInfoItem(
                Icons.access_time,
                project['status'] == 'completed'
                    ? 'Completed ${project['completedDate'] ?? 'recently'}'
                    : project['deadline'],
                Colors.orange,
              ),
            ],
          ),

          if (project['assignedTo'] != null) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  'Assigned to ${project['assignedTo']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],

          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Posted ${project['posted']}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              _buildProjectAction(project),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBidCard(Map<String, dynamic> bid) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  bid['title'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              _buildBidStatusChip(bid['status']),
            ],
          ),
          SizedBox(height: 8),

          Text(
            'Client: ${bid['client']}',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),

          SizedBox(height: 12),
          Row(
            children: [
              _buildInfoItem(
                Icons.monetization_on,
                '${bid['myBid']} tokens',
                Colors.green,
              ),
              SizedBox(width: 16),
              _buildInfoItem(
                Icons.people,
                '${bid['totalBids']} total bids',
                Colors.blue,
              ),
              SizedBox(width: 16),
              _buildInfoItem(
                Icons.access_time,
                bid['deadline'] ?? 'No deadline',
                Colors.orange,
              ),
            ],
          ),

          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bid placed ${bid['bidDate']}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              _buildBidAction(bid),
            ],
          ),
        ],
      ),
    );
  }

  // Status chip builders remain the same
  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'active':
        color = Colors.blue;
        text = 'Active';
        break;
      case 'in_progress':
        color = Colors.orange;
        text = 'In Progress';
        break;
      case 'completed':
        color = Colors.green;
        text = 'Completed';
        break;
      case 'assigned':
        color = Colors.purple;
        text = 'Assigned';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBidStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'Pending';
        break;
      case 'accepted':
        color = Colors.green;
        text = 'Accepted';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Rejected';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildProjectAction(Map<String, dynamic> project) {
    switch (project['status']) {
      case 'active':
        return ElevatedButton(
          onPressed: () => _viewProjectBids(project),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          child: Text(
            'View Bids (${project['bids']})',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        );
      case 'in_progress':
      case 'assigned':
        return TextButton(
          onPressed: () => _viewProjectProgress(project),
          child: Text('View Progress'),
        );
      case 'completed':
        return TextButton(
          onPressed: () => _viewProjectDetails(project),
          child: Text('View Details'),
        );
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildBidAction(Map<String, dynamic> bid) {
    switch (bid['status']) {
      case 'pending':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(onPressed: () => _editBid(bid), child: Text('Edit')),
            TextButton(
              onPressed: () => _withdrawBid(bid),
              child: Text('Withdraw', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      case 'accepted':
        return ElevatedButton(
          onPressed: () => _startWork(bid),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: Text('Start Work', style: TextStyle(color: Colors.white)),
        );
      case 'rejected':
        return Text(
          'Not selected',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        );
      default:
        return SizedBox.shrink();
    }
  }

  // Action methods
  void _viewProjectBids(Map<String, dynamic> project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectBidsPage(
          projectId: project['id'],
          projectTitle: project['title'],
        ),
      ),
    );
  }

  void _viewProjectProgress(Map<String, dynamic> project) {
    // Navigate to project progress page
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Project Progress'),
        content: Text('Progress tracking feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _viewProjectDetails(Map<String, dynamic> project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(project['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${project['status']}'),
            Text('Tokens: ${project['tokens']}'),
            Text('Total Bids: ${project['bids']}'),
            if (project['assignedTo'] != null)
              Text('Assigned to: ${project['assignedTo']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editBid(Map<String, dynamic> bid) {
    TextEditingController bidController = TextEditingController(
      text: bid['myBid'].toString(),
    );
    TextEditingController messageController = TextEditingController(
      text: bid['message'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Bid'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: bidController,
              decoration: InputDecoration(labelText: 'Bid Amount'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: InputDecoration(labelText: 'Message'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _updateBid(bid, bidController.text, messageController.text);
              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateBid(
    Map<String, dynamic> bid,
    String newAmount,
    String newMessage,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(bid['projectId'])
          .collection('bids')
          .doc(bid['bidId'])
          .update({
            'bidAmount': int.parse(newAmount),
            'message': newMessage,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      _fetchMyData(); // Refresh data
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Bid updated successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update bid: $e')));
    }
  }

  void _withdrawBid(Map<String, dynamic> bid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Withdraw Bid'),
        content: Text('Are you sure you want to withdraw this bid?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _deleteBid(bid);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Withdraw', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBid(Map<String, dynamic> bid) async {
    try {
      // Delete the bid
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(bid['projectId'])
          .collection('bids')
          .doc(bid['bidId'])
          .delete();

      // Decrease bid count
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(bid['projectId'])
          .update({'bids': FieldValue.increment(-1)});

      _fetchMyData(); // Refresh data
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Bid withdrawn successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to withdraw bid: $e')));
    }
  }

  void _startWork(Map<String, dynamic> bid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Start Work'),
        content: Text(
          'Congratulations! You can now start working on this project.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    IconData icon,
    String buttonText,
    VoidCallback onPressed,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(buttonText, style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
