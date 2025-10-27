import 'package:flutter/foundation.dart';
import '../models/conversation.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _service = ChatService();

  bool _loading = false;
  bool _sending = false;
  List<Conversation> _conversations = [];
  Conversation? _currentConversation;
  String? _error;

  bool get isLoading => _loading;
  bool get isSending => _sending;
  List<Conversation> get conversations => _conversations;
  Conversation? get currentConversation => _currentConversation;
  String? get error => _error;

  // Fetch all conversations
  Future<void> fetchConversations() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await _service.getConversations();
    } catch (e) {
      _error = e.toString();
      _conversations = [];
      print('Error fetching conversations: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Load a specific conversation
  Future<void> loadConversation(String conversationId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _currentConversation = await _service.getConversation(conversationId);
    } catch (e) {
      _error = e.toString();
      print('Error loading conversation: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Send a message
  Future<bool> sendMessage(String message, {String? conversationId}) async {
    if (message.trim().isEmpty) return false;

    _sending = true;
    _error = null;

    // Add user message optimistically
    final userMessage = ChatMessage(
      role: 'user',
      content: message,
      createdAt: DateTime.now(),
    );

    if (_currentConversation != null) {
      _currentConversation = _currentConversation!.copyWith(
        messages: [..._currentConversation!.messages, userMessage],
      );
    }
    notifyListeners();

    try {
      final response = await _service.sendMessage(
        message: message,
        conversationId: conversationId,
      );

      print('Chat provider received response: $response');

      // Check if response has success flag
      if (response['success'] == false) {
        _error = response['message'] ?? 'Failed to send message';
        _sending = false;
        notifyListeners();
        return false;
      }

      // Extract reply and conversation ID from the data object
      final data = response['data'];
      if (data == null) {
        _error = 'No data received from server';
        _sending = false;
        notifyListeners();
        return false;
      }

      final reply = data['reply'] as String?;
      if (reply == null) {
        _error = 'No reply received from AI';
        _sending = false;
        notifyListeners();
        return false;
      }

      final newConversationId = data['conversation_id'].toString();

      // Create assistant message
      final assistantMessage = ChatMessage(
        role: 'assistant',
        content: reply,
        createdAt: DateTime.now(),
      );

      // Update current conversation with new message
      if (_currentConversation != null) {
        _currentConversation = _currentConversation!.copyWith(
          messages: [..._currentConversation!.messages, assistantMessage],
        );
      } else {
        // Create a new conversation locally if we don't have one
        _currentConversation = Conversation(
          id: newConversationId,
          title: message.length > 50 ? '${message.substring(0, 50)}...' : message,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          messages: [userMessage, assistantMessage],
          messageCount: 2,
          lastMessage: assistantMessage,
        );
      }

      _sending = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error sending message: $e');

      // Extract user-friendly error message
      String errorMessage = 'Failed to send message';
      if (e.toString().contains('500')) {
        errorMessage = 'Server error. Please check your internet connection and try again.';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Chat service not found. Please contact support.';
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        errorMessage = 'Authentication error. Please login again.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timed out. Please try again.';
      }

      _error = errorMessage;
      _sending = false;
      notifyListeners();
      return false;
    }
  }

  // Create a new conversation
  Future<Conversation?> createConversation(String title) async {
    try {
      final conversation = await _service.createConversation(title);
      _conversations.insert(0, conversation);
      _currentConversation = conversation;
      notifyListeners();
      return conversation;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      print('Error creating conversation: $e');
      return null;
    }
  }

  // Delete a conversation
  Future<bool> deleteConversation(String conversationId) async {
    try {
      final success = await _service.deleteConversation(conversationId);
      if (success) {
        _conversations.removeWhere((c) => c.id == conversationId);
        if (_currentConversation?.id == conversationId) {
          _currentConversation = null;
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      print('Error deleting conversation: $e');
      return false;
    }
  }

  // Start a new conversation (clear current)
  void startNewConversation() {
    _currentConversation = null;
    _error = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
