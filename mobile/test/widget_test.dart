import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:traceoff_mobile/providers/url_cleaner_provider.dart';
import 'package:traceoff_mobile/providers/history_provider.dart';
import 'package:traceoff_mobile/providers/settings_provider.dart';
import 'package:traceoff_mobile/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('HomeScreen displays correctly', (WidgetTester tester) async {
      // Mock shared preferences
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => UrlCleanerProvider()),
            ChangeNotifierProvider(create: (_) => HistoryProvider()),
            ChangeNotifierProvider(create: (_) => SettingsProvider(prefs)),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Verify that the home screen displays
      expect(find.text('Enter Link to Clean'), findsOneWidget);
      expect(find.text('Clean Link'), findsOneWidget);
    });

    testWidgets('URL input field accepts text', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => UrlCleanerProvider()),
            ChangeNotifierProvider(create: (_) => HistoryProvider()),
            ChangeNotifierProvider(create: (_) => SettingsProvider(prefs)),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Find the URL input field and enter text
      final urlField = find.byType(TextField);
      expect(urlField, findsOneWidget);

      await tester.enterText(urlField, 'https://example.com?utm_source=test');
      await tester.pump();

      // Verify the text was entered
      expect(find.text('https://example.com?utm_source=test'), findsOneWidget);
    });
  });

  group('UrlCleanerProvider Tests', () {
    test('initial state is correct', () {
      final provider = UrlCleanerProvider();

      expect(provider.isLoading, false);
      expect(provider.error, null);
      expect(provider.result, null);
      expect(provider.currentUrl, '');
    });

    test('clearResult resets state', () {
      final provider = UrlCleanerProvider();

      // Simulate some state
      provider.clearResult();

      expect(provider.isLoading, false);
      expect(provider.error, null);
      expect(provider.result, null);
      expect(provider.currentUrl, '');
    });
  });
}
