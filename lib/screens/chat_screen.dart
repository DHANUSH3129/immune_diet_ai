import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../services/firestore_service.dart';
import '../services/claude_service.dart';
import '../models/chat_message.dart';
import '../utils/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl    = TextEditingController();
  final _scroll  = ScrollController();
  final _fs      = FirestoreService();
  final _claude  = ClaudeService();
  bool  _typing  = false;

  // Local chat history for Claude context
  final List<Map<String, String>> _localHistory = [];

  final _suggestions = [
    'What foods boost my immunity?',
    'Best foods for Vitamin D?',
    'Iron-rich vegetarian foods?',
    'How to reduce inflammation?',
    'Weekly meal plan tips?',
  ];

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _ctrl.clear();
    final uid = context.read<AppProvider>().user?.uid;
    if (uid == null) return;

    // Save user message to Firestore
    await _fs.sendMessage(uid, 'user', text);
    _localHistory.add({'role': 'user', 'text': text});

    setState(() => _typing = true);
    _scrollDown();

    try {
      // Get Claude AI response with full conversation context
      final reply = await _claude.chat(
        text,
        _localHistory.length > 1
            ? _localHistory.sublist(0, _localHistory.length - 1)
            : [],
        null, // Pass report analysis if available
      );

      // Save AI reply to Firestore
      await _fs.sendMessage(uid, 'ai', reply);
      _localHistory.add({'role': 'assistant', 'text': reply});
    } catch (e) {
      await _fs.sendMessage(uid, 'ai', 'Sorry, I could not connect right now. Please check your internet connection.');
    }

    setState(() => _typing = false);
    _scrollDown();
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AppProvider>().user?.uid;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(children: [

        // Header
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEDE8F8), Color(0xFFE8F8EF)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 20),
          child: Row(children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.mintDark, AppColors.lavenderDark]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Immune AI Coach',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 20)),
              Row(children: [
                Container(width: 6, height: 6,
                    decoration: const BoxDecoration(color: AppColors.mintDark, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text('Claude AI · Real-time conversation',
                    style: TextStyle(fontSize: 11, color: AppColors.mintDark, fontWeight: FontWeight.w600)),
              ]),
            ]),
          ]),
        ),

        // Chat messages from Firestore (real-time stream)
        Expanded(child: uid == null
            ? const Center(child: Text('Please log in'))
            : StreamBuilder<List<ChatMessage>>(
          stream: _fs.chatStream(uid),
          builder: (ctx, snap) {
            final msgs = snap.data ?? [];
            return ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: msgs.length + (_typing ? 1 : 0) + (msgs.isEmpty ? 1 : 0),
              itemBuilder: (_, i) {
                // Welcome bubble
                if (msgs.isEmpty && i == 0) {
                  return _aiBubble(
                      'Hi! I\'m your Immune Diet AI Coach powered by Claude AI 🛡️\n\n'
                          'I can help you with:\n'
                          '• Personalised nutrition advice\n'
                          '• Immunity-boosting foods\n'
                          '• Meal planning tips\n\n'
                          'Upload your lab report in the Profile tab for personalised advice!'
                  );
                }
                if (i < msgs.length) {
                  return msgs[i].isUser
                      ? _userBubble(msgs[i].text)
                      : _aiBubble(msgs[i].text);
                }
                return _typingBubble();
              },
            );
          },
        )),

        // Suggestion chips
        if (!_typing)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: _suggestions.map((s) => GestureDetector(
                onTap: () => _send(s),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.mintMid, width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
                  ),
                  child: Text(s, style: const TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w600, color: AppColors.mintDeep)),
                ),
              )).toList(),
            ),
          ),

        // Input row
        Container(
          color: AppColors.cream,
          padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _ctrl,
              onSubmitted: _send,
              maxLines: null,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: 'Ask about nutrition, immunity, meals...',
                hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
                filled: true, fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.mintMid, width: 1.5)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.mintMid, width: 1.5)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.mintDark, width: 1.5)),
              ),
            )),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _send(_ctrl.text),
              child: Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.mintDark, AppColors.lavenderDark]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _userBubble(String text) => Align(
    alignment: Alignment.centerRight,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10, left: 60),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.mintDark, AppColors.lavenderDark]),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18), topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18), bottomRight: Radius.circular(4),
        ),
      ),
      child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.5)),
    ),
  );

  Widget _aiBubble(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10, right: 60),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4), topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.55)),
    ),
  );

  Widget _typingBubble() => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('Claude is thinking', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
        const SizedBox(width: 8),
        ...List.generate(3, (i) => _dot(i)),
      ]),
    ),
  );

  Widget _dot(int i) => TweenAnimationBuilder<double>(
    key: ValueKey(i),
    tween: Tween(begin: 0.0, end: 1.0),
    duration: Duration(milliseconds: 600 + i * 150),
    builder: (_, v, __) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 6, height: 6,
      decoration: BoxDecoration(
          color: Color.lerp(AppColors.mintMid, AppColors.mintDark, v),
          shape: BoxShape.circle),
    ),
  );
}