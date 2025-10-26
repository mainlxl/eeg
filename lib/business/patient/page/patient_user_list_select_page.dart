import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/business/patient/page/add_or_patient_page.dart';
import 'package:eeg/business/patient/viewmodel/patient_list_view_model.dart';
import 'package:eeg/business/user/user_info.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:eeg/common/common_dialog.dart';
import 'package:eeg/common/widget/loading_status_page.dart';
import 'package:flutter/material.dart';

typedef PatientCallback = void Function(Patient);

/// 患者列表选择页面
class PatientListSelectPage extends StatelessWidget {
  final PatientCallback onSelect;

  const PatientListSelectPage({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return LoadingPageStatusWidget<PatientListViewModel>(
        createOrGetViewMode: () => PatientListViewModel(),
        buildPageContent: (ctx, vm) => Scaffold(
              backgroundColor: bgColor,
              floatingActionButton: Visibility(
                visible: vm.pageStatus == PageStatus.loadingSuccess,
                child: GestureDetector(
                  onLongPress: () {
                    CommonDialog.show(
                        context: context,
                        title: '退出登录',
                        content: '确认要退出登录吗？',
                        type: DialogType.warning,
                        confirmButtonText: '取消',
                        cancelButtonText: '确认',
                        onCancel: UserInfo.cleanTaskAndPushLoginPage);
                  },
                  child: FloatingActionButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => Container(
                          margin: const EdgeInsets.all(15),
                          child: const AddPatientPage()),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    tooltip: '点击添加用户\n长按退出登录',
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
              body: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: '搜索年龄/性别/手机号',
                      suffixIcon: Icon(Icons.search),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12.0), // 优化输入框高度
                    ),
                    onChanged: vm.onSearchChanged,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: vm.patients.length,
                      itemBuilder: (context, index) {
                        final patient = vm.patients[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                avatarName(patient),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(patient.name),
                            subtitle: Text(
                              '年龄: ${patient.age} 性别: ${patient.genderInfo} 需求: ${patient.usageNeeds}',
                            ),
                            isThreeLine: false,
                            onTap: () => onSelect(patient),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ));
  }

  String avatarName(Patient patient) =>
      patient.name.isNotEmpty ? patient.name.substring(0, 1) : '';
}
