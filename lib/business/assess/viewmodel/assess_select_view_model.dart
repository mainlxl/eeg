import 'package:eeg/business/assess/mode/assess_data.dart';
import 'package:eeg/business/assess/page/assess_page.dart';
import 'package:eeg/business/assess/viewmodel/assess_home_view_model.dart';
import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/common/widget/loading_status_page.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:eeg/core/utils/router_utils.dart';
import 'package:eeg/core/utils/toast.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// 评测模式选择页
class AssessSelectViewModel extends LoadingPageStatusViewModel {
  Patient patient;

  List<AssessCategory> data = [];
  AssessCategory? selectedCategory;
  AssessSubCategory? selectedSubCategory;
  ShadSelectController<AssessSubCategory> controllerSubCategory =
      ShadSelectController();
  AssessInspectionPoint? selectedInspectionPoint;
  ShadSelectController<AssessInspectionPoint> controllerInspectionPoint =
      ShadSelectController();

  AssessSelectViewModel(this.patient);

  @override
  void init() async {
    super.init();
    await _loadData();
  }

  Future<void> _loadData() async {
    ResponseData response =
        await HttpService.post('/api/v2/train/list');
    if (response.status == 0) {
      data = AssessCategoryJson.fromJson(response.data['classfy_list']).config;
      setPageStatus(PageStatus.loadingSuccess);
    } else {
      setPageStatus(PageStatus.error);
    }
  }

  @override
  void onClickRetryLoadingData() {
    _loadData();
  }

  void onCategoryChanged(AssessCategory? value) {
    selectedCategory = value;
    selectedSubCategory = null;
    selectedInspectionPoint = null;
    controllerSubCategory.value.clear();
    controllerInspectionPoint.value.clear();
    notifyListeners();
  }

  void onSubCategoryChanged(AssessSubCategory? value) {
    selectedSubCategory = value;
    selectedInspectionPoint = null;
    controllerInspectionPoint.value.clear();
    notifyListeners();
  }

  void onAssessInspectionPointChanged(AssessInspectionPoint? value) {
    selectedInspectionPoint = value;
    notifyListeners();
  }

  void onClickStartAssess() {
    if (selectedCategory != null &&
        selectedSubCategory != null &&
        selectedInspectionPoint != null) {
      if (selectedInspectionPoint?.data.isEmpty == true) {
        showToast('评测数据异常');
        return;
      }
      assessHomePageManager.removeLastPage();
      context.push(
        (ctx) => AssessPage(
          patient: patient,
          selectedCategory: selectedCategory!,
          selectedSubCategory: selectedSubCategory!,
          assessInspectionPoint: selectedInspectionPoint!,
        ),
      );
    } else {
      showToast('请先选择评测部位');
    }
  }
}
