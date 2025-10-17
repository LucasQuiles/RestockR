import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../core/config/backend_config.dart';
import 'models/restock_alert.dart';

/// Native Dart WebSocket client implementing Socket.IO protocol
/// This bypasses the socket_io_client package to avoid iOS networking issues
class NativeWebSocketClient {
  final BackendConfig config;
  final String? authToken;

  WebSocketChannel? _channel;
  StreamController<RestockAlert>? _alertStreamController;
  bool _isConnected = false;
  Timer? _pingTimer;
  int _packetId = 0;

  // Event handlers
  final Map<String, List<Function(dynamic)>> _eventHandlers = {};

  NativeWebSocketClient({
    required this.config,
    this.authToken,
  });

  /// Check if the client is currently connected
  bool get isConnected => _isConnected;

  /// Connect to the WebSocket server
  Future<void> connect() async {
    if (_isConnected) {
      print('[NativeWS] Already connected');
      return;
    }

    try {
      // Build WebSocket URL: wss://host/socket.io/?EIO=4&transport=websocket
      final wsUrl = _buildWebSocketUrl();
      print('[NativeWS] 🔌 Connecting to: $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Listen to incoming messages
      _channel!.stream.listen(
        _handleMessage,
        onDone: () {
          print('[NativeWS] 🔌 Connection closed');
          _isConnected = false;
          _stopPingTimer();
        },
        onError: (error) {
          print('[NativeWS] ❌ Error: $error');
          _isConnected = false;
          _stopPingTimer();
        },
      );

      print('[NativeWS] ⏳ Waiting for handshake...');
    } catch (e) {
      print('[NativeWS] ❌ Failed to connect: $e');
      _isConnected = false;
    }
  }

  String _buildWebSocketUrl() {
    final baseUrl = config.wsUrl?.toString() ?? config.apiBase.toString();
    final wsUrl = baseUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');

    // Socket.IO WebSocket upgrade path with authentication
    final uri = Uri.parse('$wsUrl/socket.io/');
    final queryParams = {
      'EIO': '4',  // Engine.IO v4
      'transport': 'websocket',
    };

    return uri.replace(queryParameters: queryParams).toString();
  }

  void _handleMessage(dynamic message) {
    if (message is! String) return;

    // Socket.IO packet format: <type>[data]
    // Types: 0=open, 1=close, 2=ping, 3=pong, 4=message, 5=upgrade, 6=noop
    // Message types: 0=connect, 1=disconnect, 2=event, 3=ack, 4=error

    if (message.isEmpty) return;

    final type = message[0];
    final data = message.length > 1 ? message.substring(1) : '';

    switch (type) {
      case '0': // Open packet
        _handleOpenPacket(data);
        break;
      case '2': // Ping packet
        print('[NativeWS] 📥 Received ping from server');
        _sendPong();
        break;
      case '3': // Pong packet
        print('[NativeWS] 📥 Received pong from server');
        break;
      case '4': // Message packet
        _handleMessagePacket(data);
        break;
      case '1': // Close packet
        print('[NativeWS] 📥 Received close packet from server');
        _isConnected = false;
        break;
      default:
        print('[NativeWS] 📦 Unknown packet type: $type, data: $data');
    }
  }

  void _handleOpenPacket(String data) {
    try {
      final json = jsonDecode(data);
      print('[NativeWS] ✅ Connection established');
      print('[NativeWS] 📋 Session ID: ${json['sid']}');
      print('[NativeWS] ⏱️  Ping interval: ${json['pingInterval']}ms');
      print('[NativeWS] ⏱️  Ping timeout: ${json['pingTimeout']}ms');

      // Send Socket.IO connect message with authentication
      _sendConnect();

      // Start ping timer
      final pingInterval = json['pingInterval'] ?? 25000;
      _startPingTimer(Duration(milliseconds: pingInterval));

      _isConnected = true;
    } catch (e) {
      print('[NativeWS] ❌ Error parsing open packet: $e');
    }
  }

  void _sendConnect() {
    // Socket.IO connect packet: 40{auth_data}
    if (authToken != null) {
      final authData = jsonEncode({'token': authToken});
      _send('40$authData');
      print('[NativeWS] 🔐 Sent authentication');
    } else {
      _send('40');
      print('[NativeWS] ⚠️  Connected without authentication');
    }
  }

  void _handleMessagePacket(String data) {
    if (data.isEmpty) return;

    final subType = data[0];
    final payload = data.length > 1 ? data.substring(1) : '';

    switch (subType) {
      case '0': // Connect ACK
        print('[NativeWS] ✅ Socket.IO connected');
        _onConnectAck();
        break;
      case '1': // Disconnect
        print('[NativeWS] 🔌 Socket.IO disconnected');
        _isConnected = false;
        break;
      case '2': // Event
        _handleEvent(payload);
        break;
      case '4': // Error
        print('[NativeWS] ❌ Socket.IO error: $payload');
        if (payload.contains('Missing token') || payload.contains('Invalid token')) {
          print('[NativeWS] ❌ Authentication failed - check JWT token');
        }
        break;
      default:
        print('[NativeWS] 📦 Unknown message type: $subType');
    }
  }

  void _handleEvent(String data) {
    try {
      // Event format: ["event_name",{data}] or ["event_name",data1,data2,...]
      final decoded = jsonDecode(data);
      if (decoded is! List || decoded.isEmpty) return;

      final eventName = decoded[0] as String;
      final eventData = decoded.length > 1 ? decoded[1] : null;

      print('[NativeWS] 📡 Event: $eventName');

      // Handle built-in events
      if (eventName == 'restock' && eventData is Map<String, dynamic>) {
        _handleRestockEvent(eventData);
      }

      // Call registered handlers
      final handlers = _eventHandlers[eventName];
      if (handlers != null) {
        for (final handler in handlers) {
          try {
            handler(eventData);
          } catch (e) {
            print('[NativeWS] ❌ Error in event handler: $e');
          }
        }
      }
    } catch (e) {
      print('[NativeWS] ❌ Error parsing event: $e');
    }
  }

  void _handleRestockEvent(Map<String, dynamic> data) {
    try {
      final alert = RestockAlert.fromJson(data);
      _alertStreamController?.add(alert);
    } catch (e) {
      print('[NativeWS] ❌ Error parsing restock alert: $e');
    }
  }

  void _onConnectAck() {
    // Connection fully established, can now send events
    print('[NativeWS] 🎉 Ready to send/receive events');
  }

  void _startPingTimer(Duration interval) {
    _stopPingTimer();
    // Respond to server pings, don't initiate them
    // Socket.IO server sends pings, client responds with pongs
    print('[NativeWS] 🔔 Ping timer started (${interval.inMilliseconds}ms)');
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
    print('[NativeWS] 🔕 Ping timer stopped');
  }

  void _sendPing() {
    _send('2'); // Ping packet
    print('[NativeWS] 📤 Sent ping');
  }

  void _sendPong() {
    _send('3'); // Pong packet
    print('[NativeWS] 📤 Sent pong');
  }

  void _send(String message) {
    try {
      _channel?.sink.add(message);
    } catch (e) {
      print('[NativeWS] ❌ Error sending message: $e');
    }
  }

  /// Emit an event to the server
  void emit(String event, dynamic data) {
    if (!_isConnected) {
      print('[NativeWS] ⚠️  Cannot emit $event: not connected');
      return;
    }

    try {
      // Socket.IO event format: 42<packet_id>["event_name",{data}]
      final payload = jsonEncode([event, data]);
      _send('42$payload');
      print('[NativeWS] 📤 Emitted: $event');
    } catch (e) {
      print('[NativeWS] ❌ Error emitting event: $e');
    }
  }

  /// Register an event handler
  void on(String event, Function(dynamic) handler) {
    _eventHandlers[event] ??= [];
    _eventHandlers[event]!.add(handler);
  }

  /// Remove an event handler
  void off(String event, [Function(dynamic)? handler]) {
    if (handler == null) {
      _eventHandlers.remove(event);
    } else {
      _eventHandlers[event]?.remove(handler);
    }
  }

  /// Get a stream of real-time restock alerts
  Stream<RestockAlert> get alertStream {
    _alertStreamController ??= StreamController<RestockAlert>.broadcast(
      onListen: () {
        if (!_isConnected) {
          connect();
        }
      },
    );

    return _alertStreamController!.stream;
  }

  /// Submit a reaction to an alert via WebSocket
  bool submitReaction(String alertId, bool isPositive) {
    if (!_isConnected) {
      print('[NativeWS] ⚠️  Cannot submit reaction: not connected');
      return false;
    }

    emit('react', {
      'alertId': alertId,
      'type': isPositive ? 'yes' : 'no',
    });
    return true;
  }

  /// Sync watchlist SKUs to backend via WebSocket
  void syncWatchlist(List<String> skus) {
    if (!_isConnected) {
      print('[NativeWS] ⚠️  Cannot sync watchlist: not connected');
      return;
    }

    emit('watchlistUpdate', skus);
    print('[NativeWS] 📋 Watchlist synced: ${skus.length} items');
  }

  /// Listen for reaction updates from the server
  void onReactionUpdate(Function(String, int, int, String) callback) {
    on('reactionUpdate', (data) {
      try {
        final update = data as Map<String, dynamic>;
        final alertId = update['alertId'] as String;
        final reactions = update['reactions'] as Map<String, dynamic>;
        final username = update['username'] as String;
        final yesCount = (reactions['yes'] as num?)?.toInt() ?? 0;
        final noCount = (reactions['no'] as num?)?.toInt() ?? 0;

        callback(alertId, yesCount, noCount, username);
      } catch (e) {
        print('[NativeWS] ❌ Error parsing reaction update: $e');
      }
    });
  }

  /// Listen for watchlist updates from server
  void onWatchlistUpdate(Function(List<String>) callback) {
    on('watchlistUpdate', (data) {
      try {
        final skus = (data as List<dynamic>)
            .map((e) => e.toString())
            .toList();
        print('[NativeWS] 📋 Watchlist update received: ${skus.length} items');
        callback(skus);
      } catch (e) {
        print('[NativeWS] ❌ Error parsing watchlist update: $e');
      }
    });
  }

  /// Disconnect from WebSocket
  void disconnect() {
    if (_channel != null) {
      print('[NativeWS] 🔌 Disconnecting...');
      _send('41'); // Socket.IO disconnect packet
      _channel?.sink.close();
      _channel = null;
    }
    _isConnected = false;
    _stopPingTimer();
  }

  /// Clean up resources
  void dispose() {
    disconnect();
    _alertStreamController?.close();
    _alertStreamController = null;
    _eventHandlers.clear();
  }
}
