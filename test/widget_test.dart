// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:restockr/main.dart';
import 'package:restockr/core/utils/navigator_service.dart';
import 'package:restockr/routes/app_routes.dart';

void main() {
  testWidgets('MyApp configures MaterialApp with splash route', (tester) async {
    await tester.pumpWidget(ProviderScope(child: MyApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 3000));

    final materialAppFinder = find.byType(MaterialApp);
    expect(materialAppFinder, findsOneWidget);

    final materialApp = tester.widget<MaterialApp>(materialAppFinder);
    expect(materialApp.initialRoute, AppRoutes.initialRoute);
    expect(materialApp.navigatorKey, equals(NavigatorService.navigatorKey));
  });
}
