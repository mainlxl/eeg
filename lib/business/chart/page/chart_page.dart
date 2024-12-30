import 'package:flutter/material.dart';

class EegLineChart extends StatefulWidget {
  final int totalPoints; // 总点数
  final int totalLine; // 总行数
  final int pointSpacing; // 数据点之间的间隔
  List<List<double>> data = [[]];

// 构造函数
  EegLineChart({
    this.pointSpacing = 3,
    required this.data,
  })  : totalLine = data.length,
        totalPoints = data.isNotEmpty ? data[0].length : 0; // 总点数

  @override
  _EegLineChartState createState() => _EegLineChartState();
}

class _EegLineChartState extends State<EegLineChart> {
  final ScrollController _scrollController = ScrollController();
  int scrollOffset = 0; // 当前滚动的偏移量

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        int maxOffset = (widget.totalPoints * widget.pointSpacing).toInt();
        scrollOffset = _scrollController.offset.ceil().clamp(0, maxOffset);
      });
    });
  }

  /// 生成数据，并补齐范围内的数据
  List<double> generateData(int line, int startIndex, int count) {
    return widget.data[line].sublist(startIndex, count);
  }

  @override
  Widget build(BuildContext context) {
    double canvasWidth = (widget.totalPoints * widget.pointSpacing).toDouble();
    return LayoutBuilder(builder: (context, constraints) {
      var maxWidth = constraints.maxWidth;
      var maxHeight = constraints.maxHeight;
      int countByWidth = (maxWidth / widget.pointSpacing).ceil();
      double lineHeight = maxHeight / widget.totalLine;
      return SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: List.generate(
                widget.totalLine,
                (index) => CustomPaint(
                  size: Size(canvasWidth, lineHeight),
                  painter: LineChartPainter(
                    visibleData: generateData(
                      index,
                      (scrollOffset / widget.pointSpacing).floor(),
                      countByWidth,
                    ),
                    minData: 0,
                    maxData: 100,
                    scrollOffset: scrollOffset,
                    pointSpacing: widget.pointSpacing,
                    countByWidth: countByWidth,
                    drawCoordinates: index == (widget.totalLine - 1),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> visibleData;
  final double maxData;
  final double minData;
  final int scrollOffset;
  final int pointSpacing;
  final int countByWidth;
  final bool drawCoordinates;

  final Paint linePaint = Paint()
    ..color = Colors.blue
    ..strokeWidth = 2.0;

  final Paint pointPaint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.fill;

  LineChartPainter({
    required this.visibleData,
    required this.maxData,
    required this.minData,
    required this.scrollOffset,
    required this.pointSpacing,
    required this.countByWidth,
    this.drawCoordinates = false,
  });

  double mapYValueToPixel(double value, double height) {
    double normalized = (value - minData) / (maxData - minData);
    return height * (1 - normalized);
  }

  @override
  void paint(Canvas canvas, Size size) {
    int startIndex = (scrollOffset / pointSpacing).floor();
    for (int i = 0; i < visibleData.length - 1; i++) {
      double x1 = (i * pointSpacing).toDouble();
      double y1 = mapYValueToPixel(visibleData[i], size.height);
      double x2 = ((i + 1) * pointSpacing).toDouble();
      double y2 = mapYValueToPixel(visibleData[i + 1], size.height);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
      canvas.drawCircle(Offset(x1, y1), 3.0, pointPaint);

      if (drawCoordinates && (i % 20 == 0)) {
        double y = size.height + 10;
        canvas.drawCircle(Offset(x1, y), 3, pointPaint);

        TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: (visibleData[i]).toStringAsFixed(1),
            style: TextStyle(color: Colors.black, fontSize: 10),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x1 - textPainter.width / 2, y + 5));
      }
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return oldDelegate.visibleData != visibleData ||
        oldDelegate.scrollOffset != scrollOffset;
  }
}
