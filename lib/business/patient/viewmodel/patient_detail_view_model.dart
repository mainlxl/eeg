import 'package:eeg/app.dart';
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
import 'package:eeg/core/utils/iterable_extend.dart';
import 'package:eeg/core/utils/router_utils.dart';
import 'package:eeg/core/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PatientDetailViewModel extends LoadingPageStatusViewModel {
  Patient patient;
  bool _needPopResultData = false;
  List<Evaluation> evaluationtList = [];
  bool isExpanded = false;
  final VoidCallback? onClosePage;

  PatientDetailViewModel(this.patient, {this.onClosePage});

  @override
  void init() {
    loadPatientEvaluateList();
    addSubscription(eventBus
        .on<UpdateOrInsertPatientEvaluateEvent>()
        .listen(_onCreatePatientEvaluateEvent));
  }

  onClickUpdate() async {
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
      data: patient.requestMiniParam,
    );
    if (post.status == 0 && post.data != null) {
      evaluationtList = post.data['evaluate_list']
              ?.map((json) => json['evaluate_info'] != null
                  ? Evaluation.fromJson(
                      json['evaluate_info'], json['evaluate_data'])
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
        inputHasUploaded: item.metaInfo?.uploadedName,
      ),
    );
    _onUpdateOrInsertEvaluationByPatientId(item.evaluationId);
  }

  Future<Evaluation?> _onUpdateOrInsertEvaluationByPatientId(
      int patientEvaluationId) async {
    var post = await HttpService.post(
      '/api/v1/patients/evaluate/GetPatientEvaluate',
      data: {"patient_evaluation_id": patientEvaluationId},
    );
    if (post.status == 0 && post.data != null) {
      var data = Evaluation.fromJson(post.data,null);
      var old = evaluationtList.firstWhereOrNull(
          (element) => element.evaluationId == patientEvaluationId);
      if (old != null) {
        var indexOf = evaluationtList.indexOf(old);
        if (indexOf >= 0) {
          evaluationtList[indexOf] = data;
          notifyListeners();
        }
      } else {
        evaluationtList.add(data);
        notifyListeners();
      }
      return data;
    }
    return null;
  }

  /// 点击分析
  void onClickItemAnalyse(Evaluation item) {}

  /// 点击下载报告
  void onClickItemReportDownload(Evaluation item) {}

  /// 点击预览报告
  void onClickItemReportPreview(Evaluation item) {}

  /// 点击数据展示
  void onClickItemAnalyze(Evaluation item, MetaItemInfo metaInfo) async {
    MetaItemInfo meta = metaInfo;
    if (meta.channels == null || meta.channels?.isEmpty == true) {
      Evaluation? data =
          await _onUpdateOrInsertEvaluationByPatientId(item.evaluationId);
      var newMeta = data?.metaInfo?.findMetaInfoByType(metaInfo.dataType);
      var newChannels = newMeta?.channels;
      if (newMeta == null || newChannels == null || newChannels.isEmpty) {
        "数据正在解析,中请稍后再试!!!".toast;
        return;
      }
      meta = newMeta;
    }
    context.push((ctx) => EegLineChart(
        title: '${patient.name}:${metaInfo.dataType}:${metaInfo.dataId}',
        channelMeta: ChannelMeta(
          dataId: meta.dataId,
          dataType: meta.dataType,
          patientEvaluationId: item.evaluationId,
          channels: meta.channels,
          totalSecond: meta.totalSecond,
        )));
  }

  void _onCreatePatientEvaluateEvent(
      UpdateOrInsertPatientEvaluateEvent event) async {
    if (patient.patientId == event.patientId) {
      _onUpdateOrInsertEvaluationByPatientId(event.patientEvaluationId);
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
}

class UpdateOrInsertPatientEvaluateEvent {
  final int patientEvaluationId;
  final int patientId;

  UpdateOrInsertPatientEvaluateEvent(
      {required this.patientEvaluationId, required this.patientId});
}
