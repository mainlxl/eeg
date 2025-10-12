import 'package:eeg/app.dart';
import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/business/user/user_info.dart';
import 'package:eeg/common/widget/loading_status_page.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:eeg/core/utils/router_utils.dart';

class PatientListViewModel extends LoadingPageStatusViewModel {
  List<Patient>? _patients;
  List<Patient>? _searchResults;

  List<Patient> get patients => _searchResults ?? _patients ?? [];

  String query = '';

  @override
  void init() {
    super.init();
    loadData();
    addSubscription(
        eventBus.on<PatientListRefreshEvent>().listen((event) => loadData()));
  }

  Future<void> loadData([bool enableLoadingPage = true]) async {
    try {
      if (enableLoadingPage) setPageStatus(PageStatus.loading);
      ResponseData response = await HttpService.post('/api/v2/patient/list');
      if (response.status == 0) {
        final dataList = response.data['patient_list'];
        if (dataList == null || dataList is! List || dataList.isEmpty) {
          _patients = [];
        } else {
          _patients = dataList
              .map((item) => Patient.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        if (enableLoadingPage) {
          setPageStatus(PageStatus.loadingSuccess);
        } else {
          notifyListeners();
        }
      } else {
        if (enableLoadingPage) setPageStatus(PageStatus.error);
      }
    } finally {
      if (pageStatus == PageStatus.loading) {
        setPageStatus(PageStatus.error);
      }
    }
  }

  @override
  void onClickRetryLoadingData() => loadData();

  void onClickPatientItem(Patient patient) async {
    var result = await context.pushNamed('/patient/detail', arguments: patient);
    var patients = _patients;
    if (patients != null && result != null) {
      if (result is Patient) {
        for (var i = 0; i < _patients!.length; i++) {
          if (_patients![i].patientId == patient.patientId) {
            _patients![i] = patient;
            notifyListeners();
            break;
          }
        }
      } else if (result == PagePopType.deleteData) {
        patients.remove(patient);
        notifyListeners();
      } else if (result == PagePopType.refreshData) {
        loadData();
      }
    }
  }

  void onSearchChanged(String query) {
    this.query = query;
    var patients = _patients;
    if (patients != null) {
      final searchResult = patients
          .where((patient) =>
              patient.name.toString().toLowerCase().contains(query) ||
              patient.gender.toString().toLowerCase().contains(query) ||
              patient.genderInfo.toString().toLowerCase().contains(query) ||
              patient.phoneNumber.toString().toLowerCase().contains(query) ||
              patient.usageNeeds.toString().toLowerCase().contains(query) ||
              patient.age.toString().toLowerCase().contains(query))
          .toList();
      _searchResults = searchResult;
      notifyListeners();
    }
  }
}

class PatientListRefreshEvent {
  String name;

  PatientListRefreshEvent(this.name);
}
