import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:traceoff_mobile/providers/settings_provider.dart';
import 'package:traceoff_mobile/config/environment.dart';
import 'package:traceoff_mobile/providers/history_provider.dart';
import 'package:traceoff_mobile/models/cleaning_strategy.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _serverUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().init();
    });
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          _serverUrlController.text = settings.serverUrl;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // General Settings
              _buildSectionHeader('General'),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Auto-copy Primary Result'),
                      subtitle: const Text(
                        'Automatically copy the primary cleaned link to clipboard',
                      ),
                      value: settings.autoCopyPrimary,
                      onChanged: (value) => settings.setAutoCopyPrimary(value),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Show Confirmation'),
                      subtitle: const Text(
                        'Show confirmation dialogs for actions',
                      ),
                      value: settings.showConfirmation,
                      onChanged: (value) => settings.setShowConfirmation(value),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Show Clean Link Previews'),
                      subtitle: const Text(
                          'Render previews only for cleaned links (local only, can be disabled)'),
                      value: settings.showCleanLinkPreviews,
                      onChanged: (value) =>
                          settings.setShowCleanLinkPreviews(value),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Local Processing'),
                      subtitle: const Text(
                        kIsWeb
                            ? 'Not available on web. Use the mobile app for offline/local processing.'
                            : 'Process links locally on device instead of using cloud API. When enabled, all cleaning happens on your device for better privacy.',
                      ),
                      value: kIsWeb ? false : settings.offlineMode,
                      onChanged: (value) {
                        if (kIsWeb && value) {
                          _showInstallAppToast();
                        } else {
                          settings.setOfflineMode(value);
                        }
                      },
                      activeThumbColor: Colors.blue,
                      inactiveThumbColor: Colors.green,
                      secondary: Icon(
                        (kIsWeb ? false : settings.offlineMode)
                            ? Icons.storage
                            : Icons.cloud,
                        color: (kIsWeb ? false : settings.offlineMode)
                            ? Colors.blue
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Cleaning Strategies
              _buildSectionHeader('Cleaning Strategies'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.tune),
                      title: const Text('Manage Local Strategies'),
                      subtitle: Text(
                        kIsWeb
                            ? 'Not available on web. Download the app to customize offline strategies.'
                            : 'Active: ${settings.activeStrategy?.name ?? 'Default offline cleaner'}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        if (kIsWeb) {
                          _showInstallAppToast();
                        } else {
                          _showStrategiesDialog(settings);
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Appearance Settings
              _buildSectionHeader('Appearance'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Theme'),
                      subtitle: Text(_getThemeModeText(settings.themeMode)),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showThemeDialog(settings),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Server Settings
              _buildSectionHeader('Server'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Server URL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _serverUrlController,
                        decoration: InputDecoration(
                          hintText: EnvironmentConfig.baseUrl,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          settings.setServerUrl(value);
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the URL of your TraceOff server',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Debug info for development
                      if (EnvironmentConfig.environment ==
                          Environment.development)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Debug Info:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Environment: ${EnvironmentConfig.environment.name}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              Text(
                                'Base URL: ${EnvironmentConfig.baseUrl}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              Text(
                                'API URL: ${EnvironmentConfig.apiUrl}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Data Management
              _buildSectionHeader('Data Management'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('Clear History'),
                      subtitle: const Text('Remove all history items'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showClearHistoryDialog(),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.download),
                      title: const Text('Export History'),
                      subtitle: const Text('Export history to clipboard'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _exportHistory(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // About
              _buildSectionHeader('About'),
              Card(
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.info),
                      title: Text('Version'),
                      subtitle: Text('1.0.0'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.code),
                      title: const Text('Open Source'),
                      subtitle: const Text('View source code on GitHub'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // TODO: Open GitHub repository
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('GitHub link not implemented'),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: const Text('Privacy Policy'),
                      subtitle: const Text('How we handle your data'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.of(context).pushNamed('/privacy');
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Reset Settings
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: ListTile(
                  leading: Icon(
                    Icons.restore,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  title: Text(
                    'Reset to Defaults',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Reset all settings to their default values',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onErrorContainer.withValues(alpha: 0.7),
                    ),
                  ),
                  onTap: () => _showResetDialog(settings),
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showInstallAppToast() async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final snack = SnackBar(
      content: const Text(
        'Local offline processing is not available on web. Download the app to use local strategies.',
      ),
      action: SnackBarAction(
        label: 'Get the app',
        onPressed: () async {
          final url = Uri.parse('https://github.com/aimuhire/TraceOff');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
      ),
      duration: const Duration(seconds: 6),
    );
    messenger.showSnackBar(snack);
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemeDialog(SettingsProvider settings) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final ThemeMode current = settings.themeMode;

        Widget option(ThemeMode mode, String label) {
          final bool selected = current == mode;
          return ListTile(
            title: Text(label),
            trailing: selected ? const Icon(Icons.check) : null,
            onTap: () {
              settings.setThemeMode(mode);
              Navigator.of(dialogCtx).pop(); // use dialog's context
            },
          );
        }

        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              option(ThemeMode.system, 'System Default'),
              option(ThemeMode.light, 'Light'),
              option(ThemeMode.dark, 'Dark'),
            ],
          ),
        );
      },
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to delete all history items? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<HistoryProvider>().clearAllHistory();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('History cleared')));
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _exportHistory() {
    final historyProvider = context.read<HistoryProvider>();
    final items = historyProvider.historyItems;

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No history items to export')),
      );
      return;
    }

    final exportText = items
        .map(
          (item) =>
              '${item.originalUrl} -> ${item.cleanedUrl} (${item.domain}, ${(item.confidence * 100).toStringAsFixed(1)}%)',
        )
        .join('\n');

    // Copy to clipboard
    // Note: In a real app, you might want to use a file picker to save to a file
    Clipboard.setData(ClipboardData(text: exportText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('History exported to clipboard')),
    );
  }

  void _showStrategiesDialog(SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          final strategies = settings.strategies;
          return AlertDialog(
            title: const Text('Local Cleaning Strategies'),
            content: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Default option at top
                  ListTile(
                    leading: Icon(
                      settings.activeStrategyId == null
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: settings.activeStrategyId == null
                          ? Colors.green
                          : null,
                    ),
                    title: const Text('Default offline cleaner'),
                    subtitle:
                        const Text('Use built-in offline cleaning strategy'),
                    onTap: () async {
                      await settings.setActiveStrategy(null);
                      setState(() {});
                    },
                  ),
                  const Divider(height: 1),
                  ListView.separated(
                    shrinkWrap: true,
                    itemCount: strategies.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final s = strategies[index];
                      final active = settings.activeStrategyId == s.id;
                      return ListTile(
                        leading: Icon(
                            active
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: active ? Colors.green : null),
                        title: Text(s.name),
                        subtitle: Text('${s.steps.length} step(s)'),
                        onTap: () async {
                          await settings.setActiveStrategy(s.id);
                          setState(() {});
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                await _showEditStrategyDialog(settings, s);
                                setState(() {});
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await settings.deleteStrategy(s.id);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Strategy'),
                      onPressed: () async {
                        await _showEditStrategyDialog(settings, null);
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _showEditStrategyDialog(
      SettingsProvider settings, CleaningStrategy? strategy) async {
    final isNew = strategy == null;
    final id = strategy?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final nameController =
        TextEditingController(text: strategy?.name ?? 'My Strategy');

    final List<CleaningStep> steps =
        List.of(strategy?.steps ?? <CleaningStep>[]);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(isNew ? 'New Strategy' : 'Edit Strategy'),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 12),
                    const Text('Steps',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...steps.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final step = entry.value;
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.drag_indicator),
                          title: Text(step.type.toString().split('.').last),
                          subtitle: Text(_stepSummary(step)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                steps.removeAt(idx);
                              });
                            },
                          ),
                          onTap: () async {
                            final edited = await _showEditStepDialog(step);
                            if (edited != null) {
                              setState(() {
                                steps[idx] = edited;
                              });
                            }
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: PopupMenuButton<String>(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextButton.icon(
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text('Add Step',
                                style: TextStyle(color: Colors.white)),
                            onPressed: null, // Handled by PopupMenuButton
                          ),
                        ),
                        onSelected: (value) {
                          setState(() {
                            if (value == 'redirect') {
                              steps.add(const CleaningStep(
                                  type: CleaningStepType.redirect,
                                  params: {'times': 1}));
                            } else if (value == 'removeQuery') {
                              steps.add(const CleaningStep(
                                  type: CleaningStepType.removeQuery,
                                  params: {'keys': <String>[]}));
                            } else if (value == 'stripFragment') {
                              steps.add(const CleaningStep(
                                  type: CleaningStepType.stripFragment));
                            }
                          });
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                              value: 'redirect',
                              child: Text('Redirect (N times)')),
                          PopupMenuItem(
                              value: 'removeQuery',
                              child: Text('Remove query keys')),
                          PopupMenuItem(
                              value: 'stripFragment',
                              child: Text('Strip fragment')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final updated = CleaningStrategy(
                      id: id,
                      name: nameController.text.trim().isEmpty
                          ? 'Strategy'
                          : nameController.text.trim(),
                      steps: steps);
                  await settings.upsertStrategy(updated);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<CleaningStep?> _showEditStepDialog(CleaningStep step) async {
    final type = step.type;
    if (type == CleaningStepType.redirect) {
      final controller =
          TextEditingController(text: (step.params['times'] ?? 1).toString());
      final res = await showDialog<int>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Redirect step'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Times'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () =>
                    Navigator.pop(context, int.tryParse(controller.text) ?? 1),
                child: const Text('Save')),
          ],
        ),
      );
      if (res == null) return null;
      return CleaningStep(
          type: CleaningStepType.redirect, params: {'times': res});
    }
    if (type == CleaningStepType.removeQuery) {
      final controller = TextEditingController(
          text: (step.params['keys'] as List?)?.join(',') ?? '');
      final res = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remove query keys'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Comma-separated keys',
              hintText: 'e.g. utm_source, utm_medium, fbclid',
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Save')),
          ],
        ),
      );
      if (res == null) return null;
      final keys = res
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      return CleaningStep(
          type: CleaningStepType.removeQuery, params: {'keys': keys});
    }
    if (type == CleaningStepType.stripFragment) {
      // No parameters
      return const CleaningStep(type: CleaningStepType.stripFragment);
    }
    return null;
  }

  void _showResetDialog(SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to their default values?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              settings.resetToDefaults();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _stepSummary(CleaningStep step) {
    switch (step.type) {
      case CleaningStepType.redirect:
        final times = (step.params['times'] as int?) ?? 1;
        return 'Redirect $times time(s)';
      case CleaningStepType.removeQuery:
        final keys = (step.params['keys'] as List?)?.join(', ') ?? '';
        return keys.isEmpty ? 'Remove no query keys' : 'Remove keys: $keys';
      case CleaningStepType.stripFragment:
        return 'Strip URL fragment';
    }
  }
}
