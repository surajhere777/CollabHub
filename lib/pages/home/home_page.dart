import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackathonpro/pages/home/bid_now_page.dart';
import 'package:hackathonpro/pages/home/find_work.dart';
import 'package:hackathonpro/pages/post/post_page.dart';
import 'package:hackathonpro/pages/profile/profile_page.dart';
import 'package:hackathonpro/provider/post_provider.dart';
import 'package:hackathonpro/provider/user_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> featuredProjects = [];
  bool isLoadingPosts = true;
  bool isLoadingUser = true;

  void initState() {
    super.initState();
    // Fetch user when this screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _initializeUserData(user.uid);
      }
    });
  }

  Future<void> _initializeUserData(String userId) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final postProvider = Provider.of<PostProvider>(context, listen: false);

      // Initialize PostProvider with current user
      postProvider.setCurrentUserId(userId);

      await userProvider.fetchUser(userId);
      setState(() {
        isLoadingUser = false;
      });
    } catch (e) {
      print('Error initializing user data: $e');
      setState(() {
        isLoadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // Show loading screen while user data is being fetched
    if (isLoadingUser || userProvider.user == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'CollabHub',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          // Token balance
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monetization_on, color: Colors.green[700], size: 16),
                SizedBox(width: 4),
                Text(
                  '${userProvider.user?.token ?? 0} tokens',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Profile avatar
          GestureDetector(
            onTap: () {
              // Navigate to profile page
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return ProfilePage();
                  },
                ),
              );
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue[200],
              child: Icon(Icons.person, color: Colors.blue[700]),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            _buildWelcomeSection(userProvider),
            SizedBox(height: 24),

            // Quick actions
            _buildQuickActions(),
            SizedBox(height: 24),

            // Stats cards
            _buildStatsCards(userProvider),
            SizedBox(height: 24),

            // Featured projects - Now using PostProvider
            _buildFeaturedProjectsFromProvider(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(UserProvider userProvider) {
    final user = userProvider.user;
    if (user == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${user.firstname ?? ''} ${user.lastname ?? ''}!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Ready to collaborate and earn tokens?',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow[300], size: 16),
                    SizedBox(width: 4),
                    Text(
                      '${user.rating ?? 0} rating',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.school, size: 60, color: Colors.white.withOpacity(0.3)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            'Post Project',
            Icons.add_circle_outline,
            Colors.green,
            () {
              // Navigate to post project page
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) {
                        return PostProjectPage();
                      },
                    ),
                  )
                  .then((_) {
                    // Refresh data when returning from post page
                    final postProvider = Provider.of<PostProvider>(
                      context,
                      listen: false,
                    );
                    postProvider.refreshPosts();
                  });
            },
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildActionCard('Find Work', Icons.search, Colors.orange, () {
            // Navigate to browse projects page
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return FindWorkPage();
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(UserProvider userProvider) {
    final user = userProvider.user;
    if (user == null) return SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            (user.completedprojects ?? 0).toString(),
            'Completed',
            Icons.check_circle,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            ((user.totalprojects ?? 0) - (user.completedprojects ?? 0))
                .toString(),
            'In Progress',
            Icons.pending,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            (user.token ?? 0).toString(),
            'Tokens',
            Icons.monetization_on,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue[600], size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // Updated to use PostProvider
  Widget _buildFeaturedProjectsFromProvider() {
    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Featured Projects',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all projects
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => FindWorkPage()),
                    );
                  },
                  child: Text('View All'),
                ),
              ],
            ),
            SizedBox(height: 12),
            postProvider.isLoading
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : postProvider.posts.isEmpty
                ? Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'No projects available at the moment.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                : Column(
                    children: postProvider.posts
                        .take(5) // Show only first 5 projects on home page
                        .map(
                          (project) => _buildProjectCard(project, postProvider),
                        )
                        .toList(),
                  ),
          ],
        );
      },
    );
  }

  Widget _buildProjectCard(
    Map<String, dynamic> project,
    PostProvider postProvider,
  ) {
    final projectId = project['id'] ?? '';
    final hasBidded = postProvider.hasBidOnProject(projectId);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  project['title'] ?? 'No Title',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${project['tokens'] ?? 0} tokens',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            project['description'] ?? 'No description',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children: (project['skills'] as List<dynamic>? ?? [])
                .map(
                  (skill) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      skill.toString(),
                      style: TextStyle(color: Colors.blue[700], fontSize: 11),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    project['deadline'] ?? 'No deadline',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.people, size: 14, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    '${project['bids'] ?? 0} bids',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: hasBidded
                    ? null // Disable button if already bidded
                    : () {
                        _showBidDialog(project, postProvider);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasBidded
                      ? Colors.grey[400]
                      : Colors.blue[600],
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasBidded)
                      Icon(Icons.check, size: 14, color: Colors.white),
                    if (hasBidded) SizedBox(width: 4),
                    Text(
                      hasBidded ? 'Bidded' : 'Bid Now',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBidDialog(Map<String, dynamic> project, PostProvider postProvider) {
    TextEditingController bidController = TextEditingController();
    TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Submit Your Bid'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Project: ${project['title'] ?? "No Title"}'),
              SizedBox(height: 16),
              TextField(
                controller: bidController,
                decoration: InputDecoration(
                  labelText: 'Your bid (tokens)',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your bid amount',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  labelText: 'Cover message',
                  border: OutlineInputBorder(),
                  hintText: 'Why should you be chosen for this project?',
                ),
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
                await _submitBid(
                  project,
                  bidController.text,
                  messageController.text,
                  postProvider,
                );
                Navigator.pop(context);
              },
              child: Text('Submit Bid'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitBid(
    Map<String, dynamic> project,
    String bidAmount,
    String message,
    PostProvider postProvider,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please login to submit a bid')));
        return;
      }

      if (bidAmount.isEmpty || int.tryParse(bidAmount) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid bid amount')),
        );
        return;
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.user;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User data not loaded. Please try again.')),
        );
        return;
      }

      String projectId = project['id'] ?? '';

      if (projectId.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: Project ID not found')));
        return;
      }

      // Use PostProvider to submit bid
      await postProvider.submitBid(
        projectId: projectId,
        bidderId: user.uid,
        bidderName:
            '${currentUser.firstname ?? ''} ${currentUser.lastname ?? ''}',
        bidderEmail: user.email ?? '',
        bidAmount: int.parse(bidAmount),
        message: message,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Bid submitted successfully!')));
      }
    } catch (e) {
      print('Error submitting bid: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit bid: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
