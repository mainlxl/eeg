import 'package:easy_localization/easy_localization.dart';

extension LocalExtension on String {
  String get lc => this.tr();
}
