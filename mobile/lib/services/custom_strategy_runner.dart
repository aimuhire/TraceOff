import 'package:traceoff_mobile/models/clean_result.dart';
import 'package:traceoff_mobile/models/cleaning_strategy.dart';
import 'package:traceoff_mobile/services/offline_cleaner_service.dart';

class CustomStrategyRunner {
  static Future<CleanResult> run(String url, CleaningStrategy strategy) async {
    String workingUrl = url;
    final actions = <String>[];
    List<String> chain = [url];
    // Debug prints for troubleshooting
    // ignore: avoid_print
    print(
        '[CustomStrategyRunner] START - URL: $url | Strategy: ${strategy.name} | Steps: ${strategy.steps.length}');

    for (final step in strategy.steps) {
      // ignore: avoid_print
      print(
          '[CustomStrategyRunner] step=${step.type} before url=$workingUrl params=${step.params}');
      switch (step.type) {
        case CleaningStepType.redirect:
          final times = (step.params['times'] as int?) ?? 1;
          var current = workingUrl;
          int hops = 0;
          // ignore: avoid_print
          print(
              '[CustomStrategyRunner] REDIRECT - Attempting $times redirects from: $current');
          for (int i = 0; i < times; i++) {
            // ignore: avoid_print
            print(
                '[CustomStrategyRunner] REDIRECT - Attempt ${i + 1}/$times from: $current');
            final res = await OfflineCleanerService.followOneRedirect(current);
            if (res == null) {
              // ignore: avoid_print
              print(
                  '[CustomStrategyRunner] REDIRECT - Failed at attempt ${i + 1}, no more redirects available');
              break;
            }
            current = res;
            chain.add(current);
            hops++;
            // ignore: avoid_print
            print(
                '[CustomStrategyRunner] REDIRECT - Success! Redirected to: $current');
          }
          if (hops > 0) {
            actions.add('Followed $hops redirects');
            // ignore: avoid_print
            print(
                '[CustomStrategyRunner] REDIRECT - Completed $hops/$times redirects successfully');
          } else {
            // ignore: avoid_print
            print(
                '[CustomStrategyRunner] REDIRECT - No redirects followed, using original URL');
          }
          workingUrl = current;
          break;
        case CleaningStepType.removeQuery:
          final keys =
              (step.params['keys'] as List?)?.cast<String>() ?? const [];
          final uri = Uri.parse(workingUrl);
          final before = Map<String, String>.from(uri.queryParameters);
          final qp = Map<String, String>.from(before);
          int removed = 0;
          for (final target in keys) {
            final lowerTarget = target.toLowerCase();
            final match = qp.keys.firstWhere(
              (k) => k.toLowerCase() == lowerTarget,
              orElse: () => '',
            );
            if (match.isNotEmpty) {
              qp.remove(match);
              removed++;
            }
          }
          Uri newUri;
          if (qp.isEmpty) {
            // Some platforms keep original query when passing null.
            // Rebuild URI without query to guarantee removal.
            newUri = Uri(
              scheme: uri.scheme,
              userInfo: uri.userInfo,
              host: uri.host,
              port: uri.hasPort ? uri.port : null,
              path: uri.path,
              fragment: null,
            );
          } else {
            newUri = uri.replace(queryParameters: qp, fragment: null);
          }
          // ignore: avoid_print
          print(
              '[CustomStrategyRunner] removed=$removed beforeKeys=${before.keys.toList()} afterKeys=${qp.keys.toList()}');
          if (removed > 0) actions.add('Removed $removed parameters');
          workingUrl = newUri.toString();
          break;
        case CleaningStepType.stripFragment:
          final uri = Uri.parse(workingUrl);
          final newUri = uri.replace(fragment: null);
          if (uri.fragment.isNotEmpty) actions.add('Stripped fragment');
          workingUrl = newUri.toString();
          break;
      }
      // ignore: avoid_print
      print('[CustomStrategyRunner] step=${step.type} after url=$workingUrl');
    }

    // Fallback safety: run conservative param cleaning akin to offline service
    // ignore: avoid_print
    print('[CustomStrategyRunner] FINAL - Running cleanBasic on: $workingUrl');
    final offlineResult = await OfflineCleanerService.cleanBasic(workingUrl);
    // ignore: avoid_print
    print(
        '[CustomStrategyRunner] COMPLETE - Final URL: ${offlineResult.primary.url} | Actions: ${[
      ...actions,
      ...offlineResult.primary.actions
    ]} | Chain Length: ${chain.length}');

    return CleanResult(
      primary: CleanedUrl(
        url: offlineResult.primary.url,
        confidence: offlineResult.primary.confidence,
        actions: [...actions, ...offlineResult.primary.actions],
        redirectionChain: chain.length > 1 ? chain : null,
      ),
      alternatives: offlineResult.alternatives,
      meta: offlineResult.meta,
    );
  }
}
