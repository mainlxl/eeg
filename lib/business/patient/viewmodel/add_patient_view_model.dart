import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:eeg/core/utils/id_card_check_utils.dart';
import 'package:eeg/core/utils/router_utils.dart';
import 'package:eeg/core/utils/toast.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AddPatientViewModel extends BaseViewModel {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController idCardController;

  // 病史
  late final TextEditingController medicalHistoryController;

  // 全局 Key 用于管理 Form 的状态
  final formKey = GlobalKey<FormState>();
  Patient? _patient;

  bool get isEdit => _patient != null;

  String get name => _patient?.name ?? '';

  AddPatientViewModel(Patient? patient) {
    _patient = patient;
    nameController = TextEditingController(text: patient?.name);
    phoneController = TextEditingController(text: patient?.phoneNumber);
    idCardController = TextEditingController(text: patient?.identityInfo);
    medicalHistoryController =
        TextEditingController(text: patient?.medicalHistory);
  }

  void updatePatient() async {
    var patient = _patient;
    if (patient != null && formKey.currentState!.validate()) {
      showLoading();
      var idCard = idCardController.text;
      var newData = {
        "name": nameController.text.trim(),
        "age": IdCardUtils.getAge(idCard),
        "gender": IdCardUtils.getGender(idCard),
        "medical_history": medicalHistoryController.text.trim(),
        "phone_number": phoneController.text.trim(),
        "identity_info": idCard,
      };
      ResponseData? post = await HttpService.post(
          '/api/v1/patients/update/${patient.id}',
          data: newData);
      hideLoading();
      if (post?.status == 0) {
        '病人信息已更新'.showToast();
        nameController.clear();
        idCardController.clear();
        medicalHistoryController.clear();
        patient.name = newData['name'] as String;
        patient.age = newData['age'] as int;
        patient.gender = newData['gender'] as String;
        patient.medicalHistory = newData['medical_history'] as String;
        patient.phoneNumber = newData['phone_number'] as String;
        patient.identityInfo = newData['identity_info'] as String;
        context.popPage(patient);
      }
    } else {
      '更新失败'.showToast();
    }
  }

  void addPatient() async {
    if (formKey.currentState!.validate()) {
      showLoading();
      var idCard = idCardController.text;
      ResponseData? post = await HttpService.post('/api/v1/patients', data: {
        "name": nameController.text.trim(),
        "age": IdCardUtils.getAge(idCard),
        "gender": IdCardUtils.getGender(idCard),
        "medical_history": medicalHistoryController.text.trim(),
        "usage_needs": "",
        "phone_number": phoneController.text.trim(),
        "identity_info": idCard,
      });
      hideLoading();
      if (post?.status == 0) {
        '病人信息已添加'.showToast();
        nameController.clear();
        idCardController.clear();
        medicalHistoryController.clear();
        Navigator.pop(context);
      }
    } else {
      '添加失败'.showToast();
    }
  }
}
