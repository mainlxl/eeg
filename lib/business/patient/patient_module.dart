import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/business/patient/page/add_or_patient_page.dart';
import 'package:eeg/business/patient/page/patient_detail_page.dart';
import 'package:eeg/business/patient/page/patient_list_page.dart';
import 'package:eeg/core/base/module.dart';

class PatientModule extends BaseModule {
  @override
  Map<String, RouteBuilder>? routeBuilders() {
    return {
      'patient/add_or_edit': (ctx, settings) {
        return AddPatientPage(
          patient: settings.arguments as Patient?,
        );
      },
      'patient/list': (ctx, settings) => const PatientListPage(),
      'patient/detail': (ctx, settings) =>
          PatientDetailPage(patient: settings.arguments as Patient),
    };
  }
}
