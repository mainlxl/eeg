import 'package:eeg/business/chart/dialog/base_close_dialog.dart';
import 'package:eeg/business/chart/mode/preporcessing.dart';
import 'package:eeg/business/chart/viewmodel/chart_line_view_model.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:eeg/common/widget/loading_status_page.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:eeg/core/utils/size.dart';
import 'package:eeg/core/utils/toast.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// 预处理算法
class PreprocessingAlgorithmDialog extends BaseCloseDialog {
  final ChartLineViewModel parentViewModel;
  final ScrollController _scrollController = ScrollController();

  PreprocessingAlgorithmDialog({
    super.key,
    required this.parentViewModel,
  });

  Widget _renderList(PreprocessingAlgorithmViewModel vm) {
    return Scrollbar(
      controller: _scrollController,
      thickness: 8.0,
      radius: Radius.circular(8),
      thumbVisibility: true,
      child: ReorderableListView.builder(
        scrollController: _scrollController,
        padding: EdgeInsets.zero,
        buildDefaultDragHandles: false,
        itemCount: vm.data.length,
        onReorder: vm.onDargReorder,
        itemBuilder: (_, index) =>
            _ItemWidget(index: index, data: vm.data[index], vm: vm),
      ),
    );
  }

  @override
  Widget? buildTitleWidget() {
    const smallText = TextStyle(fontSize: 12);
    return Row(
      children: [
        const Text("预处理"),
        const Spacer(),
        const Text("点击可切换 ， 生效算法: ", style: smallText),
        const Icon(Icons.featured_play_list, color: iconColor),
        const Text("  忽略算法: ", style: smallText),
        const Icon(Icons.featured_play_list, color: subtitleColor),
        const Text("    |    拖动对应条目的 ", style: smallText),
        const Icon(Icons.featured_play_list, color: iconColor),
        const Text(" 可调整算法顺序 ", style: smallText),
      ],
    );
  }

  @override
  Widget buildContentWidget() {
    return SizedBox(
      width: SizeUtils.screenWidth * 0.8,
      height: SizeUtils.screenHeight * 0.8,
      child: LoadingPageStatusWidget<PreprocessingAlgorithmViewModel>(
        createOrGetViewMode: () =>
            PreprocessingAlgorithmViewModel(parentViewModel),
        buildPageContent: (ctx, vm) => _renderList(vm),
      ),
    );
  }

  @override
  List<Widget> actionsWidget() {
    return [
      fluent.Button(
        onPressed: () {
          var list = parentViewModel.preporcessingAlgorithmList;
          if (list == null || list.isEmpty) {
            '没有可用的预处理算法，请点击重试获取参数后再试！'.toast;
            return;
          }
          list = list.where((e) => e.checked).toList();
          if (list.isEmpty) {
            '请先点击选中一种预处理算法！'.toast;
            return;
          }
          if (list.any((e) => !e.available())) {
            '有参数错误,请检查输入参数'.toast;
            return;
          }
          parentViewModel.preporcessingAlgorithmList
              ?.forEach((e) => e.synchronizeData(isInput: true));
          closeDialog(parentViewModel.context);
          parentViewModel.applicationPreprocessingAlgorithm(enable: true);
        },
        child: Text('应用预处理参数'),
      ),
      if (parentViewModel.usePreporcessingAlgorithm)
        fluent.Button(
          onPressed: () {
            closeDialog(parentViewModel.context);
            parentViewModel.applicationPreprocessingAlgorithm(enable: false);
          },
          child: Text('显示原始数据'),
        ),
      fluent.Button(
        onPressed: () {
          var list = parentViewModel.preporcessingAlgorithmList;
          if (list != null) {
            for (var e in list) {
              e.resetDefault();
            }
          }
        },
        child: Text('恢复参数默认值'),
      )
    ];
  }

  @override
  void onCloseDialog() {
    // 如果未点击应用预处理参数，则重置所有参数 如果点击了应用预处理参数
    parentViewModel.preporcessingAlgorithmList
        ?.forEach((e) => e.synchronizeData(isInput: false));
  }
}

class PreprocessingAlgorithmViewModel extends LoadingPageStatusViewModel {
  final ChartLineViewModel parentViewModel;
  List<PreporcessingAlgorithm>? _data;

