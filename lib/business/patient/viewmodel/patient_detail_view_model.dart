import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:eeg/core/utils/router_utils.dart';

class PatientDetailViewModel extends BaseViewModel {
  Patient patient;
  bool _needPopResultData = false;

  PatientDetailViewModel(this.patient);

  onClickUpdate() async {
    // 这里可以添加更新信息的逻辑，例如导航到更新页面
    var result =
        await context.pushNamed('/patient/add_or_edit', arguments: patient);
    if (result is Patient) {
      patient = result;
      _needPopResultData = true;
      notifyListeners();
    } else if (result == PagePopType.deleteData) {
      context.maybePopPage(PagePopType.deleteData);
    }
  }

  void popPage() {
    if (_needPopResultData) {
      context.maybePopPage(patient);
    } else {
      context.maybePopPage();
    }
  }
}
