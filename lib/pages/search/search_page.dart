import 'package:flutter/material.dart';

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

  // Sample projects data - replace with your actual data
  List<Map<String, dynamic>> allProjects = [
    {
      'id': 1,
      'title': 'E-commerce Website Development',
      'description':
          'Need a full-stack e-commerce site with payment integration, user authentication, and admin panel.',
      'tokens': 120,
      'deadline': '2 weeks',
      'category': 'Web Development',
      'requester': 'Sarah Kim',
      'requesterRating': 4.8,
      'skills': ['React', 'Node.js', 'JavaScript'],
      'bids': 5,
      'postedDate': '2024-01-20',
      'urgency': 'medium',
    },
    {
      'id': 2,
      'title': 'Mobile App UI/UX Design',
      'description':
          'Design complete UI/UX for fitness tracking mobile app. Need wireframes, mockups, and prototypes.',
      'tokens': 80,
      'deadline': '1 week',
      'category': 'Design',
      'requester': 'Mike Johnson',
      'requesterRating': 4.6,
      'skills': ['Figma', 'UI/UX', 'Mobile'],
      'bids': 12,
      'postedDate': '2024-01-22',
      'urgency': 'high',
    },
    {
      'id': 3,
      'title': 'Data Analysis for Marketing Campaign',
      'description':
          'Analyze customer data and create insights report with visualizations for marketing strategy.',
      'tokens': 60,
      'deadline': '5 days',
      'category': 'Data Science',
      'requester': 'Emma Davis',
      'requesterRating': 4.9,
      'skills': ['Python', 'Data Analysis'],
      'bids': 8,
      'postedDate': '2024-01-21',
      'urgency': 'high',
    },
    {
      'id': 4,
      'title': 'Blog Content Writing',
      'description':
          'Write 5 SEO-optimized blog posts about sustainable living. Each post should be 1500+ words.',
      'tokens': 45,
      'deadline': '1 week',
      'category': 'Writing',
      'requester': 'Alex Chen',
      'requesterRating': 4.3,
      'skills': ['Writing', 'SEO'],
      'bids': 15,
      'postedDate': '2024-01-19',
      'urgency': 'low',
    },
    {
      'id': 5,
      'title': 'Flutter Mobile App Development',
      'description':
          'Build a cross-platform mobile app for task management with Firebase integration.',
      'tokens': 100,
      'deadline': '3 weeks',
      'category': 'Mobile Development',
      'requester': 'John Smith',
      'requesterRating': 4.7,
      'skills': ['Flutter', 'Firebase', 'Mobile'],
      'bids': 3,
      'postedDate': '2024-01-23',
      'urgency': 'medium',
    },
  ];

  List<Map<String, dynamic>> get filteredProjects {
    List<Map<String, dynamic>> filtered = List.from(allProjects);

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where(
            (project) =>
                project['title'].toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                project['description'].toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ),
          )
          .toList();
    }

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((project) => project['category'] == _selectedCategory)
          .toList();
    }

    // Filter by token range
    filtered = filtered
        .where(
          (project) =>
              project['tokens'] >= _tokenRange.start &&
              project['tokens'] <= _tokenRange.end,
        )
        .toList();

    // Filter by skills
    if (_selectedSkills.isNotEmpty) {
      filtered = filtered.where((project) {
        List<String> projectSkills = List<String>.from(project['skills']);
        return _selectedSkills.any((skill) => projectSkills.contains(skill));
      }).toList();
    }

    // Sort projects
    switch (_sortBy) {
      case 'highest_tokens':
        filtered.sort((a, b) => b['tokens'].compareTo(a['tokens']));
        break;
      case 'lowest_tokens':
        filtered.sort((a, b) => a['tokens'].compareTo(b['tokens']));
        break;
      case 'most_bids':
        filtered.sort((a, b) => b['bids'].compareTo(a['bids']));
        break;
      case 'oldest':
        filtered.sort((a, b) => a['postedDate'].compareTo(b['postedDate']));
        break;
      case 'deadline':
        // Sort by urgency (high, medium, low)
        final urgencyOrder = {'high': 0, 'medium': 1, 'low': 2};
        filtered.sort(
          (a, b) => urgencyOrder[a['urgency']]!.compareTo(
            urgencyOrder[b['urgency']]!,
          ),
        );
        break;
      default: // newest
        filtered.sort((a, b) => b['postedDate'].compareTo(a['postedDate']));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Browse Projects',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
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
          _buildResultsHeader(),

          // Projects list
          Expanded(
            child: filteredProjects.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredProjects.length,
                    itemBuilder: (context, index) {
                      return _buildProjectCard(filteredProjects[index]);
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

  Widget _buildResultsHeader() {
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

  Widget _buildProjectCard(Map<String, dynamic> project) {
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
          // Header with title and tokens
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
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
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project['requester'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, size: 12, color: Colors.amber),
                              SizedBox(width: 2),
                              Text(
                                '${project['requesterRating']}',
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

              // Bid button
              ElevatedButton(
                onPressed: () {
                  // Navigate to project details/bidding page
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'View & Bid',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
}
