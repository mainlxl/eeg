import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;

extension StringCryptoExtension on String {
  String get md5 => '${crypto.md5.convert(utf8.encode(this))}';
}
