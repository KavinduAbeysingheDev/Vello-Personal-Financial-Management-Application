import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:vello_chatbot_backend/controllers/chat_controller.dart';
import 'package:vello_chatbot_backend/utils/constants.dart';

/// Entry point for the Vello AI Chatbot backend server.
void main(List<String> args) async {
  // Parse port from args or environment or use default
  final port = int.tryParse(
        Platform.environment['PORT'] ?? '',
      ) ??
      (args.isNotEmpty ? int.tryParse(args[0]) : null) ??
      AppConstants.defaultPort;

  // Create the main router
  final app = Router();

  // Mount the chat controller under /api
  final chatController = ChatController();
  app.mount('/api/', chatController.router.call);

  // Root endpoint
  app.get('/', (Request request) {
    return Response.ok(
      '{"service": "Vello AI Chatbot Backend", '
      '"version": "1.0.0", '
      '"status": "running", '
      '"endpoints": {'
      '"chat": "POST /api/chat", '
      '"health": "GET /api/chat/health", '
      '"quickReplies": "GET /api/chat/quick-replies"'
      '}}',
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Build the handler pipeline with CORS and logging
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(
        corsHeaders(
          headers: {
            ACCESS_CONTROL_ALLOW_ORIGIN: '*',
            ACCESS_CONTROL_ALLOW_METHODS: 'GET, POST, OPTIONS',
            ACCESS_CONTROL_ALLOW_HEADERS: 'Origin, Content-Type, Accept',
          },
        ),
      )
      .addHandler(app.call);

  // Start the server
  final server = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4,
    port,
  );

  print('╔══════════════════════════════════════════════════╗');
  print('║     🚀 Vello AI Chatbot Backend Server          ║');
  print('╠══════════════════════════════════════════════════╣');
  print('║  Server running on http://${server.address.host}:${server.port}');
  print('║                                                  ║');
  print('║  Endpoints:                                      ║');
  print('║  POST /api/chat          - Send a message        ║');
  print('║  GET  /api/chat/health   - Health check          ║');
  print('║  GET  /api/chat/quick-replies - Quick replies     ║');
  print('╚══════════════════════════════════════════════════╝');
  print('');
  print('Press Ctrl+C to stop the server.');
}
