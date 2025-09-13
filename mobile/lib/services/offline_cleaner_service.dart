import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:traceoff_mobile/models/clean_result.dart';

class OfflineCleanerService {
  // --- Tracking params (unchanged) ---
  static const Map<String, String> _trackingParams = {
    'utm_source': 'UTM source tracking',
    'utm_medium': 'UTM medium tracking',
    'utm_campaign': 'UTM campaign tracking',
    'utm_content': 'UTM content tracking',
    'utm_term': 'UTM term tracking',
    'utm_name': 'UTM name tracking',
    'utm_id': 'UTM ID tracking',
    'fbclid': 'Facebook click ID',
    'gclid': 'Google click ID',
    'igshid': 'Instagram tracking',
    'igsh': 'Instagram tracking',
    'ig_mid': 'Instagram message ID tracking',
    'si': 'Instagram session',
    'ref': 'Referral tracking',
    'source': 'Source tracking',
    'campaign': 'Campaign tracking',
    'medium': 'Medium tracking',
    'content': 'Content tracking',
    'term': 'Term tracking',
    'affiliate': 'Affiliate tracking',
    'partner': 'Partner tracking',
    'promo': 'Promo tracking',
    'discount': 'Discount tracking',
    'tracking': 'Generic tracking',
    'click_id': 'Click ID tracking',
    'clickid': 'Click ID tracking',
    'click': 'Click tracking',
    'link': 'Link tracking',
    'redirect': 'Redirect tracking',
    'goto': 'Goto tracking',
    'continue': 'Continue tracking',
    'return': 'Return tracking',
    'callback': 'Callback tracking',
    'success': 'Success tracking',
    'error': 'Error tracking',
    'status': 'Status tracking',
    'result': 'Result tracking',
    'session': 'Session tracking',
    'sessionid': 'Session ID tracking',
    'sid': 'Session ID tracking',
    'token': 'Token tracking',
    'key': 'Key tracking',
    'id': 'ID tracking',
    'uid': 'User ID tracking',
    'user': 'User tracking',
    'member': 'Member tracking',
    'account': 'Account tracking',
    'profile': 'Profile tracking',
    'settings': 'Settings tracking',
    'preferences': 'Preferences tracking',
  };

  // --- Allowed params (unchanged) ---
  static const List<String> _allowedParams = [
    'v',
    't',
    'list',
    'hl',
    'locale',
    'context',
    'tab',
    'line',
  ];

  // --- Redirect walker defaults ---
  static const int _defaultMaxDepth = 10;
  static const Duration _perHopTimeout = Duration(seconds: 6);
  static const int _defaultMaxBodyBytes =
      512 * 1024; // 512 KB cap for HTML sniff

