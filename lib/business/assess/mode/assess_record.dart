import 'package:eeg/business/assess/mode/assess_evaluation.dart';

class AssessRecord {
  //评估id
  int evaluationId;
  DateTime evaluationDate;
  String evaluateType;
  String evaluateClassification;
  FeatureData? featureData;

  AssessRecord({
    required this.evaluationId,
    required this.evaluationDate,
    required this.evaluateType,
    required this.evaluateClassification,
    this.featureData,
  });

  factory AssessRecord.fromJson(Map<String, dynamic> json) {
    return AssessRecord(
      evaluationId: json['evaluate_id'] ?? 0,
      evaluationDate:
          DateTime.parse(json['evaluation_date'] ?? DateTime(1970).toString()),
      evaluateType: json['evaluate_type'] ?? "",
      evaluateClassification: json['evaluate_classification'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_evaluation_id': evaluationId,
      'evaluation_date': evaluationDate.toIso8601String(),
      'evaluate_type': evaluateType,
      'evaluate_classification': evaluateClassification,
      'feature_data': featureData,
    };
  }

  @override
  String toString() {
    return 'AssessRecord{evaluationId: $evaluationId, evaluationDate: $evaluationDate, evaluateType: $evaluateType, evaluateClassification: $evaluateClassification, featureData: $featureData}';
  }
}
