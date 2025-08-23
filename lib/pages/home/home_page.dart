import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackathonpro/pages/home/bid_now_page.dart';
import 'package:hackathonpro/pages/home/find_work.dart';
import 'package:hackathonpro/pages/post/post_page.dart';
import 'package:hackathonpro/provider/post_provider.dart';
import 'package:hackathonpro/provider/user_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Sample data - replace with your actual data models
  final currentUser = {
    'name': 'Alex Chen',
    'tokens': 85,
    'rating': 4.8,
    'avatar': 'assets/avatar.png', // Add your asset
  };

  // final List<Map<String, dynamic>> featuredProjects = [
  //   {
  //     'title': 'Portfolio Website',
  //     'description': 'Need a responsive portfolio site with React...',
  //     'tokens': 50,
  //     'deadline': '5 days',
  //     'category': 'Web Dev',
  //     'requester': 'Sarah Kim',
  //     'rating': 4.6,
  //     'skills': ['React', 'CSS', 'JavaScript'],
  //     'bids': 3,
  //   },
  //   {
  //     'title': 'Data Analysis Project',
  //     'description': 'Statistical analysis using Python pandas...',
  //     'tokens': 35,
  //     'deadline': '3 days',
  //     'category': 'Data Science',
  //     'requester': 'Mike Johnson',
  //     'rating': 4.2,
  //     'skills': ['Python', 'Pandas'],
  //     'bids': 7,
  //   },
  // ];
  void initState() {
    super.initState();
    // Fetch user when this screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Provider.of<UserProvider>(context, listen: false).fetchUser(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final postprovider = Provider.of<PostProvider>(context);
    final List<Map<String, dynamic>> featuredProjects = postprovider.posts;
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
                  '${userProvider.user!.token} tokens',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Profile avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue[200],
            child: Icon(Icons.person, color: Colors.blue[700]),
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

            // Featured projects
            _buildFeaturedProjects(featuredProjects),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(UserProvider userProvider) {
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
                  'Welcome back, ${userProvider.user!.firstname} ${userProvider.user!.lastname}!',
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
                      '${userProvider.user!.rating} rating',
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
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return PostProjectPage();
                  },
                ),
              );
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
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            userProvider.user!.completedprojects.toString(),
            'Completed',
            Icons.check_circle,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            (userProvider.user!.totalprojects -
                    userProvider.user!.completedprojects)
                .toString(),
            'In Progress',
            Icons.pending,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            userProvider.user!.token,
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

  Widget _buildFeaturedProjects(List<Map<String, dynamic>> projects) {
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
              },
              child: Text('View All'),
            ),
          ],
        ),
        SizedBox(height: 12),
        Column(
          children: projects
              .map((project) => _buildProjectCard(project))
              .toList(),
        ),
      ],
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
                  project['title'],
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
                  '${project['tokens']} tokens',
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
            project['description'],
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children: (project['skills'] as List<dynamic>)
                .map(
                  (skill) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      skill,
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
                    project['deadline'],
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.people, size: 14, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    '${project['bids']} bids',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle bid action
                  showBidDialog(
                    context,
                    project,
                    onBidSubmitted: (bidData) {
                      setState(() {
                        project['bids'] = (project['bids'] as int) + 1;
                      });
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Bid Now',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
