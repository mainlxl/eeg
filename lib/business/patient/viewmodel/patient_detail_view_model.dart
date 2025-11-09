import 'dart:convert';

import 'package:eeg/business/assess/mode/assess_evaluation.dart';
import 'package:eeg/business/assess/page/assess_select_page.dart';
import 'package:eeg/business/assess/page/assess_upload_page.dart';
import 'package:eeg/business/assess/viewmodel/assess_home_view_model.dart';
import 'package:eeg/business/chart/mode/channels_meta_data.dart';
import 'package:eeg/business/chart/page/chart_page.dart';
import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/business/patient/page/add_or_patient_page.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:eeg/common/widget/loading_status_page.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:eeg/core/utils/date_format.dart';
import 'package:eeg/core/utils/router_utils.dart';
import 'package:eeg/core/utils/toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PatientDetailViewModel extends LoadingPageStatusViewModel {
  Patient patient;
  bool _needPopResultData = false;
  List<Evaluation> evaluationtList = [];
  bool isExpanded = false;
  final VoidCallback? onClosePage;

  PatientDetailViewModel(this.patient, {this.onClosePage});

  @override
  void init() {
    super.init();
    loadPatientEvaluateList();
    onEvent<UpdateOrInsertPatientEvaluateEvent>(_onCreatePatientEvaluateEvent);
  }

  void onClickPatientUpdate() async {
    var result = await showDialog(
      context: context,
      builder: (context) => Container(
        margin: const EdgeInsets.all(15),
        child: AddPatientPage(patient: patient),
      ),
    );
    if (result is Patient) {
      patient = result;
      _needPopResultData = true;
      notifyListeners();
    } else if (result == PagePopType.deleteData) {
      context.maybePopPage(PagePopType.deleteData);
      onClosePage?.call();
    }
  }

  void popPage() {
    if (_needPopResultData) {
      context.maybePopPage(patient);
    } else {
      context.maybePopPage();
    }
  }

  @override
  void onClickRetryLoadingData() {
    loadPatientEvaluateList();
  }

  void loadPatientEvaluateList() async {
    setPageStatus(PageStatus.loading);
    final post = await HttpService.post(
      '/api/v2/evaluation/list',
      data: {'patient_id': patient.patientId},
    );
    if (post.status == 0 && post.data != null) {
      evaluationtList = post.data['evaluate_list']
              ?.map((json) => json['evaluate_info'] != null
                  ? Evaluation.fromJson(json['evaluate_info'],
                      json['evaluate_data'], patient.patientId)
                  : null) // 将 null 过滤掉
              .where((evaluation) => evaluation != null)
              .cast<Evaluation>()
              .toList() ??
          [];
      setPageStatus(evaluationtList.isNotEmpty
          ? PageStatus.loadingSuccess
          : PageStatus.empty);
    } else {
      setPageStatus(PageStatus.error);
    }
  }

  // @deprecated
  // void onClickDataItem(ChannelMeta channelMeta) {
  //   context.push((ctx) => EegLineChart(
  //       title:
  //           '${patient.name}:${channelMeta.data_type}:${channelMeta.data_id}',
  //       channelMeta: channelMeta));
  // }
  void onClickDataItem(Evaluation channelMeta) {
    ///TODO
    // context.push((ctx) => EegLineChart(
    //     title:
    //         '${patient.name}:${channelMeta.data_type}:${channelMeta.data_id}',
    //     channelMeta: channelMeta));
  }

  void onClickShowAssessDialog() async {
    assessHomePageManager.addNextPage(
        title: '选择评估部位',
        builder: (patient) => AssessSelectPage(patient: this.patient));
  }

  void onItemClick(Evaluation item) {
    item.evaluateType.toast;
  }

  /// 点击上传数据
  void onClickItemUpload(Evaluation item) async {
    await showShadDialog<bool?>(
      context: context,
      builder: (context) => AssessUploadPage(
        patientId: patient.patientId,
        patientEvaluationId: item.evaluationId,
      ),
    );
    loadPatientEvaluateList();
  }

  /// 点击分析
  void onClickItemAnalyse(Evaluation item) {}

  /// 点击下载报告
  void onClickItemReportDownload(Evaluation item) async {
    final evaluateReport = item.evaluateReport;
    if (evaluateReport.isEmpty) {
      '报告下载错误,报告空'.toast;
    }
    var filename =
        '报告-${item.evaluationDate}-${patient.name}-${item.evaluationId}';
    if (filename.length > 240) {
      filename = '${filename.substring(0, 240)}……';
    }
    try {
      final saveFile = await FilePicker.platform.saveFile(
          dialogTitle: '保存报告PDF文件',
          fileName: '$filename.pdf',
          bytes: base64Decode(evaluateReport));
      if (saveFile != null) {
        '报告下载成功: $saveFile'.toast;
      }
    } catch (e) {
      '报告下载失败: $e'.toast;
    }
  }

  /// 点击预览报告
  void onClickItemReportPreview(Evaluation item) {
    assessHomePageManager.addNextPage(
        title: '预览报告${item.evaluationDate.yyyy_MM_dd_HH_mm_ss}',
        builder: (patient) => Stack(
              children: [
                SfPdfViewer.memory(base64Decode(item.evaluateReport)),
                TextButton(
                  onPressed: () => onClickItemReportDownload(item),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.withAlpha(50),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // 设置圆角
                    ),
                  ),
                  child: Text(
                    '下载',
                    style: const TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                ),
              ],
            ));
  }

  /// 点击数据展示
  void onClickItemAnalyze(Evaluation data, DataItem item) {
    context.push(
      (ctx) => EegLineChart(
        title: '${patient.name}:${item.dataType}:${item.dataId}',
        channelMeta: ChannelMeta(
          dataId: item.dataId,
          dataType: item.dataType,
          patientEvaluationId: data.evaluationId,
          channels: item.channel,
          totalSecond: item.totalSecond,
        ),
      ),
    );
  }

  void _onCreatePatientEvaluateEvent(UpdateOrInsertPatientEvaluateEvent event) {
    if (patient.patientId == event.patientId) {
      loadPatientEvaluateList();
    }
  }

  void onExpandableClick() {
    showShadDialog<bool?>(
      context: context,
      builder: (context) => Container(
        margin: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("  病史:"),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    context.pop(); // 关闭页面
                  },
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: SelectableText('  ${patient.medicalHistory}')),
            ),
          ],
        ),
      ),
    );
  }

  void onClickItemReportGenerate(Evaluation item) async {
    showLoading('正在生成报告...');
    final post = await HttpService.post('/api/v2/report/generate', data: {
      'patient_id': item.patientId,
      'patient_evalution_data': {'patient_evaluation_id': item.evaluationId},
    });
    hideLoading();
    showToast(post.ok ? '报告生成成功' : '报告生成失败');
    loadPatientEvaluateList();
  }
}

class UpdateOrInsertPatientEvaluateEvent {
  final int patientEvaluationId;
  final int patientId;

  UpdateOrInsertPatientEvaluateEvent(
      {required this.patientEvaluationId, required this.patientId});
}
