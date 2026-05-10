import 'package:socket_io_client/socket_io_client.dart' as io;

import 'api_client.dart';

typedef SocketEventHandler = void Function(String eventName, dynamic payload);

class SocketSyncService {
  static const _events = [
    'request_created',
    'request_accepted',
    'request_started',
    'request_completed',
    'request_cancelled',
    'message_created',
  ];

  final ApiClient _apiClient;
  io.Socket? _socket;

  SocketSyncService(this._apiClient);

  void connect({required SocketEventHandler onEvent}) {
    try {
      final socket = io.io(
        _apiClient.baseUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableReconnection()
            .disableAutoConnect()
            .build(),
      );

      for (final eventName in _events) {
        socket.on(eventName, (payload) => onEvent(eventName, payload));
      }

      socket.onConnectError((_) {});
      socket.onError((_) {});

      _socket = socket;
      socket.connect();
    } catch (_) {
      _socket = null;
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
