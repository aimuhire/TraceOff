import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traceoff_mobile/providers/server_status_provider.dart';

class ServerStatusWidget extends StatelessWidget {
  const ServerStatusWidget({
    super.key,
    this.showDetails = false,
    this.onTap,
  });

  final bool showDetails;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Consumer<ServerStatusProvider>(
      builder: (context, serverStatus, child) {
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: onTap ?? () => serverStatus.checkServerStatus(),
            borderRadius: BorderRadius.circular(8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getStatusIcon(serverStatus.status),
                        size: 20,
                        color: _getStatusColor(serverStatus.status),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Server Status: ${serverStatus.statusText}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: _getStatusColor(serverStatus.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      if (serverStatus.isChecking)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  if (showDetails) ...[
                    const SizedBox(height: 8),
                    if (serverStatus.lastChecked != null)
                      Text(
                        'Last checked: ${serverStatus.lastCheckedText}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (serverStatus.responseTime != null)
                      Text(
                        'Response time: ${serverStatus.responseTimeText}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (serverStatus.serverTimestamp != null)
                      Text(
                        'Server time: ${serverStatus.serverTimestamp}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (serverStatus.serverStatus != null)
                      Text(
                        'Server status: ${serverStatus.serverStatus}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (serverStatus.errorMessage != null)
                      Text(
                        'Error: ${serverStatus.errorMessage}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.red,
                            ),
                      ),
                  ],
                  if (!showDetails && serverStatus.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        serverStatus.errorMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.red,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(ServerStatus status) {
    switch (status) {
      case ServerStatus.online:
        return Colors.green;
      case ServerStatus.offline:
        return Colors.red;
      case ServerStatus.error:
        return Colors.orange;
      case ServerStatus.checking:
        return Colors.blue;
      case ServerStatus.unknown:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(ServerStatus status) {
    switch (status) {
      case ServerStatus.unknown:
        return Icons.help_outline;
      case ServerStatus.checking:
        return Icons.cloud_sync;
      case ServerStatus.online:
        return Icons.cloud_done;
      case ServerStatus.offline:
        return Icons.cloud_off;
      case ServerStatus.error:
        return Icons.cloud_off;
    }
  }
}

class ServerStatusIndicator extends StatefulWidget {
  const ServerStatusIndicator({super.key});

  @override
  State<ServerStatusIndicator> createState() => _ServerStatusIndicatorState();
}

class _ServerStatusIndicatorState extends State<ServerStatusIndicator> {
  @override
  void initState() {
    super.initState();
    // Trigger health check when widget is first rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkHealthIfNeeded();
    });
  }

  void _checkHealthIfNeeded() {
    final serverStatus = context.read<ServerStatusProvider>();
    // Check health if status is unknown, offline, or error
    if (serverStatus.status == ServerStatus.unknown ||
        serverStatus.status == ServerStatus.offline ||
        serverStatus.status == ServerStatus.error) {
      serverStatus.checkServerStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServerStatusProvider>(
      builder: (context, serverStatus, child) {
        // Trigger health check if previous check failed
        if (serverStatus.status == ServerStatus.offline ||
            serverStatus.status == ServerStatus.error) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkHealthIfNeeded();
          });
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(serverStatus.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getStatusColor(serverStatus.status),
              width: 1,
            ),
          ),
          child: GestureDetector(
            onTap: () async {
              await serverStatus.checkServerStatus();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      serverStatus.isOnline
                          ? 'Server is online and healthy'
                          : serverStatus.isOffline
                              ? 'Server is offline - using local processing'
                              : 'Server status updated',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Icon(
              _getStatusIcon(serverStatus.status),
              size: 20,
              color: _getStatusColor(serverStatus.status),
            ),
          ),
        );
      },
    );
  }
}

Color _getStatusColor(ServerStatus status) {
  switch (status) {
    case ServerStatus.online:
      return Colors.green;
    case ServerStatus.offline:
      return Colors.red;
    case ServerStatus.error:
      return Colors.orange;
    case ServerStatus.checking:
      return Colors.blue;
    case ServerStatus.unknown:
      return Colors.grey;
  }
}

IconData _getStatusIcon(ServerStatus status) {
  switch (status) {
    case ServerStatus.unknown:
      return Icons.help_outline;
    case ServerStatus.checking:
      return Icons.cloud_sync;
    case ServerStatus.online:
      return Icons.cloud_done;
    case ServerStatus.offline:
      return Icons.cloud_off;
    case ServerStatus.error:
      return Icons.cloud_off;
  }
}