  static Future<CleanResult> cleanUrl(String url) async {
    try {
      final startUri = Uri.parse(url);
      if (!startUri.hasScheme ||
          !(startUri.scheme == 'http' || startUri.scheme == 'https')) {
        throw Exception('Invalid URL: Must be http or https');
      }

      // ignore: avoid_print
      print('[OfflineCleanerService] START - Cleaning URL: $url');

      // 1) Resolve redirects (HTTP Location + generic HTML hints)
      // ignore: avoid_print
      print(
          '[OfflineCleanerService] REDIRECT - Starting redirect resolution (max depth: $_defaultMaxDepth)');
      final redirectResult = await _followRedirectsGeneric(
        url,
        maxDepth: _defaultMaxDepth,
        maxBodyBytes: _defaultMaxBodyBytes,
      );

      final finalUrl = redirectResult['finalUrl'] as String;
      final redirectChain = (redirectResult['chain'] as List<String>);
      final redirectCount = redirectResult['count'] as int;

      // ignore: avoid_print
      print(
          '[OfflineCleanerService] REDIRECT - Completed: $redirectCount redirects followed');
      // ignore: avoid_print
      print(
          '[OfflineCleanerService] REDIRECT - Chain: ${redirectChain.join(' → ')}');
      // ignore: avoid_print
      print('[OfflineCleanerService] REDIRECT - Final URL: $finalUrl');

      // 2) Clean parameters (conservative)
      final finalUri = Uri.parse(finalUrl);
      final domain = finalUri.host.toLowerCase();

      final cleanedParams = <String, String>{};
      final removedParams = <String>[];

      finalUri.queryParameters.forEach((key, value) {
        final lowerKey = key.toLowerCase();
        if (_allowedParams.contains(lowerKey)) {
          cleanedParams[key] = value;
        } else if (_trackingParams.containsKey(lowerKey)) {
          removedParams.add(key); // Store just the parameter name
        } else {
          cleanedParams[key] = value; // conservative keep
        }
      });

      // ignore: avoid_print
      print('[OfflineCleanerService] PARAMS - Original URL: $finalUrl');
      // ignore: avoid_print
      print(
          '[OfflineCleanerService] PARAMS - Original parameters: ${finalUri.queryParameters.keys.join(', ')}');
      // ignore: avoid_print
      print(
          '[OfflineCleanerService] PARAMS - cleanedParams before replace: ${cleanedParams.keys.join(', ')}');
      // ignore: avoid_print
      print(
          '[OfflineCleanerService] PARAMS - Removed ${removedParams.length} tracking parameters: ${removedParams.join(', ')}');

      final cleanedUri = cleanedParams.isEmpty
          ? finalUri.replace(queryParameters: {}, fragment: null)
          : finalUri.replace(queryParameters: cleanedParams, fragment: null);
      final cleanedUrl = cleanedUri.toString();

      // Remove trailing ? if no parameters
      final finalCleanedUrl = cleanedUrl.endsWith('?')
          ? cleanedUrl.substring(0, cleanedUrl.length - 1)
          : cleanedUrl;

      // ignore: avoid_print
      print(
          '[OfflineCleanerService] PARAMS - cleanedUri.queryParameters: ${cleanedUri.queryParameters.keys.join(', ')}');
      // ignore: avoid_print
      print(
          '[OfflineCleanerService] PARAMS - Final cleaned URL: $finalCleanedUrl');

      // 3) Confidence
      final totalParams = finalUri.queryParameters.length;
      final removedCount = removedParams.length;
      final confidence = totalParams > 0
          ? (totalParams - removedCount) / (totalParams == 0 ? 1 : totalParams)
          : 1.0;

      // 4) Actions
      final actions = <String>[];
      if (redirectCount > 0) actions.add('Followed $redirectCount redirects');
      if (removedCount > 0) {
        actions.add('Removed $removedCount tracking parameters');
      }
      if (removedCount == 0 && totalParams > 0) {
        actions.add('No tracking parameters detected');
      }
      if (totalParams == 0 && redirectCount == 0) {
        actions.add('URL was already clean');
      }

      // 5) Alternatives
      final alternatives = <CleanedUrl>[];
      if (cleanedUrl != url) {
        alternatives.add(CleanedUrl(
          url: url,
          confidence: 0.55,
          actions: const [],
          reason: 'Original input',
        ));
      }
      final paramFree =
          finalUri.replace(queryParameters: {}, fragment: null).toString();
      final paramFreeClean = paramFree.endsWith('?')
          ? paramFree.substring(0, paramFree.length - 1)
          : paramFree;
      if (paramFreeClean != finalCleanedUrl) {
        alternatives.add(CleanedUrl(
          url: paramFreeClean,
          confidence: confidence,
          actions: const ['Removed all parameters and fragments'],
          reason: 'Parameter-free canonical',
        ));
      }

      final result = CleanResult(
        primary: CleanedUrl(
          url: finalCleanedUrl,
          confidence: confidence,
          actions: actions,
          redirectionChain: redirectChain.length > 1 ? redirectChain : null,
        ),
        alternatives: alternatives,
        meta: CleanMeta(
          domain: domain,
          strategyId: 'offline-generic',
          strategyVersion: '1.2.0',
          timing: const TimingMetrics(
            totalMs: 0,
            redirectMs: 0,
            processingMs: 0,
          ),
          appliedAt: DateTime.now().toIso8601String(),
        ),
      );

      // ignore: avoid_print
      print(
          '[OfflineCleanerService] COMPLETE - Strategy: offline-generic | Confidence: ${(confidence * 100).toStringAsFixed(1)}% | Actions: ${actions.join(', ')}');
      // ignore: avoid_print
      print(
          '[OfflineCleanerService] COMPLETE - Final result: ${result.primary.url}');

      return result;
    } catch (e) {
      throw Exception('Failed to clean URL offline: $e');
    }
  }

