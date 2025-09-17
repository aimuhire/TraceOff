import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:traceoff_mobile/providers/url_cleaner_provider.dart';
import 'package:traceoff_mobile/providers/history_provider.dart';
import 'package:traceoff_mobile/providers/settings_provider.dart';
import 'package:traceoff_mobile/providers/server_status_provider.dart';
import 'package:traceoff_mobile/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:traceoff_mobile/l10n/app_localizations.dart';

void main() {
  // Set up test environment
  setUpAll(() async {
    // Initialize dotenv for tests - try to load .env file, but don't fail if it doesn't exist
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // .env file doesn't exist, that's okay for tests
      print('Note: .env file not found, using default test values');
    }
    // Set test environment variables
    dotenv.env['ENVIRONMENT'] = 'test';
    dotenv.env['API_BASE_URL'] = 'http://localhost:3000';
    dotenv.env['DEBUG_LOGGING'] = 'true';
  });

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
            ChangeNotifierProvider(create: (_) => ServerStatusProvider()),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: HomeScreen(),
          ),
        ),
      );

      // Verify that the home screen displays
      expect(find.text('Paste Link to Clean'), findsOneWidget);
      expect(
          find.text('TraceOff — Clean Links'), findsOneWidget); // App bar title
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
            ChangeNotifierProvider(create: (_) => ServerStatusProvider()),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
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

    testWidgets('URL input field accepts text with URL extraction',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => UrlCleanerProvider()),
            ChangeNotifierProvider(create: (_) => HistoryProvider()),
            ChangeNotifierProvider(create: (_) => SettingsProvider(prefs)),
            ChangeNotifierProvider(create: (_) => ServerStatusProvider()),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: HomeScreen(),
          ),
        ),
      );

      // Find the URL input field and enter text with a URL
      final urlField = find.byType(TextField);
      expect(urlField, findsOneWidget);

      // Test with text containing a URL
      const String textWithUrl = '''
      I'm using Gboard to type in English (US) (QWERTY). You can try it at: 
      https://gboard.app.goo.gl?utm_campaign=user_referral&amv=26830000&apn=com.google.android.inputmethod.latin
      
      This is a very long URL with many parameters.
      ''';

      await tester.enterText(urlField, textWithUrl);
      await tester.pump();

      // Verify the text was entered (the field should accept any text)
      // Note: The text might be formatted differently in the TextField
      expect(find.byType(TextField), findsOneWidget);

      // Verify that the TextField contains the URL we entered
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, contains('https://gboard.app.goo.gl'));
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
