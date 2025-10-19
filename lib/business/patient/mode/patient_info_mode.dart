class Patient {
  int patientId = 1;
  String name;
  int age;
  String gender;
  String medicalHistory;
  String usageNeeds;
  String phoneNumber;
  String identityInfo;

  String get genderInfo => gender.toLowerCase() == 'male'
      ? '男'
      : (gender.toLowerCase() == 'female' ? '女' : '未知');

  Patient({
    required this.patientId,
    required this.name,
    required this.age,
    required this.gender,
    required this.medicalHistory,
    required this.usageNeeds,
    required this.phoneNumber,
    required this.identityInfo,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      patientId: json['patient_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      gender: json['gender'] as String? ?? '',
      medicalHistory: json['medical_history'] as String? ?? '',
      usageNeeds: json['usage_needs'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      identityInfo: json['identity_info'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'medical_history': medicalHistory,
      'usage_needs': usageNeeds,
      'phone_number': phoneNumber,
      'identity_info': identityInfo,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Patient &&
          runtimeType == other.runtimeType &&
          patientId == other.patientId;

  @override
  int get hashCode => patientId.hashCode;
}
