import 'package:eeg/business/chart/page/chart_page.dart';
import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/business/patient/viewmodel/patient_detail_view_model.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:eeg/common/widget/expandable_text.dart';
import 'package:eeg/common/widget/loading_status_page.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:eeg/core/utils/date_format.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PatientDetailPage extends StatelessWidget {
  final Patient patient;
  final bool embed;
  final VoidCallback? onClosePage;

  const PatientDetailPage(
      {required this.patient, this.embed = false, this.onClosePage});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PatientDetailViewModel>(
      create: () =>
          PatientDetailViewModel(this.patient, onClosePage: onClosePage),
      child: Consumer<PatientDetailViewModel>(
        builder: (context, vm, _) => embed
            ? _buildContent(vm)
            : Scaffold(
                backgroundColor: bgColor,
                appBar: AppBar(
                  leading: BackButton(onPressed: vm.popPage),
                  title: Text('${patient.name} 的详情'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: vm.onClickUpdate,
                    )
                  ],
                ),
                body: _buildContent(vm),
              ),
      ),
    );
  }

  Widget _buildContent(PatientDetailViewModel vm) {
    final content = Container(
      color: bgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoGrid(), // 网格布局替换原始列布局
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 8),
              Icon(Icons.medical_services, size: 20),
              const SizedBox(width: 4),
              Expanded(
                child: SelectableExpandableText(
                    onExpandableChange: vm.onExpandableChange,
                    isExpanded: vm.isExpanded,
                    textStyle: const TextStyle(fontSize: 14, color: textColor),
                    linkTextColor: iconColor,
                    text:
                        '病史: ${patient.medicalHistory.isNotEmpty ? patient.medicalHistory : '暂未填写'}'),
              ),
            ],
          ),
          ...renderActionButtons(vm),
          ..._renderChartList(vm),
        ],
      ),
    );
    return DragToMoveArea(
      child: vm.isExpanded ? SingleChildScrollView(child: content) : content,
    );
  }

  Widget _buildInfoGrid() {
    return Wrap(
      children: [
        _buildInfoItem('姓名', patient.name, Icons.person),
        _buildInfoItem('年龄', '${patient.age}', Icons.cake),
        _buildInfoItem('性别', patient.gender, Icons.transgender),
        _buildInfoItem('身份证', patient.identityInfo, Icons.credit_card),
        _buildInfoItem('电话', patient.phoneNumber, Icons.phone),
        _buildInfoItem('需求', patient.usageNeeds, Icons.accessibility),
        _buildDateItem('创建', patient.createdAt),
        _buildDateItem('更新', patient.updatedAt),
      ],
    );
  }

  Size calculateTextSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: material.TextDirection.ltr,
    );

    textPainter.layout();
    return textPainter.size; // 返回文本的宽度和高度
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    final text = '$label: ${value.isEmpty ? "未填写" : value}';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 8),
        Icon(icon, size: 20),
        const SizedBox(width: 4),
        SelectableText(text, style: TextStyle(fontSize: 14, color: textColor)),
      ],
    );
  }

  Widget _buildDateItem(String label, DateTime date) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 8),
        Icon(Icons.calendar_today, size: 20),
        const SizedBox(width: 4),
        SelectableText(
          '$label: ${date.yyyy_MM_dd}',
          style: const TextStyle(fontSize: 14),
        )
      ],
    );
  }

  List<Widget> _renderChartList(PatientDetailViewModel vm) {
    var loadingPageStatusWidget = LoadingPageStatusWidget(
      createOrGetViewMode: () => vm,
      needViewModelBuild: false,
      buildPageContent: (ctx, vm) => ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: vm.chartList.length,
        shrinkWrap: true,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final channelMeta = vm.chartList[index];
          return ListTile(
            dense: true,
            leading: const Icon(Icons.insert_chart, size: 24),
            title: Text(
              'ID: ${channelMeta.data_id}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('类型: ${channelMeta.data_type}'),
                Text(channelMeta.description ?? '暂无描述'),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => vm.onClickDataItem(channelMeta),
          );
        },
      ),
    );
    return [
      Text('数据列表',
          style: TextStyle(
              fontSize: 20, color: textColor, fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      vm.isExpanded
          ? loadingPageStatusWidget
          : Expanded(child: loadingPageStatusWidget)
    ];
  }

  List<Widget> renderActionButtons(PatientDetailViewModel vm) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: vm.onClickUpdate,
            child: const Text('编辑用户信息'),
          ),
        ],
      )
    ];
  }

// PopupMenuButton<String>(
// initialValue: '语文',
// child: Text('学科'),
// itemBuilder: (context) {
// return <PopupMenuEntry<String>>[
// CheckedPopupMenuItem<String>(
// value: '语文',
// child: Text('语文'),
// ),
// PopupMenuItem<String>(
// value: '数学',
// child: Text('数学'),
// ),
// PopupMenuItem<String>(
// value: '英语',
// child: Text('英语'),
// ),
// PopupMenuItem<String>(
// value: '生物',
// child: Text('生物'),
// ),
// PopupMenuItem<String>(
// value: '化学',
// child: Text('化学'),
// ),
// ];
// },
// ),
}
