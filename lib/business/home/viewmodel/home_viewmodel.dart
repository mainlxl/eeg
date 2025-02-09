import 'package:eeg/app.dart';
import 'package:eeg/business/patient/page/add_or_patient_page.dart';
import 'package:eeg/business/patient/viewmodel/patient_list_view_model.dart';
import 'package:eeg/business/user/user_info.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

class HomeViewModel extends BaseViewModel {
  int _selectIndex = 0;

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

  /// 添加病人
  void onClickAddPatient() async {
    showDialog(context: context, builder: (context) => const AddPatientPage());
  }

  void onClickSetting() async {
    // context.pushNamed('/patient/list');

    var post = await HttpService.get('/api/patients');
    var response = await HttpService.get(
      '/api/eeg-data',
      queryParameters: {
        'upload_id': 8,
        'start_second': 0,
        'end_second': 10,
        'channels': '1,2,3', // 如果需要传递多个值，用字符串或列表
        'page': 1,
        'page_size': 10,
      },
    );
    var resData = response?.data as Map<String, Object?>?;
  }
}
