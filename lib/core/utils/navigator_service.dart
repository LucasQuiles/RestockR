import 'dart:async';

import 'package:flutter/material.dart';

// ignore_for_file: must_be_immutable
typedef RouteGuard = FutureOr<bool> Function(
  String routeName,
  dynamic arguments,
);

class NavigatorService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static RouteGuard? _routeGuard;

  static void registerGuard(RouteGuard guard) {
    _routeGuard = guard;
  }

  static Future<bool> _canNavigate(
    String routeName, {
    dynamic arguments,
  }) async {
    final guard = _routeGuard;
    if (guard == null) {
      return true;
    }

    try {
      final result = await guard(routeName, arguments);
      return result;
    } catch (error, stackTrace) {
      assert(() {
        debugPrint(
          'NavigatorService guard threw while checking $routeName: $error\n'
          '$stackTrace',
        );
        return true;
      }());
      return false;
    }
  }

  static Future<Object?> pushNamed(
    String routeName, {
    Object? arguments,
  }) async {
    if (!await _canNavigate(routeName, arguments: arguments)) {
      return null;
    }

    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      return null;
    }

    return navigator.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  static void goBack() {
    return navigatorKey.currentState?.pop();
  }

  static Future<Object?> pushNamedAndRemoveUntil(
    String routeName, {
    bool routePredicate = false,
    Object? arguments,
  }) async {
    if (!await _canNavigate(routeName, arguments: arguments)) {
      return null;
    }

    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      return null;
    }

    return navigator.pushNamedAndRemoveUntil(
      routeName,
      (route) => routePredicate,
      arguments: arguments,
    );
  }

  static Future<Object?> popAndPushNamed(
    String routeName, {
    Object? arguments,
  }) async {
    if (!await _canNavigate(routeName, arguments: arguments)) {
      return null;
    }

    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      return null;
    }

    return navigator.popAndPushNamed(
      routeName,
      arguments: arguments,
    );
  }
}
