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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.verified_user,
                    color: colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!
                        .supportedPlatformsAndWhatWeClean,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (onRequestHideDialog != null) {
                      await onRequestHideDialog!.call();
                    }
                  },
                  icon: const Icon(Icons.close),
                  tooltip: AppLocalizations.of(context)!.hide,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Privacy-first explanation
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer.withValues(alpha: 0.3),
                    colorScheme.secondaryContainer.withValues(alpha: 0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.shield,
                    size: 22,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.whyCleanLinksDescription,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Platforms grid (responsive)
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                int crossAxisCount;
                double aspect;
                if (width < 380) {
                  crossAxisCount = 1;
                  aspect = 2.5;
                } else if (width < 700) {
                  crossAxisCount = 2;
                  aspect = 2.2;
                } else {
                  crossAxisCount = 3;
                  aspect = 1.9;
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
                          'tiktok.com/@user/video/123?is_from_webapp=1&sender_device=pc',
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
                          'reddit.com/r/sub/comments/abc?ref=share&context=3',
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

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                AppLocalizations.of(context)!.privacyNotesDescription,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final it = items[i];
        return _AnimatedPlatformCard(item: it, index: i);
      },
    );
  }
}

class _AnimatedPlatformCard extends StatefulWidget {
  const _AnimatedPlatformCard({required this.item, required this.index});
  final _PlatformItem item;
  final int index;

  @override
  State<_AnimatedPlatformCard> createState() => _AnimatedPlatformCardState();
}

class _AnimatedPlatformCardState extends State<_AnimatedPlatformCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;
  bool _hasStopped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500), // Faster animation
    );
    // Start animation with delay based on index
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted && !_hasStopped) {
        _controller.repeat(reverse: true);
      }
    });
    // Stop animation after 20 seconds
    Future.delayed(const Duration(seconds: 20), () {
      if (mounted && !_hasStopped) {
        setState(() {
          _hasStopped = true;
        });
        _controller.stop();
        // Animate to the clean state (final state)
        _controller.animateTo(1.0, duration: const Duration(milliseconds: 500));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isHovered
                ? [
                    colorScheme.primaryContainer.withValues(alpha: 0.4),
                    colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  ]
                : [
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? colorScheme.primary.withValues(alpha: 0.3)
                : colorScheme.outline.withValues(alpha: 0.15),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    widget.item.icon,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: _AnimatedExample(
                inText: widget.item.exampleIn,
                outText: widget.item.exampleOut,
                animation: animation,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedExample extends StatelessWidget {
  const _AnimatedExample({
    required this.inText,
    required this.outText,
    required this.animation,
  });
  final String inText;
  final String outText;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const mono = TextStyle(fontFamily: 'monospace', fontSize: 9);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // When animation is stopped at 1.0, show both links fully visible
        final isStopped = animation.value == 1.0;
        final showClean = animation.value > 0.5 || isStopped;
        final dirtyOpacity = isStopped
            ? 1.0
            : (showClean
                ? 1.0 - ((animation.value - 0.5) * 2)
                : 1.0 - (animation.value * 2));
        final cleanOpacity =
            isStopped ? 1.0 : (showClean ? (animation.value - 0.5) * 2 : 0.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dirty link (fades out)
            AnimatedOpacity(
              opacity: dirtyOpacity,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: colorScheme.error.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.link_off,
                      size: 10,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        inText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: mono.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Animated arrow
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  Icons.arrow_downward_rounded,
                  key: ValueKey(showClean),
                  size: 16,
                  color: showClean
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            // Clean link (fades in)
            AnimatedOpacity(
              opacity: cleanOpacity,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primaryContainer.withValues(alpha: 0.4),
                      colorScheme.secondaryContainer.withValues(alpha: 0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 10,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        outText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: mono.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
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
