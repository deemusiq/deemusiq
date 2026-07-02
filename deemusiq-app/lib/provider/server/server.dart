import 'dart:io';
import 'dart:math';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shelf/shelf_io.dart';
import 'package:deemusiq/provider/server/pipeline.dart';
import 'package:deemusiq/provider/server/router.dart';
import 'package:deemusiq/provider/user_preferences/user_preferences_provider.dart';
import 'package:deemusiq/services/audio_player/audio_player.dart';
import 'package:deemusiq/services/logger/logger.dart';

final serverProvider = FutureProvider(
  (ref) async {
    final enabledRemoteConnect = ref.watch(
      userPreferencesProvider.select((value) => value.enableConnect),
    );
    final connectPort = ref.watch(
      userPreferencesProvider.select((value) => value.connectPort),
    );
    final pipeline = ref.watch(pipelineProvider);
    final router = ref.watch(serverRouterProvider);

    if (connectPort == -1) {
      if (DeeMusiqMedia.serverPort == 0) {
        final port = Random().nextInt(17500) + 5000;
        DeeMusiqMedia.serverPort = port;
      }
    } else {
      DeeMusiqMedia.serverPort = connectPort;
    }

    HttpServer server;
    var maxRetries = 10;
    while (true) {
      try {
        server = await serve(
          pipeline.addHandler(router.call),
          enabledRemoteConnect
              ? InternetAddress.anyIPv4
              : InternetAddress.loopbackIPv4,
          DeeMusiqMedia.serverPort,
          shared: true,
        );
        break;
      } on SocketException catch (e, stack) {
        if (e.osError?.errorCode == 98 && --maxRetries > 0) {
          AppLogger.log.w('Port ${DeeMusiqMedia.serverPort} in use, retrying...');
          DeeMusiqMedia.serverPort = Random().nextInt(17500) + 5000;
          continue;
        }
        AppLogger.reportError(e, stack, 'server port bind failed');
        rethrow;
      }
    }

    AppLogger.log.t(
      'Playback server at http://${server.address.host}:${server.port}',
    );

    ref.onDispose(() {
      server.close();
    });

    return (
      server: server,
      port: DeeMusiqMedia.serverPort,
    );
  },
);
