import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProjectBidsPage extends StatelessWidget {
  final String projectId;
  final String projectTitle;

  ProjectBidsPage({required this.projectId, required this.projectTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bids for $projectTitle'), centerTitle: true),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(projectId)
            .collection('bids')
            .orderBy('submittedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final bids = snapshot.data!.docs;

          if (bids.isEmpty) {
            return Center(child: Text('No bids yet'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: bids.length,
            itemBuilder: (context, index) {
              final bid = bids[index].data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(bid['bidderName'] ?? 'Unknown'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bid: ${bid['bidAmount']} tokens'),
                      Text('Message: ${bid['message']}'),
                      Text('Status: ${bid['status']}'),
                    ],
                  ),
                  trailing: bid['status'] == 'pending'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () => _acceptBid(
                                context,
                                projectId,
                                bids[index].id,
                              ),
                              child: Text('Accept'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _rejectBid(
                                context,
                                projectId,
                                bids[index].id,
                              ),
                              child: Text('Reject'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _acceptBid(BuildContext context, String projectId, String bidId) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(projectId)
          .collection('bids')
          .doc(bidId)
          .update({'status': 'accepted'});

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(projectId)
          .update({'status': 'assigned'});

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Bid accepted successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error accepting bid: $e')));
    }
  }

  void _rejectBid(BuildContext context, String projectId, String bidId) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(projectId)
          .collection('bids')
          .doc(bidId)
          .update({'status': 'rejected'});

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Bid rejected successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error rejecting bid: $e')));
    }
  }
}
