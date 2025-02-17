class Channels {
  List<Channel> data;
  int? page;

  Channels({this.page, required this.data});

  factory Channels.fromJson(Map<String, dynamic> json) => Channels(
        page: json["page"],
        data: json["data"] == null
            ? []
            : List<Channel>.from(
                json["data"]!.map((item) => Channel.fromJson(item))),
      );
}

class Channel {
  Channel({
    required this.channel,
    required this.channelName,
    required this.data,
    required this.max,
    required this.min,
  });

  int channel;
  String? channelName;
  List<double> data;
  double max;
  double min;

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
        channel: json["channel"] ?? 0,
        channelName: json["channel_name"],
        data: json["data"] == null
            ? []
            : List<double>.from(json["data"]!.map((x) => x.toDouble())),
        max: json["max"]?.toDouble() ?? 0,
        min: json["min"]?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "channel": channel,
        "channel_name": channelName,
        "data": data,
        "max": max,
        "min": min,
      };
}
