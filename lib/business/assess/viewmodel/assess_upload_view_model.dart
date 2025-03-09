import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:eeg/core/utils/crypto.dart';
import 'package:eeg/core/utils/router_utils.dart';
import 'package:eeg/core/utils/toast.dart';
import 'package:http/http.dart' as http;
import 'package:shadcn_ui/shadcn_ui.dart';

class AssessUploadViewModel extends BaseViewModel {
  final int patientId;
  final int patientEvaluationId;

  File? selectedFile;
  int? sampleRate;
  String? dataType;
  String? dataSha256;
  int? dataSize;

  AssessUploadViewModel(this.patientId, this.patientEvaluationId);

  ShadSelectController<String> fileTypeControl = ShadSelectController();

  Future<void> onUploadChange(List<File> files) async {
    if (files.isNotEmpty) {
      final file = files.first;
      await _calculateFileInfo(file);
      final ext = file.path.split('.').last.toLowerCase();
      if (['edf', 'cnt', 'csv'].contains(ext)) {
        fileTypeControl.value = [ext];
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

  void setSampleRate(String value) {
    sampleRate = int.tryParse(value);
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
    if (sampleRate == null || fileType == null || dataType == null) {
      '请填写所有必填项'.toast;
      return;
    }
    try {
      showLoading();
      notifyListeners();
      ResponseData res = await HttpService.post(
        '/api/v1/patients/evaluate/UpdatePatientEvaluateData',
        data: FormData.fromMap(
          {
            'metadata': '''
            {
              "patient_evaluation_id": ${patientEvaluationId},
              "patient_id": ${patientId},
              "sample_rate": ${sampleRate},
              "file_type": "${fileType}",
              "data_type": "${dataType}",
              "data_varify": "${dataSha256}",
              "data_size": ${dataSize}
            }
            ''',
            'file': await MultipartFile.fromFile(
              path,
              filename: '${DateTime.now().millisecondsSinceEpoch}.${fileType}',
            ),
          },
        ),
        onDioError: (e) {
          '上传失败: ${e.message}'.toast;
        },
      );
      // 处理响应
      if (res.ok) {
        '上传成功'.toast;
        context.popPage();
      }
    } on TimeoutException {
      '请求超时，请检查网络'.toast;
    } on http.ClientException catch (e) {
      '网络错误'.toast;
    } catch (e) {
      '发生未知错误: $e'.toast;
    } finally {
      hideLoading();
      notifyListeners();
    }
  }
}
