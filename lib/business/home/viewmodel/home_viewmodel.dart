import 'package:eeg/business/patient/page/add_or_patient_page.dart';
import 'package:eeg/business/user/user_info.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

class HomeViewModel extends BaseViewModel {
  int _selectIndex = 0;

  int get selectIndex => _selectIndex;
  PaneDisplayMode displayMode = PaneDisplayMode.open;
  final assessPageKey = GlobalKey();
  final patientListKey = GlobalKey();

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

  @override
  bool onClickClose() {
    return false; //不处理直接退出
  }

  void onHomeTabChange(int selectIndex) {
    _selectIndex = selectIndex;
    notifyListeners();
  }

  void onClickSignOut() async {
    UserInfo.cleanTaskAndPushLoginPage();
  }

  /// 添加用户
  void onClickAddPatient() async {
    showDialog(context: context, builder: (context) => const AddPatientPage());
  }
}
