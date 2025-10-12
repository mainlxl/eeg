import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:eeg/core/utils/crypto.dart';
import 'package:eeg/core/utils/iterable_extend.dart';
import 'package:eeg/core/utils/router_utils.dart';
import 'package:eeg/core/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shadcn_ui/shadcn_ui.dart';

class UploadRecording {
  String name;
  bool upload = false;

  UploadRecording(this.name);
}

class AssessUploadViewModel extends BaseViewModel {
  final int patientId;
  final int patientEvaluationId;
  TextEditingController sampleRateController = TextEditingController();
  File? selectedFile;
  String? dataType;
  String? dataSha256;
  int? dataSize;

  late List<UploadRecording> uploadRecording = [
    UploadRecording('EEG'),
    UploadRecording('IR'),
    UploadRecording('EMG'),
    UploadRecording('IMU'),
  ];

  AssessUploadViewModel(this.patientId, this.patientEvaluationId,
      List<String>? inputHasUploaded) {
    if (inputHasUploaded != null && inputHasUploaded.isNotEmpty) {
      for (var e in uploadRecording) {
        e.upload = inputHasUploaded.contains(e.name);
      }
    }
  }

  ShadSelectController<String> fileTypeControl = ShadSelectController();
  ShadSelectController<String> dataTypeControl = ShadSelectController();

  Future<void> onUploadChange(List<File> files) async {
    if (files.isNotEmpty) {
      final file = files.first;
      await _calculateFileInfo(file);
      final ext = file.path.split('.').last.toLowerCase();
      if (['edf', 'cnt', 'csv'].contains(ext)) {
        fileTypeControl.value = {ext};
      }
      selectedFile = file;
    }
    notifyListeners();
  }

  Future<void> _calculateFileInfo(File file) async {
    dataSize = await file.length();
    dataSha256 = await file.sha256;
    notifyListeners();
  }

  void setDataType(String? value) {
    dataType = value;
    notifyListeners();
  }

  Future<void> uploadData() async {
    var path = selectedFile?.path;
    if (path == null || path.isEmpty) {
      '请先选择文件'.toast;
      return;
    }
    final fileType = fileTypeControl.value.firstOrNull;
    if (sampleRateController.text.isEmpty ||
        fileType == null ||
        dataType == null) {
      '请填写所有必填项'.toast;
      return;
    }
    try {
      showLoading();
      notifyListeners();
      ResponseData res = await HttpService.post(
        '/api/v2/data/upload',
        data: FormData.fromMap(
          {
            "evaluate_id": patientEvaluationId,
            "patient_id": patientId,
            "sample_rate": sampleRateController.text,
            "file_type": fileTypeControl.value.firstOrNull,
            "data_type": dataType,
            "data_sign": dataSha256,
            "data_size": dataSize,
            'file': await MultipartFile.fromFile(
              path,
              filename: '${DateTime.now().millisecondsSinceEpoch}.$fileType',
            ),
          },
        ),
        onDioError: (e) {
          '上传失败: ${e.message}'.toast;
        },
      );
      // 处理响应
      if (res.ok) {
        hideLoading();
        uploadRecording.firstWhereOrNull((e) => e.name == dataType)?.upload =
            true;
        var toBeUploaded = uploadRecording.where((e) => !e.upload);
        final nextContinue = await showShadDialog(
          context: context,
          builder: (context) {
            return ShadDialog.alert(
              title: Text('${dataType}上传成功'),
              description: Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  toBeUploaded.isNotEmpty
                      ? "还可以上传数据: ${toBeUploaded.map((e) => e.name).join(' , ')}"
                      : '数据已全部上传完成(${uploadRecording.map((e) => e.name).join(', ')})',
                ),
              ),
              actions: [
                ShadButton.destructive(
                  child: const Text('结束上传'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                if (toBeUploaded.isNotEmpty)
                  ShadButton(
                    onPressed: () async {
                      context.popPage(true);
                    },
                    gradient: LinearGradient(colors: [
                      Colors.cyan,
                      Colors.indigo,
                    ]),
                    shadows: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: .4),
                        spreadRadius: 4,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    child: const Text('继续上传'),
                  )
              ],
            );
          },
        );
        if (!nextContinue) {
          if (mounted) {
            context.popPage(true);
          }
        } else {
          selectedFile = null;
          sampleRateController.clear();
          dataType = null;
          dataSha256 = null;
          dataSize = null;
          fileTypeControl.value = {};
          dataTypeControl.value = {};
          notifyListeners();
        }
      }
    } on TimeoutException {
      '请求超时，请检查网络'.toast;
    } on http.ClientException {
      '网络错误'.toast;
    } catch (e) {
      '发生未知错误: $e'.toast;
    } finally {
      hideLoading();
      notifyListeners();
    }
  }
}
