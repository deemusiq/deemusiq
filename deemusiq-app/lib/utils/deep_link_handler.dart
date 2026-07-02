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

  static String? _extractYouTubeId(Uri uri) {
    if (uri.host.contains('youtube.com') || uri.host.contains('youtu.be')) {
      if (uri.pathSegments.isNotEmpty && uri.host.contains('youtu.be')) {
        return uri.pathSegments.first;
      }
      return uri.queryParameters['v'];
    }
    if (uri.host.contains('music.youtube.com')) {
      return uri.queryParameters['v'];
    }
    return null;
  }
}
