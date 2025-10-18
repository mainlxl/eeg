import 'dart:io';

import 'package:eeg/business/assess/viewmodel/assess_upload_view_model.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:eeg/common/widget/drag_to_move_area_widget.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AssessUploadPage extends StatelessWidget {
  final int patientId;
  final int patientEvaluationId;

  const AssessUploadPage(
      {super.key, required this.patientId, required this.patientEvaluationId});

  @override
  Widget build(BuildContext context) {
    return DragToMoveWidget(
      child: ViewModelBuilder<AssessUploadViewModel>(
        create: () => AssessUploadViewModel(patientId, patientEvaluationId),
        child: Consumer<AssessUploadViewModel>(
          builder: (context, vm, _) => _buildUploadInterface(context, vm),
        ),
      ),
    );
  }

  Widget _buildUploadInterface(BuildContext context, AssessUploadViewModel vm) {
    return Container(
      margin: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 40,
              margin: const EdgeInsets.all(10),
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop(); // 关闭页面
                },
              ),
            ),
          ),
          Spacer(),
          _uploadSuccessTip(context, vm),
          _buildFileUploadArea(context, vm),
          const SizedBox(height: 20),
          _buildParameterInputs(context, vm),
          const SizedBox(height: 20),
          _buildUploadButton(vm),
          Spacer(),
          SizedBox(
            height: 40,
          )
        ],
      ),
    );
  }

  Widget _buildFileUploadArea(BuildContext context, AssessUploadViewModel vm) {
    return GestureDetector(
      onTap: () => _pickFiles(context, vm),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey, width: 2),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.upload_file, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              vm.selectedFile == null
                  ? '点击选择文件 (edf/cnt/csv)'
                  : '已选文件: ${vm.selectedFile?.path.split('/').last}',
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
            if (vm.dataSize != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '文件大小: ${vm.dataSize} bytes',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            if (vm.dataSha256 != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'sha256: ${vm.dataSha256}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFiles(
      BuildContext context, AssessUploadViewModel vm) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowedExtensions: ['edf', 'cnt', 'csv'],
      type: FileType.custom,
    );
    if (result != null && result.files.isNotEmpty) {
      await vm.onUploadChange([File(result.files.first.path!)]);
    }
  }

  Widget _buildParameterInputs(BuildContext context, AssessUploadViewModel vm) {
    final theme = ShadTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '文件类型: ',
          style: theme.textTheme.muted.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.popoverForeground,
          ),
          textAlign: TextAlign.start,
        ),
        ShadSelect<String>(
          placeholder: const Text('选择文件类型'),
          options: [
            ShadOption(value: "edf", child: Text('edf')),
            ShadOption(value: "cnt", child: Text('cnt')),
            ShadOption(value: "csv", child: Text('csv')),
          ],
          selectedOptionBuilder: (context, value) => Text(value),
          controller: vm.fileTypeControl,
        ),
        const SizedBox(width: 16),
        Text(
          '数据类型: ',
          style: theme.textTheme.muted.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.popoverForeground,
          ),
          textAlign: TextAlign.start,
        ),
        ShadSelect<String>(
          placeholder: const Text('选择数据类型'),
          options: vm.uploadRecording
              .where((e) => !e.upload)
              .map((e) => ShadOption(value: e.name, child: Text(e.name)))
              .toList(),
          selectedOptionBuilder: (context, value) => Text(value),
          onChanged: vm.setDataType,
          controller: vm.dataTypeControl,
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 150,
          child: TextField(
            maxLines: 1,
            controller: vm.sampleRateController,
            decoration: const InputDecoration(
              labelText: '采样率 (Hz)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        )
      ],
    );
  }

  Widget _buildUploadButton(AssessUploadViewModel vm) {
    return ShadButton(
      onPressed: vm.uploadData,
      leading: const Icon(Icons.cloud_upload),
      child: Text('开始上传'),
    );
  }

  Widget _uploadSuccessTip(BuildContext context, AssessUploadViewModel vm) {
    return Visibility(
      visible: vm.uploadRecording.any((e) => e.upload),
      child: Text(
        "已上传过数据: ${vm.uploadRecording.where((e) => e.upload).map((e) => e.name).join(' , ')}",
        style: TextStyle(color: Colors.green),
      ),
    );
  }
}
