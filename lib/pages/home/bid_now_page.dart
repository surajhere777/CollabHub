import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BidDialog extends StatefulWidget {
  final Map<String, dynamic> project;
  final Function(Map<String, dynamic> bidData)? onBidSubmitted;

  const BidDialog({
    Key? key,
    required this.project,
    this.onBidSubmitted,
  }) : super(key: key);

  @override
  _BidDialogState createState() => _BidDialogState();
}

class _BidDialogState extends State<BidDialog> {
  final _formKey = GlobalKey<FormState>();
  final _bidAmountController = TextEditingController();
  final _deliveryTimeController = TextEditingController();
  final _proposalController = TextEditingController();
  
  bool _isSubmitting = false;
  String _selectedDeliveryUnit = 'days';
  
  final List<String> _deliveryUnits = ['days', 'weeks', 'months'];

  @override
  void dispose() {
    _bidAmountController.dispose();
    _deliveryTimeController.dispose();
    _proposalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Submit Your Bid',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // Project info card
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.project['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Budget: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${widget.project['tokens']} tokens',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Deadline: ${widget.project['deadline']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                
                // Bid amount
                Text(
                  'Your Bid Amount',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _bidAmountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Enter your bid in tokens',
                    prefixIcon: Icon(Icons.monetization_on, color: Colors.green[600]),
                    suffixText: 'tokens',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue[600]!),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your bid amount';
                    }
                    final bidAmount = int.tryParse(value);
                    if (bidAmount == null || bidAmount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    if (bidAmount > widget.project['tokens']) {
                      return 'Bid cannot exceed project budget';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                // Delivery time
                Text(
                  'Delivery Time',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _deliveryTimeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          hintText: 'Time',
                          prefixIcon: Icon(Icons.schedule, color: Colors.orange[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.blue[600]!),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final time = int.tryParse(value);
                          if (time == null || time <= 0) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: _selectedDeliveryUnit,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.blue[600]!),
                          ),
                        ),
                        items: _deliveryUnits.map((String unit) {
                          return DropdownMenuItem<String>(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedDeliveryUnit = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // Proposal/Cover letter
                Text(
                  'Your Proposal',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _proposalController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Explain why you\'re the best fit for this project...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue[600]!),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please write a proposal';
                    }
                    if (value.trim().length < 20) {
                      return 'Proposal should be at least 20 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 8),
                Text(
                  'Tip: Mention your relevant experience and how you plan to approach this project',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 24),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(color: Colors.grey[400]!),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitBid,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Submit Bid',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitBid() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Prepare bid data
      final bidData = {
        'projectId': widget.project['id'],
        'bidAmount': int.parse(_bidAmountController.text),
        'deliveryTime': int.parse(_deliveryTimeController.text),
        'deliveryUnit': _selectedDeliveryUnit,
        'proposal': _proposalController.text.trim(),
        'submittedAt': DateTime.now().toIso8601String(),
      };

      // Simulate API call
      await Future.delayed(Duration(seconds: 1));

      setState(() {
        _isSubmitting = false;
      });

      // Call the callback function if provided
      if (widget.onBidSubmitted != null) {
        widget.onBidSubmitted!(bidData);
      }

      // Close dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Bid submitted successfully!'),
            ],
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}

// Helper function to show the bid dialog
void showBidDialog(BuildContext context, Map<String, dynamic> project, {Function(Map<String, dynamic>)? onBidSubmitted}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return BidDialog(
        project: project,
        onBidSubmitted: onBidSubmitted,
      );
},
);
}
