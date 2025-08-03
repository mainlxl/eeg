import 'package:eeg/business/chart/mode/channel_alagorithm.dart';
import 'package:eeg/business/chart/dialog/base_close_dialog.dart';
import 'package:eeg/business/chart/viewmodel/chart_line_view_model.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:eeg/common/widget/loading_status_page.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:eeg/core/utils/size.dart';
import 'package:eeg/core/utils/toast.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';

// 预处理算法
class PreprocessingAlgorithmDialog extends BaseCloseDialog {
  final ChartLineViewModel parentViewModel;
  bool isUseInputSynchronizeData = false;

  PreprocessingAlgorithmDialog({
    super.key,
    required this.parentViewModel,
  });

  Widget _renderList(PreprocessingAlgorithmViewModel vm) {
    return ReorderableListView.builder(
        padding: EdgeInsets.zero,
        buildDefaultDragHandles: false,
        itemCount: vm.data.length,
        onReorder: vm.onDargReorder,
        itemBuilder: (_, index) =>
            _ItemWidget(index: index, data: vm.data[index]));
  }

  @override
  Widget? buildTitleWidget() {
    return Row(
      children: [
        const Text("预处理(拖动对应条目的"),
        const Icon(Icons.featured_play_list, color: iconColor),
        const Text("可调整顺序)"),
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
          final list = parentViewModel.preporcessingAlgorithmList;
          if (list == null || list.isEmpty) {
            '没有可用的预处理算法，请点击重试获取参数后再试！'.toast;
            return;
          }
          if (list.any((e) => !e.available())) {
            '有参数错误,请检查输入参数'.toast;
            return;
          }
          isUseInputSynchronizeData = true;
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
    final list = parentViewModel.preporcessingAlgorithmList;
    if (list != null) {
      for (var e in list) {
        e.synchronizeData(isInput: isUseInputSynchronizeData);
      }
    }
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
    ResponseData response = await HttpService.get(
        '/api/v1/eeg-data/algorithm/${parentViewModel.channelMeta.dataType}');
    if (response.ok) {
      setPageStatus(PageStatus.loadingSuccess);
      List<PreporcessingAlgorithm> preporcessingAlgorithmList =
          response.data == null
              ? []
              : PreporcessingAlgorithm.listFromJson(response.data);
      this._data = preporcessingAlgorithmList;
      parentViewModel.preporcessingAlgorithmList = preporcessingAlgorithmList;
    } else {
      setPageStatus(PageStatus.error);
    }
  }

  @override
  void onClickRetryeLoadingData() {
    _loadData();
  }

  void onDargReorder(int oldIndex, int newIndex) {
    final data = this.data;
    if (oldIndex < newIndex) newIndex--;
    final item = data.removeAt(oldIndex);
    data.insert(newIndex, item);
  }
}

class _ItemWidget extends StatelessWidget {
  final PreporcessingAlgorithm data;
  final int index;

  // key 必须唯一用于拖动
  _ItemWidget({required this.index, required this.data})
      : super(key: Key('$index'));

  @override
  Widget build(BuildContext context) {
    return fluent.Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          fluent.Row(
            children: [
              ReorderableDragStartListener(
                  index: index,
                  child:
                      const Icon(Icons.featured_play_list, color: iconColor)),
              SizedBox(width: 10),
              Text(data.des,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 10),
          ...List.generate(data.params.length,
              (index) => _buildFeaturesParametersItem(data.params[index])),
        ],
      ),
    );
  }

  Widget _buildFeaturesParametersItem(PreporcessingParam param) {
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

  Widget _renderPrefix(PreporcessingParam param) {
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
