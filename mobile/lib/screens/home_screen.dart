import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:traceoff_mobile/providers/url_cleaner_provider.dart';
import 'package:traceoff_mobile/providers/settings_provider.dart';
import 'package:traceoff_mobile/providers/server_status_provider.dart';
import 'package:traceoff_mobile/screens/tutorial_screen.dart';
import 'package:traceoff_mobile/widgets/server_status_widget.dart';
import 'package:traceoff_mobile/models/clean_result.dart';
import 'package:traceoff_mobile/widgets/supported_platforms_panel.dart';
import 'package:traceoff_mobile/l10n/app_localizations.dart';
import 'package:traceoff_mobile/utils/url_extractor.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _urlFocusNode = FocusNode();
  bool _usageTipsShown = false;
  final Map<String, String> _titleCache = {};
  final Map<String, String> _imageCache = {};
  String? _lastHandledResultUrl;
  bool _hideSupportedPanel = false;
  String _previousText = '';

  @override
  void initState() {
    super.initState();
    // Initialize settings and check server status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().init();
      // Check server status on app startup
      context.read<ServerStatusProvider>().checkServerStatus();
      _loadUsageTipsFlag();
      _loadHideSupportedPanelFlag();
      _checkAndShowFirstTimeMessage();
      // Consume shared/pending URL from provider if any
      final pending = context.read<UrlCleanerProvider>().takePendingInputUrl();
      if (pending != null && pending.isNotEmpty) {
        _urlController.text = pending;
        setState(() {});
      }
      // Only check clipboard after prioritizing shared intent
      _suggestPasteFromClipboard();
      // Set offline mode from settings
      _updateOfflineMode();
      // Attach settings to cleaner for custom strategies
      final urlCleaner = context.read<UrlCleanerProvider>();
      final settings = context.read<SettingsProvider>();
      urlCleaner.attachSettings(settings);
    });
  }

  void _updateOfflineMode() {
    final settings = context.read<SettingsProvider>();
    final cleaner = context.read<UrlCleanerProvider>();
    cleaner.setOfflineMode(settings.offlineMode);
  }

  Future<void> _suggestPasteFromClipboard() async {
    // If a shared/pending URL exists or input already has text, skip clipboard
    final pending = context.read<UrlCleanerProvider>().pendingInputUrl;
    if (pending != null && pending.isNotEmpty) return;
    if (_urlController.text.isNotEmpty) return;
    final data = await Clipboard.getData('text/plain');
    final text = data?.text?.trim() ?? '';
    if (!mounted) return;
    final settings = context.read<SettingsProvider>();

    // Extract the first HTTP URL from the clipboard text
    final String? extractedUrl = UrlExtractor.extractFirstHttpUrl(text);

    if (extractedUrl != null && _urlController.text.isEmpty) {
      if (settings.autoSubmitClipboard) {
        _urlController.text = extractedUrl;
        setState(() {});
        // Auto-submit
        _cleanUrl();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.snackPastedAndCleaning),
              duration: const Duration(seconds: 2)),
        );
      } else {
        // Only paste, no auto-submit
        _urlController.text = extractedUrl;
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.snackPasted),
              duration: const Duration(seconds: 2)),
        );
      }
    }
  }

  Future<void> _loadUsageTipsFlag() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _usageTipsShown = prefs.getBool('usage_tips_shown') ?? false;
    });
  }

  Future<void> _loadHideSupportedPanelFlag() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _hideSupportedPanel = prefs.getBool('hide_supported_panel') ?? false;
    });
  }

  Future<void> _checkAndShowFirstTimeMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('first_time_message_shown') ?? false;
    if (!hasSeen && mounted) {
      // Wait a bit for the UI to settle
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _showFirstTimeMessage();
      }
    }
  }

  Future<void> _markFirstTimeMessageShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time_message_shown', true);
  }

  Future<void> _markHideSupportedPanel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hide_supported_panel', true);
    if (!mounted) return;
    setState(() {
      _hideSupportedPanel = true;
    });
  }

  Future<void> _markUsageTipsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('usage_tips_shown', true);
    if (!mounted) return;
    setState(() {
      _usageTipsShown = true;
    });
  }

  Future<void> _ensureTitleFetched(String url) async {
    if (_titleCache.containsKey(url)) return;
    try {
      final uri = Uri.parse(url);
      final res = await http.get(uri).timeout(const Duration(seconds: 5));
      if (!mounted) return;
      if (res.statusCode == 200) {
        final match =
            RegExp(r'<title[^>]*>([\s\S]*?)<\/title>', caseSensitive: false)
                .firstMatch(res.body);
        final raw = match?.group(1)?.trim();
        if (raw != null && raw.isNotEmpty) {
          if (!mounted) return;
          setState(() {
            _titleCache[url] = raw.replaceAll(RegExp(r'\s+'), ' ');
          });
        }

        // Try to extract preview image (Open Graph / Twitter)
        final og = RegExp(
          r'''<meta[^>]+(?:property|name)\s*=\s*["']og:image["'][^>]*content\s*=\s*["']([^"']+)["']''',
          caseSensitive: false,
        ).firstMatch(res.body);
        final tw = RegExp(
          r'''<meta[^>]+(?:property|name)\s*=\s*["']twitter:image["'][^>]*content\s*=\s*["']([^"']+)["']''',
          caseSensitive: false,
        ).firstMatch(res.body);
        final img = og?.group(1) ?? tw?.group(1);
        if (img != null && img.isNotEmpty) {
          final absolute = _resolveUrl(url, img);
          if (!mounted) return;
          setState(() {
            _imageCache[url] = absolute;
          });
        }
      }
    } catch (_) {
      // Ignore title fetch errors silently
    }
  }

  String _titleForUrl(String url, String fallback) {
    if (!_titleCache.containsKey(url)) {
      // Fire and forget
      _ensureTitleFetched(url);
    }
    return _titleCache[url] ?? fallback;
  }

  String? _imageForUrl(String url) => _imageCache[url];

  String _resolveUrl(String pageUrl, String resourceUrl) {
    try {
      final page = Uri.parse(pageUrl);
      final res = Uri.parse(resourceUrl);
      if (res.hasScheme) return resourceUrl;
      return page.resolveUri(res).toString();
    } catch (_) {
      return resourceUrl;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  bool _isValidHttpUrl(String input) {
    try {
      final uri = Uri.parse(input.trim());
      return (uri.hasScheme &&
              (uri.scheme == 'http' || uri.scheme == 'https')) &&
          uri.hasAuthority;
    } catch (_) {
      return false;
    }
  }

  void _cleanUrl() {
    final url = _urlController.text.trim();
    if (!_isValidHttpUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.enterValidUrl)),
      );
      return;
    }
    context.read<UrlCleanerProvider>().cleanUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return settings.offlineMode
                  ? const SizedBox.shrink()
                  : const ServerStatusIndicator();
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer2<UrlCleanerProvider, SettingsProvider>(
        builder: (context, provider, settings, child) {
          // If a pending shared URL arrives while the screen is active, populate the input
          final pendingShared = provider.pendingInputUrl;
          if (pendingShared != null &&
              pendingShared.isNotEmpty &&
              _urlController.text != pendingShared) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _urlController.text = pendingShared;
              setState(() {});
              provider.takePendingInputUrl();
            });
          }
          // Auto-share and/or copy when result is received (if enabled)
          if (provider.result != null && !provider.isLoading) {
            final url = provider.result!.primary.url;
            final shouldHandle =
                (settings.autoShareOnSuccess || settings.autoCopyPrimary) &&
                    _lastHandledResultUrl != url;
            if (shouldHandle) {
              _lastHandledResultUrl = url;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _autoShareAndCopy(url);
                }
              });
            }
          }

          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 220,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.14),
                        Theme.of(context)
                            .colorScheme
                            .secondary
                            .withValues(alpha: 0.1),
                        Theme.of(context).colorScheme.surface,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    _buildUrlInputCard(provider, settings),
                    const SizedBox(height: 16),
                    if (provider.error != null) _buildErrorCard(provider),
                    // Results Display
                    if (provider.result != null) ...[
                      _buildPrimaryResult(provider.result!),
                      if ((provider.result!.primary.confidence) < 1.0) ...[
                        const SizedBox(height: 8),
                        Card(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .notCertainReviewAlternatives,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _buildAlternatives(provider.result!),
                      const SizedBox(height: 16),
                    ],
                    if (!_hideSupportedPanel) ...[
                      const SizedBox(height: 12),
                      SupportedPlatformsPanel(
                        onHideForever: _markHideSupportedPanel,
                        onHideOnce: () =>
                            setState(() => _hideSupportedPanel = true),
                        onRequestHideDialog: () async {
                          if (!mounted) return;
                          final choice = await showDialog<String>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(AppLocalizations.of(context)!
                                    .hideSupportedTitle),
                                content: Text(AppLocalizations.of(context)!
                                    .hideSupportedQuestion),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop('cancel'),
                                    child: Text(
                                        AppLocalizations.of(context)!.cancel),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop('hide'),
                                    child: Text(
                                        AppLocalizations.of(context)!.hide),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop('forever'),
                                    child: Text(AppLocalizations.of(context)!
                                        .dontShowAgain),
                                  ),
                                ],
                              );
                            },
                          );
                          if (choice == 'hide') {
                            if (!mounted) return;
                            setState(() => _hideSupportedPanel = true);
                          } else if (choice == 'forever') {
                            await _markHideSupportedPanel();
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

 
  Widget _buildModeToggle(SettingsProvider settings) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                if (settings.offlineMode) return;
                if (!mounted) return;
                final messenger = ScaffoldMessenger.of(context);
                final localizations = AppLocalizations.of(context)!;
                await settings.setOfflineMode(true);
                _updateOfflineMode();
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(localizations.switchedToLocal),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: settings.offlineMode
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.storage_rounded,
                      size: 18,
                      color: settings.offlineMode
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.local,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: settings.offlineMode
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                if (!settings.offlineMode) return;
                if (!mounted) return;
                final messenger = ScaffoldMessenger.of(context);
                final localizations = AppLocalizations.of(context)!;
                await settings.setOfflineMode(false);
                _updateOfflineMode();
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(localizations.switchedToRemote),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: !settings.offlineMode
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_outlined,
                      size: 18,
                      color: !settings.offlineMode
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.remote,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: !settings.offlineMode
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlInputCard(
      UrlCleanerProvider provider, SettingsProvider settings) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.link, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.pasteLinkTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: AppLocalizations.of(context)!.processingMode,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TutorialScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.info_outline,
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildModeToggle(settings),
            const SizedBox(height: 14),
            TextField(
              controller: _urlController,
              focusNode: _urlFocusNode,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.inputHintHttp,
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                  ),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: AppLocalizations.of(context)!.actionPaste,
                      icon: const Icon(Icons.content_paste_rounded),
                      onPressed: () async {
                        final data = await Clipboard.getData('text/plain');
                        final text = data?.text ?? '';
                        if (text.isNotEmpty) {
                          if (!mounted) return;

                          final String? extractedUrl =
                              UrlExtractor.extractFirstHttpUrl(text);
                          if (extractedUrl != null) {
                            _urlController.text = extractedUrl;
                            _previousText = extractedUrl;
                            setState(() {});

                            if (settings.autoSubmitClipboard) {
                              _cleanUrl();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)!
                                      .snackPastedAndCleaning),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)!
                                      .snackPasted),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          } else {
                            _urlController.text = text.trim();
                            _previousText = text.trim();
                            setState(() {});
                          }
                        }
                      },
                    ),
                    IconButton(
                      tooltip: AppLocalizations.of(context)!.actionClear,
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        if (!mounted) return;
                        _urlController.clear();
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.go,
              onChanged: (text) {
                setState(() {});
                if (text.length > _previousText.length + 10) {
                  final String? extractedUrl =
                      UrlExtractor.extractFirstHttpUrl(text);
                  if (extractedUrl != null && extractedUrl != text) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _urlController.value = TextEditingValue(
                          text: extractedUrl,
                          selection: TextSelection.collapsed(
                            offset: extractedUrl.length,
                          ),
                        );
                        setState(() {});
                      }
                    });
                  }
                }
                _previousText = text;
              },
              onSubmitted: (_) => _cleanUrl(),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed:
                    provider.isLoading || !_isValidHttpUrl(_urlController.text)
                        ? null
                        : _cleanUrl,
                icon: provider.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.flash_on_rounded),
                label: Text(
                  provider.isLoading
                      ? AppLocalizations.of(context)!.cleaning
                      : (_isValidHttpUrl(_urlController.text)
                          ? AppLocalizations.of(context)!.tabClean
                          : AppLocalizations.of(context)!.enterValidUrl),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(UrlCleanerProvider provider) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.error!,
                    style: TextStyle(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => provider.clearError(),
                  icon: Icon(
                    Icons.close,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
            if (provider.error!.contains('Remote processing failed'))
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _processLocally(provider),
                        icon: const Icon(Icons.storage),
                        label:
                            Text(AppLocalizations.of(context)!.processLocally),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.onErrorContainer,
                          foregroundColor: theme.colorScheme.errorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryResult(CleanResult result) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with success indicator
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.cleanLinkReady,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(result.primary.confidence * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Clean URL with copy button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.cleanLinkLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _openUrl(result.primary.url),
                    onLongPress: () => _copyToClipboard(result.primary.url),
                    borderRadius: BorderRadius.circular(8),
                    splashColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    highlightColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.05),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        result.primary.url,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (!_usageTipsShown) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .tipLongPressToCopy)),
                        );
                        _markUsageTipsShown();
                      }
                      _copyToClipboard(result.primary.url);
                    },
                    icon: const Icon(Icons.copy),
                    label: Text(AppLocalizations.of(context)!.copyCleanLink),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (!_usageTipsShown) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .tipTapOpenLongPressCopy)),
                        );
                        _markUsageTipsShown();
                      }
                      _shareUrl(result.primary.url);
                    },
                    icon: const Icon(Icons.share),
                    label: Text(AppLocalizations.of(context)!.shareLink),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            // Collapsible details section
            const SizedBox(height: 16),
            ExpansionTile(
              title: Text(
                AppLocalizations.of(context)!.technicalDetails,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              children: [
                // Optional preview for cleaned link (local-only)
                Consumer<SettingsProvider>(
                  builder: (context, settings, _) {
                    if (!settings.showCleanLinkPreviews) {
                      return const SizedBox.shrink();
                    }
                    final uri = Uri.tryParse(result.primary.url);
                    final domain = uri?.host ?? result.meta.domain;
                    final faviconUrl =
                        'https://www.google.com/s2/favicons?domain=$domain&sz=64';
                    return Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: ListTile(
                        onTap: () => _openUrl(result.primary.url),
                        onLongPress: () => _copyToClipboard(result.primary.url),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: (_imageForUrl(result.primary.url) != null)
                              ? Image.network(
                                  _imageForUrl(result.primary.url)!,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Image.network(
                                    faviconUrl,
                                    width: 32,
                                    height: 32,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.link),
                                  ),
                                )
                              : Image.network(
                                  faviconUrl,
                                  width: 32,
                                  height: 32,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.link),
                                ),
                        ),
                        title: Text(
                          _titleForUrl(result.primary.url, domain),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          result.primary.url,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontFamily: 'monospace', fontSize: 12),
                        ),
                        trailing: IconButton(
                          tooltip: 'Share',
                          icon: const Icon(Icons.share),
                          onPressed: () => _shareUrl(result.primary.url),
                        ),
                      ),
                    );
                  },
                ),
                if (result.primary.actions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.actionsTaken,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: (result.primary.actions as List<dynamic>)
                        .map(
                          (action) => Chip(
                            label: Text(action.toString()),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 8),
                _buildInfoRow('Domain', result.meta.domain),
                _buildInfoRow(
                  'Strategy',
                  '${result.meta.strategyId} (v${result.meta.strategyVersion})',
                ),
                _buildInfoRow(
                    'Processing Time', '${result.meta.timing.totalMs}ms'),
                _buildInfoRow(
                    'Applied At', _formatDateTime(result.meta.appliedAt)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlternatives(CleanResult result) {
    if (result.alternatives.isEmpty) return const SizedBox.shrink();

    // Sort alternatives by confidence DESC
    final alternatives = [...result.alternatives]
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.alternativeResults,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...alternatives.asMap().entries.map((entry) {
              final index = entry.key;
              final alt = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${AppLocalizations.of(context)!.alternative} ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${(alt.confidence * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      if (alt.reason != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          alt.reason!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            )
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _openUrl(alt.url),
                        onLongPress: () => _copyToClipboard(alt.url),
                        borderRadius: BorderRadius.circular(6),
                        splashColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        highlightColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.05),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  alt.url,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip:
                                  'Share (may still contain tracking parameters)',
                              icon: const Icon(Icons.share, size: 18),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(context)!
                                          .shareAltWarningSnack,
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                                _shareUrl(alt.url);
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  String _formatDateTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.copiedToClipboard)),
    );
  }

  void _openUrl(String url) async {
    await _launchUrl(url);
  }

  void _shareUrl(String url) async {
    await SharePlus.instance.share(ShareParams(text: url));
  }

  void _autoShareAndCopy(String url) async {
    final settings = context.read<SettingsProvider>();
    if (settings.autoCopyPrimary) {
      Clipboard.setData(ClipboardData(text: url));
    }
    if (settings.autoShareOnSuccess) {
      await SharePlus.instance.share(ShareParams(text: url));
    }
    if (mounted && (settings.autoCopyPrimary || settings.autoShareOnSuccess)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(settings.autoCopyPrimary && settings.autoShareOnSuccess
              ? AppLocalizations.of(context)!.urlCleanedCopiedAndShared
              : settings.autoCopyPrimary
                  ? 'URL cleaned: copied'
                  : 'URL cleaned: shared'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showFirstTimeMessage() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  Icons.clean_hands,
                  color: theme.colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.appTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.whyCleanLinks,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.whyCleanLinksDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates_outlined,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.pasteLinkTitle,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            FilledButton.icon(
              onPressed: () {
                _markFirstTimeMessageShown();
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.check),
              label: Text(AppLocalizations.of(context)!.close),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('${AppLocalizations.of(context)!.couldNotLaunch} $url')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('${AppLocalizations.of(context)!.errorLaunchingUrl} $e')));
    }
  }

  void _processLocally(UrlCleanerProvider provider) async {
    // Switch to offline mode in settings
    final settings = context.read<SettingsProvider>();
    await settings.setOfflineMode(true);
    _updateOfflineMode();

    // Process the URL with local processing
    await provider.fallbackToOfflineMode(provider.currentUrl);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!
              .switchedToLocalProcessingAndCleaned),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
