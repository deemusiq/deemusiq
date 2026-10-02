part of '../database.dart';

class DecryptedText {
  final String value;
  const DecryptedText(this.value);

  /// v2 blobs: `v2:` + base64(12-byte nonce || ciphertext+GCM-tag), encrypted
  /// with AES-256-GCM under a key derived from the store key material (the
  /// same construction as the wallet secure channel). Values WITHOUT the
  /// prefix are legacy Salsa20 blobs (8-byte IV prefix) — readable forever
  /// via [_legacyEncrypter], but never written anymore: the next [encrypt]
  /// call transparently upgrades the row to v2.
  static const _v2Prefix = 'v2:';

  static Encrypter? _legacy;
  static Encrypter? _gcm;

  static Encrypter get _legacyEncrypter {
    _legacy ??= Encrypter(
      Salsa20(
        Key.fromUtf8(EncryptedKvStoreService.encryptionKeySync),
      ),
    );
    return _legacy!;
  }

  static Encrypter get _gcmEncrypter {
    _gcm ??= Encrypter(
      AES(
        Key(EncryptedKvStoreService.aesKeyBytes),
        mode: AESMode.gcm,
      ),
    );
    return _gcm!;
  }

  factory DecryptedText.decrypted(String value) {
    if (value.startsWith(_v2Prefix)) {
      final combined = base64Decode(value.substring(_v2Prefix.length));
      final iv = IV(combined.sublist(0, 12));
      final encrypted = Encrypted(combined.sublist(12));
      return DecryptedText(
        _gcmEncrypter.decrypt(encrypted, iv: iv),
      );
    }
    final combined = base64Decode(value);
    final iv = IV(combined.sublist(0, 8));
    final encrypted = Encrypted(combined.sublist(8));
    return DecryptedText(
      _legacyEncrypter.decrypt(encrypted, iv: iv),
    );
  }

  String encrypt() {
    final iv = IV.fromSecureRandom(12);
    final encrypted = _gcmEncrypter.encrypt(value, iv: iv);
    final combined = [...iv.bytes, ...encrypted.bytes];
    return '$_v2Prefix${base64Encode(combined)}';
  }
}

class EncryptedTextConverter extends TypeConverter<DecryptedText, String> {
  @override
  DecryptedText fromSql(String fromDb) {
    return DecryptedText.decrypted(fromDb);
  }

  @override
  String toSql(DecryptedText value) {
    return value.encrypt();
  }
}
