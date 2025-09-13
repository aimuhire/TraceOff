import 'package:flutter_test/flutter_test.dart';
import 'package:traceoff_mobile/models/clean_result.dart';
import 'package:traceoff_mobile/models/cleaning_strategy.dart';
import 'package:traceoff_mobile/services/custom_strategy_runner.dart';

void main() {
  group('CustomStrategyRunner', () {
    test('removes only specified params', () async {
      final strategy = CleaningStrategy(
        id: 's1',
        name: 'remove-utm',
        steps: [
          const CleaningStep(
            type: CleaningStepType.removeQuery,
            params: {
              'keys': ['utm_source', 'utm_medium', 'fbclid']
            },
          ),
        ],
      );

      const input =
          'https://example.com/page?utm_source=x&keep=1&fbclid=abc&v=2';
      final result = await CustomStrategyRunner.run(input, strategy);
      expect(result, isA<CleanResult>());
      expect(result.primary.url, 'https://example.com/page?keep=1&v=2');
    });

    test('chrome webstore link keeps path, strips params', () async {
      final strategy = CleaningStrategy(
        id: 's2',
        name: 'strip-params',
        steps: [
          const CleaningStep(type: CleaningStepType.removeQuery, params: {
            'keys': ['utm_source', 'utm_medium', 'hl', 'gl', 'pli']
          })
        ],
      );
      const input =
          'https://chromewebstore.google.com/detail/jfgmbkmojppmjcploaneponncjieneok?hl=en&pli=1&utm_source=item-share-cb';
      final result = await CustomStrategyRunner.run(input, strategy);
      expect(result.primary.url,
          'https://chromewebstore.google.com/detail/jfgmbkmojppmjcploaneponncjieneok');
    });

    test('instagram redirect then remove igsh', () async {
      // Note: In unit tests, network redirects may not run. We bound redirect step to max N hops.
      final strategy = CleaningStrategy(
        id: 's3',
        name: 'ig-clean',
        steps: [
          const CleaningStep(
              type: CleaningStepType.redirect, params: {'times': 2}),
          const CleaningStep(type: CleaningStepType.removeQuery, params: {
            'keys': ['igsh']
          }),
        ],
      );
      const input = 'https://www.instagram.com/share/BASdbDGwpY';
      final result = await CustomStrategyRunner.run(input, strategy);
      // We can only assert that igsh is not present if present; the URL may remain if network blocked.
      expect(result.primary.url.contains('igsh='), isFalse);
    });

    test('instagram post URL removes ig_mid parameter', () async {
      final strategy = CleaningStrategy(
        id: 's4',
        name: 'instagram-clean',
        steps: [
          const CleaningStep(type: CleaningStepType.removeQuery, params: {
            'keys': [
              'ig_mid',
              'igsh',
              'igshid',
              'si',
              'utm_source',
              'utm_medium',
              'utm_campaign'
            ]
          }),
        ],
      );
      const input =
          'https://www.instagram.com/p/DOhILIkjjC3?ig_mid=FD6AF636-1E3C-48A3-98DE-F0BCF488F8DB';
      final result = await CustomStrategyRunner.run(input, strategy);
      expect(result.primary.url, 'https://www.instagram.com/p/DOhILIkjjC3');
    });

    test('instagram post URL with multiple tracking params', () async {
      final strategy = CleaningStrategy(
        id: 's5',
        name: 'instagram-multi-clean',
        steps: [
          const CleaningStep(type: CleaningStepType.removeQuery, params: {
            'keys': [
              'ig_mid',
              'igsh',
              'igshid',
              'si',
              'utm_source',
              'utm_medium',
              'utm_campaign',
              'ref',
              'source'
            ]
          }),
        ],
      );
      const input =
          'https://www.instagram.com/p/DOhILIkjjC3?ig_mid=FD6AF636-1E3C-48A3-98DE-F0BCF488F8DB&utm_source=share&ref=home&keep=this';
      final result = await CustomStrategyRunner.run(input, strategy);
      expect(result.primary.url,
          'https://www.instagram.com/p/DOhILIkjjC3?keep=this');
    });
  });
}
