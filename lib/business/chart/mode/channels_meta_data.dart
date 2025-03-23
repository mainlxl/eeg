class ChannelMeta {
  String? dataId;
  String? dataType;
  int patientEvaluationId;
  String? description;
  List<String>? channels;
  int totalSecond;

  String get channelJoin => channels?.join(',') ?? '';

  ChannelMeta({
    required this.dataId,
    required this.dataType,
    required this.patientEvaluationId,
    this.description,
    required this.channels,
    this.totalSecond = 0,
  }) {
    // 数据验证: 可以根据需要添加字段的检验逻辑
    if (dataId == null || dataId!.isEmpty) {
      throw ArgumentError('data_id cannot be null or empty');
    }
    // 可以添加更多的验证逻辑
  }

  // 从 JSON 创建 ChannelMeta 实例
  factory ChannelMeta.fromJson(Map<String, dynamic> json) {
    return ChannelMeta(
      dataId: json['data_id'] as String?,
      dataType: json['data_type'] as String?,
      description: json['description'] as String?,
      patientEvaluationId: json['patient_evaluation_id'] as int? ?? 0,
      totalSecond: json['second'] as int? ?? 0,
      channels: (json['channels'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList(),
    );
  }

  // 将 ChannelMeta 实例转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'data_id': dataId,
      'data_type': dataType,
      'description': description,
      'channels': channels,
      'second': totalSecond,
    };
  }

  // 从 JSON 列表创建 ChannelMeta 实例列表
  static List<ChannelMeta> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => ChannelMeta.fromJson(json)).toList();
  }

  // 将 ChannelMeta 实例列表转换为 JSON 列表
  static List<Map<String, dynamic>> listToJson(
      List<ChannelMeta> channelMetaList) {
    return channelMetaList.map((channelMeta) => channelMeta.toJson()).toList();
  }

  // Override == 和 hashCode
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChannelMeta &&
          runtimeType == other.runtimeType &&
          dataId == other.dataId;

  @override
  int get hashCode => dataId.hashCode;

  @override
  String toString() {
    return 'ChannelMeta{data_id: $dataId, data_type: $dataType, description: $description, channels: $channels}';
  }
}
