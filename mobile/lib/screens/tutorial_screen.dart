import 'package:flutter/material.dart';
import 'package:traceoff_mobile/l10n/app_localizations.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.tutorialProcessingModes),
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
              title: AppLocalizations.of(context)!.tutorialLocalProcessing,
              icon: Icons.storage,
              color: Colors.blue,
              description:
                  AppLocalizations.of(context)!.tutorialLocalDescription,
              pros: [
                AppLocalizations.of(context)!.tutorialLocalPros1,
                AppLocalizations.of(context)!.tutorialLocalPros2,
                AppLocalizations.of(context)!.tutorialLocalPros3,
                AppLocalizations.of(context)!.tutorialLocalPros4,
              ],
              cons: [
                AppLocalizations.of(context)!.tutorialLocalCons1,
                AppLocalizations.of(context)!.tutorialLocalCons2,
                AppLocalizations.of(context)!.tutorialLocalCons3,
                AppLocalizations.of(context)!.tutorialLocalCons4,
              ],
              whenToUse: AppLocalizations.of(context)!.tutorialLocalWhenToUse,
            ),

            const SizedBox(height: 24),

            // Remote Processing Section
            _buildModeCard(
              context,
              title: AppLocalizations.of(context)!.tutorialRemoteProcessing,
              icon: Icons.cloud,
              color: Colors.green,
              description:
                  AppLocalizations.of(context)!.tutorialRemoteDescription,
              pros: [
                AppLocalizations.of(context)!.tutorialRemotePros1,
                AppLocalizations.of(context)!.tutorialRemotePros2,
                AppLocalizations.of(context)!.tutorialRemotePros3,
                AppLocalizations.of(context)!.tutorialRemotePros4,
                AppLocalizations.of(context)!.tutorialRemotePros5,
              ],
              cons: [
                AppLocalizations.of(context)!.tutorialRemoteCons1,
                AppLocalizations.of(context)!.tutorialRemoteCons2,
                AppLocalizations.of(context)!.tutorialRemoteCons3,
                AppLocalizations.of(context)!.tutorialRemoteCons4,
              ],
              whenToUse: AppLocalizations.of(context)!.tutorialRemoteWhenToUse,
            ),

            const SizedBox(height: 24),

            // Security & Privacy Section
            _buildInfoCard(
              context,
              title: AppLocalizations.of(context)!.tutorialSecurityPrivacy,
              icon: Icons.security,
              color: Colors.orange,
              content: [
                AppLocalizations.of(context)!.tutorialSec1,
                AppLocalizations.of(context)!.tutorialSec2,
                AppLocalizations.of(context)!.tutorialSec3,
                AppLocalizations.of(context)!.tutorialSec4,
                AppLocalizations.of(context)!.tutorialSec5,
              ],
            ),

            const SizedBox(height: 24),

            // Recommendations Section
            _buildInfoCard(
              context,
              title: AppLocalizations.of(context)!.tutorialRecommendations,
              icon: Icons.lightbulb,
              color: Colors.purple,
              content: [
                AppLocalizations.of(context)!.tutorialRec1,
                AppLocalizations.of(context)!.tutorialRec2,
                AppLocalizations.of(context)!.tutorialRec3,
                AppLocalizations.of(context)!.tutorialRec4,
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
              AppLocalizations.of(context)!.tutorialAdvantages,
              Icons.check_circle,
              Colors.green,
              pros,
            ),

            const SizedBox(height: 16),

            // Cons
            _buildListSection(
              context,
              AppLocalizations.of(context)!.tutorialLimitations,
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
                        AppLocalizations.of(context)!.tutorialWhenToUseLabel,
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