  // Expose single-hop redirect resolution for custom runner
  static Future<String?> followOneRedirect(String url) async {
    try {
      // ignore: avoid_print
      print(
          '[OfflineCleanerService] followOneRedirect - Attempting redirect from: $url');

      final head = await _requestOnce(
        method: 'HEAD',
        url: url,
        userAgent: null,
        timeout: _perHopTimeout,
        wantBody: false,
      );
      if (_isHttpRedirect(head.statusCode) && _hasLocation(head.headers)) {
        final redirectUrl = _resolveLocation(url, head.headers['location']!);
        // ignore: avoid_print
        print(
            '[OfflineCleanerService] followOneRedirect - HEAD redirect found: $redirectUrl');
        return redirectUrl;
      }

      final get = await _requestOnce(
        method: 'GET',
        url: url,
        userAgent: null,
        timeout: _perHopTimeout,
        wantBody: true,
        maxBodyBytes: _defaultMaxBodyBytes,
      );
      if (_isHttpRedirect(get.statusCode) && _hasLocation(get.headers)) {
        final redirectUrl = _resolveLocation(url, get.headers['location']!);
        // ignore: avoid_print
        print(
            '[OfflineCleanerService] followOneRedirect - GET redirect found: $redirectUrl');
        return redirectUrl;
      }

      // ignore: avoid_print
      print(
          '[OfflineCleanerService] followOneRedirect - No redirect found for: $url');
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('[OfflineCleanerService] followOneRedirect - Error for $url: $e');
      return null;
    }
  }

  // Lightweight basic cleaner used by custom runner to finalize
  static Future<CleanResult> cleanBasic(String url) async {
    // ignore: avoid_print
    print(
        '[OfflineCleanerService] cleanBasic - Starting basic cleaning for: $url');

    final uri = Uri.parse(url);
    final domain = uri.host.toLowerCase();
    final cleanedParams = <String, String>{};
    final removedParams = <String>[];
    uri.queryParameters.forEach((key, value) {
      final lowerKey = key.toLowerCase();
      if (_allowedParams.contains(lowerKey)) {
        cleanedParams[key] = value;
      } else if (_trackingParams.containsKey(lowerKey)) {
        removedParams.add(key); // Store just the parameter name
      } else {
        cleanedParams[key] = value;
      }
    });
    final cleanedUri = cleanedParams.isEmpty
        ? uri.replace(queryParameters: {}, fragment: null)
        : uri.replace(queryParameters: cleanedParams, fragment: null);
    final cleanedUrl = cleanedUri.toString();

    // Remove trailing ? if no parameters
    final finalUrl = cleanedUrl.endsWith('?')
        ? cleanedUrl.substring(0, cleanedUrl.length - 1)
        : cleanedUrl;
    final totalParams = uri.queryParameters.length;
    final removedCount = removedParams.length;
    final confidence = totalParams > 0
        ? (totalParams - removedCount) / (totalParams == 0 ? 1 : totalParams)
        : 1.0;
    final result = CleanResult(
      primary: CleanedUrl(
        url: finalUrl,
        confidence: confidence,
        actions: removedCount > 0
            ? ['Removed $removedCount tracking parameters']
            : const ['No tracking parameters detected'],
      ),
      alternatives: const [],
      meta: CleanMeta(
        domain: domain,
        strategyId: 'offline-basic',
        strategyVersion: '1.0.0',
        timing: const TimingMetrics(totalMs: 0, redirectMs: 0, processingMs: 0),
        appliedAt: DateTime.now().toIso8601String(),
      ),
    );

    // ignore: avoid_print
    print('[OfflineCleanerService] cleanBasic - Original URL: $url');
    // ignore: avoid_print
    print(
        '[OfflineCleanerService] cleanBasic - Original parameters: ${uri.queryParameters.keys.join(', ')}');
    // ignore: avoid_print
    print(
        '[OfflineCleanerService] cleanBasic - Removed: $removedCount params (${removedParams.join(', ')}) | Confidence: ${(confidence * 100).toStringAsFixed(1)}%');
    // ignore: avoid_print
    print('[OfflineCleanerService] cleanBasic - Final URL: $finalUrl');

    return result;
  }

