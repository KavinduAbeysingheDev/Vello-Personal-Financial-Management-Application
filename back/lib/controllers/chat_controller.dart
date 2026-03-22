import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/chatbot_service.dart';

/// HTTP controller for the chat API endpoints.
class ChatController {
  final ChatbotService _chatbotService = ChatbotService();

  /// Create the router with all chat endpoints.
  Router get router {
    final router = Router();

    // POST /api/chat — Process a chat message
    router.post('/chat', _handleChatMessage);

    // GET /api/chat/health — Health check endpoint
    router.get('/chat/health', _handleHealthCheck);

    // GET /api/chat/quick-replies — Get default quick replies
    router.get('/chat/quick-replies', _handleQuickReplies);

    return router;
  }

  /// Handle incoming chat messages.
  /// Expects: { "message": "...", "userId": "..." }
  /// Returns: ChatMessage JSON with bot response
  Future<Response> _handleChatMessage(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      final message = json['message'] as String?;
      final userId = json['userId'] as String?;

      if (message == null || message.trim().isEmpty) {
        return _jsonResponse(
          {'error': 'Message is required'},
          status: 400,
        );
      }

      // Process the message through the chatbot service
      final response = _chatbotService.processMessage(
        message.trim(),
        userId: userId,
      );

      return _jsonResponse({
        'success': true,
        'data': response.toJson(),
      });
    } on FormatException {
      return _jsonResponse(
        {'error': 'Invalid JSON body'},
        status: 400,
      );
    } catch (e) {
      print('Error processing chat message: $e');
      return _jsonResponse(
        {'error': 'Internal server error'},
        status: 500,
      );
    }
  }

  /// Health check endpoint.
  Future<Response> _handleHealthCheck(Request request) async {
    return _jsonResponse({
      'status': 'healthy',
      'service': 'Vello AI Chatbot',
      'version': '1.0.0',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Get default quick reply options.
  Future<Response> _handleQuickReplies(Request request) async {
    return _jsonResponse({
      'quickReplies': [
        'Analyze my spending',
        'Budget recommendations',
        'Weekly summary',
        'Savings tips',
      ],
    });
  }

  /// Create a JSON response with proper headers.
  Response _jsonResponse(Map<String, dynamic> body, {int status = 200}) {
    return Response(
      status,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
