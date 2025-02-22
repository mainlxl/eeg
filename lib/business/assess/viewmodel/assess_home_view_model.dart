import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

class AssessHomeViewModel extends BaseViewModel {
  int _selectIndex = 0;
  Patient? patient;

  AssessHomeViewModel(this.patient);

  int get selectIndex => _selectIndex;
  PaneDisplayMode displayMode = PaneDisplayMode.top;

  @override
  void init() async {
    super.init();
    //设置移动端强制横屏
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void onItemPressed(int index) {}

  void onHomeTabChange(int selectIndex) {
    _selectIndex = selectIndex;
    notifyListeners();
  }

  void onClickSetting() {}

  void onSelectPatient(Patient patient) {
    this.patient = patient;
    notifyListeners();
  }
}
