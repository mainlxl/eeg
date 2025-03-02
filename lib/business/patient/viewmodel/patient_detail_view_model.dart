import 'package:eeg/business/chart/mode/channels_meta_data.dart';
import 'package:eeg/business/chart/page/chart_page.dart';
import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/business/patient/page/add_or_patient_page.dart';
import 'package:eeg/common/widget/loading_status_page.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:eeg/core/utils/router_utils.dart';
import 'package:flutter/material.dart';

class PatientDetailViewModel extends LoadingPageStatusViewModel {
  Patient patient;
  bool _needPopResultData = false;
  List<ChannelMeta> chartList = [];
  bool isExpanded = false;
  final VoidCallback? onClosePage;

  PatientDetailViewModel(this.patient, {this.onClosePage});

  @override
  void init() {
    loadData();
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

  void loadData() async {
    setPageStatus(PageStatus.loading);
    var post = await HttpService.post('/api/v1/eeg-data/list', data: {
      "patient_id": patient.id,
      "required_type": ['EEG', 'IR', 'EMG', 'IMU']
    });
    if (post.status == 0 && post.data != null) {
      var jsonList = post.data as List<dynamic>;
      var listFromJson = ChannelMeta.listFromJson(jsonList);
      chartList = listFromJson;
      setPageStatus(
          chartList.isNotEmpty ? PageStatus.loading_success : PageStatus.empty);
    } else {
      setPageStatus(PageStatus.error);
    }
  }

  void onClickDataItem(ChannelMeta channelMeta) {
    context.push((ctx) => EegLineChart(
        title:
            '${patient.name}:${channelMeta.data_type}:${channelMeta.data_id}',
        channelMeta: channelMeta));
  }

  void onExpandableChange(bool isExpanded) {
    this.isExpanded = isExpanded;
    notifyListeners();
  }
}
