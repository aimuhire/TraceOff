import 'dart:io' show Platform;
import 'package:flutter_test/flutter_test.dart';
import 'package:traceoff_mobile/services/offline_cleaner_service.dart';

void main() {
  final allowNetwork = Platform.environment['ALLOW_NETWORK'] == 'true';
  test('Pinterest shortener resolves to canonical pin (real network)',
      () async {
    const input = 'https://pin.it/46SsDHkyg';
    const expected =
        'https://www.pinterest.com/pin/how-to-create-the-scandinavian-hallway-aesthetic-edward-george-in-2025--16466354884561676/';
    final result = await OfflineCleanerService.cleanUrl(input);
    expect(result.primary.url, expected);
  }, skip: allowNetwork ? false : 'Set ALLOW_NETWORK=true to run network test');
}
