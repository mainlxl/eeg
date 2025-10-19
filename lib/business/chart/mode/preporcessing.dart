import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

class PreporcessingAlgorithm {
  String algorithmName;
  String des;
  String dataType;
  List<FeaturesParam> features;
  bool checked = false;

  PreporcessingAlgorithm({
    required this.algorithmName,
    required this.des,
    required this.features,
    required this.dataType,
  });

  static List<PreporcessingAlgorithm> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => PreporcessingAlgorithm.fromJson(json))
        .toList();
  }

  factory PreporcessingAlgorithm.fromJson(Map<String, dynamic> json) {
    return PreporcessingAlgorithm(
      algorithmName: json["algorithm_name"],
      des: json["des"],
      dataType: json["type"] as String? ?? '',
      features: json["params"] == null
          ? []
          : List<FeaturesParam>.from(
          json["params"].map((x) => FeaturesParam.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "algorithm_name": algorithmName,
        "des": des,
        "params": List<dynamic>.from(features.map((x) => x.toJson())),
      };

  void synchronizeData({required bool isInput}) {
    for (var e in features) {
      e.synchronizeData(isInput: isInput);
    }
  }

  bool available() {
    if (features.isEmpty) {
      return false;
    }
    return !features.any((e) => !e.available());
  }

  void resetDefault() {
    for (var e in features) {
      e._value = e.defaultValue;
      e.controller.text = e.defaultValue.toString();
    }
  }
}

class FeaturesParam {
  String name;
  String type;
  dynamic _value;
  List<String> enumList;

  dynamic get value {
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

  set value(dynamic newValue) {
    _value = newValue;
    controller.text = newValue.toString();
  }

  String des;
  late final dynamic defaultValue = _value;

  FeaturesParam({
    required this.name,
    required this.type,
    required dynamic value,
    required this.des,
    required this.enumList,
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

  factory FeaturesParam.fromJson(Map<String, dynamic> json) {
    List<String> enumList = json["enum_list"] == null
        ? []
        : List<String>.from(json["enum_list"].map((x) => x));
    var value = json["value"];
    if (enumList.isNotEmpty) {
      if (!enumList.contains(value)) {
        value = enumList.first;
      }
    }
    return FeaturesParam(
      name: json["name"],
      type: json["type"] as String? ?? '',
      value: value,
      enumList: enumList,
      des: json["des"] ?? '',
    );
  }

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
    var text = _controller?.text ?? value;
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
        } else if (type == 'enum') {
          return enumList.contains(text);
        }
      } catch (e) {
        return false;
      }
    }
    return false;
  }
}
