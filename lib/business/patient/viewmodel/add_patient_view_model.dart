import 'package:eeg/app.dart';
import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/business/patient/viewmodel/patient_list_view_model.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:eeg/core/utils/id_card_check_utils.dart';
import 'package:eeg/core/utils/router_utils.dart';
import 'package:eeg/core/utils/toast.dart';
import 'package:flutter/material.dart';

class AddPatientViewModel extends BaseViewModel {
  late final TextEditingController nameController;
  late final TextEditingController usageNeedsController;
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
    usageNeedsController = TextEditingController(text: patient?.usageNeeds);
    phoneController = TextEditingController(text: patient?.phoneNumber);
    idCardController = TextEditingController(text: patient?.identityInfo);
    medicalHistoryController =
        TextEditingController(text: patient?.medicalHistory);
  }

  void onClickUpdatePatient() async {
    var patient = _patient;
    if (patient != null && formKey.currentState!.validate()) {
      showLoading();
      var idCard = idCardController.text;
      final newData = {
        "name": nameController.text.trim(),
        "age": IdCardUtils.getAge(idCard),
        "gender": IdCardUtils.getGender(idCard),
        "medical_history": medicalHistoryController.text.trim(),
        "phone_number": phoneController.text.trim(),
        "usage_needs": usageNeedsController.text.trim(),
        "identity_info": idCard,
      };
      ResponseData post = await HttpService.post('/api/v2/patient/update',
          data: {'patient_id': patient.patientId, 'patient': newData});
      hideLoading();
      if (post.status == 0) {
        '用户信息已更新'.showToast();
        nameController.clear();
        idCardController.clear();
        medicalHistoryController.clear();
        patient.name = newData['name'] as String;
        patient.age = newData['age'] as int;
        patient.gender = newData['gender'] as String;
        patient.medicalHistory = newData['medical_history'] as String;
        patient.phoneNumber = newData['phone_number'] as String;
        patient.identityInfo = newData['identity_info'] as String;
        patient.usageNeeds = newData['usage_needs'] as String;
        eventBus.fire(PatientListRefreshEvent(patient.name));
        context.popPage(patient);
      }
    } else {
      '更新失败'.showToast();
    }
  }

  void onClickAddPatient() async {
    if (formKey.currentState!.validate()) {
      showLoading();
      var idCard = idCardController.text;
      ResponseData post = await HttpService.post('/api/v2/patient/add', data: {
        'patient': {
          "name": nameController.text.trim(),
          "age": IdCardUtils.getAge(idCard),
          "gender": IdCardUtils.getGender(idCard),
          "medical_history": medicalHistoryController.text.trim(),
          "usage_needs": usageNeedsController.text.trim(),
          "phone_number": phoneController.text.trim(),
          "identity_info": idCard,
        }
      });
      hideLoading();
      if (post.status == 0) {
        '用户信息已添加'.showToast();
        nameController.clear();
        idCardController.clear();
        medicalHistoryController.clear();
        eventBus.fire(PatientListRefreshEvent(nameController.text.trim()));
        Navigator.pop(context, PagePopType.refreshData);
      }
    } else {
      '添加失败'.showToast();
    }
  }

  void onClickDeletePatient() async {
    var patient = _patient;
    if (patient != null) {
      // 展示对话框如果用户确认删除
      if (await confirmDeleteDialog(patient)) {
        showLoading();
        ResponseData post = await HttpService.post(
            '/api/v2/patient/delete',data: {'patient_id': patient.patientId});
        hideLoading();
        if (post.status == 0) {
          '用户信息已删除'.showToast();
          eventBus.fire(PatientListRefreshEvent(patient.name));
          Navigator.pop(context, PagePopType.deleteData);
        } else {
          '删除失败'.showToast();
        }
      }
    } else {
      '删除失败'.showToast();
    }
  }

  Future<bool> confirmDeleteDialog(Patient patient) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('确认删除患者信息'),
              content: RichText(
                text: TextSpan(
                  style: const TextStyle(color: textColor), // 默认颜色
                  children: [
                    const TextSpan(
                      text: '确定要删除患者',
                    ),
                    TextSpan(
                      text: patient.name,
                      style: TextStyle(color: Colors.red), // 红色
                    ),
                    const TextSpan(
                      text: '信息吗？',
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // 取消
                  },
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // 确认
                  },
                  child: const Text('确认'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
