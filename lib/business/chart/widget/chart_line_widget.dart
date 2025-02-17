import 'package:eeg/business/chart/mode/channel_page_data.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:fluent_ui/fluent_ui.dart';

class ChannelLineChartPainter extends CustomPainter {
  final Channel data;
  late final int maxShowCount;
  double scrollOffset = 0;
  bool isScroll = false;
  final int pointGap;
  final double contentWidth;
  late final maxDifference = (data.max - data.min);
  final Paint linePaint = Paint()
    ..color = textColor.withOpacity(0.5)
    ..strokeWidth = 1.0;

  ChannelLineChartPainter({
    required this.data,
    required this.scrollOffset,
    this.isScroll = false,
    required this.pointGap,
    required this.contentWidth,
  }) {
    maxShowCount = (contentWidth / pointGap).ceil();
  }

  double mapYValueToPixel(double value, double height) {
    double normalized = (value - data.min) / maxDifference;
    return height * (1 - normalized);
  }

  @override
  void paint(Canvas canvas, Size size) {
    var channelData = data.data;
    var startIndex = (scrollOffset / pointGap).floor();
    var checkShowChannelName = (maxShowCount / 5).ceil();
    for (int i = 0; i < maxShowCount; i++) {
      var dataIndex = i + startIndex;
      var nextDataIndex = dataIndex + 1;
      if (startIndex < 0 ||
          startIndex >= channelData.length ||
          nextDataIndex >= channelData.length ||
          nextDataIndex < 0) {
        return;
      }
      final double x1 = (i * pointGap) + scrollOffset;
      final double y1 = mapYValueToPixel(channelData[dataIndex], size.height);
      final double x2 = ((i + 1) * pointGap) + scrollOffset;
      final double y2 =
          mapYValueToPixel(channelData[nextDataIndex], size.height);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
      if (!isScroll && i % checkShowChannelName == 0) {
        drawChannelName(canvas, size, Offset(x1, y1), i == 0);
      }
    }
    var paint = linePaint..color = Colors.grey.withOpacity(0.15);
    for (var i = scrollOffset; i < scrollOffset + contentWidth; i = i + 20) {
      canvas.drawLine(
          Offset(i, size.height), Offset(i + 5, size.height), paint);
    }
  }

  void drawChannelName(
      Canvas canvas, Size size, Offset position, bool isStart) {
    var channelName = data.channelName;
    if (channelName?.isNotEmpty == true) {
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: channelName,
          style: TextStyle(
              color: isStart ? textColor : subtitleColor, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
          canvas,
          Offset(
              isStart ? position.dx + 2 : position.dx - textPainter.width / 2,
              isStart
                  ? size.height / 2 - textPainter.height / 2
                  : position.dy));
    }
  }

  @override
  bool shouldRepaint(covariant ChannelLineChartPainter oldDelegate) => true;
}