  List<PreporcessingAlgorithm> get data => _data ?? [];

  PreprocessingAlgorithmViewModel(this.parentViewModel);

  @override
  void init() async {
    super.init();
    await _loadData();
  }

  Future<void> _loadData() async {
    if (parentViewModel.preporcessingAlgorithmList != null) {
      _data = parentViewModel.preporcessingAlgorithmList;
      setPageStatus(PageStatus.loadingSuccess);
      return;
    }
    setPageStatus(PageStatus.loading);
    ResponseData response =
        await HttpService.post('/api/v2/feature/list', data: {
      'patient_evalution_data': {
        "data_type": parentViewModel.channelMeta.dataType,
        "data_id": parentViewModel.channelMeta.dataId,
        "patient_evaluation_id":
            parentViewModel.channelMeta.patientEvaluationId,
      }
    });
    if (response.ok) {
      setPageStatus(PageStatus.loadingSuccess);
      List<PreporcessingAlgorithm> preporcessingAlgorithmList =
          response.data == null
              ? []
              : PreporcessingAlgorithm.listFromJson(
                  response.data?['patient_evaluate_algorithm_list'] ?? []);
      this._data = preporcessingAlgorithmList;
      parentViewModel.preporcessingAlgorithmList = preporcessingAlgorithmList;
    } else {
      setPageStatus(PageStatus.error);
    }
  }

  @override
  void onClickRetryLoadingData() {
    _loadData();
  }

  void onDargReorder(int oldIndex, int newIndex) {
    final data = this.data;
    if (oldIndex < newIndex) newIndex--;
    final item = data.removeAt(oldIndex);
    data.insert(newIndex, item);
  }

  // 点击预处理算法条目
  void onClickItemPreporcessingAlgorithm(
      int index, PreporcessingAlgorithm data) {
    data.checked = !data.checked;
    notifyListeners();
  }
}

class _ItemWidget extends StatelessWidget {
  final PreporcessingAlgorithm data;
  final int index;
  final PreprocessingAlgorithmViewModel vm;

  // key 必须唯一用于拖动
  _ItemWidget({required this.index, required this.data, required this.vm})
      : super(key: Key('$index'));

  @override
  Widget build(BuildContext context) {
    return fluent.Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            onPressed: () => vm.onClickItemPreporcessingAlgorithm(index, data),
            child: Row(
              children: [
                ReorderableDragStartListener(
                    index: index,
                    child: Icon(Icons.featured_play_list,
                        color: data.checked ? iconColor : subtitleColor)),
                SizedBox(width: 10),
                Text.rich(
                  TextSpan(
                    text: data.des,
                    style: TextStyle(
                      color: data.checked ? textColor : subtitleColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: '\t分类:${data.category}',
                        style: TextStyle(
                          color: data.checked
                              ? subtitleColor
                              : textColor.withAlpha(60),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (data.checked) SizedBox(height: 10),
          if (data.checked)
            ...List.generate(data.features.length,
                (index) => _buildFeaturesParametersItem(data.features[index])),
        ],
      ),
    );
  }

  Widget _buildFeaturesParametersItem(FeaturesParam param) {
    final theme = ShadTheme.of(vm.context);
    if (param.enumList.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _renderPrefix(param),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 20),
              child: ShadSelect<String>(
                  placeholder: Text(param.value),
                  options: param.enumList.map((e) => ShadOption(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      value: e,
                      child: Text(e))),
                  selectedOptionBuilder: (context, value) => Text(value),
                  onChanged: (value) => param.value = value ?? ''),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: TextField(
        style: TextStyle(fontSize: 16, height: 1.0),
        inputFormatters: param.getInputFormatters(),
        controller: param.controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: _renderPrefix(param),
        ),
      ),
    );
  }

  Widget _renderPrefix(FeaturesParam param) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
            color: iconColor, fontSize: 18, fontWeight: FontWeight.bold),
        children: [
          TextSpan(text: param.name),
          TextSpan(
            text: " (${param.des},${param.type}默认值: ${param.defaultValue})",
            style: TextStyle(color: subtitleColor, fontSize: 12),
          ),
          TextSpan(
            text: ' : ',
          ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
