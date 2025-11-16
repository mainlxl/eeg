import 'package:eeg/business/assess/mode/assess_data.dart';
import 'package:eeg/business/assess/page/assess_page.dart';
import 'package:eeg/business/assess/viewmodel/assess_home_view_model.dart';
import 'package:eeg/business/assess/widgets/game_cognition_color_widget.dart';
import 'package:eeg/business/assess/widgets/game_cognition_image_widget.dart';
import 'package:eeg/business/assess/widgets/game_cognition_number_widget.dart';
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

  bool get isMovementCategory => selectedCategory?.name == '运动';

  bool get isEnableNext =>
      selectedCategory != null &&
      selectedSubCategory != null &&
      (selectedInspectionPoint != null || !isMovementCategory);

  AssessSelectViewModel(this.patient);

  @override
  void init() async {
    super.init();
    await _loadData();
  }

  Future<void> _loadData() async {
    ResponseData response = await HttpService.post('/api/v2/train/list');
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
    if (isMovementCategory) {
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
    } else {
      if (selectedCategory != null && selectedSubCategory != null) {
        assessHomePageManager.removeLastPage();
        // GameCognitionImageWidget.createAssessData(),
        // GameCognitionNumberWidget.createAssessData(),
        final subCategory = selectedSubCategory!;
        var game = [GameCognitionColorWidget.createAssessData()];
        if (subCategory.name == '想象') {
          game = [GameCognitionNumberWidget.createAssessData()];
        } else if (subCategory.name == '记忆') {
          game = [GameCognitionImageWidget.createAssessData()];
        }
        context.push(
          (ctx) {
            return AssessPage(
              patient: patient,
              selectedCategory: selectedCategory!,
              selectedSubCategory: subCategory,
              assessInspectionPoint:
                  AssessInspectionPoint(name: '-', data: game),
            );
          },
        );
      } else {
        showToast('请先选择评测方向');
      }
    }
  }
}
