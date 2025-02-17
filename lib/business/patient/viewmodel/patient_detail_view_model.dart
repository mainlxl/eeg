import 'package:eeg/business/chart/mode/channels_meta_data.dart';
import 'package:eeg/business/chart/page/chart_page.dart';
import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:eeg/core/utils/router_utils.dart';

class PatientDetailViewModel extends BaseViewModel {
  Patient patient;
  bool _needPopResultData = false;
  List<ChannelMeta> chartList = [];

  PatientDetailViewModel(this.patient);

  @override
  void init() {
    loadData();
  }

  onClickUpdate() async {
    // 这里可以添加更新信息的逻辑，例如导航到更新页面
    var result =
        await context.pushNamed('/patient/add_or_edit', arguments: patient);
    if (result is Patient) {
      patient = result;
      _needPopResultData = true;
      notifyListeners();
    } else if (result == PagePopType.deleteData) {
      context.maybePopPage(PagePopType.deleteData);
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
    var post = await HttpService.post('/api/v1/eeg-data/list', data: {
      "patient_id": patient.id,
      "required_type": ['EEG', 'IR', 'EMG', 'IMU']
    });
    if (post.status == 0 && post.data != null) {
      var jsonList = post.data as List<dynamic>;
      var listFromJson = ChannelMeta.listFromJson(jsonList);
      chartList = listFromJson;
      notifyListeners();
    }
  }

  void onClickDataItem(ChannelMeta channelMeta) {
    context.push((ctx) => EegLineChart(
        title:
            '${patient.name}:${channelMeta.data_type}:${channelMeta.data_id}',
        channelMeta: channelMeta));
  }
}
