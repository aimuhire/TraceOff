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

  @override
  void initState() {
    super.initState();
    // Initialize settings and check server status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().init();
      // Check server status on app startup
      context.read<ServerStatusProvider>().checkServerStatus();
      _loadUsageTipsFlag();
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
    if (text.isNotEmpty &&
        _isValidHttpUrl(text) &&
        _urlController.text.isEmpty) {
      if (settings.autoSubmitClipboard) {
        _urlController.text = text;
        setState(() {});
        // Auto-submit
        _cleanUrl();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Pasted URL from clipboard and cleaning...'),
              duration: Duration(seconds: 2)),
        );
      } else {
        // Only paste, no auto-submit
        _urlController.text = text;
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Pasted URL from clipboard'),
              duration: Duration(seconds: 2)),
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
        const SnackBar(content: Text('Please enter a valid http/https URL')),
      );
      return;
    }
    context.read<UrlCleanerProvider>().cleanUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TraceOff'),
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
      body: Consumer<UrlCleanerProvider>(
        builder: (context, provider, child) {
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
            final settings = context.read<SettingsProvider>();
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Server Status Section

                // URL Input Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<SettingsProvider>(
                          builder: (context, settings, child) {
                            return Column(
                              children: [
                                // Segmented Control Style Toggle
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Local Option
                                      GestureDetector(
                                        onTap: () async {
                                          if (settings.offlineMode) {
                                            return; // Already local, no need to switch
                                          }
                                          await settings.setOfflineMode(true);
                                          _updateOfflineMode();
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Switched to local cleaning - using device processing'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: settings.offlineMode
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.storage,
                                                size: 16,
                                                color: settings.offlineMode
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Local',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: settings.offlineMode
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Remote Option
                                      GestureDetector(
                                        onTap: () async {
                                          if (!settings.offlineMode) {
                                            return; // Already remote, no need to switch
                                          }
                                          await settings.setOfflineMode(false);
                                          _updateOfflineMode();
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Switched to remote cleaning - using cloud API'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: !settings.offlineMode
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.cloud,
                                                size: 16,
                                                color: !settings.offlineMode
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Remote',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: !settings.offlineMode
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Info button
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TutorialScreen(),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Processing Mode',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.info_outline,
                                        size: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Paste Link to Clean',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _urlController,
                          focusNode: _urlFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Paste a link to clean (http/https)',
                            prefixIcon: const Icon(Icons.link),
                            border: const OutlineInputBorder(),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Paste',
                                  icon: const Icon(Icons.paste),
                                  onPressed: () async {
                                    final data =
                                        await Clipboard.getData('text/plain');
                                    final text = data?.text ?? '';
                                    if (text.isNotEmpty) {
                                      if (!mounted) return;
                                      _urlController.text = text.trim();
                                      setState(() {});
                                    }
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Clear',
                                  icon: const Icon(Icons.clear),
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
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _cleanUrl(),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: provider.isLoading ||
                                    !_isValidHttpUrl(_urlController.text)
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
                                : const Icon(Icons.cleaning_services),
                            label: Text(provider.isLoading
                                ? 'Cleaning...'
                                : (_isValidHttpUrl(_urlController.text)
                                    ? 'Clean Link'
                                    : 'Enter a valid http/https URL')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Error Display
                if (provider.error != null)
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  provider.error!,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => provider.clearError(),
                                icon: Icon(
                                  Icons.close,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                                ),
                              ),
                            ],
                          ),
                          // Show fallback option for remote processing failures
                          if (provider.error!
                              .contains('Remote processing failed'))
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _processLocally(provider),
                                      icon: const Icon(Icons.storage),
                                      label: const Text('Process Locally'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .onErrorContainer,
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .errorContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                // Results Display
                if (provider.result != null) ...[
                  _buildPrimaryResult(provider.result!),
                  if ((provider.result!.primary.confidence) < 1.0) ...[
                    const SizedBox(height: 8),
                    Card(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This result is not 100% certain. Please review the alternatives below.',
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
              ],
            ),
          );
        },
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
                  'Clean Link Ready',
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
                    'Clean Link:',
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
                    borderRadius: BorderRadius.circular(4),
                    splashColor: Colors.blue.withValues(alpha: 0.1),
                    highlightColor: Colors.blue.withValues(alpha: 0.05),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: Text(
                        result.primary.url,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
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
                          const SnackBar(
                              content:
                                  Text('Tip: Long-press any link to copy')),
                        );
                        _markUsageTipsShown();
                      }
                      _copyToClipboard(result.primary.url);
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Clean Link'),
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
                          const SnackBar(
                              content: Text(
                                  'Tip: Tap link to open, long-press to copy')),
                        );
                        _markUsageTipsShown();
                      }
                      _shareUrl(result.primary.url);
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share Link'),
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
                'Technical Details',
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
                    'Actions taken:',
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
            const Text(
              'Alternative Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                            'Alternative ${index + 1}',
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
                        borderRadius: BorderRadius.circular(4),
                        splashColor: Colors.blue.withValues(alpha: 0.1),
                        highlightColor: Colors.blue.withValues(alpha: 0.05),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 2),
                                child: Text(
                                  alt.url,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    color: Colors.blue,
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
                                  const SnackBar(
                                    content: Text(
                                      'Warning: Alternative may still contain trackers',
                                    ),
                                    duration: Duration(seconds: 2),
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
      const SnackBar(content: Text('Copied to clipboard')),
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
              ? 'URL cleaned: copied and shared'
              : settings.autoCopyPrimary
                  ? 'URL cleaned: copied'
                  : 'URL cleaned: shared'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not launch $url')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error launching URL: $e')));
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
        const SnackBar(
          content: Text('Switched to local processing and cleaned URL'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
