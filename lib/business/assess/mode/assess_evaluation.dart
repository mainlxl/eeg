import 'dart:convert';

class Evaluation {
  int id;
  int patientEvaluationId;
  int patientId;
  String evaluationDate;
  String evaluateLevel;
  String evaluateType;
  String evaluateClassification;
  EvaluationMetaInfo? metaInfo;
  FeatureData? featureData;

  bool hasMetaInfo() {
    return metaInfo != null;
  }

  bool hasFeatureData() {
    return featureData != null;
  }

  // 构造函数，字段可以为空时给出默认值
  Evaluation({
    required this.id,
    required this.patientEvaluationId,
    required this.patientId,
    required this.evaluateLevel,
    required this.evaluationDate,
    required this.evaluateType,
    required this.evaluateClassification,
    this.metaInfo, // 默认空 JSON 字符串
    this.featureData, // 默认空 JSON 字符串
  });

  static List<Evaluation> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Evaluation.fromJson(json)).toList();
  }

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    return Evaluation(
      id: json['ID'] ?? 0,
      patientEvaluationId: json['patient_evaluation_id'] ?? 0,
      evaluateLevel: json['evaluate_level'] ?? '',
      patientId: json['patient_id'] ?? 0,
      evaluationDate: json['evaluation_date'] ?? '',
      evaluateType: json['evaluate_type'] ?? '',
      evaluateClassification: json['evaluate_classification'] ?? '',
      metaInfo: json['meta_info'] == null || json['meta_info'] == '{}'
          ? null
          : json['meta_info'].runtimeType == String
              ? EvaluationMetaInfo.fromJsonStr(json['meta_info'])
              : EvaluationMetaInfo.fromJson(json['meta_info']),
      featureData: json['feature_data'] != null
          ? FeatureData.fromJson(json['feature_data'])
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Evaluation &&
          runtimeType == other.runtimeType &&
          patientEvaluationId == other.patientEvaluationId;

  @override
  int get hashCode => patientEvaluationId.hashCode;
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

class EvaluationMetaInfo {
  final MetaItemInfo irData;
  final MetaItemInfo eegData;
  final MetaItemInfo emgData;
  final MetaItemInfo imuData;
  final int version;
  final String evaluateReport;

  MetaItemInfo? findMetaInfoByType(String dataType) {
    if (dataType == irData.dataType) {
      return irData;
    } else if (dataType == eegData.dataType) {
      return eegData;
    } else if (dataType == emgData.dataType) {
      return emgData;
    } else if (dataType == imuData.dataType) {
      return imuData;
    }
    return null;
  }

  EvaluationMetaInfo({
    required this.irData,
    required this.version,
    required this.eegData,
    required this.emgData,
    required this.imuData,
    required this.evaluateReport,
  });

  List<String> get uploadedName {
    List<String> dataList = [];
    if (irData.hasDate) dataList.add(irData.dataType);
    if (eegData.hasDate) dataList.add(eegData.dataType);
    if (emgData.hasDate) dataList.add(emgData.dataType);
    if (imuData.hasDate) dataList.add(imuData.dataType);
    return dataList;
  }

  bool get needUpload {
    if (irData.hasDate &&
        eegData.hasDate &&
        emgData.hasDate &&
        imuData.hasDate) {
      return false;
    }
    return true;
  }

  factory EvaluationMetaInfo.fromJson(Map<String, dynamic> json) {
    return EvaluationMetaInfo(
      irData: MetaItemInfo.fromJson(json['ir_data'] ?? {}),
      version: json['version'] ?? 0,
      eegData: MetaItemInfo.fromJson(json['eeg_data'] ?? {}),
      emgData: MetaItemInfo.fromJson(json['emg_data'] ?? {}),
      imuData: MetaItemInfo.fromJson(json['imu_data'] ?? {}),
      evaluateReport: json['evaluate_report'] ?? '',
    );
  }

  factory EvaluationMetaInfo.fromJsonStr(String jsonStr) {
    return EvaluationMetaInfo.fromJson(jsonDecode(jsonStr));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationMetaInfo &&
          runtimeType == other.runtimeType &&
          irData == other.irData &&
          eegData == other.eegData &&
          emgData == other.emgData &&
          imuData == other.imuData &&
          version == other.version &&
          evaluateReport == other.evaluateReport;

  @override
  int get hashCode =>
      irData.hashCode ^
      eegData.hashCode ^
      emgData.hashCode ^
      imuData.hashCode ^
      version.hashCode ^
      evaluateReport.hashCode;
}

class MetaItemInfo {
  final String dataId;
  final List<String>? channels;
  final String dataType;
  final int channelNum;
  final int sampleRate;
  final String dataOriPath;
  final bool evaluateState;
  final int totalSecond;

  MetaItemInfo({
    required this.dataId,
    required this.channels,
    required this.dataType,
    required this.channelNum,
    required this.sampleRate,
    required this.dataOriPath,
    required this.evaluateState,
    required this.totalSecond,
  });

  bool get hasDate => dataId.isNotEmpty;

  // 从Json转换成EEGData对象
  factory MetaItemInfo.fromJson(Map<String, dynamic> json) {
    return MetaItemInfo(
      dataId: json['data_id'] ?? '',
      channels:
          json['channels'] != null ? List<String>.from(json['channels']) : null,
      dataType: json['data_type'] ?? '',
      channelNum: json['channel_num'] ?? 0,
      sampleRate: json['sample_rate'] ?? 0,
      totalSecond: json['total_second'] ?? 0,
      dataOriPath: json['data_ori_path'] ?? '',
      evaluateState: json['evaluate_state'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetaItemInfo &&
          runtimeType == other.runtimeType &&
          dataId == other.dataId &&
          channels == other.channels &&
          dataType == other.dataType &&
          channelNum == other.channelNum &&
          sampleRate == other.sampleRate &&
          dataOriPath == other.dataOriPath &&
          evaluateState == other.evaluateState;

  @override
  int get hashCode =>
      dataId.hashCode ^
      channels.hashCode ^
      dataType.hashCode ^
      channelNum.hashCode ^
      sampleRate.hashCode ^
      dataOriPath.hashCode ^
      evaluateState.hashCode;
}
