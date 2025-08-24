import 'package:flutter/material.dart';
import 'package:hackathonpro/provider/post_provider.dart';
import 'package:hackathonpro/provider/user_provider.dart';
import '../../api_key.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ChatbotWidget extends StatefulWidget {
  final ScrollController? scrollController;
  const ChatbotWidget({Key? key, this.scrollController}) : super(key: key);

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  late final ScrollController _scrollController;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
  }

  /// Gemini API call
  Future<String> fetchMiddlemanAnswer(String prompt) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$projectAiApiKey',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {'parts': [{'text': prompt}]},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      try {
        return data['candidates'][0]['content']['parts'][0]['text'] ?? 'No answer found.';
      } catch (e) {
        return 'No answer found.';
      }
    } else {
      return 'Error: ${response.body}';
    }
  }

  /// Format AI response to be user-friendly
  String formatMiddlemanResponse(String raw) {
    if (raw.isEmpty) return 'No advice available.';

    List<String> lines = raw.split('\n');
    List<String> formatted = [];

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.toLowerCase().contains('project:')) {
        formatted.add('1️⃣ **${line.replaceAll("Project:", "").trim()}**');
      } else if (line.toLowerCase().contains('description:')) {
        formatted.add('   🔹 **Description:** ${line.split(':')[1].trim()}');
      } else if (line.toLowerCase().contains('current bidders:')) {
        formatted.add('   🔹 **Current Bidders:** ${line.split(':')[1].trim()}');
      } else if (line.toLowerCase().contains('why')) {
        formatted.add('   🔹 **Why this fits you:** ${line.split(':')[1].trim()}');
      } else if (line.toLowerCase().contains('next steps')) {
        formatted.add('\n📝 **Next Steps**');
      } else if (line.startsWith('1.') || line.startsWith('2.') || line.startsWith('3.') || line.startsWith('4.')) {
        formatted.add('✅ ' + line.substring(2).trim());
      } else {
        formatted.add(line);
      }
    }

    return formatted.join('\n');
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final user = userProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User info not loaded yet.")),
      );
      return;
    }

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
      _controller.clear();
    });

    // Build dynamic project summary
    String projectSummary = '';
    for (var project in postProvider.posts) {
      projectSummary +=
          'Project: ${project['title']}\n'
          'Description: ${project['description']}\n'
          'Current Bidders: ${project['bids'] ?? 0}\n'
          'Why this fits you: Matches your skills and tokens.\n\n';
    }

    // Build AI prompt
    String prompt = '''
You are CollabHub's professional middleman assistant. Provide clear guidance on projects, bids, deadlines, tokens, and strategies.

User info:
- Name: ${user.firstname} ${user.lastname}
- Tokens: ${user.token}
- Completed projects: ${user.completedprojects}
- Total projects: ${user.totalprojects}
- Skills: ${user.skills.join(', ')}
- Rating: ${user.rating}

Projects:
$projectSummary

User question: "$text"

Guidelines:
- Explain project requirements clearly.
- Suggest bid strategy based on user's skills and current bidders.
- Highlight deadlines, tokens, and progress.
- Maintain a professional, friendly, and neutral tone.
- Format output using headings, bullets, and emojis for readability.
''';

    String aiResponse = await fetchMiddlemanAnswer(prompt);
    aiResponse = formatMiddlemanResponse(aiResponse);

    setState(() {
      _messages.add({'role': 'ai', 'text': aiResponse});
      _isLoading = false;
    });

    // Scroll to bottom
    await Future.delayed(Duration(milliseconds: 100));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.handshake, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text('CollabHub Assistant',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, idx) {
                final msg = _messages[idx];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: isUser
                          ? Border.all(color: Colors.blueAccent.withOpacity(0.3))
                          : Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Text(msg['text'] ?? ''),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) ...[
            SizedBox(height: 8),
            CircularProgressIndicator(),
          ],
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Ask about bids, projects, or strategy...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.send, color: Colors.blueAccent),
                onPressed: _isLoading ? null : _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
