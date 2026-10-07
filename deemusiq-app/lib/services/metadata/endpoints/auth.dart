import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/utils/platform.dart';

class MetadataAuthEndpoint {
  MetadataAuthEndpoint();

  /// User-configurable fields this provider exposes, rendered by the
  /// metadata-provider settings form. Empty when the provider has nothing
  /// to configure — the built-in DeeMusiq provider currently has none.
  List<MetadataFormFieldObject> get configurationFields => const [];

  Stream get authStateStream {
    throw UnimplementedError('Native plugin must override');
  }

  Future<void> authenticate() async {
    throw UnimplementedError('Native plugin must override');
  }

  bool isAuthenticated() {
    throw UnimplementedError('Native plugin must override');
  }

  Future<void> logout() async {
    if (kIsMobile) {
      WebStorageManager.instance().deleteAllData();
      CookieManager.instance().deleteAllCookies();
    }
    if (kIsDesktop) {
      await WebviewWindow.clearAll();
    }
  }
}
