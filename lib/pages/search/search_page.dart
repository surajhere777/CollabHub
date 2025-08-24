import 'package:flutter/material.dart';
import 'package:hackathonpro/provider/post_provider.dart';
import 'package:hackathonpro/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BrowseProjectsPage extends StatefulWidget {
  @override
  _BrowseProjectsPageState createState() => _BrowseProjectsPageState();
}

class _BrowseProjectsPageState extends State<BrowseProjectsPage> {
  TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _sortBy = 'newest';
  RangeValues _tokenRange = RangeValues(0, 100);
  List<String> _selectedSkills = [];

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
    'newest',
    'oldest',
    'highest_tokens',
    'lowest_tokens',
    'most_bids',
    'deadline',
  ];

  final List<String> availableSkills = [
    'React',
    'Flutter',
    'Python',
    'JavaScript',
    'UI/UX',
    'Figma',
    'Node.js',
    'Java',
    'CSS',
    'HTML',
    'Data Analysis',
    'Writing',
  ];

  List<Map<String, dynamic>> allProjects =
      []; // Assume this gets populated from an API or database

  List<Map<String, dynamic>> getFilteredProjects(
    List<Map<String, dynamic>> allProjects,
    UserProvider userProvider,
  ) {
    List<Map<String, dynamic>> filtered = List.from(allProjects);

    // FIRST: Filter out current user's own posts (most important filter)
    if (userProvider.user != null) {
      filtered = filtered
          .where((project) => project['ownerId'] != userProvider.user!.uid)
          .toList();
    }

    // Filter by search text
    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where(
            (project) =>
                (project['title'] != null &&
                    project['title'].toString().toLowerCase().contains(
                      _searchController.text.toLowerCase(),
                    )) ||
                (project['description'] != null &&
                    project['description'].toString().toLowerCase().contains(
                      _searchController.text.toLowerCase(),
                    )),
          )
          .toList();
    }

    // Filter by category
    if (_selectedCategory != null && _selectedCategory != 'All') {
      filtered = filtered
          .where((project) => project['category'] == _selectedCategory)
          .toList();
    }

    // Filter by token range
    if (_tokenRange != null) {
      filtered = filtered.where((project) {
        final tokens = project['tokens'];
        if (tokens == null) return false;
        return tokens >= _tokenRange.start && tokens <= _tokenRange.end;
      }).toList();
    }

    // Filter by skills
    if (_selectedSkills.isNotEmpty) {
      filtered = filtered.where((project) {
        final projectSkills = project['skills'];
        if (projectSkills == null) return false;

        List<String> skillsList = List<String>.from(projectSkills);
        return _selectedSkills.any((skill) => skillsList.contains(skill));
      }).toList();
    }

    // Sort projects
    switch (_sortBy) {
      case 'highest_tokens':
        filtered.sort((a, b) {
          final tokensA = a['tokens'] ?? 0;
          final tokensB = b['tokens'] ?? 0;
          return tokensB.compareTo(tokensA);
        });
        break;

      case 'lowest_tokens':
        filtered.sort((a, b) {
          final tokensA = a['tokens'] ?? 0;
          final tokensB = b['tokens'] ?? 0;
          return tokensA.compareTo(tokensB);
        });
        break;

      case 'most_bids':
        filtered.sort((a, b) {
          final bidsA = a['bids'] ?? 0;
          final bidsB = b['bids'] ?? 0;
          return bidsB.compareTo(bidsA);
        });
        break;

      case 'oldest':
        filtered.sort((a, b) {
          final timeA = a['postedTime'];
          final timeB = b['postedTime'];
          if (timeA == null || timeB == null) return 0;
          return timeA.compareTo(timeB);
        });
        break;

      case 'deadline':
        // Sort by urgency (high, medium, low)
        final urgencyOrder = {'high': 0, 'medium': 1, 'low': 2};
        filtered.sort((a, b) {
          final urgencyA = a['urgency'] ?? 'low';
          final urgencyB = b['urgency'] ?? 'low';
          return (urgencyOrder[urgencyA] ?? 2).compareTo(
            urgencyOrder[urgencyB] ?? 2,
          );
        });
        break;

      default: // newest
        filtered.sort((a, b) {
          final timeA = a['postedTime'];
          final timeB = b['postedTime'];
          if (timeA == null || timeB == null) return 0;
          return timeB.compareTo(timeA);
        });
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final List<Map<String, dynamic>> allProjects = postProvider.posts;
    final filteredProjects = getFilteredProjects(allProjects, userProvider);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Browse Projects',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.black),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),

          // Quick filters
          _buildQuickFilters(),

          // Results count and sort
          _buildResultsHeader(filteredProjects),

          // Projects list
          Expanded(
            child: filteredProjects.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredProjects.length,
                    itemBuilder: (context, index) {
                      return _buildProjectCard(
                        filteredProjects[index],
                        postProvider,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search projects...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[600]!),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          return Container(
            margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category : 'All';
                });
              },
              selectedColor: Colors.blue[100],
              checkmarkColor: Colors.blue[700],
              backgroundColor: Colors.grey[100],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsHeader(List<Map<String, dynamic>> filteredProjects) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${filteredProjects.length} projects found',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          DropdownButton<String>(
            value: _sortBy,
            onChanged: (value) {
              setState(() {
                _sortBy = value!;
              });
            },
            items: [
              DropdownMenuItem(value: 'newest', child: Text('Newest')),
              DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
              DropdownMenuItem(
                value: 'highest_tokens',
                child: Text('Highest Tokens'),
              ),
              DropdownMenuItem(
                value: 'lowest_tokens',
                child: Text('Lowest Tokens'),
              ),
              DropdownMenuItem(value: 'most_bids', child: Text('Most Bids')),
              DropdownMenuItem(value: 'deadline', child: Text('Urgent First')),
            ],
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title, tokens, and bid status indicator
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                    SizedBox(height: 4),
                    Text(
                      project['category'],
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: Colors.green[700],
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${project['tokens']}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Description
          Text(
            project['description'],
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 12),

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
                      border: Border.all(color: Colors.blue[200]!),
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

          // Footer with info and action
          Row(
            children: [
              // Requester info
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.grey[300],
                      child: Icon(
                        Icons.person,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Project info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
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
                        project['deadline'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.people, size: 14, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        '${project['bids']} bids',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(width: 12),

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
                        // Navigate to project details/bidding page
                        _showProjectDetails(project);
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
                        'View',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  void _showProjectDetails(Map<String, dynamic> project) {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final bool hasBid = postProvider.hasBidOnProject(project['id'] ?? '');

    // Navigate to project details page or show detailed modal
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(project['title']),
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
                Text(project['description']),
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
                  _showBidDialog(project, context);
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
                  'Project: ${project['title']}',
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No projects found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search terms',
            style: TextStyle(color: Colors.grey[500]),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _selectedCategory = 'All';
                _selectedSkills.clear();
                _tokenRange = RangeValues(0, 100);
              });
            },
            child: Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = 'All';
                          _selectedSkills.clear();
                          _tokenRange = RangeValues(0, 100);
                        });
                        Navigator.pop(context);
                      },
                      child: Text('Clear All'),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Token range
                      Text(
                        'Token Range',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      RangeSlider(
                        values: _tokenRange,
                        min: 0,
                        max: 200,
                        divisions: 20,
                        labels: RangeLabels(
                          '${_tokenRange.start.round()}',
                          '${_tokenRange.end.round()}',
                        ),
                        onChanged: (values) {
                          setModalState(() {
                            _tokenRange = values;
                          });
                        },
                      ),

                      SizedBox(height: 24),

                      // Skills filter
                      Text(
                        'Required Skills',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: availableSkills.map((skill) {
                          final isSelected = _selectedSkills.contains(skill);
                          return FilterChip(
                            label: Text(skill),
                            selected: isSelected,
                            onSelected: (selected) {
                              setModalState(() {
                                if (selected) {
                                  _selectedSkills.add(skill);
                                } else {
                                  _selectedSkills.remove(skill);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              // Apply button
              Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBidDialog(Map<String, dynamic> project, BuildContext context) {
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
