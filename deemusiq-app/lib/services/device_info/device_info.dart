import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';

class DeviceInfoService {
  final DeviceInfoPlugin deviceInfo;
  DeviceInfoService._() : deviceInfo = DeviceInfoPlugin();

  static final instance = DeviceInfoService._();

  static const _uuid = Uuid();
  String? _sessionId;

  /// Random per-process instance id advertised over mDNS / used for Connect
  /// self-filtering (M7). Deliberately NOT the OS machine id — a stable
  /// hardware identifier on the LAN would be a persistent tracker. Regenerated
  /// every app start, in-memory only, never persisted.
  String get sessionId => _sessionId ??= _uuid.v4();

  Future<String> deviceId() async {
    final info = await deviceInfo.deviceInfo;

    return switch (info) {
      AndroidDeviceInfo() => info.id,
      IosDeviceInfo() => info.identifierForVendor ?? info.model,
      MacOsDeviceInfo() => info.systemGUID ?? info.model,
      WindowsDeviceInfo() => info.deviceId,
      LinuxDeviceInfo() => info.machineId ?? info.id,
      _ => 'Unknown',
    };
  }

  Future<String> computerName() async {
    final info = await deviceInfo.deviceInfo;

    return switch (info) {
      AndroidDeviceInfo() => info.model,
      IosDeviceInfo() => info.localizedModel,
      MacOsDeviceInfo() => info.computerName,
      WindowsDeviceInfo() => info.computerName,
      LinuxDeviceInfo() => info.name,
      _ => 'Unknown',
    };
  }
}
