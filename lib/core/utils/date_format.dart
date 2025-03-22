import 'package:easy_localization/easy_localization.dart';

final _yyyy_MM_dd = DateFormat('yyyy-MM-dd');
final _yyyy_MM_dd_HH_mm_ss = DateFormat('yyyy-MM-dd HH:mm:ss');
final _yyyy_MM_dd_n_HH_mm_ss = DateFormat('yyyy-MM-dd \n HH:mm:ss');

extension DateFormatExtension on DateTime {
  String get yyyy_MM_dd => _yyyy_MM_dd.format(this);

  String get yyyy_MM_dd_HH_mm_ss => _yyyy_MM_dd_HH_mm_ss.format(this);
}

extension IntDateFormatExtension on int {
  String get yyyy_MM_dd =>
      _yyyy_MM_dd.format(DateTime.fromMillisecondsSinceEpoch(this));

  String get yyyy_MM_dd_HH_mm_ss =>
      _yyyy_MM_dd_HH_mm_ss.format(DateTime.fromMillisecondsSinceEpoch(this));
}

extension StringFormatExtension on String {
  String get yyyy_MM_dd => _yyyy_MM_dd.format(DateTime.parse(this));

  String get yyyy_MM_dd_HH_mm_ss =>
      _yyyy_MM_dd_HH_mm_ss.format(DateTime.parse(this));
  String get yyyy_MM_dd_n_HH_mm_ss =>
      _yyyy_MM_dd_n_HH_mm_ss.format(DateTime.parse(this));
}
