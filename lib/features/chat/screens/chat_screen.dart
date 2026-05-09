import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌾 ruz.ai Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              context.read<ChatProvider>().clearChat();
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.messages.length + (provider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.messages.length) {
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('ruz.ai sedang mengetik...'),
                        ),
                      );
                    }
                    final msg = provider.messages[index];
                    return _buildChatBubble(msg);
                  },
                );
              },
            ),
          ),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Align(
      alignment: message.isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isFromUser ? AppColors.primary : AppColors.cardBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isFromUser ? 16 : 0),
            bottomRight: Radius.circular(message.isFromUser ? 0 : 16),
          ),
          border: message.isFromUser ? null : Border.all(color: Colors.grey.shade300),
        ),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isFromUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              provider.isListening ? Icons.mic : Icons.mic_none,
              color: provider.isListening ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              if (provider.isListening) {
                // stop listening if possible
              } else {
                provider.startVoiceInput();
              }
            },
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: provider.isListening ? 'Mendengarkan...' : 'Ketik pesan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onSubmitted: (val) {
                if (val.isNotEmpty) {
                  provider.sendMessage(val);
                  _controller.clear();
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.primary),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                provider.sendMessage(_controller.text);
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
