class Patient {
  int id;
  DateTime createdAt;
  DateTime updatedAt;
  String? deletedAt;
  String name;
  int age;
  String gender;
  String medicalHistory;
  String usageNeeds;
  String phoneNumber;
  String identityInfo;
  int userId;

  Patient({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    required this.age,
    required this.gender,
    required this.medicalHistory,
    required this.usageNeeds,
    required this.phoneNumber,
    required this.identityInfo,
    required this.userId,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['ID'] as int? ?? 0,
      createdAt: DateTime.parse(
          json['CreatedAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['UpdatedAt'] as String? ?? DateTime.now().toIso8601String()),
      deletedAt: json['DeletedAt'] as String?,
      name: json['name'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      gender: json['gender'] as String? ?? '',
      medicalHistory: json['medical_history'] as String? ?? '',
      usageNeeds: json['usage_needs'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      identityInfo: json['identity_info'] as String? ?? '',
      userId: json['user_id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UpdatedAt': DateTime.now().toIso8601String(),
      'DeletedAt': deletedAt,
      'name': name,
      'age': age,
      'gender': gender,
      'medical_history': medicalHistory,
      'usage_needs': usageNeeds,
      'phone_number': phoneNumber,
      'identity_info': identityInfo,
      'user_id': userId,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Patient && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
