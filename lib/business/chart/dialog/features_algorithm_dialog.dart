import 'package:eeg/business/chart/mode/channel_alagorithm.dart';
import 'package:eeg/business/chart/mode/channels_meta_data.dart';
import 'package:eeg/business/chart/dialog/base_close_dialog.dart';
import 'package:eeg/business/chart/viewmodel/chart_line_view_model.dart';
import 'package:eeg/business/chart/widget/features_algorithm/algorithm_parames_select_widget.dart';
import 'package:eeg/business/chart/widget/features_algorithm/algorithm_result_widget.dart';
import 'package:eeg/business/chart/widget/features_algorithm/algorithm_select_widget.dart';
import 'package:eeg/business/chart/widget/features_algorithm/features_select_widget.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:eeg/common/widget/loading_status_page.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:eeg/core/utils/size.dart';
import 'package:eeg/core/utils/toast.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 特征算法
class FeaturesAlgorithmDialog extends BaseCloseDialog {
  final VoidCallback onClickOneKey;
  final ChartLineViewModel parentViewModel;
  final DialogActionsController actionButtonsController =
      DialogActionsController();

  FeaturesAlgorithmDialog({
    super.key,
    required this.parentViewModel,
    required this.onClickOneKey,
  });

  @override
  Widget buildContentWidget() {
    return SizedBox(
      width: SizeUtils.screenWidth * 0.8,
      height: SizeUtils.screenHeight * 0.8,
      child: LoadingPageStatusWidget<AlgorithmViewModel>(
        createOrGetViewMode: () =>
            AlgorithmViewModel(parentViewModel, actionButtonsController),
        buildPageContent: (ctx, vm) {
          return Consumer<AlgorithmViewModel>(builder: (context, vm, _) {
            return _renderBody(ctx, vm);
          });
        },
      ),
    );
  }

  Widget _renderBody(BuildContext ctx, AlgorithmViewModel vm) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 40),
          child: IndexedStack(
            index: vm.selectUiIndex,
            children: vm.uiItems.map((e) => e.value).toList(),
          ),
        ),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.centerLeft,
          child: fluent.BreadcrumbBar<ItemContainerWidget>(
            items: vm.uiItems,
            onItemPressed: vm.onUiSelectedIndex,
          ),
        )
      ],
    );
  }

  @override
  Widget? buildTitleWidget() {
    return const Text("特征处理计算");
  }

  @override
  List<Widget> actionsWidget() {
    return [StatefulActionsWidget(controller: actionButtonsController)];
  }
}

class AlgorithmViewModel extends LoadingPageStatusViewModel {
  late final uiItems = <fluent.BreadcrumbItem<ItemContainerWidget>>[];
  int selectUiIndex = 0;
  late List<AlgorithmDatum> data;
  final ChartLineViewModel parentViewModel;
  final DialogActionsController actionButtonsController;

  AlgorithmViewModel(this.parentViewModel, this.actionButtonsController);

  @override
  void init() async {
    super.init();
    await _loadData();
  }

  //拉取算法元数据
  Future<void> _loadData() async {
    data = parentViewModel.algorithmDatumData ?? [];
    if (data.isEmpty) {
      setPageStatus(PageStatus.loading);
      ResponseData response =
          await HttpService.get('/api/v1/patients/evaluate/feature_meta');
      if (response.ok) {
        setPageStatus(PageStatus.loadingSuccess);
        data = AlgorithmDatum.listFromJson(response.data);
        parentViewModel.algorithmDatumData = data;
      } else {
        setPageStatus(PageStatus.error);
      }
    }
    if (uiItems.isNotEmpty) {
      uiItems.clear();
    }
    selectUiIndex = 0;
    uiItems.add(fluent.BreadcrumbItem(
      label: _buildTitle('算法分类'),
      value: FeaturesAlgorithmSelectWidget(
          data: data, onSelect: onSelectAlgorithmClass),
    ));
    _onStartShowWidget();
  }

  Widget _buildTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, color: textColor));
  }

  @override
  void onClickRetryLoadingData() => _loadData();

  // 选择算法
  void onSelectAlgorithmClass(AlgorithmDatum data, int index) {
    uiItems.add(fluent.BreadcrumbItem(
      label: _buildTitle(data.category),
      value: AlgorithmSelectWidget(
          data: data, onSelect: (e, index) => onSelectAlgorithm(data, e)),
    ));
    selectUiIndex = uiItems.length - 1;
    _onStartShowWidget();
    notifyListeners();
  }

  // 选择算法
  void onSelectAlgorithm(AlgorithmDatum algorithmDatum, AlgorithmFeature data) {
    uiItems.add(fluent.BreadcrumbItem(
      label: _buildTitle(data.name),
      value: AlgorithmParamsSelectWidget(
          data: data,
          parentViewModel: this,
          onComputer: (e) => onClickComputer(algorithmDatum, e)),
    ));
    selectUiIndex = uiItems.length - 1;
    _onStartShowWidget();
    notifyListeners();
  }

  void onClickComputer(
      AlgorithmDatum algorithmDatum, AlgorithmFeature feature) {
    for (AlgorithmParameter item in feature.parameters) {
      if (!item.available()) {
        '[ ${item.name} ] 参数设置有问题'.toast;
        return;
      }
    }
    nextResultFeaturesWidget(algorithmDatum, feature);
  }

  void nextResultFeaturesWidget(
      AlgorithmDatum algorithmDatum, AlgorithmFeature data) {
    uiItems.add(fluent.BreadcrumbItem(
      label: _buildTitle('计算结果'),
      value: AlgorithmResultWidget(
          rootViewModel: parentViewModel,
          algorithmDatum: algorithmDatum,
          algorithmFeature: data,
          parentViewModel: this),
    ));
    selectUiIndex = uiItems.length - 1;
    _onStartShowWidget();
    notifyListeners();
  }

  void _onStartShowWidget() {
    if (selectUiIndex >= 0 && selectUiIndex < uiItems.length) {
      final widget = uiItems[selectUiIndex].value;
      widget.actionButtonsController = actionButtonsController;
      actionButtonsController.notifyActionWidgets([]);
      widget.onStartShowWidget();
    }
  }

  void onUiSelectedIndex(fluent.BreadcrumbItem<ItemContainerWidget> item) {
    if (uiItems.length > 1) {
      final index = uiItems.indexOf(item);
      if (index >= 0 && index < uiItems.length - 1) {
        uiItems.removeRange(index + 1, uiItems.length);
      }
      selectUiIndex = uiItems.length - 1;
      _onStartShowWidget();
      notifyListeners();
    }
  }
}

abstract class ItemContainerWidget extends StatelessWidget {
  DialogActionsController? actionButtonsController;

  ItemContainerWidget({super.key});

  void onStartShowWidget() {}
}
