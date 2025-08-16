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

class PreporcessingAlgorithm {
  String algorithmName;
  String des;
  List<PreporcessingParam> params;
  bool checked = false;

  PreporcessingAlgorithm({
    required this.algorithmName,
    required this.des,
    required this.params,
  });

  static List<PreporcessingAlgorithm> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => PreporcessingAlgorithm.fromJson(json))
        .toList();
  }

  factory PreporcessingAlgorithm.fromJson(Map<String, dynamic> json) =>
      PreporcessingAlgorithm(
        algorithmName: json["algorithm_name"],
        des: json["des"],
        params: json["params"] == null
            ? []
            : List<PreporcessingParam>.from(
                json["params"].map((x) => PreporcessingParam.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "algorithm_name": algorithmName,
        "des": des,
        "params": List<dynamic>.from(params.map((x) => x.toJson())),
      };

  void synchronizeData({required bool isInput}) {
    for (var e in params) {
      e.synchronizeData(isInput: isInput);
    }
  }

  bool available() {
    if (params.isEmpty) {
      return false;
    }
    return !params.any((e) => !e.available());
  }

  void resetDefault() {
    for (var e in params) {
      e._value = e.defaultValue;
      e.controller.text = e.defaultValue.toString();
    }
  }
}

class PreporcessingParam {
  String name;
  String type;
  num _value;

  num get value {
    var text = _controller?.text;
    if (text != null) {
      try {
        return type == 'double' || type == 'float64'
            ? double.tryParse(text) ?? _value
            : int.tryParse(text) ?? _value;
      } catch (e) {
        return _value;
      }
    }
    return _value;
  }

  String des;
  late final num defaultValue = _value;

  PreporcessingParam({
    required this.name,
    required this.type,
    required num value,
    required this.des,
  }) : _value = value;

  TextEditingController? _controller;

  TextEditingController get controller =>
      _controller ??= TextEditingController(text: _value.toString());

  List<TextInputFormatter> getInputFormatters() {
    switch (type) {
      case 'double':
      case 'float64':
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
        ];
      case 'int':
      default:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ];
    }
  }

  factory PreporcessingParam.fromJson(Map<String, dynamic> json) =>
      PreporcessingParam(
        name: json["name"],
        type: json["type"],
        value: json["value"],
        des: json["des"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "type": type,
        "value": value,
        "des": des,
      };

  void synchronizeData({required bool isInput}) {
    if (isInput) {
      _value = value;
    } else {
      controller.text = _value.toString();
    }
  }

  bool available() {
    var text = _controller?.text;
    if (text != null && text.isNotEmpty) {
      try {
        if (type == 'double' || type == 'float64') {
          if (double.tryParse(text) != null) {
            return true;
          }
        } else if (type == 'int') {
          var intDate = int.tryParse(text);
          if (intDate != null) {
            if (des.contains('必须是奇数')) {
              return intDate.isOdd;
            } else if (des.contains('必须是偶数')) {
              return intDate.isEven;
            } else {
              return true;
            }
          }
        }
      } catch (e) {
        return false;
      }
    }
    return false;
  }
}
