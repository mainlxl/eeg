import 'package:eeg/app.dart';
import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/business/patient/page/patient_detail_page.dart';
import 'package:eeg/business/patient/page/patient_list_select_page.dart';
import 'package:eeg/business/patient/viewmodel/patient_list_view_model.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

class AssessHomeViewModel extends BaseViewModel {
  late final items = <fluent.BreadcrumbItem<Widget>>[
    fluent.BreadcrumbItem(
      label: _buildTitle('选择用户'),
      value: PatientListSelectPage(onSelect: onSelectPatient),
    ),
  ];
  Patient? patient;

  AssessHomeViewModel(this.patient);

  int get selectIndex => items.length - 1;
  PaneDisplayMode displayMode = PaneDisplayMode.top;

  @override
  void init() async {
    super.init();
    addSubscription(eventBus
        .on<PatientListRefreshEvent>()
        .listen((event) => _updatePatientName(event.name)));
    //设置移动端强制横屏
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void onSelectPatient(Patient patient) {
    this.patient = patient;
    items.add(
      fluent.BreadcrumbItem(
        label: _buildTitle('用户:${patient.name}'),
        value: PatientDetailPage(
            patient: patient,
            embed: true,
            onClosePage: () {
              onSelectedIndex(items[0]);
            }),
      ),
    );
    notifyListeners();
  }

  void onSelectedIndex(BreadcrumbItem<Widget> item) {
    if (items.length > 1) {
      final index = items.indexOf(item);
      if (index >= 0 && index < items.length - 1) {
        items.removeRange(index + 1, items.length);
      }
      notifyListeners();
    }
  }

  Widget _buildTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, color: textColor));
  }

  void _updatePatientName(String name) {
    if (items.length > 1) {
      var old = items[1];
      items[1] = fluent.BreadcrumbItem(
        label: _buildTitle('用户:${name}'),
        value: old.value,
      );
      notifyListeners();
    }
  }
}
