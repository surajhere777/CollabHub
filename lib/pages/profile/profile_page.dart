import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hackathonpro/provider/user_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<Map<String, dynamic>> recentReviews = [
    {
      'reviewer': 'Sarah Kim',
      'rating': 5,
      'project': 'Portfolio Website',
      'comment': 'Excellent work! Very professional and delivered on time.',
      'date': '3 days ago',
    },
    {
      'reviewer': 'Mike Johnson',
      'rating': 5,
      'project': 'Data Analysis',
      'comment': 'Great insights and clear visualizations. Highly recommended!',
      'date': '1 week ago',
    },
    {
      'reviewer': 'Emma Davis',
      'rating': 4,
      'project': 'Mobile App UI',
      'comment':
          'Good design skills, minor revisions needed but overall satisfied.',
      'date': '2 weeks ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.user == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: _showSettingsSheet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(userProvider),
            SizedBox(height: 16),
            _buildStatsRow(userProvider),
            SizedBox(height: 16),
            _buildSkillsSection(userProvider),
            SizedBox(height: 16),
            _buildRecentReviews(),
            SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProvider userProvider) {
    return Container(
      padding: EdgeInsets.all(20),
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
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue[100],
                child: Icon(Icons.person, size: 40, color: Colors.blue[700]),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${userProvider.user!.firstname} ${userProvider.user!.lastname}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      userProvider.user!.stream,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    Text(
                      userProvider.user!.education,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '${userProvider.user!.rating} rating',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${userProvider.user!.token} tokens',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            userProvider.user!.info,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String successRate(UserProvider userProvider) {
    final total = userProvider.user!.totalprojects;
    final completed = userProvider.user!.completedprojects;

    if (total == 0) return "0%";
    return "${((completed / total) * 100).round()}%";
  }

  Widget _buildStatsRow(UserProvider userProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Projects',
            userProvider.user!.totalprojects.toString(),
            Icons.work_outline,
            Colors.blue,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Completed',
            userProvider.user!.completedprojects.toString(),
            Icons.check_circle_outline,
            Colors.green,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Success Rate',
            successRate(userProvider),
            Icons.trending_up,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
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
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(UserProvider userProvider) {
    // Add null check and ensure skills is not null
    final skills = userProvider.user?.skills ?? <String>[];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.psychology,
                      color: Colors.purple[600],
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Skills & Expertise',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton.icon(
                  onPressed: () => _editSkills(userProvider),
                  icon: Icon(Icons.edit, size: 16, color: Colors.blue[600]),
                  label: Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Check if skills list is empty
          skills.isEmpty ? _buildEmptySkillsState() : _buildSkillsGrid(skills),
        ],
      ),
    );
  }

  Widget _buildEmptySkillsState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.psychology_outlined, size: 48, color: Colors.grey[400]),
          SizedBox(height: 12),
          Text(
            'No skills added yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your skills to showcase your expertise',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsGrid(List<String> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${skills.length} ${skills.length == 1 ? 'Skill' : 'Skills'}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: skills.asMap().entries.map((entry) {
            final index = entry.key;
            final skill = entry.value;

            // Different colors for variety
            final colors = [
              {
                'bg': Colors.blue[50]!,
                'text': Colors.blue[700]!,
                'border': Colors.blue[200]!,
              },
              {
                'bg': Colors.green[50]!,
                'text': Colors.green[700]!,
                'border': Colors.green[200]!,
              },
              {
                'bg': Colors.purple[50]!,
                'text': Colors.purple[700]!,
                'border': Colors.purple[200]!,
              },
              {
                'bg': Colors.orange[50]!,
                'text': Colors.orange[700]!,
                'border': Colors.orange[200]!,
              },
              {
                'bg': Colors.teal[50]!,
                'text': Colors.teal[700]!,
                'border': Colors.teal[200]!,
              },
              {
                'bg': Colors.indigo[50]!,
                'text': Colors.indigo[700]!,
                'border': Colors.indigo[200]!,
              },
            ];

            final colorSet = colors[index % colors.length];

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: colorSet['bg'],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorSet['border']!, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: colorSet['border']!.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: colorSet['text'],
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    skill,
                    style: TextStyle(
                      color: colorSet['text'],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentReviews() {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Reviews',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              TextButton(onPressed: _viewAllReviews, child: Text('View All')),
            ],
          ),
          SizedBox(height: 12),
          ...recentReviews
              .take(2)
              .map((review) => _buildReviewItem(review))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 16, color: Colors.grey[600]),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['reviewer'],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(
                          review['rating'],
                          (index) =>
                              Icon(Icons.star, size: 12, color: Colors.amber),
                        ),
                        SizedBox(width: 4),
                        Text(
                          review['project'],
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                review['date'],
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            review['comment'],
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _editProfile(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Edit Profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _shareProfile,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Share Profile'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _viewPortfolio,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Portfolio'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _editProfile(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Controllers for form fields
    final firstNameController = TextEditingController(
      text: userProvider.user!.firstname,
    );
    final lastNameController = TextEditingController(
      text: userProvider.user!.lastname,
    );
    final educationController = TextEditingController(
      text: userProvider.user!.education,
    );
    final streamController = TextEditingController(
      text: userProvider.user!.stream,
    );
    final infoController = TextEditingController(text: userProvider.user!.info);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: educationController,
                decoration: InputDecoration(
                  labelText: 'Education',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: streamController,
                decoration: InputDecoration(
                  labelText: 'Stream/Major',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: infoController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Update user profile
              await _updateUserProfile(
                userProvider,
                firstNameController.text,
                lastNameController.text,
                educationController.text,
                streamController.text,
                infoController.text,
              );
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserProfile(
    UserProvider userProvider,
    String firstName,
    String lastName,
    String education,
    String stream,
    String info,
  ) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      // Update in Firestore
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('Usercredential')
            .doc(uid)
            .update({
              'firstname': firstName,
              'lastname': lastName,
              'education': education,
              'stream': stream,
              'info': info,
            });

        // Refresh user data
        await userProvider.fetchUser(uid);
      }

      // Hide loading
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Hide loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editSkills(UserProvider userProvider) {
    List<String> currentSkills = List.from(
      userProvider.user?.skills ?? <String>[],
    );
    TextEditingController skillController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.psychology, color: Colors.purple[600]),
              SizedBox(width: 8),
              Text(
                'Edit Skills',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: skillController,
                      decoration: InputDecoration(
                        hintText: 'Add a new skill...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        suffixIcon: Container(
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              if (skillController.text.trim().isNotEmpty) {
                                setState(() {
                                  currentSkills.add(
                                    skillController.text.trim(),
                                  );
                                  skillController.clear();
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          setState(() {
                            currentSkills.add(value.trim());
                            skillController.clear();
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  if (currentSkills.isNotEmpty) ...[
                    Text(
                      'Your Skills (${currentSkills.length})',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: currentSkills.map((skill) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Chip(
                            label: Text(
                              skill,
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            deleteIcon: Container(
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.red[600],
                              ),
                            ),
                            onDeleted: () {
                              setState(() {
                                currentSkills.remove(skill);
                              });
                            },
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                          ),
                        );
                      }).toList(),
                    ),
                  ] else ...[
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.psychology_outlined,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No skills added yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: currentSkills.isEmpty
                  ? null
                  : () async {
                      await _updateUserSkills(userProvider, currentSkills);
                      Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Save Changes',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateUserSkills(
    UserProvider userProvider,
    List<String> skills,
  ) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('Usercredential')
            .doc(uid)
            .update({'skills': skills});

        await userProvider.fetchUser(uid);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Skills updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating skills: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _shareProfile() {
    final user = FirebaseAuth.instance.currentUser;
    final profileLink = 'https://collabhub.app/profile/${user?.uid ?? "user"}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Share Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Share your profile with others:'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                profileLink,
                style: TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: profileLink));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Profile link copied to clipboard!')),
              );
            },
            child: Text('Copy Link'),
          ),
        ],
      ),
    );
  }

  void _viewPortfolio() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Portfolio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.work, size: 48, color: Colors.blue),
            SizedBox(height: 16),
            Text('Portfolio feature coming soon!'),
            SizedBox(height: 8),
            Text(
              'This will showcase your completed projects and achievements.',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
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

  void _viewAllReviews() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('All Reviews'),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: recentReviews.length,
            itemBuilder: (context, index) {
              final review = recentReviews[index];
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, size: 20),
                          SizedBox(width: 8),
                          Text(
                            review['reviewer'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Spacer(),
                          ...List.generate(
                            review['rating'],
                            (i) =>
                                Icon(Icons.star, size: 16, color: Colors.amber),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        review['project'],
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(review['comment']),
                      SizedBox(height: 4),
                      Text(
                        review['date'],
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
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

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  _buildSettingsItem(
                    'Account Settings',
                    Icons.person_outline,
                    _showAccountSettings,
                  ),
                  _buildSettingsItem(
                    'Notifications',
                    Icons.notifications,
                    _showNotifications,
                  ),
                  _buildSettingsItem(
                    'Privacy',
                    Icons.privacy_tip_outlined,
                    _showPrivacy,
                  ),
                  _buildSettingsItem(
                    'Help & Support',
                    Icons.help_outline,
                    _showHelp,
                  ),
                  _buildSettingsItem('About', Icons.info_outline, _showAbout),
                  SizedBox(height: 10),
                  _buildSettingsItem(
                    'Logout',
                    Icons.logout,
                    _logout,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey[700]),
      title: Text(title, style: TextStyle(color: color ?? Colors.grey[800])),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  void _showAccountSettings() {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Account Settings'),
        content: Text(
          'Account settings functionality will be implemented here.',
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

  void _showNotifications() {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notifications'),
        content: Text('Notification preferences will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacy() {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Settings'),
        content: Text('Privacy settings will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Help & Support'),
        content: Text(
          'Contact support at support@collabhub.app or visit our FAQ section.',
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

  void _showAbout() {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About'),
        content: Text(
          'CollabHub v1.0.0\nA platform for student collaboration and project management.',
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

  void _logout() async {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
