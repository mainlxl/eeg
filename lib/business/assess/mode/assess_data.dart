import 'package:eeg/business/assess/widgets/game_cognition_color_widget.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AssessCategoryJson {
  final List<AssessCategory> config;

  AssessCategoryJson({required this.config});

  factory AssessCategoryJson.fromJson(Map<String, dynamic> json) =>
      AssessCategoryJson(
          config: json["config"] != null && json["config"].isNotEmpty
              ? List<AssessCategory>.from(
                  json["config"].map((x) => AssessCategory.fromJson(x)))
              : []);
}

class AssessCategory {
  final String name;
  final List<AssessSubCategory> data;

  AssessCategory({
    required this.name,
    required this.data,
  });

  factory AssessCategory.fromJson(Map<String, dynamic> json) => AssessCategory(
        name: json["name"] ?? '',
        data: List<AssessSubCategory>.from(
            json["data"] != null && json["data"].isNotEmpty
                ? json["data"].map((x) => AssessSubCategory.fromJson(x))
                : []),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class AssessSubCategory {
  final String name;
  final List<AssessInspectionPoint> data;

  AssessSubCategory({
    required this.name,
    required this.data,
  });

  factory AssessSubCategory.fromJson(Map<String, dynamic> json) =>
      AssessSubCategory(
        name: json["name"] ?? '',
        data: List<AssessInspectionPoint>.from(
            json["data"] != null && json["data"].isNotEmpty
                ? json["data"].map((x) => AssessInspectionPoint.fromJson(x))
                : []),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class AssessInspectionPoint {
  final String name;
  final List<AssessData> data;

  AssessInspectionPoint({
    required this.name,
    required this.data,
  });

  factory AssessInspectionPoint.fromJson(Map<String, dynamic> json) =>
      AssessInspectionPoint(
        name: json["name"] ?? '',
        data: List<AssessData>.from(
            json["data"] != null && json["data"].isNotEmpty
                ? json["data"].map((x) => AssessData.fromJson(x))
                : []),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class AssessData {
  final String id;
  final String dataType;
  final List<String> dataList;
  final String dataPath;
  final String dataDescription;
  final Widget Function(OnGameCognitionFinish onFinish, OnGameResetControl onResetControlChange)?
      gameBuild;

  bool get isVideo => dataType == 'video';

  bool get isImage => dataType == 'image';

  bool get isGame => gameBuild != null && dataType == 'game';

  AssessData({
    required this.id,
    required this.dataType,
    required this.dataList,
    required this.dataPath,
    required this.dataDescription,
    this.gameBuild,
  });

  factory AssessData.fromJson(Map<String, dynamic> json) => AssessData(
        id: json["id"] ?? '',
        dataType: json["data_type"] ?? '',
        dataList: json["data_list"] != null && json["data_list"].isNotEmpty
            ? List<String>.from(json["data_list"].map((x) => x))
            : [],
        dataPath: json["data_path"] ?? '',
        dataDescription: json["data_description"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "data_type": dataType,
        "data_list": List<dynamic>.from(dataList.map((x) => x)),
        "data_path": dataPath,
        "data_description": dataDescription,
      };
}
