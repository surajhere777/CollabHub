import 'package:flutter/material.dart';

class MyWorkPage extends StatefulWidget {
  @override
  _MyWorkPageState createState() => _MyWorkPageState();
}

class _MyWorkPageState extends State<MyWorkPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  // Sample data - replace with your actual data
  final List<Map<String, dynamic>> myProjects = [
    {
      'title': 'Website Design for Restaurant',
      'tokens': 60,
      'bids': 8,
      'status': 'active',
      'posted': '2 days ago',
      'deadline': '1 week',
    },
    {
      'title': 'Data Analysis Project',
      'tokens': 45,
      'bids': 3,
      'status': 'in_progress',
      'posted': '1 week ago',
      'deadline': '3 days',
      'assignedTo': 'Sarah Kim',
    },
    {
      'title': 'Mobile App UI Design',
      'tokens': 80,
      'bids': 0,
      'status': 'completed',
      'posted': '3 weeks ago',
      'completedDate': '5 days ago',
      'assignedTo': 'Mike Chen',
    },
  ];

  final List<Map<String, dynamic>> myBids = [
    {
      'title': 'E-commerce Website',
      'myBid': 75,
      'totalBids': 12,
      'status': 'pending',
      'bidDate': '1 day ago',
      'deadline': '2 weeks',
      'client': 'Alex Johnson',
    },
    {
      'title': 'Logo Design',
      'myBid': 35,
      'totalBids': 6,
      'status': 'accepted',
      'bidDate': '3 days ago',
      'deadline': '1 week',
      'client': 'Emma Davis',
    },
    {
      'title': 'Python Script',
      'myBid': 25,
      'totalBids': 15,
      'status': 'rejected',
      'bidDate': '1 week ago',
      'deadline': 'Not specified',
      'client': 'John Smith',
    },
  ];

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
            Tab(text: 'My Projects'),
            Tab(text: 'My Bids'),
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
    if (myProjects.isEmpty) {
      return _buildEmptyState(
        'No Projects Yet',
        'Start by posting your first project',
        Icons.work_outline,
        'Post Project',
        () {
          // Navigate to post project page
        },
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: myProjects.length,
      itemBuilder: (context, index) {
        return _buildProjectCard(myProjects[index]);
      },
    );
  }

  Widget _buildMyBids() {
    if (myBids.isEmpty) {
      return _buildEmptyState(
        'No Bids Yet',
        'Browse projects and place your first bid',
        Icons.gavel,
        'Browse Projects',
        () {
          // Navigate to browse page
        },
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: myBids.length,
      itemBuilder: (context, index) {
        return _buildBidCard(myBids[index]);
      },
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
                    ? 'Completed ${project['completedDate']}'
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
        return TextButton(
          onPressed: () {
            // View bids
          },
          child: Text('View Bids (${project['bids']})'),
        );
      case 'in_progress':
        return TextButton(
          onPressed: () {
            // View progress
          },
          child: Text('View Progress'),
        );
      case 'completed':
        return TextButton(
          onPressed: () {
            // View details
          },
          child: Text('View Details'),
        );
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildBidAction(Map<String, dynamic> bid) {
    switch (bid['status']) {
      case 'pending':
        return TextButton(
          onPressed: () {
            // Edit bid or withdraw
          },
          child: Text('Edit Bid'),
        );
      case 'accepted':
        return TextButton(
          onPressed: () {
            // Start work
          },
          child: Text('Start Work'),
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
