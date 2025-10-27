import 'chat_message.dart';

class Conversation {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage> messages;
  final int messageCount;
  final ChatMessage? lastMessage;

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
    required this.messageCount,
    this.lastMessage,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    List<ChatMessage> messages = [];
    if (json['messages'] != null) {
      messages = (json['messages'] as List)
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList();
    }

    ChatMessage? lastMessage;
    if (json['last_message'] != null) {
      lastMessage = ChatMessage.fromJson(json['last_message'] as Map<String, dynamic>);
    }

    return Conversation(
      id: json['id'].toString(),
      title: json['title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      messages: messages,
      messageCount: json['message_count'] as int? ?? messages.length,
      lastMessage: lastMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'message_count': messageCount,
      if (lastMessage != null) 'last_message': lastMessage!.toJson(),
    };
  }

  Conversation copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ChatMessage>? messages,
    int? messageCount,
    ChatMessage? lastMessage,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      messageCount: messageCount ?? this.messageCount,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}
