import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PostProjectPage extends StatefulWidget {
  @override
  _PostProjectPageState createState() => _PostProjectPageState();
}

class _PostProjectPageState extends State<PostProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tokensController = TextEditingController();
  final _additionalNotesController = TextEditingController();

  String _selectedCategory = '';
  String _selectedDeadline = '';
  String _selectedUrgency = 'Medium';
  List<String> _selectedSkills = [];
  List<String> _attachments = [];

  bool _isPosting = false;
  int _currentUserTokens = 85; // Get from user data

  final List<String> categories = [
    'Web Development',
    'Mobile Development',
    'Data Science',
    'Design',
    'Writing',
    'Marketing',
    'Other',
  ];

  final List<String> deadlineOptions = [
    '1-2 days',
    '3-5 days',
    '1 week',
    '2 weeks',
    '1 month',
    'Flexible',
  ];

  final List<String> urgencyLevels = ['Low', 'Medium', 'High', 'Urgent'];

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
    'SEO',
    'Social Media',
    'Graphic Design',
    'Video Editing',
    'WordPress',
    'PHP',
    'MongoDB',
    'Firebase',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tokensController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Post New Project',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Token balance indicator
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
                  '$_currentUserTokens tokens',
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
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress indicator
                    _buildProgressIndicator(),
                    SizedBox(height: 24),

                    // Project basics
                    _buildSectionCard('Project Basics', Icons.info_outline, [
                      _buildProjectTitle(),
                      SizedBox(height: 16),
                      _buildCategorySelector(),
                      SizedBox(height: 16),
                      _buildProjectDescription(),
                    ]),
                    SizedBox(height: 16),

                    // Requirements
                    _buildSectionCard('Requirements', Icons.build_outlined, [
                      _buildSkillsSelector(),
                      SizedBox(height: 16),
                      _buildDeadlineAndUrgency(),
                    ]),
                    SizedBox(height: 16),

                    // Token offer
                    _buildSectionCard(
                      'Token Offer',
                      Icons.monetization_on_outlined,
                      [
                        _buildTokensInput(),
                        SizedBox(height: 12),
                        _buildTokenGuidance(),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Additional details
                    _buildSectionCard(
                      'Additional Details',
                      Icons.note_outlined,
                      [_buildAdditionalNotes()],
                    ),
                    SizedBox(height: 16),

                    // Preview card
                    _buildPreviewCard(),
                    SizedBox(height: 100), // Space for floating button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildPostButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildProgressIndicator() {
    double progress = _calculateProgress();
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Project Setup Progress',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            color: Colors.blue[600],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue[600], size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildProjectTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project Title *',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'e.g., Build a responsive e-commerce website',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue[600]!),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a project title';
            }
            if (value.length < 10) {
              return 'Title should be at least 10 characters';
            }
            return null;
          },
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category *',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCategory.isEmpty ? null : _selectedCategory,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: 'Select project category',
            ),
            items: categories
                .map(
                  (category) =>
                      DropdownMenuItem(value: category, child: Text(category)),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value ?? '';
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a category';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProjectDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project Description *',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText:
                'Describe your project in detail...\n\n• What exactly needs to be done?\n• What deliverables do you expect?\n• Any specific requirements or preferences?',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue[600]!),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please provide a project description';
            }
            if (value.length < 50) {
              return 'Description should be at least 50 characters';
            }
            return null;
          },
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildSkillsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Skills *',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedSkills.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedSkills
                      .map(
                        (skill) => Chip(
                          label: Text(skill, style: TextStyle(fontSize: 12)),
                          deleteIcon: Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _selectedSkills.remove(skill);
                            });
                          },
                          backgroundColor: Colors.blue[100],
                        ),
                      )
                      .toList(),
                ),
                SizedBox(height: 12),
              ],
              GestureDetector(
                onTap: _showSkillsDialog,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.add, color: Colors.blue[600]),
                      SizedBox(width: 8),
                      Text(
                        _selectedSkills.isEmpty
                            ? 'Select required skills'
                            : 'Add more skills',
                        style: TextStyle(color: Colors.blue[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_selectedSkills.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Please select at least one skill',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDeadlineAndUrgency() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deadline *',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedDeadline.isEmpty ? null : _selectedDeadline,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    hintText: 'Select deadline',
                  ),
                  items: deadlineOptions
                      .map(
                        (deadline) => DropdownMenuItem(
                          value: deadline,
                          child: Text(deadline),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDeadline = value ?? '';
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Urgency',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedUrgency,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: urgencyLevels
                      .map(
                        (urgency) => DropdownMenuItem(
                          value: urgency,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getUrgencyColor(urgency),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(urgency),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUrgency = value ?? 'Medium';
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTokensInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Token Offer *',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _tokensController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: 'Enter token amount',
            prefixIcon: Icon(Icons.monetization_on, color: Colors.green[600]),
            suffixText: 'tokens',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue[600]!),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter token amount';
            }
            final tokens = int.tryParse(value);
            if (tokens == null || tokens <= 0) {
              return 'Please enter a valid amount';
            }
            if (tokens > _currentUserTokens) {
              return 'Insufficient tokens (You have $_currentUserTokens)';
            }
            return null;
          },
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildTokenGuidance() {
    final enteredTokens = int.tryParse(_tokensController.text) ?? 0;
    String guidance = '';
    Color guidanceColor = Colors.grey[600]!;

    if (enteredTokens > 0) {
      if (enteredTokens < 20) {
        guidance = 'Low offer - may receive fewer bids';
        guidanceColor = Colors.orange;
      } else if (enteredTokens < 50) {
        guidance = 'Fair offer - good for simple projects';
        guidanceColor = Colors.green;
      } else if (enteredTokens < 100) {
        guidance = 'Competitive offer - attracts quality freelancers';
        guidanceColor = Colors.blue;
      } else {
        guidance = 'High offer - perfect for complex projects';
        guidanceColor = Colors.purple;
      }
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                'Token Guidance',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (guidance.isNotEmpty)
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: guidanceColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  guidance,
                  style: TextStyle(color: guidanceColor, fontSize: 12),
                ),
              ],
            )
          else
            Text(
              '• Simple tasks: 20-40 tokens\n• Medium projects: 50-80 tokens\n• Complex work: 100+ tokens',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildAdditionalNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _additionalNotesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText:
                'Any additional requirements, preferences, or information...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue[600]!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewCard() {
    if (_titleController.text.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview, color: Colors.blue[600]),
              SizedBox(width: 8),
              Text(
                'Preview',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titleController.text,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                if (_selectedCategory.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    _selectedCategory,
                    style: TextStyle(color: Colors.blue[600], fontSize: 12),
                  ),
                ],
                if (_descriptionController.text.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text(
                    _descriptionController.text,
                    style: TextStyle(color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (_selectedSkills.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children: _selectedSkills
                        .take(3)
                        .map(
                          (skill) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              skill,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (_tokensController.text.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_selectedDeadline.isNotEmpty)
                        Text(
                          _selectedDeadline,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_tokensController.text} tokens',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostButton() {
    final isFormValid =
        _titleController.text.isNotEmpty &&
        _selectedCategory.isNotEmpty &&
        _descriptionController.text.length >= 50 &&
        _selectedSkills.isNotEmpty &&
        _selectedDeadline.isNotEmpty &&
        _tokensController.text.isNotEmpty &&
        (int.tryParse(_tokensController.text) ?? 0) <= _currentUserTokens;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: isFormValid ? _postProject : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: _isPosting ? 0 : 4,
        ),
        child: _isPosting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Posting Project...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Text(
                'Post Project',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  void _showSkillsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        List<String> tempSelectedSkills = List.from(_selectedSkills);
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text('Select Skills'),
            content: Container(
              width: double.maxFinite,
              height: 300,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableSkills.map((skill) {
                    final isSelected = tempSelectedSkills.contains(skill);
                    return FilterChip(
                      label: Text(skill),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() {
                          if (selected) {
                            tempSelectedSkills.add(skill);
                          } else {
                            tempSelectedSkills.remove(skill);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedSkills = tempSelectedSkills;
                  });
                  Navigator.pop(context);
                },
                child: Text('Done'),
              ),
            ],
          ),
        );
      },
    );
  }
  void _postProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isPosting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      // Create a post object
      final postData = {
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "category": _selectedCategory,
        "skills": _selectedSkills,
        "deadline": _selectedDeadline,
        "urgency": _selectedUrgency,
        "tokens": int.parse(_tokensController.text),
        "notes": _additionalNotesController.text.trim(),
        "attachments": _attachments,
        "ownerId": user.uid, // Who created the post
        "createdAt": FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await FirebaseFirestore.instance.collection("posts").add(postData);

      // Success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: Text('Project Posted!'),
          content: Text(
            'Your project "${_titleController.text}" has been posted successfully.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back
              },
              child: Text('Great!'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error posting project: $e")));
    }

    setState(() {
      _isPosting = false;
    });
  }

  double _calculateProgress() {
    double progress = 0;
    if (_titleController.text.isNotEmpty) progress += 0.2;
    if (_selectedCategory.isNotEmpty) progress += 0.15;
    if (_descriptionController.text.length >= 50) progress += 0.2;
    if (_selectedSkills.isNotEmpty) progress += 0.15;
    if (_selectedDeadline.isNotEmpty) progress += 0.1;
    if (_tokensController.text.isNotEmpty &&
        (int.tryParse(_tokensController.text) ?? 0) > 0)
      progress += 0.2;
    return progress.clamp(0.0, 1.0);
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.red;
      case 'Urgent':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
