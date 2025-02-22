import 'package:eeg/business/chart/mode/channels_meta_data.dart';
import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/business/patient/viewmodel/patient_detail_view_model.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PatientDetailPage extends StatelessWidget {
  final Patient patient;

  const PatientDetailPage({required this.patient});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PatientDetailViewModel>(
      create: () => PatientDetailViewModel(this.patient),
      child: Consumer<PatientDetailViewModel>(
        builder: (context, vm, _) => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: BackButton(onPressed: vm.popPage),
            title: Text('${patient.name} 的详情'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: vm.onClickUpdate,
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '姓名: ${patient.name}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('年龄: ${patient.age}'),
                SizedBox(height: 10),
                Text('性别: ${patient.gender}'),
                SizedBox(height: 10),
                Text('联系电话: ${patient.phoneNumber}'),
                SizedBox(height: 10),
                Text('身份信息: ${patient.identityInfo}'),
                SizedBox(height: 10),
                Text('医疗历史: ${patient.medicalHistory}'),
                SizedBox(height: 10),
                Text('使用需求: ${patient.usageNeeds}'),
                SizedBox(height: 10),
                Text(
                    '创建时间: ${patient.createdAt.toLocal().toString().split(' ')[0]}'),
                SizedBox(height: 10),
                Text(
                    '更新时间: ${patient.updatedAt.toLocal().toString().split(' ')[0]}'),
                if (patient.deletedAt != null)
                  Column(
                    children: [
                      SizedBox(height: 10),
                      Text('删除时间: ${patient.deletedAt}'),
                    ],
                  ),
                if (vm.chartList.isNotEmpty)
                  Expanded(child: _renderChartList(vm)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderChartList(PatientDetailViewModel vm) {
    return ListView.builder(
      itemCount: vm.chartList.length,
      itemBuilder: (context, index) {
        ChannelMeta channelMeta = vm.chartList[index];
        return GestureDetector(
          onTap: () => vm.onClickDataItem(channelMeta),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID: ${channelMeta.data_id}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Type: ${channelMeta.data_type}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Description: ${channelMeta.description ?? "No description"}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
