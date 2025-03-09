import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/business/patient/viewmodel/patient_list_view_model.dart';
import 'package:eeg/common/widget/loading_status_page.dart';
import 'package:flutter/material.dart';

import 'add_or_patient_page.dart' show AddPatientPage;

typedef PatientCallback = void Function(Patient);

class PatientListSelectPage extends StatelessWidget {
  PatientCallback onSelect;

  PatientListSelectPage({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => Container(
              margin: const EdgeInsets.all(15), child: const AddPatientPage()),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        tooltip: '添加用户',
        child: const Icon(Icons.add),
      ),
      body: LoadingPageStatusWidget<PatientListViewModel>(
          createOrGetViewMode: () => PatientListViewModel(),
          buildPageContent: (ctx, vm) => Column(
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
                              '年龄: ${patient.age} 性别: ${patient.gender}',
                            ),
                            isThreeLine: false,
                            onTap: () => onSelect(patient),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )),
    );
  }

  String avatarName(Patient patient) =>
      patient.name.isNotEmpty ? patient.name.substring(0, 1) : '';
}
