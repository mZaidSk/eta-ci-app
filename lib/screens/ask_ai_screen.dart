import 'package:flutter/material.dart';

class AskAiScreen extends StatefulWidget {
  const AskAiScreen({super.key});
  static const routeName = '/ask-ai';

  @override
  State<AskAiScreen> createState() => _AskAiScreenState();
}

class _AskAiScreenState extends State<AskAiScreen> {
  final _controller = TextEditingController();
  final List<_AiMessage> _messages = <_AiMessage>[];
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_controller.text.trim().isEmpty) return;
    final prompt = _controller.text.trim();
    setState(() {
      _sending = true;
      _messages.add(_AiMessage(role: 'you', text: prompt));
      _controller.clear();
    });
    await Future<void>.delayed(const Duration(milliseconds: 600));
    setState(() {
      _messages.add(_AiMessage(role: 'ai', text: 'This is a placeholder response about "$prompt".'));
      _sending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ask AI')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                final isAi = m.role == 'ai';
                return Align(
                  alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isAi ? Theme.of(context).colorScheme.surfaceContainerHighest : Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(m.text),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Ask about savings, budgets, or transactions...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _sending ? null : _send,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Send'),
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

class _AiMessage {
  _AiMessage({required this.role, required this.text});

  final String role;
  final String text;
}


