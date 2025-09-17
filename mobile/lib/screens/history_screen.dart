import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:traceoff_mobile/providers/history_provider.dart';
import 'package:traceoff_mobile/providers/url_cleaner_provider.dart';
import 'package:traceoff_mobile/models/history_item.dart';
import 'package:traceoff_mobile/l10n/app_localizations.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFavoritesOnly = false;
  List<HistoryItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    // ignore: avoid_print
    print(
        '[HistoryScreen] filter: query="${_searchController.text}" favoritesOnly=$_showFavoritesOnly');
    final historyProvider = context.read<HistoryProvider>();
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (_showFavoritesOnly) {
        _filteredItems = historyProvider.favoriteItems.where((item) {
          return item.originalUrl.toLowerCase().contains(query) ||
              item.cleanedUrl.toLowerCase().contains(query) ||
              item.domain.toLowerCase().contains(query);
        }).toList();
      } else {
        _filteredItems = historyProvider.historyItems.where((item) {
          return item.originalUrl.toLowerCase().contains(query) ||
              item.cleanedUrl.toLowerCase().contains(query) ||
              item.domain.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterItems();
  }

  void _toggleFavoritesFilter() {
    setState(() {
      _showFavoritesOnly = !_showFavoritesOnly;
    });
    // ignore: avoid_print
    print('[HistoryScreen] toggleFavoritesOnly -> $_showFavoritesOnly');
    _filterItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.historyTitle),
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
            ),
            onPressed: _toggleFavoritesFilter,
            tooltip: _showFavoritesOnly
                ? AppLocalizations.of(context)!.historyShowAll
                : AppLocalizations.of(context)!.historyShowFavoritesOnly,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear_all':
                  _showClearAllDialog();
                  break;
                case 'export':
                  _exportHistory();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: const Icon(Icons.download),
                  title: Text(AppLocalizations.of(context)!.historyExport),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'clear_all',
                child: ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: Text(AppLocalizations.of(context)!.historyClearAll),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
          if (historyProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = _showFavoritesOnly
              ? historyProvider.favoriteItems
              : historyProvider.historyItems;

          // Decide which list to display: when no active search text,
          // default to the full items list instead of an empty _filteredItems.
          final hasQuery = _searchController.text.isNotEmpty;
          final displayed = hasQuery ? _filteredItems : items;

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.historySearchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => _filterItems(),
                ),
              ),

              // History List with pull-to-refresh
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    // ignore: avoid_print
                    print('[HistoryScreen] pull-to-refresh');
                    await context.read<HistoryProvider>().loadHistory();
                    _filterItems();
                  },
                  child: displayed.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _showFavoritesOnly
                                    ? Icons.favorite_border
                                    : Icons.history,
                                size: 64,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _showFavoritesOnly
                                    ? AppLocalizations.of(context)!
                                        .historyNoFavoritesYet
                                    : AppLocalizations.of(context)!
                                        .historyNoItemsYet,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(
                                    context,
                                  )
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _showFavoritesOnly
                                    ? AppLocalizations.of(context)!
                                        .historyFavoritesHint
                                    : AppLocalizations.of(context)!
                                        .historyCleanSomeUrls,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  )
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.4),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: displayed.length,
                          itemBuilder: (context, index) {
                            final item = displayed[index];
                            return _buildHistoryItem(item);
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem(HistoryItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          item.domain,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              '${AppLocalizations.of(context)!.historyOriginal} ${item.originalUrl}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
                fontFamily: 'monospace',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${AppLocalizations.of(context)!.historyCleaned} ${item.cleanedUrl}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
                fontFamily: 'monospace',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${(item.confidence * 100).toStringAsFixed(1)}% ${AppLocalizations.of(context)!.historyConfidence}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDateTime(item.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleItemAction(value, item),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'copy_original',
              child: ListTile(
                leading: const Icon(Icons.copy),
                title: Text(AppLocalizations.of(context)!.historyCopyOriginal),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'copy_cleaned',
              child: ListTile(
                leading: const Icon(Icons.cleaning_services),
                title: Text(AppLocalizations.of(context)!.historyCopyCleaned),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: const Icon(Icons.share),
                title: Text(AppLocalizations.of(context)!.historyShare),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'open',
              child: ListTile(
                leading: const Icon(Icons.open_in_browser),
                title: Text(AppLocalizations.of(context)!.historyOpen),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'reclean',
              child: ListTile(
                leading: const Icon(Icons.refresh),
                title: Text(AppLocalizations.of(context)!.historyReclean),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'toggle_favorite',
              child: ListTile(
                leading: Icon(
                  item.isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
                title: Text(
                  item.isFavorite
                      ? AppLocalizations.of(context)!.historyRemoveFromFavorites
                      : AppLocalizations.of(context)!.historyAddToFavorites,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(AppLocalizations.of(context)!.historyDelete,
                    style: const TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: () => _handleItemAction('copy_cleaned', item),
      ),
    );
  }

  void _handleItemAction(String action, HistoryItem item) async {
    switch (action) {
      case 'copy_original':
        Clipboard.setData(ClipboardData(text: item.originalUrl));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.historyOriginalCopied)),
        );
        break;
      case 'copy_cleaned':
        Clipboard.setData(ClipboardData(text: item.cleanedUrl));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.historyCleanedCopied)),
        );
        break;
      case 'share':
        await SharePlus.instance.share(ShareParams(text: item.cleanedUrl));
        break;
      case 'open':
        _launchUrl(item.cleanedUrl);
        break;
      case 'reclean':
        context.read<UrlCleanerProvider>().cleanUrl(item.originalUrl);
        // Switch to home screen
        DefaultTabController.of(context).animateTo(0);
        break;
      case 'toggle_favorite':
        context.read<HistoryProvider>().toggleFavorite(item.id);
        _filterItems(); // Refresh the filtered list
        break;
      case 'delete':
        _showDeleteDialog(item);
        break;
    }
  }

  void _showDeleteDialog(HistoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.historyDeleteItem),
        content: Text(AppLocalizations.of(context)!.historyDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<HistoryProvider>().deleteHistoryItem(item.id);
              _filterItems(); // Refresh the filtered list
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.historyDelete,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.historyClearAllTitle),
        content: Text(AppLocalizations.of(context)!.historyClearAllConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<HistoryProvider>().clearAllHistory();
              _filterItems(); // Refresh the filtered list
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.historyClearAllAction,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _exportHistory() {
    // Simple export - just copy all URLs to clipboard
    final items = _showFavoritesOnly
        ? context.read<HistoryProvider>().favoriteItems
        : context.read<HistoryProvider>().historyItems;

    final exportText = items
        .map(
          (item) =>
              '${item.originalUrl} -> ${item.cleanedUrl} (${item.domain}, ${(item.confidence * 100).toStringAsFixed(1)}%)',
        )
        .join('\n');

    Clipboard.setData(ClipboardData(text: exportText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.historyExported)),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}${AppLocalizations.of(context)!.historyDaysAgo}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}${AppLocalizations.of(context)!.historyHoursAgo}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}${AppLocalizations.of(context)!.historyMinutesAgo}';
    } else {
      return AppLocalizations.of(context)!.historyJustNow;
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)!.historyCouldNotLaunch} $url')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.historyErrorLaunching} $e')));
      }
    }
  }
}
