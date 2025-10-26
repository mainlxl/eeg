import 'package:data_table_2/data_table_2.dart';
import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/business/patient/viewmodel/patient_detail_view_model.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:eeg/common/widget/drag_to_move_area_widget.dart';
import 'package:eeg/common/widget/expandable_text.dart';
import 'package:eeg/common/widget/loading_status_page.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:eeg/core/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 患者详情页面 home
class PatientDetailPage extends StatelessWidget {
  final Patient patient;
  final bool embed;
  final VoidCallback? onClosePage;

  const PatientDetailPage(
      {super.key, required this.patient, this.embed = false, this.onClosePage});

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
                    onExpandableChange: (e) {
                      vm.onExpandableClick();
                      return false;
                    },
                    isExpanded: false,
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
    return DragToMoveWidget(
      child: vm.isExpanded ? SingleChildScrollView(child: content) : content,
    );
  }

  Widget _buildInfoGrid() {
    return Wrap(
      children: [
        _buildInfoItem('姓名', patient.name, Icons.person),
        _buildInfoItem('年龄', '${patient.age}', Icons.cake),
        _buildInfoItem('性别', patient.genderInfo, Icons.transgender),
        _buildInfoItem('身份证', patient.identityInfo, Icons.credit_card),
        _buildInfoItem('电话', patient.phoneNumber, Icons.phone),
        _buildInfoItem('需求', patient.usageNeeds, Icons.accessibility),
      ],
    );
  }

  Size calculateTextSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
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
      buildPageContent: (ctx, vm) {
        return DataTable2(
          columns: _tableTitleRow(),
          rows: vm.evaluationtList.map((item) {
            var clickStyle = const TextStyle(color: iconColor);
            return DataRow(
              onLongPress: () {},
              cells: [
                DataCell(Text(
                  item.evaluationDate.yyyy_MM_dd_n_HH_mm_ss,
                  textAlign: TextAlign.center,
                )),
                DataCell(Text(
                  '${item.evaluateLevel} - ${item.evaluateType} - ${item.evaluateClassification}',
                  textAlign: TextAlign.center,
                )),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if ((item.data?.length ?? 0) <= 4)
                      GestureDetector(
                        onTap: () => vm.onClickItemUpload(item),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('上传',
                              style: TextStyle(color: highlightColor)),
                        ),
                      ),
                    ...(item.data?.map((dataItem) {
                          return GestureDetector(
                            onTap: () => vm.onClickItemAnalyze(item, dataItem),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('${dataItem.dataType}',
                                  style: clickStyle),
                            ),
                          );
                        }).toList() ??
                        []),
                  ],
                )),
                DataCell(item.evaluateReport.isNotEmpty
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => vm.onClickItemReportPreview(item),
                            child: Text('预览', style: clickStyle),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => vm.onClickItemReportDownload(item),
                            child: Text('下载', style: clickStyle),
                          ),
                        ],
                      )
                    : GestureDetector(
                        onTap: () => vm.onClickItemReportGenerate(item),
                        child: Text('生成报告', style: clickStyle))),
              ],
            );
          }).toList(),
        );
      },
    );
    return [
      Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Text('数据列表',
            style: TextStyle(
                fontSize: 20, color: textColor, fontWeight: FontWeight.w500)),
      ),
      const SizedBox(height: 4),
      Expanded(child: loadingPageStatusWidget)
    ];
  }

  List<DataColumn> _tableTitleRow() {
    final titleStyle = const TextStyle(fontWeight: FontWeight.bold);
    return [
      DataColumn(
          columnWidth: FixedColumnWidth(140),
          label: Text('   评估时间   ',
              style: titleStyle, textAlign: TextAlign.center)),
      DataColumn(
        columnWidth: FixedColumnWidth(160),
        label: Text('评估 - 部位', style: titleStyle, textAlign: TextAlign.center),
      ),
      DataColumn(
        columnWidth: FixedColumnWidth(140),
        label: Text('评估数据', style: titleStyle, textAlign: TextAlign.center),
      ),
      DataColumn(
        label: Text('评估报告', style: titleStyle, textAlign: TextAlign.center),
      ),
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
          TextButton(
            onPressed: vm.onClickShowAssessDialog,
            child: const Text('开始评估'),
          ),
        ],
      )
    ];
  }
}
