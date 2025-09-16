import 'package:flutter_test/flutter_test.dart';
import 'dart:io' show Platform;
import 'package:traceoff_mobile/services/offline_cleaner_service.dart';

void main() {
  group('OfflineCleanerService', () {
    test('cleans Instagram post URL with ig_mid parameter', () async {
      const input =
          'https://www.instagram.com/p/DOhILIkjjC3?ig_mid=FD6AF636-1E3C-48A3-98DE-F0BCF488F8DB';
      final result = await OfflineCleanerService.cleanUrl(input);

      expect(result, isNotNull);
      expect(result.primary.url.contains('ig_mid='), isFalse);
      expect(result.primary.url.contains('instagram.com'), isTrue);
      // Instagram URLs get redirected, so we expect redirect actions
      expect(result.primary.actions.isNotEmpty, isTrue);
    });

    test('cleans Instagram post URL with multiple tracking parameters',
        () async {
      const input =
          'https://www.instagram.com/p/DOhILIkjjC3?ig_mid=FD6AF636-1E3C-48A3-98DE-F0BCF488F8DB&utm_source=share&ref=home&keep=this';
      final result = await OfflineCleanerService.cleanUrl(input);

      expect(result, isNotNull);
      expect(result.primary.url.contains('ig_mid='), isFalse);
      expect(result.primary.url.contains('utm_source='), isFalse);
      expect(result.primary.url.contains('ref='), isFalse);
      expect(result.primary.url.contains('instagram.com'), isTrue);
      expect(result.primary.actions.isNotEmpty, isTrue);
    });

    test('cleans Instagram reel URL with tracking parameters', () async {
      const input =
          'https://www.instagram.com/reel/DOhILIkjjC3?ig_mid=FD6AF636-1E3C-48A3-98DE-F0BCF488F8DB&igsh=abc123';
      final result = await OfflineCleanerService.cleanUrl(input);

      expect(result, isNotNull);
      expect(result.primary.url.contains('ig_mid='), isFalse);
      expect(result.primary.url.contains('igsh='), isFalse);
      expect(result.primary.url.contains('instagram.com'), isTrue);
      expect(result.primary.actions.isNotEmpty, isTrue);
    });

    test('cleans Instagram share URL with tracking parameters', () async {
      const input =
          'https://www.instagram.com/share/BASdbDGwpY?ig_mid=FD6AF636-1E3C-48A3-98DE-F0BCF488F8DB&utm_source=share';
      final result = await OfflineCleanerService.cleanUrl(input);

      expect(result, isNotNull);
      expect(result.primary.url.contains('ig_mid='), isFalse);
      expect(result.primary.url.contains('utm_source='), isFalse);
      expect(result.primary.url.contains('instagram.com'), isTrue);
      expect(result.primary.actions.isNotEmpty, isTrue);
    });

    test('preserves essential Instagram parameters', () async {
      const input =
          'https://www.instagram.com/p/DOhILIkjjC3?ig_mid=FD6AF636-1E3C-48A3-98DE-F0BCF488F8DB&hl=en&t=123';
      final result = await OfflineCleanerService.cleanUrl(input);

      expect(result, isNotNull);
      expect(result.primary.url.contains('ig_mid='), isFalse);
      expect(result.primary.url.contains('instagram.com'), isTrue);
      expect(result.primary.actions.isNotEmpty, isTrue);
    });

    test('basic cleaning without redirects works for simple URLs', () async {
      const input =
          'https://example.com/page?ig_mid=FD6AF636-1E3C-48A3-98DE-F0BCF488F8DB&utm_source=test&keep=this';
      final result = await OfflineCleanerService.cleanBasic(input);

      expect(result, isNotNull);
      expect(result.primary.url.contains('ig_mid='), isFalse);
      expect(result.primary.url.contains('utm_source='), isFalse);
      expect(result.primary.url.contains('keep=this'), isTrue);
      expect(result.primary.url, 'https://example.com/page?keep=this');
    });

    final allowNetwork = Platform.environment['ALLOW_NETWORK'] == 'true';
    
    test('cleans TikTok video URL by stripping tracking params (jellyfam)', () async {
      const input = 'https://www.tiktok.com/@jellyfam__/video/7535631609966677279?is_from_webapp=1&sender_device=pc';
      final result = await OfflineCleanerService.cleanUrl(input);
      expect(result.primary.url, 'https://www.tiktok.com/@jellyfam__/video/7535631609966677279');
    });
    test('LinkedIn shortener resolves to external destination (real network)',
        () async {
      const input = 'https://lnkd.in/gUfrRGMD';
      const expected = 'https://rss.com/podcasts/deescovered-oasis/2082075/';
      final result = await OfflineCleanerService.cleanUrl(input);
      expect(result.primary.url, expected);
    },
        skip: allowNetwork
            ? false
            : 'Set ALLOW_NETWORK=true to run network test');
  });
}