  /// Generic redirect follower:
  /// 1) Follow HTTP 3xx Location
  /// 2) If none, and content-type looks HTML, read up to [maxBodyBytes] and check:
  ///    - Refresh: response header
  ///    - <meta http-equiv="refresh" ...>
  ///    - <link rel="canonical" href="...">
  ///    - <meta property="og:url" content="...">
  /// Returns: { 'finalUrl': String, 'chain': List<String>, 'count': int }
  static Future<Map<String, dynamic>> _followRedirectsGeneric(
    String url, {
    required int maxDepth,
    required int maxBodyBytes,
  }) async {
    final chain = <String>[url];
    var currentUrl = url;
    var redirectCount = 0;

    final uaCandidates = _dedupeUAs(<String?>[
      null, // no UA header
      'curl/8.4.0',
      'Mozilla/5.0',
    ]);

    for (var i = 0; i < maxDepth; i++) {
      String? nextUrl; // if any UA finds a redirect, use it

      for (final ua in uaCandidates) {
        // (A) HEAD first
        final headResp = await _requestOnce(
          method: 'HEAD',
          url: currentUrl,
          userAgent: ua,
          timeout: _perHopTimeout,
          wantBody: false,
        );

        if (_isHttpRedirect(headResp.statusCode) &&
            _hasLocation(headResp.headers)) {
          nextUrl = _resolveLocation(currentUrl, headResp.headers['location']!);
          break;
        }

        // (B) GET (streamed), possibly inspect minimal body for HTML-driven redirects
        final getResp = await _requestOnce(
          method: 'GET',
          url: currentUrl,
          userAgent: ua,
          timeout: _perHopTimeout,
          wantBody: true,
          maxBodyBytes: maxBodyBytes,
        );

        // HTTP Location wins if present
        if (_isHttpRedirect(getResp.statusCode) &&
            _hasLocation(getResp.headers)) {
          nextUrl = _resolveLocation(currentUrl, getResp.headers['location']!);
          break;
        }

        // Try HTTP Refresh: header
        final refreshHeader = getResp.headers['refresh'];
        if (refreshHeader != null) {
          final rUrl = _parseRefreshHeader(refreshHeader);
          if (rUrl != null) {
            nextUrl = _resolveLocation(currentUrl, rUrl);
            break;
          }
        }

        // If HTML, inspect small body head for meta/canonical/og
        if (_isLikelyHtml(getResp.headers['content-type']) &&
            getResp.bodySnippet != null) {
          final html = getResp.bodySnippet!;
          final metaUrl = _extractMetaRefresh(html);
          if (metaUrl != null) {
            nextUrl = _resolveLocation(currentUrl, metaUrl);
            break;
          }

          final canonical = _extractCanonical(html) ?? _extractOgUrl(html);
          if (canonical != null) {
            nextUrl = _resolveLocation(currentUrl, canonical);
            break;
          }
        }

        // Optional: bail out if Content-Length is huge
        final cl = int.tryParse(getResp.headers['content-length'] ?? '');
        if (cl != null && cl > maxBodyBytes) {
          // Treat current as final to avoid heavy download
          break;
        }
      }

      if (nextUrl == null) {
        // None of the UA attempts yielded a redirect → final
        break;
      }

      // Loop detection
      if (chain.contains(nextUrl)) {
        // Stop at last stable URL before loop
        return {'finalUrl': currentUrl, 'chain': chain, 'count': redirectCount};
      }

      chain.add(nextUrl);
      currentUrl = nextUrl;
      redirectCount++;
    }

    return {'finalUrl': currentUrl, 'chain': chain, 'count': redirectCount};
  }

