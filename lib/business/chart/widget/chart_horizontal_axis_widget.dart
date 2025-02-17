import 'package:fluent_ui/fluent_ui.dart';

class HorizontalAxisChartPainter extends CustomPainter {
  final int maxShowCount;
  final double scrollOffset;
  final double contentWidth;
  late final double pointGap;
  final Paint linePaint = Paint()
    ..color = Colors.blue
    ..strokeWidth = 2.0;

  final Paint pointPaint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.fill;

  HorizontalAxisChartPainter({
    required this.scrollOffset,
    required this.contentWidth,
    this.maxShowCount = 20,
  }) {
    pointGap = contentWidth / (maxShowCount - 1); // maxShowCount - 1 间隔数
  }

  @override
  void paint(Canvas canvas, Size size) {
    var offset = Offset(scrollOffset, 3);
    canvas.drawLine(
        offset, Offset(scrollOffset + contentWidth, offset.dy), pointPaint);
    for (int i = 0; i < maxShowCount; i++) {
      final double x = (i * pointGap) + scrollOffset;
      canvas.drawCircle(Offset(x, offset.dy), 3, pointPaint);
      // TextPainter textPainter = TextPainter(
      //   text: TextSpan(
      //     text: (x).toStringAsFixed(1),
      //     style: const TextStyle(color: Colors.black, fontSize: 10),
      //   ),
      //   textDirection: TextDirection.ltr,
      // );
      // textPainter.layout();
      // textPainter.paint(
      //     canvas,
      //     Offset(
      //         i == 0
      //             ? x + 2
      //             : (i == maxShowCount - 1
      //                 ? x - textPainter.width - 2
      //                 : x - textPainter.width / 2),
      //         offset.dy + 5));
    }
  }

  @override
  bool shouldRepaint(covariant HorizontalAxisChartPainter oldDelegate) {
    return oldDelegate.scrollOffset != scrollOffset ||
        oldDelegate.maxShowCount != maxShowCount;
  }
}
