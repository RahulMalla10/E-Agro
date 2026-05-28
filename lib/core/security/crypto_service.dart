import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Helpers for hashing and encrypting sensitive local payloads.
class CryptoService {
  CryptoService({AesGcm? algorithm}) : _aes = algorithm ?? AesGcm.with256bits();

  final AesGcm _aes;

  Future<String> hashSha256(String input) async {
    final bytes = utf8.encode(input);
    final digest = await Sha256().hash(bytes);
    return digest.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Returns base64(secretKey):base64(nonce):base64(cipher+mac)
  Future<String> encrypt(String plaintext, SecretKey key) async {
    final secretBox = await _aes.encrypt(
      utf8.encode(plaintext),
      secretKey: key,
    );
    return [
      base64Encode(await key.extractBytes()),
      base64Encode(secretBox.nonce),
      base64Encode(secretBox.cipherText + secretBox.mac.bytes),
    ].join(':');
  }

  Future<String> decrypt(String payload, SecretKey key) async {
    final parts = payload.split(':');
    if (parts.length != 3) {
      throw const FormatException('Invalid encrypted payload');
    }
    final nonce = base64Decode(parts[1]);
    final combined = base64Decode(parts[2]);
    final macLength = _aes.macAlgorithm.macLength;
    final cipherText = combined.sublist(0, combined.length - macLength);
    final macBytes = combined.sublist(combined.length - macLength);

    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: Mac(macBytes),
    );
    final clear = await _aes.decrypt(secretBox, secretKey: key);
    return utf8.decode(clear);
  }

  Future<SecretKey> generateKey() => _aes.newSecretKey();

  Future<SecretKey> keyFromBytes(Uint8List bytes) => _aes.newSecretKeyFromBytes(bytes);
}
