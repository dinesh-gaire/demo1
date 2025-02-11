import 'dart:io';
import 'dart:convert';
import 'package:offnet/data/objectbox.dart';
import '../utils/image_utils.dart';
import '../utils/logger.dart';

class WebSocketServer {
  static const int APP_PORT = 43721;
  final ObjectBox objectBox;
  HttpServer? _server;

  WebSocketServer(this.objectBox);

  Future<void> start() async {
    if (_server != null) return; // Already running

    try {
      _server = await HttpServer.bind(
        InternetAddress.anyIPv4, // This ensures binding to 0.0.0.0
        APP_PORT,
        shared: true, // Allow port sharing
      );
      
      final localAddresses = await NetworkInterface.list();
      log.i('WebSocket server started on port $APP_PORT');
      log.i('Available on:');
      for (var interface in localAddresses) {
        for (var addr in interface.addresses) {
          log.i('  ${interface.name}: ${addr.address}:$APP_PORT');
        }
      }

      await for (HttpRequest request in _server!) {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          try {
            final socket = await WebSocketTransformer.upgrade(request);
            final address = request.connectionInfo?.remoteAddress;
            log.i('New connection from: ${address?.address} (${address?.type.name})');
            _handleConnection(socket);
          } catch (e) {
            log.e('WebSocket upgrade failed', error: e);
          }
        }
      }
    } catch (e) {
      log.e('Failed to start WebSocket server', error: e);
      rethrow;
    }
  }

  void _handleConnection(WebSocket socket) {
    socket.listen((message) async {
      if (message == 'REQUEST_INFO') {
        final selfUser = objectBox.selfUserBox.getAll().first;
        final response = {
          'name': selfUser.name,
          'uniqueId': selfUser.uniqueId,
          'publicKey': selfUser.publicKey,
          'base64Image': selfUser.pathToImage != null
              ? await ImageUtils.imageToBase64(selfUser.pathToImage!)
              : null,
        };

        socket.add(jsonEncode(response));
      }
    });
  }

  void stop() {
    _server?.close();
    log.i('WebSocket server stopped');
  }
}
