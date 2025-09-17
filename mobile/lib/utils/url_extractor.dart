import 'dart:core';

/// Utility class for extracting URLs from text
class UrlExtractor {
  /// Extracts the first continuous link string starting with http from the given text
  ///
  /// Returns the first valid HTTP/HTTPS URL found in the text, or null if none found.
  ///
  /// Example:
  /// Input: "I'm using Gboard to type in English (US) (QWERTY). You can try it at: https://gboard.app.goo.gl?utm_campaign=user_referral&amv=26830000&apn=com.google.android.inputmethod.latin&ibi=com.google.keyboard&isi=1091700242&link=https%3A%2F%2Fdeeplink.com.google.android.inputmethod.latin%2F%3FdeeplinkInfo%3DH4sIAAAAAAAAAOPi52JNzdMNDRZiKyxPLSqplPi2aL4%252BABCf%252FHsWAAAA&utm_medium=deeplink&utm_source=access_point&ofl=https%3A%2F%2Fplay.google.com%2Fstore%2Fapps%2Fdetails%3Fid%3Dcom.google.android.inputmethod.latin"
  /// Output: "https://gboard.app.goo.gl?utm_campaign=user_referral&amv=26830000&apn=com.google.android.inputmethod.latin&ibi=com.google.keyboard&isi=1091700242&link=https%3A%2F%2Fdeeplink.com.google.android.inputmethod.latin%2F%3FdeeplinkInfo%3DH4sIAAAAAAAAAOPi52JNzdMNDRZiKyxPLSqplPi2aL4%252BABCf%252FHsWAAAA&utm_medium=deeplink&utm_source=access_point&ofl=https%3A%2F%2Fplay.google.com%2Fstore%2Fapps%2Fdetails%3Fid%3Dcom.google.android.inputmethod.latin"
  static String? extractFirstHttpUrl(String text) {
    if (text.isEmpty) return null;

    // Regular expression to match HTTP/HTTPS URLs
    // This pattern matches:
    // - http:// or https://
    // - followed by valid URL characters (including query parameters, fragments, etc.)
    // - stops at whitespace or common sentence-ending punctuation
    final RegExp urlPattern = RegExp(
      r'https?://[^\s<>"{}|\\^`\[\]]+',
      caseSensitive: false,
    );

    final Match? match = urlPattern.firstMatch(text);
    if (match == null) return null;

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
      // Invalid URI, return null
    }

    return null;
  }

  /// Extracts all HTTP/HTTPS URLs from the given text
  ///
  /// Returns a list of all valid HTTP/HTTPS URLs found in the text.
  static List<String> extractAllHttpUrls(String text) {
    if (text.isEmpty) return [];

    final RegExp urlPattern = RegExp(
      r'https?://[^\s<>"{}|\\^`\[\]]+',
      caseSensitive: false,
    );

    final List<String> urls = [];
    final Iterable<Match> matches = urlPattern.allMatches(text);

    for (final Match match in matches) {
      String url = match.group(0)!;

      // Trim trailing punctuation that might have been included
      url = url.replaceAll(RegExp(r'[.,!?;:)]+$'), '');

      // Validate that the extracted URL is actually valid
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

    return urls;
  }
}
