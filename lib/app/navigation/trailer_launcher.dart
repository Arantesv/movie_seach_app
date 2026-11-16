import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

typedef LaunchVideo = Future<bool> Function(Uri uri, LaunchMode mode);

Future<bool> _launchVideo(Uri uri, LaunchMode mode) =>
    launchUrl(uri, mode: mode);

/// Keeps platform launching outside movie state and supports a browser fallback.
class TrailerLauncher {
  const TrailerLauncher({this.launch = _launchVideo});

  final LaunchVideo launch;

  Future<bool> open(String videoKey) async {
    final uri = Uri.https('www.youtube.com', '/watch', {'v': videoKey});
    for (final mode in [
      LaunchMode.externalNonBrowserApplication,
      LaunchMode.externalApplication,
    ]) {
      try {
        if (await launch(uri, mode)) return true;
      } on PlatformException {
        // Try the next supported launch mode.
      }
    }
    return false;
  }
}
