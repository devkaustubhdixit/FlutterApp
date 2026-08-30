import 'package:flutter/material.dart';
import 'gemini_service.dart';

/// The page your homepage button navigates to.
/// Usage from homepage:
///   Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantPage()));
class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _Message {
  final String text;
  final bool isUser;
  _Message(this.text, this.isUser);
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  final GeminiService _gemini = GeminiService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_Message> _messages = [
    _Message("Hello! I'm here to chat with you. How are you feeling today?", false),
  ];
  bool _isSending = false;

  static const _bgColor = Color(0xFFF4F7F5);
  static const _botBubbleColor = Color(0xFFDDEBE3);
  static const _userBubbleColor = Color(0xFFE3E9F5);
  static const _textColor = Color(0xFF2C2C2C);
  static const double _fontSize = 22;

  void _showEscalationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Let\'s get some help', style: TextStyle(fontSize: 20)),
        content: const Text(
          'It sounds like you might need some support right now. Would you like me to call your caregiver?',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not now', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: hook up to actual caregiver contact (phone call, SMS,
              // or a push notification to a paired caregiver app/account).
            },
            child: const Text('Call caregiver', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _isSending) return;

    final needsEscalation = _gemini.messageNeedsEscalation(text);

    setState(() {
      _messages.add(_Message(text, true));
      _isSending = true;
    });
    _controller.clear();
    _scrollToBottom();

    if (needsEscalation) {
      // Escalate immediately based on local keyword check, don't wait
      // on the model's response for something potentially urgent.
      _showEscalationDialog();
    }

    try {
      final reply = await _gemini.sendMessage(text);
      setState(() => _messages.add(_Message(reply, false)));
    } catch (e) {
        debugPrint('Gemini error: $e');
        setState(() => _messages.add(_Message('Debug error: $e', false)));
//      setState(() => _messages.add(_Message(
//          "I'm having a little trouble right now. Let's try again in a moment.",
//          false)));
    } finally {
      setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text('Chat', style: TextStyle(fontSize: 24)),
        backgroundColor: _bgColor,
        elevation: 0,
        foregroundColor: _textColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _showEscalationDialog,
              icon: const Icon(Icons.phone, size: 20),
              label: const Text('Call for help'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                return Align(
                  alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: m.isUser ? _userBubbleColor : _botBubbleColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      m.text,
                      style: const TextStyle(fontSize: _fontSize, color: _textColor, height: 1.35),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isSending) const LinearProgressIndicator(minHeight: 3),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(fontSize: _fontSize),
                      textInputAction: TextInputAction.send,
                      onSubmitted: _send,
                      decoration: InputDecoration(
                        hintText: 'Type here...',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _send(_controller.text),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}