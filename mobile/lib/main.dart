import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traceoff_mobile/providers/url_cleaner_provider.dart';
import 'package:traceoff_mobile/providers/history_provider.dart';
import 'package:traceoff_mobile/providers/settings_provider.dart';
import 'package:traceoff_mobile/providers/server_status_provider.dart';
import 'package:traceoff_mobile/screens/home_screen.dart';
import 'package:traceoff_mobile/screens/history_screen.dart';
import 'package:traceoff_mobile/screens/settings_screen.dart';
import 'package:traceoff_mobile/services/database_service.dart';
import 'package:traceoff_mobile/services/api_service.dart';
import 'package:traceoff_mobile/utils/app_theme.dart';
import 'package:traceoff_mobile/config/environment.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        ChangeNotifierProvider(create: (_) => SettingsProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ServerStatusProvider()),
      ],
      child: MaterialApp(
        title: 'TraceOff',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  static const MethodChannel _shareChannel =
      MethodChannel('com.aimuhire.traceoff/share');

  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initShareListener();
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
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.cleaning_services),
            label: 'Clean Link',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
