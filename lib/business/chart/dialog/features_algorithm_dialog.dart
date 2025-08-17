import 'package:eeg/business/chart/mode/channel_alagorithm.dart';
import 'package:eeg/business/chart/mode/channels_meta_data.dart';
import 'package:eeg/business/chart/dialog/base_close_dialog.dart';
import 'package:eeg/business/chart/viewmodel/chart_line_view_model.dart';
import 'package:eeg/business/chart/widget/features_algorithm/algorithm_parames_select_widget.dart';
import 'package:eeg/business/chart/widget/features_algorithm/features_algorithm_select_widget.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:eeg/common/widget/loading_status_page.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:eeg/core/utils/size.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 特征算法
class FeaturesAlgorithmDialog extends BaseCloseDialog {
  final ChannelMeta channelMeta;
  final VoidCallback onClickOneKey;
  final ChartLineViewModel parentViewModel;

  FeaturesAlgorithmDialog({
    super.key,
    required this.parentViewModel,
    required this.channelMeta,
    required this.onClickOneKey,
  });

  @override
  Widget buildContentWidget() {
    return SizedBox(
      width: SizeUtils.screenWidth * 0.8,
      height: SizeUtils.screenHeight * 0.8,
      child: LoadingPageStatusWidget<AlgorithmViewModel>(
        createOrGetViewMode: () => AlgorithmViewModel(parentViewModel),
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
          child: fluent.BreadcrumbBar<Widget>(
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
    return [
      fluent.Button(onPressed: onClickOneKey, child: const Text('一键应用默认参数'))
    ];
  }
}

class AlgorithmViewModel extends LoadingPageStatusViewModel {
  late final uiItems = <fluent.BreadcrumbItem<Widget>>[];
  int selectUiIndex = 0;
  late List<AlgorithmDatum> data;
  final ChartLineViewModel parentViewModel;

  AlgorithmViewModel(this.parentViewModel);

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
    uiItems.add(fluent.BreadcrumbItem(
      label: _buildTitle('选择算法'),
      value: FeaturesAlgorithmSelectWidget(
          data: data, onSelect: onSelectAlgorithm),
    ));
  }

  Widget _buildTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, color: textColor));
  }

  @override
  void onClickRetryLoadingData() => _loadData();

  // 选择算法
  void onSelectAlgorithm(AlgorithmDatum data, int index) {
    uiItems.add(fluent.BreadcrumbItem(
      label: _buildTitle('${data.category}'),
      value:
          AlgorithmParamsSelectWidget(data: data, onSelect: onSelectAlgorithm),
    ));
    selectUiIndex = uiItems.length - 1;
    notifyListeners();
  }

  void onUiSelectedIndex(fluent.BreadcrumbItem<Widget> item) {
    if (uiItems.length > 1) {
      final index = uiItems.indexOf(item);
      if (index >= 0 && index < uiItems.length - 1) {
        uiItems.removeRange(index + 1, uiItems.length);
      }
      selectUiIndex = uiItems.length - 1;
      notifyListeners();
    }
  }
}
//
// class AlgorithmItemWidget extends StatelessWidget {
//   final AlgorithmDatum datum;
//
//   const AlgorithmItemWidget({super.key, required this.datum});
//
//   @override
//   Widget build(BuildContext context) {
//     return Theme(
//       data: ThemeData().copyWith(
//         dividerColor: Colors.transparent, // 隐藏默认分割线
//       ),
//       child: ExpansionTile(
//         childrenPadding: EdgeInsets.only(left: 20),
//         title: Text(datum.category,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
//         iconColor: iconColor,
//         collapsedIconColor: iconColor,
//         leading: const Icon(
//           Icons.category,
//           color: iconColor,
//         ),
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               border: Border(left: BorderSide(color: subtitleColor)),
//             ),
//             child: ListView.builder(
//               shrinkWrap: true, // 关键！防止滚动冲突
//               physics: NeverScrollableScrollPhysics(), // 禁止子列表独立滚动
//               itemCount: datum.features.length,
//               itemBuilder: (context, featureIndex) {
//                 return ExpansionTile(
//                     childrenPadding: EdgeInsets.only(left: 20),
//                     title: Text(datum.features[featureIndex].name),
//                     leading: const Icon(
//                       Icons.featured_play_list,
//                       color: iconColor,
//                     ),
//                     children: datum.features[featureIndex].parameters
//                         .map((param) => _buildFeaturesParametersItem(param))
//                         .toList());
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   ListTile _buildFeaturesParametersItem(AlgorithmParameter param) {
//     return ListTile(
//       title: RichText(
//         text: TextSpan(
//           children: [
//             TextSpan(
//               text: "${param.type ?? ''}: ",
//               style: TextStyle(
//                   color: iconColor, fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             TextSpan(
//               text: param.name ?? '',
//               style: TextStyle(
//                   color: textColor, fontSize: 16, fontWeight: FontWeight.w400),
//             ),
//             TextSpan(
//               text: " (${param.description ?? ''})",
//               style: TextStyle(color: subtitleColor, fontSize: 12),
//             ),
//           ],
//         ),
//         overflow: TextOverflow.ellipsis,
//       ),
//       subtitle: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("类型: ${param.type}"),
//           Text("默认值: ${param.defaultValue}"),
//           if (param.enums) Text("枚举"),
//           if (param.required) Text("必填"),
//         ],
//       ),
//     );
//   }
// }
