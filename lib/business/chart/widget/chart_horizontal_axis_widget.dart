import 'package:fluent_ui/fluent_ui.dart';

class HorizontalAxisChartPainter extends CustomPainter {
  final int maxShowCount;
  final double scrollOffset;
  final int pointGap;
  final Paint linePaint = Paint()
    ..color = Colors.blue
    ..strokeWidth = 2.0;

  final Paint pointPaint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.fill;

  HorizontalAxisChartPainter({
    required this.maxShowCount,
    required this.scrollOffset,
    required this.pointGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var offset = Offset(scrollOffset, 3);
    canvas.drawLine(offset, Offset(size.width, offset.dy), pointPaint);
    for (int i = 0; i < maxShowCount - 1; i++) {
      final double x = (i * pointGap) + scrollOffset;
      if (i % 20 == 0) {
        canvas.drawCircle(Offset(x, offset.dy), 3, pointPaint);
        TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: (x).toStringAsFixed(1),
            style: const TextStyle(color: Colors.black, fontSize: 10),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
            canvas,
            Offset(
                i == 0
                    ? x - textPainter.width / 2 + 8
                    : x - textPainter.width / 2,
                offset.dy + 5));
      }
    }
  }

  @override
  bool shouldRepaint(covariant HorizontalAxisChartPainter oldDelegate) {
    return oldDelegate.scrollOffset != scrollOffset ||
        oldDelegate.maxShowCount != maxShowCount;
  }
}
