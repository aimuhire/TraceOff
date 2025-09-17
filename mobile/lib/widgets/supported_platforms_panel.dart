import 'package:flutter/material.dart';
import 'package:traceoff_mobile/l10n/app_localizations.dart';

class SupportedPlatformsPanel extends StatelessWidget {
  const SupportedPlatformsPanel(
      {super.key,
      this.onHideForever,
      this.onHideOnce,
      this.onRequestHideDialog});

  final VoidCallback? onHideForever;
  final VoidCallback? onHideOnce;
  final Future<void> Function()? onRequestHideDialog;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified_user, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!
                        .supportedPlatformsAndWhatWeClean,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (onRequestHideDialog != null) {
                      await onRequestHideDialog!.call();
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.hide),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Privacy-first explanation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.whyCleanLinksDescription,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Platforms grid (responsive)
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                int crossAxisCount;
                double aspect;
                if (width < 380) {
                  crossAxisCount = 1;
                  aspect = 2.2; // single column can be wider
                } else if (width < 700) {
                  crossAxisCount = 2;
                  aspect = 1.9; // taller tiles to avoid overflow
                } else {
                  crossAxisCount = 3;
                  aspect = 1.6; // make tiles taller on wide screens
                }
                return _PlatformGrid(
                  items: const [
                    _PlatformItem(
                      name: 'Instagram',
                      icon: Icons.camera_alt,
                      exampleIn:
                          'instagram.com/share/BASdbDGwpY?igshid=xyz&si=abc',
                      exampleOut: 'instagram.com/reel/videoid1234',
                    ),
                    _PlatformItem(
                      name: 'YouTube',
                      icon: Icons.ondemand_video,
                      exampleIn:
                          'youtu.be/dQw4...?feature=share&utm_campaign=social',
                      exampleOut: 'youtube.com/watch?v=dQw4...',
                    ),
                    _PlatformItem(
                      name: 'X (Twitter)',
                      icon: Icons.alternate_email,
                      exampleIn: 'x.com/i/status/1234567890?s=20',
                      exampleOut: 'twitter.com/username/status/1234567890',
                    ),
                    _PlatformItem(
                      name: 'TikTok',
                      icon: Icons.play_circle_fill,
                      exampleIn:
                          'tiktok.com/@user/video/123?is_from_webapp=1&sender_device=pc&share_app_id=1233',
                      exampleOut: 'tiktok.com/@user/video/123',
                    ),
                    _PlatformItem(
                      name: 'Facebook',
                      icon: Icons.facebook,
                      exampleIn:
                          'facebook.com/username/posts/123?fbclid=abc123',
                      exampleOut: 'facebook.com/username/posts/123',
                    ),
                    _PlatformItem(
                      name: 'LinkedIn',
                      icon: Icons.work,
                      exampleIn: 'lnkd.in/gUfrRGMD → interstitial page',
                      exampleOut:
                          'direct external destination (no interstitial)',
                    ),
                    _PlatformItem(
                      name: 'Reddit',
                      icon: Icons.reddit,
                      exampleIn:
                          'reddit.com/r/sub/comments/abc?ref=share&context=3&rdt=12345',
                      exampleOut: 'reddit.com/r/sub/comments/abc',
                    ),
                    _PlatformItem(
                      name: 'Pinterest',
                      icon: Icons.push_pin,
                      exampleIn: 'pin.it/46SsDHkyg (short link)',
                      exampleOut: 'pinterest.com/pin/... (canonical pin)',
                    ),
                    _PlatformItem(
                      name: 'GitHub',
                      icon: Icons.code,
                      exampleIn:
                          'github.com/user/repo/blob/main/file.js?tab=readme',
                      exampleOut: 'github.com/user/repo/blob/main/file.js',
                    ),
                    _PlatformItem(
                      name: 'Medium',
                      icon: Icons.menu_book,
                      exampleIn:
                          'medium.com/@user/article?via=share&utm_source=app',
                      exampleOut: 'medium.com/@user/article',
                    ),
                  ],
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: aspect,
                );
              },
            ),

            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.privacyNotesDescription,
              style:
                  TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformGrid extends StatelessWidget {
  const _PlatformGrid(
      {required this.items,
      required this.crossAxisCount,
      required this.childAspectRatio});
  final List<_PlatformItem> items;
  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final it = items[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(it.icon, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      it.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    _Example(inText: it.exampleIn, outText: it.exampleOut),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Example extends StatelessWidget {
  const _Example({required this.inText, required this.outText});
  final String inText;
  final String outText;

  @override
  Widget build(BuildContext context) {
    const mono = TextStyle(fontFamily: 'monospace', fontSize: 11);
    final faded = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.example, style: faded),
        const SizedBox(height: 2),
        Text(inText, maxLines: 1, overflow: TextOverflow.ellipsis, style: mono),
        const Icon(Icons.arrow_downward, size: 12),
        Text(outText,
            maxLines: 1, overflow: TextOverflow.ellipsis, style: mono),
      ],
    );
  }
}

class _PlatformItem {
  const _PlatformItem({
    required this.name,
    required this.icon,
    required this.exampleIn,
    required this.exampleOut,
  });

  final String name;
  final IconData icon;
  final String exampleIn;
  final String exampleOut;
}
