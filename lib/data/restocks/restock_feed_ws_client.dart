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
          .setTransports(['websocket'])  // WebSocket only (bypass long-polling on iOS)
          .disableAutoConnect()
          .setTimeout(60000)  // 60 second timeout (increased for debugging)
          .setPath('/socket.io/')  // Explicit Socket.IO path
          .setQuery({'EIO': '4', 'transport': 'websocket'})  // Force WebSocket transport
          .enableReconnection()  // Auto-reconnect on disconnect
          .setReconnectionDelay(1000)  // Quick reconnect
          .enableForceNew();  // Force new connection

      // CRITICAL: Backend expects JWT in socket.handshake.auth.token
      if (authToken != null) {
        optionsBuilder.setAuth({'token': authToken});
        print('[WebSocket] JWT auth configured in handshake.auth.token');
        print('[WebSocket] Token preview: ${authToken.substring(0, 50)}...');
      }

      // Build headers map for cookies (session-based auth fallback)
      final headers = <String, String>{};

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
        print('[WebSocket] ❌ Connection error: $error');
        print('[WebSocket] ❌ Failed to connect to: $wsUrl');
        print('[WebSocket] ❌ Error type: ${error.runtimeType}');
        if (error is Map) {
          print('[WebSocket] ❌ Error details: $error');
        }
        if (error != null) {
          print('[WebSocket] ❌ Error string: ${error.toString()}');
        }
        _isConnected = false;
      });

      _socket?.onError((error) {
        print('[WebSocket] ❌ Socket error: $error');
        print('[WebSocket] ❌ Error type: ${error?.runtimeType}');
      });

      // Add connection timeout detection
      _socket?.on('connect_timeout', (_) {
        print('[WebSocket] ❌ Connection timeout after 30s');
      });

      // Add authentication error detection
      _socket?.on('error', (data) {
        print('[WebSocket] ❌ Server error event: $data');
      });

      // Debug: Log all Socket.IO events
      _socket?.onAny((event, data) {
        print('[WebSocket] 📡 Event: $event, Data: $data');
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

  /// Sync watchlist SKUs to backend via WebSocket
  /// Backend will update the database and echo back to this client
  void syncWatchlist(List<String> skus) {
    if (!_isConnected || _socket == null) {
      print('[WebSocket] Cannot sync watchlist: not connected');
      return;
    }

    try {
      _socket!.emit('watchlistUpdate', skus);
      print('[WebSocket] Watchlist synced: ${skus.length} items');
    } catch (e) {
      print('[WebSocket] Error syncing watchlist: $e');
    }
  }

  /// Listen for watchlist updates from server
  /// This fires when the backend confirms the update or when another device syncs
  void onWatchlistUpdate(Function(List<String>) callback) {
    _socket?.on('watchlistUpdate', (data) {
      try {
        final skus = (data as List<dynamic>)
            .map((e) => e.toString())
            .toList();
        print('[WebSocket] Watchlist update received: ${skus.length} items');
        callback(skus);
      } catch (e) {
        print('[WebSocket] Error parsing watchlist update: $e');
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
