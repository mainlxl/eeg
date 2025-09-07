import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  bool? checked;

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

  @override
  String toString() {
    return '${name}_${_controller?.text.trim()}';
  }

  factory AlgorithmParameter.fromJson(Map<String, dynamic> json) =>
      AlgorithmParameter(
        name: json["name"] ?? '',
        type: json["type"] ?? '',
        enums: json["enums"] ?? false,
        required: json["required"] ?? false,
        defaultValue: json["default"],
        description: json["description"] ?? '',
      );

  Map<String, dynamic> toJson() {
    dynamic text = _controller?.text.trim();
    if (type == 'int') {
      text = int.tryParse(text) ?? 0;
    } else if (type == 'double' || type == 'float64') {
      text = double.tryParse(text) ?? 0.0;
    }
    return {
      'name': name,
      'type': type,
      'enums': enums,
      'required': required,
      'default': text,
      'description': description,
    };
  }

  TextEditingController? _controller;

  TextEditingController get controller =>
      _controller ??= TextEditingController(text: defaultValue.toString());

  List<TextInputFormatter> getInputFormatters() {
    switch (type) {
      case 'string':
        return [];
      case 'double':
      case 'float64':
      case 'float':
        return [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];
      case 'int':
      default:
        return [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))];
    }
  }

  bool available() {
    var text = _controller?.text.trim();
    if (text != null && text.isNotEmpty) {
      try {
        if (type == 'double' || type == 'float64' || type == 'float') {
            return double.tryParse(text) != null;
        } else if (type == 'int') {
          var intDate = int.tryParse(text);
          if (intDate != null) {
            if (description.contains('必须是奇数')) {
              return intDate.isOdd;
            } else if (description.contains('必须是偶数')) {
              return intDate.isEven;
            } else {
              return true;
            }
          }
        } else if (type == 'string') {
          return true;
        } else if (type == 'bool') {
          return text == 'true' || text == 'false';
        }
      } catch (e) {
        return false;
      }
    }
    return false;
  }
}
