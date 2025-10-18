class Channels {
  List<Channel> data;
  int? page;

  Channels({this.page, required this.data});

  factory Channels.fromJson(Map<String, dynamic> json) => Channels(
        page: json["page"],
        data: json["data_info"] == null
            ? []
            : List<Channel>.from(
                json["data_info"]!.map((item) => Channel.fromJson(item))),
      );
}

class Channel {
  Channel({
    required this.channelName,
    required this.data,
    required this.max,
    required this.min,
  });

  String channelName;
  List<double> data;
  double max;
  double min;

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
        channelName: json["channel"] ?? '',
        data: json["data"] == null
            ? []
            : List<double>.from(json["data"]!.map((x) => x.toDouble())),
        max: json["max"]?.toDouble() ?? 0,
        min: json["min"]?.toDouble() ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Channel &&
          runtimeType == other.runtimeType &&
          channelName == other.channelName;

  @override
  int get hashCode => channelName.hashCode;
}