  /// Request wrapper:
  /// - For HEAD: returns headers/status only.
  /// - For GET with wantBody=true: reads up to [maxBodyBytes] into [bodySnippet] then cancels.
  static Future<_RespHead> _requestOnce({
    required String method,
    required String url,
    String? userAgent,
    required Duration timeout,
    required bool wantBody,
    int maxBodyBytes = _defaultMaxBodyBytes,
  }) async {
    final client = http.Client();
    try {
      final req = http.Request(method, Uri.parse(url));
      req.headers['Accept'] = '*/*';
      req.headers['Accept-Encoding'] = 'identity';
      if (userAgent != null) req.headers['User-Agent'] = userAgent;

      final streamed = await client.send(req).timeout(timeout);

      final headers = Map<String, String>.fromEntries(
        streamed.headers.entries
            .map((e) => MapEntry(e.key.toLowerCase(), e.value)),
      );
      final status = streamed.statusCode;

      String? snippet;
      if (wantBody) {
        // Read up to maxBodyBytes, then cancel
        final completer = Completer<void>();
        final chunks = BytesBuilder(copy: false);
        int total = 0;

        final sub = streamed.stream.listen(
          (List<int> data) {
            if (total >= maxBodyBytes) return;
            final remaining = maxBodyBytes - total;
            if (data.length <= remaining) {
              chunks.add(Uint8List.fromList(data));
              total += data.length;
            } else {
              chunks.add(Uint8List.fromList(data.sublist(0, remaining)));
              total += remaining;
            }
            if (total >= maxBodyBytes && !completer.isCompleted) {
              completer.complete();
            }
          },
          onDone: () {
            if (!completer.isCompleted) completer.complete();
          },
          onError: (_) {
            if (!completer.isCompleted) completer.complete();
          },
          cancelOnError: true,
        );

        // Wait until finished or cap reached
        await completer.future;
        try {
          await sub.cancel();
        } catch (_) {}

        // Convert bytes to a UTF-8-ish string (lossy ok)
        try {
          snippet = utf8.decode(chunks.takeBytes(), allowMalformed: true);
        } catch (_) {
          snippet = null;
        }
      } else {
        // Not reading body; drain quickly
        try {
          final sub = streamed.stream.listen((_) {});
          await sub.cancel();
        } catch (_) {}
      }

      return _RespHead(
          statusCode: status, headers: headers, bodySnippet: snippet);
    } catch (_) {
      return const _RespHead(statusCode: 599, headers: {}, bodySnippet: null);
    } finally {
      client.close();
    }
  }

  // --- Helpers ---

  static bool _isHttpRedirect(int status) => status >= 300 && status < 400;

  static bool _hasLocation(Map<String, String> headers) =>
      (headers['location'] ?? '').isNotEmpty;

  static bool _isLikelyHtml(String? contentType) =>
      contentType != null &&
      RegExp(r'text/html|application/xhtml\+xml', caseSensitive: false)
          .hasMatch(contentType);

  static String _resolveLocation(String baseUrl, String location) {
    final base = Uri.parse(baseUrl);
    return base.resolve(location).toString();
  }

  // Refresh: 0;url=/path or 0; URL='https://...'
  static String? _parseRefreshHeader(String header) {
    // Simple pattern: url=something
    final lowerHeader = header.toLowerCase();
    final urlIndex = lowerHeader.indexOf('url=');
    if (urlIndex == -1) return null;

    var start = urlIndex + 4;
    while (start < header.length && header[start] == ' ') {
      start++;
    }
    if (start >= header.length) return null;

    var end = start;
    while (end < header.length && header[end] != ';' && header[end] != ' ') {
      end++;
    }

    return header.substring(start, end).trim();
  }

