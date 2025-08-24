import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackathonpro/provider/post_provider.dart';
import 'package:hackathonpro/provider/user_provider.dart';
import 'package:provider/provider.dart';

class FindWorkPage extends StatefulWidget {
  const FindWorkPage({Key? key}) : super(key: key);
  @override
  _FindWorkPageState createState() => _FindWorkPageState();
}

class _FindWorkPageState extends State<FindWorkPage> {
  String selectedCategory = 'All';
  String selectedSort = 'Latest';
  String searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  final List<String> categories = [
    'All',
    'Web Development',
    'Mobile Development',
    'Data Science',
    'Design',
    'Writing',
    'Marketing',
    'Other',
  ];

  final List<String> sortOptions = [
    'Latest',
    'Highest Pay',
    'Lowest Pay',
    'Deadline',
    'Most Bids',
    'Fewest Bids',
  ];

  List<Map<String, dynamic>> getfilteredProjects(
    List<Map<String, dynamic>> projects,
  ) {
    List<Map<String, dynamic>> filtered = projects.where((project) {
      bool matchesCategory =
          selectedCategory == 'All' ||
          project['category'].toString().toLowerCase() ==
              selectedCategory.toLowerCase();
      return matchesCategory;
    }).toList();

    // Sort projects
    switch (selectedSort) {
      case 'Highest Pay':
        filtered.sort((a, b) => b['tokens'].compareTo(a['tokens']));
        break;
      case 'Lowest Pay':
        filtered.sort((a, b) => a['tokens'].compareTo(b['tokens']));
        break;
      case 'Most Bids':
        filtered.sort((a, b) => b['bids'].compareTo(a['bids']));
        break;
      case 'Fewest Bids':
        filtered.sort((a, b) => a['bids'].compareTo(b['bids']));
        break;
      default: // Latest
        break;
    }

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final List<Map<String, dynamic>> projects = postProvider.posts;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Find Work',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.grey[700]),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filters section
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search projects, skills, keywords...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[600]),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Category chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      bool isSelected = selectedCategory == category;
                      return Container(
                        margin: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                          selectedColor: Colors.blue[100],
                          checkmarkColor: Colors.blue[700],
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.blue[700]
                                : Colors.grey[700],
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Results header
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${getfilteredProjects(projects).length} projects found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedSort,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSort = newValue!;
                      });
                    },
                    items: sortOptions.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          'Sort: $value',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      );
                    }).toList(),
                    icon: Icon(Icons.sort, color: Colors.grey[600], size: 18),
                  ),
                ),
              ],
            ),
          ),

          // Projects list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: getfilteredProjects(projects).length,
              itemBuilder: (context, index) {
                return _buildProjectCard(
                  getfilteredProjects(projects)[index],
                  postProvider,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(
    Map<String, dynamic> project,
    PostProvider postProvider,
  ) {
    final bool hasBid = postProvider.hasBidOnProject(project['id'] ?? '');

    Color difficultyColor = project['difficulty'] == 'Beginner'
        ? Colors.green
        : project['difficulty'] == 'Intermediate'
        ? Colors.orange
        : Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
        border:
            project['urgency'] == 'High' ||
                project['urgency'] ==
                    'Urgent' // isurgent
            ? Border.all(color: Colors.orange[300]!, width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (project['urgency'] == 'High' ||
                            project['urgency'] == 'Urgent') // isurgent
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            margin: EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'URGENT',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            project['title'] ?? "None",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        // Bid status indicator
                        if (hasBid)
                          Container(
                            margin: EdgeInsets.only(left: 8),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.how_to_vote,
                                  color: Colors.orange[700],
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Bid Placed',
                                  style: TextStyle(
                                    color: Colors.orange[700],
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${project['tokens'] ?? 0} tokens',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Description
          Text(
            project['description'] ?? "No description provided.",
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 16),

          // Skills
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: (project['skills'] as List<String>)
                .map(
                  (skill) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 16),

          // Bottom row with info and actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        project['deadline'] ?? "No deadline",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.people, size: 14, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        '${project['bids'] ?? 0} bids',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: difficultyColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          project['difficulty'] ?? "None",
                          style: TextStyle(
                            color: difficultyColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        project['postedTime'] ?? "No info",
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      _showProjectDetails(project, postProvider);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue[600]!),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'View Details',
                      style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                    ),
                  ),
                  SizedBox(width: 8),
                  // Action button - changes based on bid status
                  hasBid
                      ? Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[300]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 14,
                                color: Colors.orange[700],
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Bidded',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            _showBidDialog2(project, context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
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
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Projects',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text('Token Range'),
              // Add token range slider here
              SizedBox(height: 20),
              Text('Deadline'),
              // Add deadline filter here
              SizedBox(height: 20),
              Text('Difficulty Level'),
              // Add difficulty filter here
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Reset'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProjectDetails(
    Map<String, dynamic> project,
    PostProvider postProvider,
  ) {
    final bool hasBid = postProvider.hasBidOnProject(project['id'] ?? '');

    // Navigate to project details page or show detailed modal
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(project['title'] ?? "No Title"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bid status indicator in modal
                if (hasBid)
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange[700],
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'You have already bid on this project',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                Text(
                  'Full Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(project['description'] ?? "No description provided."),
                SizedBox(height: 16),
                Text(
                  'Required Skills:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: (project['skills'] as List<String>)
                      .map(
                        (skill) => Chip(
                          label: Text(skill, style: TextStyle(fontSize: 12)),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
            if (!hasBid)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showBidDialog2(project, context);
                },
                child: Text('Bid Now'),
              )
            else
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  _showBidDetails(project, context);
                },
                child: Text('View My Bid'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange[700],
                ),
              ),
          ],
        );
      },
    );
  }

  // New method to show bid details for projects user has already bid on
  void _showBidDetails(
    Map<String, dynamic> project,
    BuildContext context,
  ) async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final bidDetails = await postProvider.getUserBidForProject(
      project['id'] ?? '',
    );

    if (bidDetails != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Your Bid Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Project: ${project['title'] ?? "No Title"}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text('Your Bid Amount: ${bidDetails['bidAmount']} tokens'),
                SizedBox(height: 8),
                Text('Status: ${bidDetails['status'] ?? 'pending'}'),
                SizedBox(height: 16),
                Text(
                  'Your Message:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(bidDetails['message'] ?? 'No message provided'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not load bid details')));
    }
  }

  void _showBidDialog(Map<String, dynamic> project) {
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
              onPressed: () {
                // Handle bid submission
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Bid submitted successfully!')),
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

  void _showBidDialog2(Map<String, dynamic> project, BuildContext context) {
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
              Text('Project: ${project['title']}'),
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
      final postProvider = Provider.of<PostProvider>(context, listen: false);

      // Use PostProvider's submitBid method
      await postProvider.submitBid(
        projectId: project['id'],
        bidderId: user.uid,
        bidderName:
            '${userProvider.user!.firstname} ${userProvider.user!.lastname}',
        bidderEmail: user.email!,
        bidAmount: int.parse(bidAmount),
        message: message,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bid submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh the page to show updated bid status
      setState(() {});
    } catch (e) {
      print('Error submitting bid: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit bid: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
