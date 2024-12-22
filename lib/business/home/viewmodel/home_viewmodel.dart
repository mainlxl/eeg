import 'package:eeg/core/utils/router_utils.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:fluent_ui/fluent_ui.dart';

class HomeViewModel extends BaseViewModel {
  int _selectIndex = 0;

  int get selectIndex => _selectIndex;
  PaneDisplayMode displayMode = PaneDisplayMode.top;

  void onItemPressed(int index) {}

  void onHomeTabChange(int selectIndex) {
    _selectIndex = selectIndex;
    notifyListeners();
  }

  void onClickSetting() {}

  void onClickSignOut() {
    context.pushReplacementNamed("/");
  }
}
