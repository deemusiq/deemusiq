import 'package:bonsoir/bonsoir.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/provider/connect/clients.dart';
import 'package:deemusiq/provider/server/server.dart';
import 'package:deemusiq/provider/user_preferences/user_preferences_provider.dart';
import 'package:deemusiq/services/device_info/device_info.dart';
import 'package:deemusiq/utils/primitive_utils.dart';

final bonsoirProvider = FutureProvider((ref) async {
  final enabled = ref.watch(
    userPreferencesProvider.select((s) => s.enableConnect),
  );
  final resolvedService = await ref.watch(
    connectClientsProvider.selectAsync((s) => s.resolvedService),
  );

  if (!enabled || resolvedService != null) {
    return null;
  }

  final (server: _, :port) = await ref.watch(serverProvider.future);

  final service = BonsoirService(
    name: await DeviceInfoService.instance.computerName(),
    type: '_spotube._tcp',
    port: port,
    attributes: {
      "id": PrimitiveUtils.uuid.v4(),
      // M7: advertise a random per-session instance id, not the OS machine
      // id — a stable hardware id on the LAN is a persistent tracker. The
      // client-side self-filter compares against the same session id.
      "deviceId": DeviceInfoService.instance.sessionId,
    },
  );

  final broadcast = BonsoirBroadcast(service: service);

  await broadcast.ready;
  await broadcast.start();

  ref.onDispose(() async {
    await broadcast.stop();
  });
});
