import 'dart:core';

/// Utility class for extracting URLs from text
class UrlExtractor {
  /// Extracts the first continuous link string starting with http from the given text
  ///
  /// Returns the first valid HTTP/HTTPS URL found in the text, or null if none found.
  /// Also detects URLs without protocol prefixes (e.g., "bit.ly/4rvJwRn") and prepends "https://".
  ///
  /// Example:
  /// Input: "I'm using Gboard to type in English (US) (QWERTY). You can try it at: https://gboard.app.goo.gl?utm_campaign=user_referral&amv=26830000&apn=com.google.android.inputmethod.latin&ibi=com.google.keyboard&isi=1091700242&link=https%3A%2F%2Fdeeplink.com.google.android.inputmethod.latin%2F%3FdeeplinkInfo%3DH4sIAAAAAAAAAOPi52JNzdMNDRZiKyxPLSqplPi2aL4%252BABCf%252FHsWAAAA&utm_medium=deeplink&utm_source=access_point&ofl=https%3A%2F%2Fplay.google.com%2Fstore%2Fapps%2Fdetails%3Fid%3Dcom.google.android.inputmethod.latin"
  /// Output: "https://gboard.app.goo.gl?utm_campaign=user_referral&amv=26830000&apn=com.google.android.inputmethod.latin&ibi=com.google.keyboard&isi=1091700242&link=https%3A%2F%2Fdeeplink.com.google.android.inputmethod.latin%2F%3FdeeplinkInfo%3DH4sIAAAAAAAAAOPi52JNzdMNDRZiKyxPLSqplPi2aL4%252BABCf%252FHsWAAAA&utm_medium=deeplink&utm_source=access_point&ofl=https%3A%2F%2Fplay.google.com%2Fstore%2Fapps%2Fdetails%3Fid%3Dcom.google.android.inputmethod.latin"
  static String? extractFirstHttpUrl(String text) {
    if (text.isEmpty) return null;

    // First, try to match HTTP/HTTPS URLs (existing behavior)
    final RegExp httpUrlPattern = RegExp(
      r'https?://[^\s<>"{}|\\^`\[\]]+',
      caseSensitive: false,
    );

    Match? match = httpUrlPattern.firstMatch(text);
    if (match != null) {
      String url = match.group(0)!;
      // Trim trailing punctuation that might have been included
      url = url.replaceAll(RegExp(r'[.,!?;:)]+$'), '');

      // Validate that the extracted URL is actually valid
      try {
        final uri = Uri.parse(url);
        if (uri.hasScheme &&
            (uri.scheme == 'http' || uri.scheme == 'https') &&
            uri.hasAuthority) {
          return url;
        }
      } catch (_) {
        // Invalid URI, continue to check for URLs without protocol
      }
    }

    // If no HTTP/HTTPS URL found, try to match URLs without protocol
    // Pattern matches:
    // - Domain (with optional www. or subdomain)
    // - Followed by optional path, query params, or fragment
    // - Must have at least a domain and TLD (e.g., "bit.ly", "example.com")
    // - Avoids matching email addresses (no @ before domain)
    // - Avoids matching if preceded by :// (already handled above)
    // - Must start at word boundary or beginning of string
    final RegExp noProtocolUrlPattern = RegExp(
      r'(?:^|[\s>])(?<!://)(?<!@)(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,}(?:/[^\s<>"{}|\\^`\[\]]*)?',
      caseSensitive: false,
    );

    match = noProtocolUrlPattern.firstMatch(text);
    if (match != null) {
      String url = match.group(0)!.trim();
      
      // Skip if it's just whitespace or empty
      if (url.isEmpty) return null;
      
      // Trim trailing punctuation that might have been included
      url = url.replaceAll(RegExp(r'[.,!?;:)]+$'), '');
      
      // Validate that it looks like a URL (has domain and TLD)
      // Check if it's not just a single word or email-like pattern
      if (url.contains('/') || 
          RegExp(r'^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\.[a-z]{2,}', caseSensitive: false).hasMatch(url)) {
        try {
          // Prepend https:// and validate
          final fullUrl = 'https://$url';
          final uri = Uri.parse(fullUrl);
          if (uri.hasAuthority && uri.host.isNotEmpty) {
            // Additional validation: ensure it's not an email address
            // Check if there's an @ before the domain in the original text
            final matchStart = match.start;
            final beforeMatch = text.substring(0, matchStart);
            // Check if there's @ before, or if it's part of a protocol (://)
            if (!beforeMatch.endsWith('@') && 
                !beforeMatch.endsWith('@ ') &&
                !beforeMatch.contains('://')) {
              return fullUrl;
            }
          }
        } catch (_) {
          // Invalid URI, return null
        }
      }
    }

    return null;
  }

  /// Extracts all HTTP/HTTPS URLs from the given text
  ///
  /// Returns a list of all valid HTTP/HTTPS URLs found in the text.
  /// Also detects URLs without protocol prefixes and prepends "https://".
  static List<String> extractAllHttpUrls(String text) {
    if (text.isEmpty) return [];

    final List<String> urls = [];

    // First, try to match HTTP/HTTPS URLs
    final RegExp httpUrlPattern = RegExp(
      r'https?://[^\s<>"{}|\\^`\[\]]+',
      caseSensitive: false,
    );

    final Iterable<Match> httpMatches = httpUrlPattern.allMatches(text);
    for (final Match match in httpMatches) {
      String url = match.group(0)!;
      url = url.replaceAll(RegExp(r'[.,!?;:)]+$'), '');

      try {
        final uri = Uri.parse(url);
        if (uri.hasScheme &&
            (uri.scheme == 'http' || uri.scheme == 'https') &&
            uri.hasAuthority) {
          urls.add(url);
        }
      } catch (_) {
        // Invalid URI, skip it
      }
    }

    // If we found HTTP/HTTPS URLs, return them (prioritize explicit protocols)
    if (urls.isNotEmpty) return urls;

    // Otherwise, try to match URLs without protocol
    final RegExp noProtocolUrlPattern = RegExp(
      r'(?<!://)(?<!@)(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,}(?:/[^\s<>"{}|\\^`\[\]]*)?',
      caseSensitive: false,
    );

    final Iterable<Match> noProtocolMatches = noProtocolUrlPattern.allMatches(text);
    for (final Match match in noProtocolMatches) {
      String url = match.group(0)!;
      url = url.replaceAll(RegExp(r'[.,!?;:)]+$'), '');

      if (url.contains('/') ||
          RegExp(r'^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\.[a-z]{2,}', caseSensitive: false).hasMatch(url)) {
        try {
          final fullUrl = 'https://$url';
          final uri = Uri.parse(fullUrl);
          if (uri.hasAuthority && uri.host.isNotEmpty) {
            // Additional validation: ensure it's not an email address
            final matchStart = match.start;
            final beforeMatch = text.substring(0, matchStart);
            if (!beforeMatch.endsWith('@') && !beforeMatch.endsWith('@ ')) {
              urls.add(fullUrl);
            }
          }
        } catch (_) {
          // Invalid URI, skip it
        }
      }
    }

    return urls;
  }
}
