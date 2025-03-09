import 'package:eeg/business/patient/mode/patient_info_mode.dart';

class AssessRecord {
  int id;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime deletedAt;
  int patientEvaluationId;
  int patientId;
  DateTime evaluationDate;
  String evaluateType;
  String evaluateClassification;
  String metaInfo;
  String featureData;
  Patient patient;

  AssessRecord({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.patientEvaluationId,
    required this.patientId,
    required this.evaluationDate,
    required this.evaluateType,
    required this.evaluateClassification,
    required this.metaInfo,
    required this.featureData,
    required this.patient,
  });

  factory AssessRecord.fromJson(Map<String, dynamic> json) {
    return AssessRecord(
      id: json['ID'] ?? 0,
      createdAt: DateTime.parse(json['CreatedAt'] ?? DateTime(1970).toString()),
      updatedAt: DateTime.parse(json['UpdatedAt'] ?? DateTime(1970).toString()),
      deletedAt: json['DeletedAt'] != null
          ? DateTime.parse(json['DeletedAt'])
          : DateTime(1970),
      patientEvaluationId: json['patient_evaluation_id'] ?? 0,
      patientId: json['patient_id'] ?? 0,
      evaluationDate:
          DateTime.parse(json['evaluation_date'] ?? DateTime(1970).toString()),
      evaluateType: json['evaluate_type'] ?? "",
      evaluateClassification: json['evaluate_classification'] ?? "",
      metaInfo: json['meta_info'] ?? "{}",
      featureData: json['feature_data'] ?? "{}",
      patient: Patient.fromJson(json['Patient'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'CreatedAt': createdAt.toIso8601String(),
      'UpdatedAt': updatedAt.toIso8601String(),
      'DeletedAt': deletedAt.toIso8601String(),
      'patient_evaluation_id': patientEvaluationId,
      'patient_id': patientId,
      'evaluation_date': evaluationDate.toIso8601String(),
      'evaluate_type': evaluateType,
      'evaluate_classification': evaluateClassification,
      'meta_info': metaInfo,
      'feature_data': featureData,
      'Patient': patient.toJson(),
    };
  }

  @override
  String toString() {
    return 'AssessRecord{id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, patientEvaluationId: $patientEvaluationId, patientId: $patientId, evaluationDate: $evaluationDate, evaluateType: $evaluateType, evaluateClassification: $evaluateClassification, metaInfo: $metaInfo, featureData: $featureData, patient: $patient}';
  }
}
