import 'package:flutter_test/flutter_test.dart';
import 'package:traceoff_mobile/utils/url_extractor.dart';

void main() {
  group('UrlExtractor Tests', () {
    group('extractFirstHttpUrl', () {
      test('extracts first HTTP URL from text with multiple URLs', () {
        const String input = '''
        I'm using Gboard to type in English (US) (QWERTY). You can try it at: 
        https://gboard.app.goo.gl?utm_campaign=user_referral&amv=26830000&apn=com.google.android.inputmethod.latin&ibi=com.google.keyboard&isi=1091700242&link=https%3A%2F%2Fdeeplink.com.google.android.inputmethod.latin%2F%3FdeeplinkInfo%3DH4sIAAAAAAAAAOPi52JNzdMNDRZiKyxPLSqplPi2aL4%252BABCf%252FHsWAAAA&utm_medium=deeplink&utm_source=access_point&ofl=https%3A%2F%2Fplay.google.com%2Fstore%2Fapps%2Fdetails%3Fid%3Dcom.google.android.inputmethod.latin
        
        Also check out: https://example.com/test
        And another: http://test.com
        ''';

        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(result, isNotNull);
        expect(result, startsWith('https://gboard.app.goo.gl'));
        expect(result, contains('utm_campaign=user_referral'));
        expect(result, contains('amv=26830000'));
        expect(result, contains('apn=com.google.android.inputmethod.latin'));
      });

      test('extracts HTTPS URL from simple text', () {
        const String input = 'Check out https://example.com for more info';
        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(result, equals('https://example.com'));
      });

      test('extracts HTTP URL from simple text', () {
        const String input = 'Visit http://test.com for details';
        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(result, equals('http://test.com'));
      });

      test('extracts URL with query parameters', () {
        const String input =
            'Link: https://example.com?param1=value1&param2=value2';
        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(
            result, equals('https://example.com?param1=value1&param2=value2'));
      });

      test('extracts URL with fragment', () {
        const String input = 'See https://example.com/page#section1';
        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(result, equals('https://example.com/page#section1'));
      });

      test('extracts URL with complex query parameters', () {
        const String input =
            'URL: https://example.com?utm_source=test&utm_medium=email&utm_campaign=newsletter&ref=homepage';
        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(
            result,
            equals(
                'https://example.com?utm_source=test&utm_medium=email&utm_campaign=newsletter&ref=homepage'));
      });

      test('extracts URL with encoded characters', () {
        const String input =
            'Link: https://example.com?encoded=%20%21%40%23%24%25%5E%26%2A';
        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(result,
            equals('https://example.com?encoded=%20%21%40%23%24%25%5E%26%2A'));
      });

      test('extracts URL with subdomain', () {
        const String input = 'Visit https://subdomain.example.com/path';
        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(result, equals('https://subdomain.example.com/path'));
      });

      test('extracts URL with port', () {
        const String input = 'Server: https://example.com:8080/api';
        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(result, equals('https://example.com:8080/api'));
      });

      test('stops at whitespace', () {
        const String input = 'URL: https://example.com and some other text';
        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(result, equals('https://example.com'));
      });

      test('stops at common punctuation', () {
        const String input = 'URL: https://example.com. Next sentence.';
        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(result, equals('https://example.com'));
      });

      test('returns null for empty text', () {
        const String input = '';
        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(result, isNull);
      });

      test('returns null for text without URLs', () {
        const String input = 'This is just plain text without any URLs';
        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(result, isNull);
      });

      test('returns null for invalid URLs', () {
        const String input = 'Invalid: https://';
        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(result, isNull);
      });

      test('returns null for non-HTTP URLs', () {
        const String input = 'FTP: ftp://example.com';
        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(result, isNull);
      });

      test('handles case insensitive matching', () {
        const String input = 'URL: HTTPS://EXAMPLE.COM/PATH';
        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(result, equals('HTTPS://EXAMPLE.COM/PATH'));
      });

      test('handles URLs with special characters in path', () {
        const String input =
            'Link: https://example.com/path/with-special_chars.html';
        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(
            result, equals('https://example.com/path/with-special_chars.html'));
      });

      test('handles URLs with multiple slashes', () {
        const String input = 'Link: https://example.com//path//to//resource';
        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(result, equals('https://example.com//path//to//resource'));
      });

      test('handles URLs with parentheses in query params', () {
        const String input =
            'Link: https://example.com?query=(test)&other=value';
        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(result, equals('https://example.com?query=(test)&other=value'));
      });
    });

    group('extractAllHttpUrls', () {
      test('extracts all URLs from text with multiple URLs', () {
        const String input = '''
        Check these links:
        https://example.com/first
        http://test.com/second
        https://another.com/third
        ''';

        final List<String> results = UrlExtractor.extractAllHttpUrls(input);

        expect(results, hasLength(3));
        expect(results, contains('https://example.com/first'));
        expect(results, contains('http://test.com/second'));
        expect(results, contains('https://another.com/third'));
      });

      test('returns empty list for text without URLs', () {
        const String input = 'This is just plain text without any URLs';
        final List<String> results = UrlExtractor.extractAllHttpUrls(input);

        expect(results, isEmpty);
      });

      test('returns empty list for empty text', () {
        const String input = '';
        final List<String> results = UrlExtractor.extractAllHttpUrls(input);

        expect(results, isEmpty);
      });

      test('filters out invalid URLs', () {
        const String input = '''
        Valid: https://example.com
        Invalid: https://
        Valid: http://test.com
        ''';

        final List<String> results = UrlExtractor.extractAllHttpUrls(input);

        expect(results, hasLength(2));
        expect(results, contains('https://example.com'));
        expect(results, contains('http://test.com'));
      });

      test('handles URLs with complex query parameters', () {
        const String input = '''
        URL1: https://example.com?param1=value1&param2=value2
        URL2: http://test.com?utm_source=test&utm_medium=email
        ''';

        final List<String> results = UrlExtractor.extractAllHttpUrls(input);

        expect(results, hasLength(2));
        expect(results,
            contains('https://example.com?param1=value1&param2=value2'));
        expect(results,
            contains('http://test.com?utm_source=test&utm_medium=email'));
      });
    });

    group('Real-world examples', () {
      test('extracts Gboard URL from complex text', () {
        const String input = '''
        I'm using Gboard to type in English (US) (QWERTY). You can try it at: 
        https://gboard.app.goo.gl?utm_campaign=user_referral&amv=26830000&apn=com.google.android.inputmethod.latin&ibi=com.google.keyboard&isi=1091700242&link=https%3A%2F%2Fdeeplink.com.google.android.inputmethod.latin%2F%3FdeeplinkInfo%3DH4sIAAAAAAAAAOPi52JNzdMNDRZiKyxPLSqplPi2aL4%252BABCf%252FHsWAAAA&utm_medium=deeplink&utm_source=access_point&ofl=https%3A%2F%2Fplay.google.com%2Fstore%2Fapps%2Fdetails%3Fid%3Dcom.google.android.inputmethod.latin
        
        This is a very long URL with many parameters.
        ''';

        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(result, isNotNull);
        expect(result, startsWith('https://gboard.app.goo.gl'));
        expect(result, contains('utm_campaign=user_referral'));
        expect(result, contains('amv=26830000'));
        expect(result, contains('apn=com.google.android.inputmethod.latin'));
        expect(result, contains('ibi=com.google.keyboard'));
        expect(result, contains('isi=1091700242'));
        expect(
            result,
            contains(
                'link=https%3A%2F%2Fdeeplink.com.google.android.inputmethod.latin'));
        expect(result, contains('utm_medium=deeplink'));
        expect(result, contains('utm_source=access_point'));
        expect(
            result,
            contains(
                'ofl=https%3A%2F%2Fplay.google.com%2Fstore%2Fapps%2Fdetails%3Fid%3Dcom.google.android.inputmethod.latin'));
      });

      test('extracts URL from email text', () {
        const String input = '''
        Hi there,
        
        I found this interesting article: https://example.com/article?ref=email&utm_source=newsletter
        
        Let me know what you think!
        
        Best regards,
        John
        ''';

        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(
            result,
            equals(
                'https://example.com/article?ref=email&utm_source=newsletter'));
      });

      test('extracts URL from social media text', () {
        const String input = '''
        Just discovered this amazing tool! 🔥
        
        Check it out: https://traceoff.com?utm_source=twitter&utm_medium=social&utm_campaign=launch
        
        #privacy #tracking #urls
        ''';

        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(
            result,
            equals(
                'https://traceoff.com?utm_source=twitter&utm_medium=social&utm_campaign=launch'));
      });

      test('extracts URL from markdown text', () {
        const String input = '''
        # My Blog Post
        
        Here's a [link](https://example.com/post?utm_source=blog&utm_medium=markdown) to read more.
        
        Also check out: https://another.com/resource
        ''';

        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(
            result,
            equals(
                'https://example.com/post?utm_source=blog&utm_medium=markdown'));
      });

      test('extracts URL without protocol prefix (bit.ly)', () {
        const String input = 'Check this out: bit.ly/4rvJwRn';

        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(result, equals('https://bit.ly/4rvJwRn'));
      });

      test('extracts URL without protocol prefix (example.com)', () {
        const String input = 'Visit example.com/path for more info';

        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(result, equals('https://example.com/path'));
      });

      test('prioritizes URLs with protocol over those without', () {
        const String input = 'See https://example.com and bit.ly/abc';

        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(result, equals('https://example.com'));
      });

      test('does not extract email addresses as URLs', () {
        const String input = 'Contact me at user@example.com';

        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(result, isNull);
      });

      test('extracts URL without protocol when no protocol URL exists', () {
        const String input = 'Short link: t.co/xyz123';

        final String? result = UrlExtractor.extractFirstHttpUrl(input);

        expect(result, equals('https://t.co/xyz123'));
      });
    });
  });
}
