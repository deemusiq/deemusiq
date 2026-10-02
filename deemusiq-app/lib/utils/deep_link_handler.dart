import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:deemusiq/collections/routes.dart';
import 'package:deemusiq/services/logger/logger.dart';

class DeepLinkHandler {
  static final AppLinks appLinks = AppLinks();
  static StreamSubscription<Uri>? _uriSubscription;
  static bool _isSetup = false;

  static void setup(AppRouter router) {
    if (_isSetup) return;
    _isSetup = true;

    _uriSubscription = appLinks.uriLinkStream.listen((uri) {
      final videoId = _extractYouTubeId(uri);
      if (videoId != null) {
        router.pushNamed('/track/$videoId');
      }
    });

    appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        final videoId = _extractYouTubeId(uri);
        if (videoId != null) {
          router.pushNamed('/track/$videoId');
        }
      }
    }).catchError((error, stack) {
      AppLogger.log.w('DeepLinkHandler: getInitialLink failed: $error');
    });
  }

  static void dispose() {
    _uriSubscription?.cancel();
    _uriSubscription = null;
    _isSetup = false;
  }

  /// Exact/suffix host matching — `contains()` would also match attacker
  /// hosts like `evil-youtube.com.evil.example` or `notyoutube.com`.
  static bool _isYouTubeHost(String host) =>
      host == 'youtube.com' || host.endsWith('.youtube.com');

  static bool _isYouTubeShortHost(String host) =>
      host == 'youtu.be' || host.endsWith('.youtu.be');

  static String? _extractYouTubeId(Uri uri) {
    final host = uri.host.toLowerCase();
    if (_isYouTubeShortHost(host)) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    if (_isYouTubeHost(host)) {
      return uri.queryParameters['v'];
    }
    return null;
  }
}
