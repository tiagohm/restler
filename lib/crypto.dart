import 'dart:convert';

import 'package:encrypt/encrypt.dart';

String encrypt(
  String text,
  String password,
) {
  try {
    final key = Key.fromUtf8(pad(password));
    final encrypter = Encrypter(Fernet(Key.fromUtf8(base64.encode(key.bytes))));
    final encrypted = encrypter.encrypt(text);
    return encrypted.base64;
  } catch (e) {
    print(e);
    return null;
  }
}

String decrypt(
  String text,
  String password,
) {
  try {
    final key = Key.fromUtf8(pad(password));
    final encrypter = Encrypter(Fernet(Key.fromUtf8(base64.encode(key.bytes))));
    final decrypted = encrypter.decrypt(Encrypted.fromBase64(text));
    return decrypted;
  } catch (e) {
    print(e);
    return null;
  }
}

const _key = 'Zutg4FryHWWtMiz3khjKrmiJvt3C3br6';

String pad(String password) {
  if (password == null) {
    throw ArgumentError('password is null');
  }

  if (password.length < 8) {
    throw ArgumentError('password is too short');
  }

  if (password.length > 32) {
    throw ArgumentError('password is too long');
  }

  for (var i = password.length, k = 0; i < 32; i++, k++) {
    password += _key[k];
  }

  return password;
}
