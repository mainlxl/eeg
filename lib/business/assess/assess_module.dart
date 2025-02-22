import 'package:eeg/business/assess/page/assess_home.dart';
import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/core/base/module.dart';

class AssessModule extends BaseModule {
  @override
  Map<String, RouteBuilder>? routeBuilders() {
    return {
      'assess/home': (ctx, settings) =>
          AssessHomePage(patient: (settings.arguments as Patient?)),
    };
  }
}
