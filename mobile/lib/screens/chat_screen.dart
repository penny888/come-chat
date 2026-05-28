// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  String? _conversationId;
  bool _useRag = false;
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _controller.clear();
      _isLoading = true;
      _messages.add({'role': 'assistant', 'content': ''}); // 占位
    });
    _scrollToBottom();

    String fullReply = '';
    try {
      log('input text: ' + text);
      final stream = ApiService().streamChat(text, _conversationId, _useRag);
      await for (final chunk in stream) {
        fullReply += chunk;
        setState(() {
          _messages.last['content'] = fullReply;
        });
        _scrollToBottom();
      }
      // 对话ID可以从响应中获取，此处简化
    } catch (e) {
      setState(() {
        _messages.last['content'] = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Come Chat'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          Row(
            children: [
              const Text('知识库'),
              Switch(
                value: _useRag,
                onChanged: (val) => setState(() => _useRag = val),
                activeThumbColor: Colors.blue,
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 消息列表区域
          Expanded(
            child: _messages.isEmpty
                ? _buildWelcomeScreen()
                : ListView.builder(
                    controller: _scrollController,
                    reverse: false,
                    itemCount: _messages.length,
                    itemBuilder: (ctx, idx) {
                      final msg = _messages[idx];
                      final isUser = msg['role'] == 'user';
                      return _buildMessageBubble(msg['content']!, isUser);
                    },
                  ),
          ),
          // 输入区域（优化）
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🤖', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            '你好，我是 AI 助手',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            '我可以帮你解答问题、整理信息、提供创意',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: const [
              SuggestionChip('如何开始创建Roblox游戏？'),
              SuggestionChip('帮我整理50个英语日常交流中最常用的短句'),
              SuggestionChip('推荐几个Docker容器管理工具'),
              SuggestionChip('怎样通过笔记构建个人知识体系？'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String content, bool isUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Text(
                'AI',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue[100] : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
              ),
              child: isUser
                  ? Text(content, style: const TextStyle(fontSize: 16))
                  : MarkdownBody(
                      data: content,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(fontSize: 16),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          if (isUser)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '输入你的问题...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
              enabled: !_isLoading,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: _isLoading ? Colors.grey : Colors.blue,
            radius: 28,
            child: IconButton(
              icon: Icon(_isLoading ? Icons.hourglass_empty : Icons.send),
              color: Colors.white,
              onPressed: _isLoading ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

// 推荐问题组件
class SuggestionChip extends StatelessWidget {
  final String label;
  const SuggestionChip(this.label, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        final chatState = context.findAncestorStateOfType<_ChatScreenState>();
        chatState?._controller.text = label;
        chatState?._sendMessage();
      },
      backgroundColor: Colors.grey[200],
      shape: StadiumBorder(),
    );
  }
}
