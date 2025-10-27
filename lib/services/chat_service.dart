import '../models/conversation.dart';
import '../models/chat_message.dart';
import 'base_service.dart';

class ChatService extends BaseService {
  ChatService() : super();

  // Send a message to the chatbot
  Future<Map<String, dynamic>> sendMessage({
    required String message,
    String? conversationId,
  }) async {
    // Build request data
    final requestData = <String, dynamic>{
      'message': message,
    };

    // Add conversation_id as integer if provided
    if (conversationId != null && conversationId.isNotEmpty) {
      final conversationIdInt = int.tryParse(conversationId);
      if (conversationIdInt != null) {
        requestData['conversation_id'] = conversationIdInt;
      }
    }

    print('Sending chat message: $requestData');

    final response = await client.post(
      '/ai/chat/',
      data: requestData,
    );

    print('Chat response: ${response.data}');
    return response.data;
  }

  // Get all conversations
  Future<List<Conversation>> getConversations() async {
    final response = await client.get('/ai/conversations/');
    final data = response.data;

    List<Conversation> conversations = [];
    if (data['data'] != null && data['data'] is List) {
      conversations = (data['data'] as List)
          .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return conversations;
  }

  // Get a specific conversation with messages
  Future<Conversation> getConversation(String conversationId) async {
    final response = await client.get('/ai/conversations/$conversationId/');
    final data = response.data;

    if (data['data'] != null) {
      return Conversation.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Conversation not found');
  }

  // Create a new conversation
  Future<Conversation> createConversation(String title) async {
    final response = await client.post(
      '/ai/conversations/create/',
      data: {'title': title},
    );
    final data = response.data;

    if (data['data'] != null) {
      return Conversation.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to create conversation');
  }

  // Delete a conversation
  Future<bool> deleteConversation(String conversationId) async {
    try {
      final response = await client.delete('/ai/conversations/$conversationId/delete/');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
