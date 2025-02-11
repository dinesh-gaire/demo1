import 'package:get_it/get_it.dart';
import '../network/websocket_server.dart';
import 'package:offnet/data/objectbox.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

final getIt = GetIt.instance;

Future<void> setupServices(ObjectBox objectBox) async {
  try {
    // Register WebSocket server as a lazy singleton
    getIt.registerLazySingleton<WebSocketServer>(
      () => WebSocketServer(objectBox),
    );

    // Start server in the background
    unawaited(_startWebSocketServer());
  } catch (e) {
    debugPrint('Service initialization error: $e');
  }
}

Future<void> _startWebSocketServer() async {
  try {
    await getIt<WebSocketServer>().start();
  } catch (e) {
    debugPrint('WebSocket server failed to start: $e');
  }
}
