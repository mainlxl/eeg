class AlgorithmDatum {
  final String category;
  final List<AlgorithmFeature> features;

  AlgorithmDatum({
    required this.category,
    required this.features,
  });

  factory AlgorithmDatum.fromJson(Map<String, dynamic> json) => AlgorithmDatum(
        category: json["category"] ?? '',
        features: json["features"] == null
            ? []
            : List<AlgorithmFeature>.from(
                json["features"].map((x) => AlgorithmFeature.fromJson(x))),
      );

  static List<AlgorithmDatum> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => AlgorithmDatum.fromJson(json)).toList();
  }
}

class AlgorithmFeature {
  final String name;
  final String description;
  final List<AlgorithmParameter> parameters;

  AlgorithmFeature({
    required this.name,
    required this.description,
    required this.parameters,
  });

  factory AlgorithmFeature.fromJson(Map<String, dynamic> json) =>
      AlgorithmFeature(
        name: json["name"] ?? '',
        description: json["description"] ?? '',
        parameters: json["parameters"] == null
            ? []
            : List<AlgorithmParameter>.from(
                json["parameters"].map((x) => AlgorithmParameter.fromJson(x))),
      );
}

class AlgorithmParameter {
  String name;
  String type;
  bool enums;
  bool required;
  String description;
  dynamic defaultValue;

  AlgorithmParameter({
    required this.name,
    required this.type,
    required this.enums,
    required this.required,
    required this.defaultValue,
    required this.description,
  });

  factory AlgorithmParameter.fromJson(Map<String, dynamic> json) =>
      AlgorithmParameter(
        name: json["name"] ?? '',
        type: json["type"] ?? '',
        enums: json["enums"] ?? false,
        required: json["required"] ?? false,
        defaultValue: json["default"],
        description: json["description"] ?? '',
      );
}
