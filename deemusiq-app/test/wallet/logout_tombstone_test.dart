import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deemusiq/services/kv_store/kv_store.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// H2: after "log out on all devices" / account sign-out, the device must NOT
/// silently re-authenticate — the tombstone in secure storage gates
/// `_authToken()` until an explicit login clears it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final secureStore = <String, String>{};
  final api = WalletApiClient.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await KVStoreService.initialize();
    secureStore.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureChannel, (call) async {
      final args = (call.arguments as Map?)?.cast<String, dynamic>() ?? {};
      switch (call.method) {
        case 'read':
          return secureStore[args['key']];
        case 'write':
          secureStore[args['key'] as String] = args['value'] as String;
          return null;
        case 'delete':
          secureStore.remove(args['key']);
          return null;
        case 'readAll':
          return Map<String, String>.from(secureStore);
        case 'deleteAll':
          secureStore.clear();
          return null;
        case 'containsKey':
          return secureStore.containsKey(args['key']);
      }
      return null;
    });
    await api.debugClearLoggedOutTombstone();
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureChannel, null);
    await api.debugClearLoggedOutTombstone();
  });

  test('fresh state is not logged out', () async {
    expect(await api.isLoggedOut(), isFalse);
  });

  test('tombstone blocks silent re-auth and survives a cache reset', () async {
    await api.markLoggedOut();
    expect(await api.isLoggedOut(), isTrue);
    expect(secureStore['deemusiq_logged_out'], 'true');

    // Authed calls fail with the explicit logged_out code BEFORE any network
    // (no backend is configured in tests, so a slip-through would surface as
    // a connectivity error instead).
    await expectLater(
      api.fetchLinkedAccounts(),
      throwsA(
        isA<WalletApiException>().having((e) => e.code, 'code', 'logged_out'),
      ),
    );
  });

  test('explicit login clears the tombstone (test seam)', () async {
    await api.markLoggedOut();
    expect(await api.isLoggedOut(), isTrue);

    // Mirrors what deviceLogin()/loginEmail()/totpRecover()/authWithGoogle()
    // do on success.
    await api.debugClearLoggedOutTombstone();
    expect(await api.isLoggedOut(), isFalse);
    expect(secureStore.containsKey('deemusiq_logged_out'), isFalse);
  });

  test('clearAccountState preserves the tombstone and device keys', () async {
    await api.markLoggedOut();
    secureStore['deemusiq_device_ed25519_seed_v1'] = 'seed';
    secureStore['deemusiq_device_id'] = 'device-1';
    secureStore['deemusiq_offline_drm_keyring'] = '{}';
    secureStore['deemusiq_secure_seq_abc_def'] = '42';
    secureStore['account_cached_thing'] = 'x';
    await KVStoreService.sharedPreferences.setString('recentSearch', 'q');

    await KVStoreService.clearAccountState();

    // Device-level keys survive — the tombstone in particular, otherwise the
    // wipe would immediately re-enable silent re-auth.
    expect(secureStore['deemusiq_logged_out'], 'true');
    expect(secureStore['deemusiq_device_ed25519_seed_v1'], 'seed');
    expect(secureStore['deemusiq_device_id'], 'device-1');
    expect(secureStore['deemusiq_offline_drm_keyring'], '{}');
    expect(secureStore['deemusiq_secure_seq_abc_def'], '42');
    // Account-derived state is gone.
    expect(secureStore.containsKey('account_cached_thing'), isFalse);
    expect(KVStoreService.sharedPreferences.getString('recentSearch'), isNull);
    expect(await api.isLoggedOut(), isTrue);
  });
}
