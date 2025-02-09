import 'package:eeg/app.dart';
import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/business/user/user_info.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:eeg/core/utils/router_utils.dart';

class PatientListViewModel extends BaseViewModel {
  List<Patient>? _patients;

  List<Patient> get patients => _patients ?? [];

  @override
  void init() {
    super.init();
    loadData();
    addSubscription(eventBus.on<PatientListRefreshEvent>().listen((event) {
      loadData();
    }));
  }

  Future<void> loadData() async {
    showLoading();
    ResponseData? response =
        await HttpService.get('/api/v1/patients/by-user/${UserInfo.userId}');
    if (response?.status == 0) {
      var dataList = (response?.data as List<dynamic>?) ?? [];
      _patients = dataList
          .map((item) => Patient.fromJson(item as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
    hideLoading();
  }

  void onClickPatientItem(Patient patient) async {
    var result = await context.pushNamed('/patient/detail', arguments: patient);
    var patients = _patients;
    if (patients != null && result != null) {
      if (result is Patient) {
        for (var i = 0; i < _patients!.length; i++) {
          if (_patients![i].id == patient.id) {
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
}

class PatientListRefreshEvent {}
