import 'dart:async';
import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../core/config/backend_config.dart';
import 'models/restock_alert.dart';

/// WebSocket client for real-time restock alerts using Socket.IO
class RestockFeedWSClient {
  final BackendConfig config;
  final String? authToken;
  final List<Cookie>? cookies;
  IO.Socket? _socket;
  StreamController<RestockAlert>? _alertStreamController;
  bool _isConnected = false;

  RestockFeedWSClient({
    required this.config,
    this.authToken,
    this.cookies,
  });

  /// Check if the client is currently connected
  bool get isConnected => _isConnected;

  /// Connect to the WebSocket server
  Future<void> connect() async {
    if (_isConnected) return;

    try {
      // Get WebSocket URL from config (with fallback to API base)
      final wsUrl = config.wsUrl?.toString() ?? config.apiBase.toString();

      // Use default Socket.IO transports (polling + websocket upgrade)
      print('[WebSocket] Attempting connection to: $wsUrl');
      print('[WebSocket] Path: /socket.io/');
      print('[WebSocket] Using default transports: polling + websocket upgrade');
      if (authToken != null) {
        print('[WebSocket] Using authentication token');
      }
      if (cookies != null && cookies!.isNotEmpty) {
        print('[WebSocket] Using ${cookies!.length} cookies for session auth');
      }

      final optionsBuilder = IO.OptionBuilder()
          .setTransports(['polling', 'websocket'])  // Start with polling, upgrade to websocket
          .disableAutoConnect()
          .setTimeout(30000)  // 30 second timeout
          .setPath('/socket.io/')  // Explicit Socket.IO path
          .setQuery({'EIO': '4'})  // Explicitly set Engine.IO v4
          .enableReconnection()  // Auto-reconnect on disconnect
          .setReconnectionDelay(1000)  // Quick reconnect
          .enableForceNew();  // Force new connection

      // Build headers map
      final headers = <String, String>{};

      // Add authentication header if token is provided
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      // Add cookies if provided (for session-based auth)
      if (cookies != null && cookies!.isNotEmpty) {
        final cookieHeader = cookies!.map((c) => '${c.name}=${c.value}').join('; ');
        headers['Cookie'] = cookieHeader;
        print('[WebSocket] Cookie header: $cookieHeader');
      }

      if (headers.isNotEmpty) {
        optionsBuilder.setExtraHeaders(headers);
      }

      _socket = IO.io(wsUrl, optionsBuilder.build());

      print('[WebSocket] Socket.IO client configured');

      _socket?.onConnect((_) {
        print('[WebSocket] Connected to $wsUrl');
        _isConnected = true;
      });

      _socket?.onDisconnect((_) {
        print('[WebSocket] Disconnected');
        _isConnected = false;
      });

      _socket?.onConnectError((error) {
        print('[WebSocket] Connection error: $error');
        print('[WebSocket] Failed to connect to: $wsUrl');
        print('[WebSocket] Error type: ${error.runtimeType}');
        if (error is Map) {
          print('[WebSocket] Error details: $error');
        }
        _isConnected = false;
      });

      _socket?.onError((error) {
        print('[WebSocket] Socket error: $error');
      });

      // Note: onConnectTimeout removed in socket_io_client v3.x
      // Timeout is now handled automatically by setTimeout option

      // Listen for restock events from backend
      _socket?.on('restock', (data) {
        try {
          final alert = RestockAlert.fromJson(data as Map<String, dynamic>);
          _alertStreamController?.add(alert);
        } catch (e) {
          print('[WebSocket] Error parsing restock alert: $e');
        }
      });

      _socket?.connect();
    } catch (e) {
      print('[WebSocket] Failed to initialize: $e');
    }
  }

  /// Get a stream of real-time restock alerts
  Stream<RestockAlert> get alertStream {
    _alertStreamController ??=
        StreamController<RestockAlert>.broadcast(
      onListen: () {
        if (!_isConnected) {
          connect();
        }
      },
    );

    return _alertStreamController!.stream;
  }

  /// Submit a reaction to an alert via WebSocket
  /// Returns true if the reaction was sent successfully
  bool submitReaction(String alertId, bool isPositive) {
    if (!_isConnected || _socket == null) {
      print('[WebSocket] Cannot submit reaction: not connected');
      return false;
    }

    try {
      _socket!.emit('react', {
        'alertId': alertId,
        'type': isPositive ? 'yes' : 'no',
      });
      print('[WebSocket] Reaction sent: $alertId -> ${isPositive ? "yes" : "no"}');
      return true;
    } catch (e) {
      print('[WebSocket] Error submitting reaction: $e');
      return false;
    }
  }

  /// Listen for reaction updates from the server
  /// Callback receives: (alertId, yesCount, noCount, username)
  void onReactionUpdate(Function(String, int, int, String) callback) {
    _socket?.on('reactionUpdate', (data) {
      try {
        final update = data as Map<String, dynamic>;
        final alertId = update['alertId'] as String;
        final reactions = update['reactions'] as Map<String, dynamic>;
        final username = update['username'] as String;
        final yesCount = reactions['yes'] as int;
        final noCount = reactions['no'] as int;

        callback(alertId, yesCount, noCount, username);
      } catch (e) {
        print('[WebSocket] Error parsing reaction update: $e');
      }
    });
  }

  /// Disconnect from WebSocket
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }

  /// Clean up resources
  void dispose() {
    disconnect();
    _alertStreamController?.close();
    _alertStreamController = null;
  }
}
