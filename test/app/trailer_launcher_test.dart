import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search_app/app/navigation/trailer_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  test('opens external app first and encodes the video key', () async {
    final modes = <LaunchMode>[];
    final launcher = TrailerLauncher(
      launch: (uri, mode) async {
        modes.add(mode);
        expect(uri.host, 'www.youtube.com');
        expect(uri.queryParameters['v'], 'video & key');
        return true;
      },
    );
    expect(await launcher.open('video & key'), isTrue);
    expect(modes, [LaunchMode.externalNonBrowserApplication]);
  });

  test(
    'unsupported app mode or platform failure falls back to browser',
    () async {
      for (final throwsError in [true, false]) {
        final modes = <LaunchMode>[];
        final launcher = TrailerLauncher(
          launch: (_, mode) async {
            modes.add(mode);
            if (mode == LaunchMode.externalNonBrowserApplication) {
              if (throwsError) throw PlatformException(code: 'unsupported');
              return false;
            }
            return true;
          },
        );
        expect(await launcher.open('video'), isTrue);
        expect(modes, [
          LaunchMode.externalNonBrowserApplication,
          LaunchMode.externalApplication,
        ]);
      }
    },
  );

  test('both modes failing is reported to the caller', () async {
    final launcher = TrailerLauncher(launch: (_, mode) async => false);
    expect(await launcher.open('video'), isFalse);
  });
}
