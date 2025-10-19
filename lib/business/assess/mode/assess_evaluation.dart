import 'dart:convert';

class Evaluation {
  int evaluationId;
  int patientId;
  String evaluationDate;
  String evaluateLevel;
  String evaluateType;
  String evaluateClassification;
  String evaluateReport;
  FeatureData? featureData;
  List<DataItem>? data;

  bool hasFeatureData() {
    return featureData != null;
  }

  // 构造函数，字段可以为空时给出默认值
  Evaluation({
    required this.evaluationId,
    required this.patientId,
    required this.evaluateLevel,
    required this.evaluationDate,
    required this.evaluateType,
    required this.evaluateReport,
    required this.evaluateClassification,
    this.featureData, // 默认空 JSON 字符串
    this.data,
  });

  factory Evaluation.fromJson(Map<String, dynamic> info, List<dynamic>? data) {
    return Evaluation(
      evaluationId: info['evaluate_id'] ?? 0,
      evaluateLevel: info['evaluate_level'] ?? '',
      patientId: info['patient_id'] ?? 0,
      evaluationDate: info['evaluate_date'] ?? '',
      evaluateType: info['evaluate_type'] ?? '',
      evaluateReport: info['evaluate_report'] ?? '',
      evaluateClassification: info['evaluate_classification'] ?? '',
      featureData: info['feature_data'] != null
          ? FeatureData.fromJson(info['feature_data'])
          : null,
      data: data?.map((item) => DataItem.fromJson(item)).toList(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Evaluation &&
          runtimeType == other.runtimeType &&
          evaluationId == other.evaluationId;

  @override
  int get hashCode => evaluationId.hashCode;
}

class FeatureData {
  final dynamic eegDataFeatureItems;
  final dynamic irDataFeatureItems;
  final dynamic emgDataFeatureItems;
  final dynamic imuDataFeatureItems;

  FeatureData({
    required this.eegDataFeatureItems,
    required this.irDataFeatureItems,
    required this.emgDataFeatureItems,
    required this.imuDataFeatureItems,
  });

  factory FeatureData.fromJson(Map<String, dynamic> json) {
    return FeatureData(
      eegDataFeatureItems: json['eeg_data_feature_items'],
      irDataFeatureItems: json['ir_data_feature_items'],
      emgDataFeatureItems: json['emg_data_feature_items'],
      imuDataFeatureItems: json['imu_data_feature_items'],
    );
  }
}

class DataItem {
  final int dataId;
  final List<String>? channel;
  final String dataType;
  final int sampleRate;
  final int totalSecond;

  DataItem({
    required this.dataId,
    required this.channel,
    required this.dataType,
    required this.sampleRate,
    required this.totalSecond,
  });

  // 从Json转换成EEGData对象
  factory DataItem.fromJson(Map<String, dynamic> json) {
    return DataItem(
      dataId: json['data_id'] ?? 0,
      channel:
          json['channel'] != null ? List<String>.from(json['channel']) : null,
      dataType: json['data_type'] ?? '',
      sampleRate: json['sample_rate'] ?? 0,
      totalSecond: json['total_second'] ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataItem &&
          runtimeType == other.runtimeType &&
          dataId == other.dataId &&
          channel == other.channel &&
          dataType == other.dataType &&
          sampleRate == other.sampleRate &&
          totalSecond == other.totalSecond;

  @override
  int get hashCode =>
      Object.hash(dataId, channel, dataType, sampleRate, totalSecond);
}
