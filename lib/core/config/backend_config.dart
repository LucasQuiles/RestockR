import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Immutable configuration resolved from `env.json` and environment defaults.
class BackendConfig {
  BackendConfig._(this._values);

  factory BackendConfig.fromMap(Map<String, Object?> overrides) =>
      BackendConfig._(_mergeWithDefaults(overrides));

  static const _defaultValues = <String, Object?>{
    'RESTOCKR_ENV': 'development',
    'RESTOCKR_API_BASE': 'https://api.local.restockr.dev',
    'RESTOCKR_WS_URL': '',
    'RESTOCKR_TIMEOUT_SECONDS': 30,
    'SUPABASE_URL': 'https://update-me.supabase.co',
    'SUPABASE_ANON_KEY': 'replace-me',
    'AUTH_PROVIDER': 'supabase',
    'AUTH_STORAGE_DRIVER': 'secure_storage',
    'AUTH_REFRESH_INTERVAL_MIN': 45,
    'RESTOCKR_MONITOR_PAGE_SIZE': 25,
    'WATCHLIST_DEFAULT_SORT': 'recent_activity',
    'WATCHLIST_MAX_ENTRIES': 100,
    'HISTORY_WINDOW_DAYS': 14,
    'HISTORY_PAGE_SIZE': 50,
    'FILTER_DEFAULTS_PROFILE': 'standard',
    'NOTIFICATION_PROVIDER': 'fcm',
    'PUSH_PUBLIC_KEY': '',
    'ANALYTICS_WRITE_KEY': '',
    'LOG_LEVEL': 'info',
    'TRACE_SAMPLING_RATE': 0.1,
  };

  final Map<String, Object?> _values;

  String get environment => _values['RESTOCKR_ENV']! as String;
  Uri get apiBase => Uri.parse(_values['RESTOCKR_API_BASE']! as String);
  int get timeoutSeconds =>
      (_values['RESTOCKR_TIMEOUT_SECONDS'] as num).toInt();

  Uri? get websocketUrl {
    final raw = (_values['RESTOCKR_WS_URL'] as String).trim();
    if (raw.isEmpty) {
      return null;
    }
    return Uri.parse(raw);
  }

  /// Convenience getter for WebSocket URL (alias for websocketUrl)
  Uri? get wsUrl => websocketUrl;

  String get supabaseUrl => _values['SUPABASE_URL']! as String;
  String get supabaseAnonKey => _values['SUPABASE_ANON_KEY']! as String;

  String get authProvider => _values['AUTH_PROVIDER']! as String;
  String get authStorageDriver => _values['AUTH_STORAGE_DRIVER']! as String;
  int get authRefreshIntervalMinutes =>
      (_values['AUTH_REFRESH_INTERVAL_MIN'] as num).toInt();

  int get monitorPageSize =>
      (_values['RESTOCKR_MONITOR_PAGE_SIZE'] as num).toInt();
  String get watchlistDefaultSort =>
      _values['WATCHLIST_DEFAULT_SORT']! as String;
  int get watchlistMaxEntries =>
      (_values['WATCHLIST_MAX_ENTRIES'] as num).toInt();
  int get historyWindowDays => (_values['HISTORY_WINDOW_DAYS'] as num).toInt();
  int get historyPageSize => (_values['HISTORY_PAGE_SIZE'] as num).toInt();
  String get filterDefaultsProfile =>
      _values['FILTER_DEFAULTS_PROFILE']! as String;

  String get notificationProvider =>
      _values['NOTIFICATION_PROVIDER']! as String;
  String? get pushPublicKey {
    final raw = (_values['PUSH_PUBLIC_KEY'] as String).trim();
    return raw.isEmpty ? null : raw;
  }

  String get analyticsWriteKey => _values['ANALYTICS_WRITE_KEY']! as String;
  String get logLevel => _values['LOG_LEVEL']! as String;
  double get traceSamplingRate =>
      (_values['TRACE_SAMPLING_RATE'] as num).toDouble();

  /// Discord Guild ID for OAuth (optional)
  String? get discordGuildId {
    final raw = _values['DISCORD_GUILD_ID'] as String?;
    return raw?.trim().isEmpty ?? true ? null : raw?.trim();
  }

  /// Returns true when the Supabase anon key has been customized.
  bool get hasSupabaseCredentials => supabaseAnonKey != 'replace-me';

  Map<String, Object?> toJson() => Map<String, Object?>.from(_values);

  /// Loads the configuration from the bundled `env.json`, merging with defaults.
  static Future<BackendConfig> load({AssetBundle? bundle}) async {
    final assetBundle = bundle ?? rootBundle;
    Map<String, Object?> raw;
    try {
      final contents = await assetBundle.loadString('env.json');
      raw = Map<String, Object?>.from(
        jsonDecode(contents) as Map<dynamic, dynamic>,
      );
    } on FlutterError catch (error) {
      debugPrint(
        'BackendConfig: Unable to load env.json from assets '
        '(${error.message}). Falling back to defaults.',
      );
      raw = const <String, Object?>{};
    } on FormatException catch (error) {
      debugPrint(
        'BackendConfig: env.json is malformed (${error.message}). '
        'Falling back to defaults.',
      );
      raw = const <String, Object?>{};
    }

    return BackendConfig._(_mergeWithDefaults(raw));
  }

  static Map<String, Object?> _mergeWithDefaults(
    Map<String, Object?> overrides,
  ) {
    final merged = Map<String, Object?>.from(_defaultValues);
    for (final entry in overrides.entries) {
      merged[entry.key] = entry.value;
    }
    return merged;
  }
}

final backendConfigProvider = Provider<BackendConfig>((ref) {
  throw StateError(
    'BackendConfig has not been initialized. Ensure BackendConfig.load() '
    'is awaited and provided via ProviderScope overrides in main().',
  );
});
