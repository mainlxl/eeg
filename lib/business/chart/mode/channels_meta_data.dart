class ChannelMeta {
  String? data_id;
  String? data_type;
  String? description;
  List<String>? channels;
  int second;

  String get channelJoin => channels?.join(',') ?? '';

  ChannelMeta({
    this.data_id,
    this.data_type,
    this.description,
    this.channels,
    this.second = 0,
  }) {
    // 数据验证: 可以根据需要添加字段的检验逻辑
    if (data_id == null || data_id!.isEmpty) {
      throw ArgumentError('data_id cannot be null or empty');
    }
    // 可以添加更多的验证逻辑
  }

  // 从 JSON 创建 ChannelMeta 实例
  factory ChannelMeta.fromJson(Map<String, dynamic> json) {
    return ChannelMeta(
      data_id: json['data_id'] as String?,
      data_type: json['data_type'] as String?,
      description: json['description'] as String?,
      second: json['second'] as int? ?? 0,
      channels: (json['channels'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList(),
    );
  }

  // 将 ChannelMeta 实例转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'data_id': data_id,
      'data_type': data_type,
      'description': description,
      'channels': channels,
      'second': second,
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
          data_id == other.data_id;

  @override
  int get hashCode => data_id.hashCode;

  // copyWith 方法
  ChannelMeta copyWith({
    String? data_id,
    String? data_type,
    String? description,
    List<String>? channels,
  }) {
    return ChannelMeta(
      data_id: data_id ?? this.data_id,
      data_type: data_type ?? this.data_type,
      description: description ?? this.description,
      channels: channels ?? this.channels,
    );
  }

  @override
  String toString() {
    return 'ChannelMeta{data_id: $data_id, data_type: $data_type, description: $description, channels: $channels}';
  }
}
