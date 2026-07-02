part of '../database.dart';

class DecryptedText {
  final String value;
  const DecryptedText(this.value);

  static Encrypter? _encrypter;

  static Encrypter get _getEncrypter {
    _encrypter ??= Encrypter(
      Salsa20(
        Key.fromUtf8(EncryptedKvStoreService.encryptionKeySync),
      ),
    );
    return _encrypter!;
  }

  factory DecryptedText.decrypted(String value) {
    final combined = base64Decode(value);
    final iv = IV(combined.sublist(0, 8));
    final encrypted = Encrypted(combined.sublist(8));
    return DecryptedText(
      _getEncrypter.decrypt(encrypted, iv: iv),
    );
  }

  String encrypt() {
    final iv = IV.fromSecureRandom(8);
    final encrypted = _getEncrypter.encrypt(value, iv: iv);
    final combined = [...iv.bytes, ...encrypted.bytes];
    return base64Encode(combined);
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
