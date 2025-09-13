import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing Modes'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Local Processing Section
            _buildModeCard(
              context,
              title: 'Local Processing',
              icon: Icons.storage,
              color: Colors.blue,
              description: 'URL cleaning happens entirely on your device',
              pros: [
                'Complete privacy - no data leaves your device',
                'Works offline - no internet required',
                'No server dependency - always available',
                'Perfect for sensitive links you\'re sending',
              ],
              cons: [
                'Less sophisticated cleaning algorithms',
                'May miss some tracking parameters',
                'Limited to basic redirect following',
                'No server-side intelligence',
              ],
              whenToUse:
                  'Use when you want maximum privacy and are sending links to others. Your IP address and the original URL never leave your device.',
            ),

            const SizedBox(height: 24),

            // Remote Processing Section
            _buildModeCard(
              context,
              title: 'Remote Processing',
              icon: Icons.cloud,
              color: Colors.green,
              description: 'URL cleaning happens on our secure servers',
              pros: [
                'Advanced cleaning algorithms',
                'Comprehensive tracking parameter detection',
                'Server-side intelligence and updates',
                'Better redirect following capabilities',
                'Regular algorithm improvements',
              ],
              cons: [
                'Requires internet connection',
                'URL is sent to our servers',
                'Your IP address is visible to our servers',
                'Depends on server availability',
              ],
              whenToUse:
                  'Use when you want the best cleaning results and are processing links you received from others. Our servers can detect more tracking parameters than local processing.',
            ),

            const SizedBox(height: 24),

            // Security & Privacy Section
            _buildInfoCard(
              context,
              title: 'Security & Privacy',
              icon: Icons.security,
              color: Colors.orange,
              content: [
                'We never store your URLs or personal data',
                'All processing is done in real-time',
                'No logs are kept of your cleaning requests',
                'Our servers use industry-standard encryption',
                'You can switch modes anytime without losing data',
              ],
            ),

            const SizedBox(height: 24),

            // Recommendations Section
            _buildInfoCard(
              context,
              title: 'Our Recommendations',
              icon: Icons.lightbulb,
              color: Colors.purple,
              content: [
                'For links you\'re sending: Use Local Processing',
                'For links you received: Use Remote Processing',
                'For best results: Use Remote Processing when possible',
                'When in doubt: Start with Remote, switch to Local if needed',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String description,
    required List<String> pros,
    required List<String> cons,
    required String whenToUse,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 16),

            // Pros
            _buildListSection(
              context,
              'Advantages',
              Icons.check_circle,
              Colors.green,
              pros,
            ),

            const SizedBox(height: 16),

            // Cons
            _buildListSection(
              context,
              'Limitations',
              Icons.warning,
              Colors.orange,
              cons,
            ),

            const SizedBox(height: 16),

            // When to use
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: color, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'When to use:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    whenToUse,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<String> content,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...content.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 6,
                        color: color,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildListSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<String> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.arrow_right,
                    size: 16,
                    color: color.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
