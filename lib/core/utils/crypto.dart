import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;

extension StringCryptoExtension on String {
  String get md5 => '${crypto.md5.convert(utf8.encode(this))}';
}

extension FileCryptoExtension on File {
  Future<String> get md5 async =>
      (await crypto.md5.bind(openRead()).last).toString();

  Future<String> get sha256 async =>
      (await crypto.sha256.bind(openRead()).last).toString();
}
