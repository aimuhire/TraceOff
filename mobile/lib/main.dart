import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traceoff_mobile/providers/url_cleaner_provider.dart';
import 'package:traceoff_mobile/providers/history_provider.dart';
import 'package:traceoff_mobile/providers/settings_provider.dart';
import 'package:traceoff_mobile/providers/server_status_provider.dart';
import 'package:traceoff_mobile/screens/home_screen.dart';
import 'package:traceoff_mobile/screens/history_screen.dart';
import 'package:traceoff_mobile/screens/settings_screen.dart';
import 'package:traceoff_mobile/screens/privacy_policy_screen.dart';
import 'package:traceoff_mobile/services/database_service.dart';
import 'package:traceoff_mobile/services/api_service.dart';
import 'package:traceoff_mobile/utils/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'package:traceoff_mobile/config/environment.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use clean path-based URLs on web (no #)
  if (kIsWeb) {
    // ignore: prefer_const_constructors
    setUrlStrategy(PathUrlStrategy());
  }

  // Initialize environment configuration
  await EnvironmentConfig.initialize();

  // Initialize API service
  await ApiService.initialize();

  // Set environment (you can change this to Environment.production for production builds)
  EnvironmentConfig.setEnvironment(Environment.development);

  // Initialize database (skip on web)
  if (!kIsWeb) {
    await DatabaseService.instance.init();
  }

  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UrlCleanerProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider(prefs)..init()),
        ChangeNotifierProvider(create: (_) => ServerStatusProvider()),
      ],
      child: Consumer<SettingsProvider>(builder: (context, settings, _) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: settings.locale,
          onGenerateRoute: (settings) {
            final name = settings.name ?? '/';
            switch (name) {
              case '/':
                return MaterialPageRoute(
                    builder: (_) => const MainScreen(initialIndex: 0));
              case '/privacy':
                return MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen());
              case '/settings':
                // Route to MainScreen with the Settings tab selected
                return MaterialPageRoute(
                    builder: (_) => const MainScreen(initialIndex: 2));
              case '/history':
                // Route to MainScreen with the History tab selected
                return MaterialPageRoute(
                    builder: (_) => const MainScreen(initialIndex: 1));
              default:
                // Fallback to home
                return MaterialPageRoute(
                    builder: (_) => const MainScreen(initialIndex: 0));
            }
          },
        );
      }),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  static const MethodChannel _shareChannel =
      MethodChannel('com.aimuhire.traceoff/share');

  @override
  void initState() {
    super.initState();
    // Initialize current tab from route-provided initialIndex
    _currentIndex = widget.initialIndex.clamp(0, 2); // 3 screens: 0, 1, 2
    _initShareListener();
    if (_currentIndex == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          context.read<HistoryProvider>().loadHistory();
        } catch (_) {}
      });
    }
  }

  void _initShareListener() {
    _shareChannel.setMethodCallHandler((call) async {
      if (call.method == 'sharedText') {
        final sharedText = (call.arguments as String?)?.trim() ?? '';
        if (sharedText.isNotEmpty) {
          _handleSharedUrl(sharedText);
        }
      }
    });
  }

  void _handleSharedUrl(String url) {
    setState(() {
      _currentIndex = 0;
    });

    // Update the browser URL on web to reflect the active tab
    if (kIsWeb) {
      // Replace rather than push so history stays clean
      Navigator.of(context, rootNavigator: true).pushReplacementNamed('/');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings = context.read<SettingsProvider>();
      final cleaner = context.read<UrlCleanerProvider>();
      cleaner.setPendingInputUrl(url);
      if (settings.autoSubmitClipboard) {
        cleaner.cleanUrl(url);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        // Rebuild screens when locale changes to ensure localization updates
        final screens = [
          const HomeScreen(),
          const HistoryScreen(),
          const SettingsScreen(),
        ];

        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: screens),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (_currentIndex == index) return;
              setState(() {
                _currentIndex = index;
              });
              if (index == 1) {
                try {
                  context.read<HistoryProvider>().loadHistory();
                } catch (_) {}
              }
              // Sync URL with selected tab on web without rebuilding routes
              if (kIsWeb) {
                switch (index) {
                  case 0:
                    SystemNavigator.routeInformationUpdated(
                      uri: Uri.parse('/'),
                      replace: true,
                    );
                    break;
                  case 1:
                    SystemNavigator.routeInformationUpdated(
                      uri: Uri.parse('/history'),
                      replace: true,
                    );
                    break;
                  case 2:
                    SystemNavigator.routeInformationUpdated(
                      uri: Uri.parse('/settings'),
                      replace: true,
                    );
                    break;
                }
              }
            },
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.cleaning_services),
                label: AppLocalizations.of(context)!.tabClean,
              ),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.history),
                  label: AppLocalizations.of(context)!.tabHistory),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings),
                label: AppLocalizations.of(context)!.tabSettings,
              ),
            ],
          ),
        );
      },
    );
  }
}
