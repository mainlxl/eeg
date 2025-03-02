import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef OnExpandableChange = void Function(bool isExpanded);

class SelectableExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle textStyle;
  final String linkTextExpand;
  final String linkTextCollapse;
  final Color linkTextColor;
  final bool? isExpanded;
  final OnExpandableChange? onExpandableChange;

  const SelectableExpandableText(
      {super.key,
      required this.text,
      this.maxLines = 2,
      this.isExpanded,
      this.onExpandableChange,
      this.textStyle = const TextStyle(color: Colors.black),
      this.linkTextColor = Colors.blue,
      this.linkTextExpand = " 展开",
      this.linkTextCollapse = " 收起"});

  @override
  State<StatefulWidget> createState() => _SelectableExpandableTextState();
}

class _SelectableExpandableTextState extends State<SelectableExpandableText> {
  bool _isExpanded = false;

  bool get isExpanded => widget.isExpanded ?? _isExpanded;
  late TextSpan expandSpan;
  late TextSpan linkTextSpan;

  @override
  void initState() {
    super.initState();
    expandSpan = TextSpan(
      text: widget.linkTextExpand,
      style: TextStyle(color: widget.linkTextColor),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          _isExpanded = !isExpanded;
          widget.onExpandableChange?.call(_isExpanded);
          setState(() {});
        },
    );

    linkTextSpan = TextSpan(
      text: '...',
      style: widget.textStyle,
      children: [expandSpan],
    );
  }

  /// 构建折叠状态下的文本
  Widget _buildCollapsedText(double maxWidth) {
    var selectionControls = CupertinoTextSelectionControls();
    // TODO 暂时没研究明白SelectableText内部的宽度问题
    maxWidth -= selectionControls.getHandleSize(0).width * widget.maxLines * 4;
    var truncatedText = widget.text;
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: widget.textStyle,
      ),
      maxLines: widget.maxLines,
      textScaler: TextScaler.noScaling,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);
    if (textPainter.didExceedMaxLines) {
      // // 文本的长度超过了最大行数，需要截取然后拼接展开部分的逻辑
      final linkPainter = TextPainter(
        text: linkTextSpan,
        maxLines: 1,
        textScaler: TextScaler.noScaling,
        textDirection: TextDirection.ltr,
      );
      linkPainter.layout();
      final end = textPainter
          .getPositionForOffset(Offset(maxWidth, textPainter.height))
          .offset;
      truncatedText = widget.text.substring(0, end);
    }

    return SelectableText.rich(
      TextSpan(
        text: truncatedText,
        children:
            widget.text.length == truncatedText.length ? [] : [linkTextSpan],
      ),
      style: widget.textStyle,
      selectionControls: selectionControls,
      maxLines: widget.maxLines,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return widget.isExpanded ?? isExpanded
            ? _buildExpandedText()
            : _buildCollapsedText(constraints.maxWidth);
      },
    );
  }

  Widget _buildExpandedText() {
    final collapseSpan = TextSpan(
      text: widget.linkTextCollapse,
      style: TextStyle(color: widget.linkTextColor),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          _isExpanded = !isExpanded;
          widget.onExpandableChange?.call(_isExpanded);
          setState(() {});
        },
    );

    return SelectableText.rich(
      TextSpan(
        text: widget.text,
        style: widget.textStyle,
        children: [collapseSpan],
      ),
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle textStyle;
  final String linkTextExpand;
  final String linkTextCollapse;
  final Color linkTextColor;

  const ExpandableText(
      {super.key,
      required this.text,
      this.maxLines = 2,
      this.textStyle = const TextStyle(color: Colors.black),
      this.linkTextColor = Colors.blue,
      this.linkTextExpand = " 展开",
      this.linkTextCollapse = " 收起"});

  @override
  State<StatefulWidget> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;
  late TextSpan expandSpan;
  late TextSpan linkTextSpan;

  @override
  void initState() {
    super.initState();
    expandSpan = TextSpan(
      text: widget.linkTextExpand,
      style: TextStyle(color: widget.linkTextColor),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          setState(() {
            isExpanded = !isExpanded;
          });
        },
    );

    linkTextSpan = TextSpan(
      text: '...',
      style: widget.textStyle,
      children: [expandSpan],
    );
  }

  /// 检查文本是否溢出
  bool checkOverflow(double width) {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.textStyle),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
    );
    textPainter.layout(maxWidth: width);
    return textPainter.height >
        widget.maxLines * textPainter.preferredLineHeight;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final maxWidth = constraints.maxWidth;
        final textSpan = TextSpan(
          text: widget.text,
          style: widget.textStyle,
        );

        final textPainter = TextPainter(
          text: textSpan,
          maxLines: isExpanded ? null : widget.maxLines,
          textDirection: TextDirection.ltr,
          textScaler: TextScaler.noScaling,
        );
        textPainter.layout(maxWidth: maxWidth);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isExpanded
                ? _buildExpandedText()
                : _buildCollapsedText(textPainter, maxWidth),
          ],
        );
      },
    );
  }

  /// 构建折叠状态下的文本
  Widget _buildCollapsedText(TextPainter textPainter, double maxWidth) {
    var truncatedText = widget.text;
    if (checkOverflow(maxWidth)) {
      // 文本的长度超过了最大行数，需要截取然后拼接展开部分的逻辑
      final linkPainter = TextPainter(
        text: linkTextSpan,
        textDirection: TextDirection.ltr,
        textScaler: TextScaler.noScaling,
      );
      linkPainter.layout(maxWidth: maxWidth);
      final position = textPainter.getPositionForOffset(
          Offset(maxWidth - linkPainter.width, textPainter.height));
      final endOffset =
          textPainter.getOffsetBefore(position.offset) ?? position.offset;
      truncatedText = widget.text.substring(0, endOffset);
    }

    return RichText(
      text: TextSpan(
        text: truncatedText,
        style: widget.textStyle,
        children:
            widget.text.length == truncatedText.length ? [] : [linkTextSpan],
      ),
      maxLines: widget.maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 构建展开状态下的文本
  Widget _buildExpandedText() {
    final collapseSpan = TextSpan(
      text: widget.linkTextCollapse,
      style: TextStyle(color: widget.linkTextColor),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          setState(() {
            isExpanded = !isExpanded;
          });
        },
    );

    return RichText(
      text: TextSpan(
        text: widget.text,
        style: widget.textStyle,
        children: [collapseSpan],
      ),
    );
  }
}
