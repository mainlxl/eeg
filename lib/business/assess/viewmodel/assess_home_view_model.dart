import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/business/patient/page/patient_detail_page.dart';
import 'package:eeg/business/patient/page/patient_user_list_select_page.dart';
import 'package:eeg/business/patient/viewmodel/patient_list_view_model.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:eeg/core/utils/app_logger.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

// 选择用户-评估首页view model
class AssessHomeViewModel extends EventViewModel {
  late final items = <fluent.BreadcrumbItem<Widget>>[
    fluent.BreadcrumbItem(
      label: _buildTitle('选择用户'),
      value: PatientListSelectPage(onSelect: onSelectPatient), // 选择患者
    ),
  ];
  Patient? patient;

  AssessHomeViewModel(this.patient);

  int get selectIndex => items.length - 1;
  PaneDisplayMode displayMode = PaneDisplayMode.top;

  @override
  void init() async {
    super.init();
    onEvent<PatientListRefreshEvent>((event) => _updatePatientName(event.name));
    //设置移动端强制横屏
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  // 选择患者
  void onSelectPatient(Patient patient) {
    this.patient = patient;
    assessHomePageManager.addNextPage(
        title: '用户:${patient.name}',
        builder: (_) => PatientDetailPage(
            patient: patient,
            embed: true,
            onClosePage: () {
              onSelectedIndex(items[0]);
            }));
    notifyListeners();
  }

  void onSelectedIndex(BreadcrumbItem<Widget> item) {
    if (items.length > 1) {
      final index = items.indexOf(item);
      if (index >= 0 && index < items.length - 1) {
        items.removeRange(index + 1, items.length);
      }
      logi(
          'AssessHomePageManager路由: ${items.map((e) => (e.label as Text).data)}');
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
        label: _buildTitle('用户:$name'),
        value: old.value,
      );
      logi(
          'AssessHomePageManager路由: ${items.map((e) => (e.label as Text).data)}');
      notifyListeners();
    }
  }

  void _updateAssessHomeManager() {
    assessHomePageManager.viewModel = this;
    assessHomePageManager._notifyListeners = notifyListeners;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAssessHomeManager();
  }

  @override
  void dispose() {
    super.dispose();
    assessHomePageManager.dispose();
  }

  @override
  bool onClickClose() {
    return false;
  }
}

typedef AssessHomePageBuilder = Widget Function(Patient? patient);

final AssessHomePageManager assessHomePageManager = AssessHomePageManager();

class AssessHomePageManager {
  late AssessHomeViewModel viewModel;
  late Function _notifyListeners;

  AssessHomePageManager();

  void addNextPage(
      {required String title, required AssessHomePageBuilder builder}) {
    viewModel.items.add(
      fluent.BreadcrumbItem(
        label: viewModel._buildTitle(title),
        value: builder.call(viewModel.patient),
      ),
    );
    logi(
        'AssessHomePageManager路由: ${viewModel.items.map((e) => (e.label as Text).data)}');
    _notifyListeners.call();
  }

  void notifyListeners() {
    _notifyListeners.call();
  }

  void removeLastPage() {
    if (viewModel.items.length > 1) {
      //保护确保至少有一个页面
      viewModel.items.removeLast();
      _notifyListeners.call();
    }
    logi(
        'AssessHomePageManager路由: ${viewModel.items.map((e) => (e.label as Text).data)}');
  }

  void dispose() {}
}
