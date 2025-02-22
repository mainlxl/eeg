import 'package:easy_localization/easy_localization.dart';
import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/business/patient/viewmodel/add_patient_view_model.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:eeg/core/utils/id_card_check_utils.dart';
import 'package:eeg/core/utils/phone_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddPatientPage extends StatelessWidget {
  final Patient? patient;

  const AddPatientPage({super.key, this.patient});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddPatientViewModel>(
      create: () => AddPatientViewModel(this.patient),
      child: Consumer<AddPatientViewModel>(
        builder: (context, vm, _) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: vm.formKey,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    Text(
                      vm.isEdit ? '编辑患者 ${vm.name} 信息' : '用户信息',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 40,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop(); // 关闭页面
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: _buildItem(
                        labelText: '姓名',
                        hintText: '请输入姓名',
                        maxLength: 10,
                        keyboardType: TextInputType.text,
                        controller: vm.nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入用户姓名';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    Expanded(
                      child: _buildItem(
                        labelText: '身份证号',
                        hintText: '请输入身份证号',
                        maxLength: 18,
                        keyboardType: TextInputType.number,
                        controller: vm.idCardController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入18位身份证号';
                          }
                          if (value.length != 18) {
                            return '身份证号应为18位';
                          }
                          if (!IdCardUtils.idCardNumberCheck(value)) {
                            return '请检查身份证的正确性';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: _buildItem(
                        labelText: '手机',
                        hintText: '请输入11位手机号',
                        keyboardType: TextInputType.number,
                        maxLength: 11,
                        controller: vm.phoneController,
                        validator: (value) {
                          if (value == null ||
                              value.length != 11 ||
                              !PhoneUtils.isValidPhoneNumber(value)) {
                            return '请输入有效的11位手机号';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    Expanded(
                        child: const SizedBox(
                      width: 1,
                    )),
                  ],
                ),
                // const SizedBox(height: 20.0),
                // _buildItem(
                //   labelText: '家庭地址',
                //   hintText: '请输入籍贯',
                //   keyboardType: TextInputType.text,
                //   controller: vm.nativePlaceController,
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return '请输入籍贯';
                //     }
                //     return null;
                //   },
                // ),
                const SizedBox(height: 20.0),
                _buildItem(
                  labelText: '过往病史',
                  hintText: '请输入过往病史',
                  minLines: 10,
                  keyboardType: TextInputType.text,
                  controller: vm.medicalHistoryController,
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: vm.isEdit
                      ? MainAxisAlignment.spaceAround
                      : MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: vm.isEdit
                          ? vm.onClickUpdatePatient
                          : vm.onClickAddPatient,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3.0, horizontal: 50.0),
                        child: Text(
                          "提   交".tr(),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: vm.isEdit,
                      child: FilledButton(
                        onPressed: vm.onClickDeletePatient,
                        style: () {
                          return ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.resolveWith((states) {
                              if (states == WidgetState.hovered) {
                                return Colors.red.withOpacity(0.8);
                              } else {
                                return Colors.red;
                              }
                            }),
                          );
                        }(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 3.0, horizontal: 50.0),
                          child: Text(
                            "删   除".tr(),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem({
    required String labelText,
    required String hintText,
    required TextEditingController controller,
    required TextInputType keyboardType,
    int? minLines,
    int? maxLength,
    FormFieldValidator<String?>? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLength: maxLength,
      maxLines: minLines != null ? 1000 : null,
      decoration: InputDecoration(
        labelText: labelText,
        alignLabelWithHint: true,
        // 使标签与输入框内容对齐
        labelStyle: const TextStyle(color: subtitleColor),
        floatingLabelStyle: const TextStyle(color: textColor),
        hintText: hintText,
        hintStyle: const TextStyle(color: subtitleColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: textColor, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: textColor, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: textColor, width: 2.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      ),
      style: const TextStyle(fontSize: 14.0),
      validator: validator,
    );
  }
}
