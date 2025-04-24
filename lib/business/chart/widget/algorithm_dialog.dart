import 'package:eeg/business/chart/mode/channel_alagorithm.dart';
import 'package:eeg/business/chart/mode/channels_meta_data.dart';
import 'package:eeg/business/chart/widget/base_close_dialog.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:eeg/common/widget/loading_status_page.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:eeg/core/utils/size.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlgorithmDialog extends BaseCloseDialog {
  final ChannelMeta channelMeta;
  final VoidCallback onClickOneKey;

  AlgorithmDialog({
    super.key,
    required this.channelMeta,
    required this.onClickOneKey,
  });

  @override
  Widget buildContentWidget() {
    return SizedBox(
      width: SizeUtils.screenWidth * 0.8,
      height: SizeUtils.screenHeight * 0.8,
      child: LoadingPageStatusWidget<AlgorithmViewModel>(
        createOrGetViewMode: () => AlgorithmViewModel(),
        buildPageContent: (ctx, vm) {
          return Consumer<AlgorithmViewModel>(builder: (context, vm, _) {
            return ListView.builder(
                itemCount: vm.data.length,
                itemBuilder: (_, index) =>
                    AlgorithmItemWidget(datum: vm.data[index]));
          });
        },
      ),
    );
  }

  @override
  Widget? buildTitleWidget() {
    return const Text("特征处理计算");
  }

  @override
  List<Widget> actionsWidget() {
    return [
      fluent.Button(child: const Text('一键应用默认参数'), onPressed: onClickOneKey)
    ];
  }
}

class AlgorithmViewModel extends LoadingPageStatusViewModel {
  late List<AlgorithmDatum> data;

  @override
  void init() async {
    super.init();
    await _loadData();
  }

  Future<void> _loadData() async {
    setPageStatus(PageStatus.loading);
    ResponseData response =
        await HttpService.get('/api/v1/patients/evaluate/feature_meta');
    if (response.ok) {
      setPageStatus(PageStatus.loadingSuccess);
      data = AlgorithmDatum.listFromJson(response.data);
    } else {
      setPageStatus(PageStatus.error);
    }
  }

  @override
  void onClickRetryeLoadingData() {
    _loadData();
  }
}

class AlgorithmItemWidget extends StatelessWidget {
  final AlgorithmDatum datum;

  const AlgorithmItemWidget({super.key, required this.datum});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData().copyWith(
        dividerColor: Colors.transparent, // 隐藏默认分割线
      ),
      child: ExpansionTile(
        childrenPadding: EdgeInsets.only(left: 20),
        title: Text('${datum.category}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
        iconColor: iconColor,
        collapsedIconColor: iconColor,
        leading: const Icon(
          Icons.category,
          color: iconColor,
        ),
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: subtitleColor)),
            ),
            child: ListView.builder(
              shrinkWrap: true, // 关键！防止滚动冲突
              physics: NeverScrollableScrollPhysics(), // 禁止子列表独立滚动
              itemCount: datum.features.length,
              itemBuilder: (context, featureIndex) {
                return ExpansionTile(
                    childrenPadding: EdgeInsets.only(left: 20),
                    title: Text(datum.features[featureIndex].name),
                    leading: const Icon(
                      Icons.featured_play_list,
                      color: iconColor,
                    ),
                    children: datum.features[featureIndex].parameters
                        .map((param) => _buildFeaturesParametersItem(param))
                        .toList());
              },
            ),
          ),
        ],
      ),
    );
  }

  ListTile _buildFeaturesParametersItem(AlgorithmParameter param) {
    return ListTile(
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "${param.type ?? ''}: ",
              style: TextStyle(
                  color: iconColor, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: param.name ?? '',
              style: TextStyle(
                  color: textColor, fontSize: 16, fontWeight: FontWeight.w400),
            ),
            TextSpan(
              text: " (${param.description ?? ''})",
              style: TextStyle(color: subtitleColor, fontSize: 12),
            ),
          ],
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("类型: ${param.type}"),
          Text("默认值: ${param.defaultValue}"),
          if (param.enums) Text("枚举"),
          if (param.required) Text("必填"),
        ],
      ),
    );
  }
}