  // <meta http-equiv="refresh" content="0; url='...'>  (quotes optional)
  static String? _extractMetaRefresh(String html) {
    final lowerHtml = html.toLowerCase();
    final refreshIndex = lowerHtml.indexOf('http-equiv="refresh"');
    if (refreshIndex == -1) return null;

    final contentIndex = lowerHtml.indexOf('content=', refreshIndex);
    if (contentIndex == -1) return null;

    final contentStart = contentIndex + 8;
    final contentEnd = html.indexOf('>', contentStart);
    if (contentEnd == -1) return null;

    final content = html.substring(contentStart, contentEnd);
    final urlIndex = content.toLowerCase().indexOf('url=');
    if (urlIndex == -1) return null;

    var start = urlIndex + 4;
    while (start < content.length &&
        (content[start] == ' ' ||
            content[start] == '"' ||
            content[start] == "'")) {
      start++;
    }
    if (start >= content.length) return null;

    var end = start;
    while (end < content.length &&
        content[end] != '"' &&
        content[end] != "'" &&
        content[end] != ';') {
      end++;
    }

    return content.substring(start, end).trim();
  }

  // <link rel="canonical" href="...">
  static String? _extractCanonical(String html) {
    final lowerHtml = html.toLowerCase();
    final canonicalIndex = lowerHtml.indexOf('rel="canonical"');
    if (canonicalIndex == -1) return null;

    final linkStart = lowerHtml.lastIndexOf('<link', canonicalIndex);
    if (linkStart == -1) return null;

    final linkEnd = lowerHtml.indexOf('>', canonicalIndex);
    if (linkEnd == -1) return null;

    final linkTag = html.substring(linkStart, linkEnd);
    final hrefIndex = linkTag.toLowerCase().indexOf('href=');
    if (hrefIndex == -1) return null;

    var start = hrefIndex + 5;
    while (start < linkTag.length &&
        (linkTag[start] == ' ' ||
            linkTag[start] == '"' ||
            linkTag[start] == "'")) {
      start++;
    }
    if (start >= linkTag.length) return null;

    var end = start;
    while (end < linkTag.length &&
        linkTag[end] != '"' &&
        linkTag[end] != "'" &&
        linkTag[end] != ' ') {
      end++;
    }

    return linkTag.substring(start, end).trim();
  }

  // <meta property="og:url" content="...">
  static String? _extractOgUrl(String html) {
    final lowerHtml = html.toLowerCase();
    final ogUrlIndex = lowerHtml.indexOf('property="og:url"');
    if (ogUrlIndex == -1) return null;

    final metaStart = lowerHtml.lastIndexOf('<meta', ogUrlIndex);
    if (metaStart == -1) return null;

    final metaEnd = lowerHtml.indexOf('>', ogUrlIndex);
    if (metaEnd == -1) return null;

    final metaTag = html.substring(metaStart, metaEnd);
    final contentIndex = metaTag.toLowerCase().indexOf('content=');
    if (contentIndex == -1) return null;

    var start = contentIndex + 8;
    while (start < metaTag.length &&
        (metaTag[start] == ' ' ||
            metaTag[start] == '"' ||
            metaTag[start] == "'")) {
      start++;
    }
    if (start >= metaTag.length) return null;

    var end = start;
    while (end < metaTag.length &&
        metaTag[end] != '"' &&
        metaTag[end] != "'" &&
        metaTag[end] != ' ') {
      end++;
    }

    return metaTag.substring(start, end).trim();
  }

  static List<String?> _dedupeUAs(List<String?> uas) {
    final out = <String?>[];
    final seen = <String>{};
    for (final ua in uas) {
      final key = ua ?? '<none>';
      if (!seen.contains(key)) {
        seen.add(key);
        out.add(ua);
      }
    }
    return out;
  }

  // Simple online check (unchanged)
  static Future<bool> isOnline() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

/// Lightweight response head + optional small body snippet for HTML sniff.
class _RespHead {
  const _RespHead({
    required this.statusCode,
    required this.headers,
    required this.bodySnippet,
  });

  final int statusCode;
  final Map<String, String> headers; // lowercased keys
  final String? bodySnippet; // only when wantBody == true
}
