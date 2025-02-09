import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/business/patient/viewmodel/patient_list_view_model.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PatientListPage extends StatelessWidget {
  const PatientListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PatientListViewModel>(
      create: () => PatientListViewModel(),
      child: Consumer<PatientListViewModel>(
        builder: (context, vm, _) => ListView.builder(
          itemCount: vm.patients.length,
          itemBuilder: (context, index) {
            final patient = vm.patients[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                onTap: () => vm.onClickPatientItem(patient),
              ),
            );
          },
        ),
      ),
    );
  }

  String avatarName(Patient patient) =>
      patient.name.isNotEmpty ? patient.name.substring(0, 1) : '';
}
