import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String role;   // 'user' | 'ai'
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
  });

  bool get isUser => role == 'user';

  Map<String, dynamic> toMap() => {
    'role': role,
    'text': text,
    'timestamp': FieldValue.serverTimestamp(),
  };

  factory ChatMessage.fromMap(String id, Map<String, dynamic> m) =>
      ChatMessage(
        id:        id,
        role:      m['role'] ?? 'ai',
        text:      m['text'] ?? '',
        timestamp: (m['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}
