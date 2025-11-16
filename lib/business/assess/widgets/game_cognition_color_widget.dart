import 'dart:math';

import 'package:eeg/business/assess/mode/assess_data.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:eeg/core/utils/toast.dart';
import 'package:flutter/material.dart';

typedef OnGameCognitionFinish = void Function(int correctCount, int count);
typedef OnGameResetControl = void Function(VoidCallback reset);

class GameCognitionColorWidget extends StatefulWidget {
  final int count;
  final OnGameCognitionFinish onFinish;
  final OnGameResetControl? onResetControlChange;
  final bool isStart;

  static AssessData createAssessData() => AssessData(
        id: 'GameCognitionColorWidget',
        dataType: 'game',
        dataList: ['颜色认知'],
        dataPath: '',
        dataDescription: '',
        gameBuild: (finish, onResetControl) => GameCognitionColorWidget(
            onFinish: finish, onResetControlChange: onResetControl),
      );

  const GameCognitionColorWidget(
      {super.key,
      this.count = 60,
      required this.onFinish,
      required this.onResetControlChange,
      this.isStart = false});

  @override
  State<StatefulWidget> createState() => _GameCognitionColorWidgetState();
}

class _GameCognitionColorWidgetState extends State<GameCognitionColorWidget> {
  late bool _isStart = widget.isStart;
  late _Topic _currentItem;
  int _currentCount = 0;
  int _correctCount = 0;
  final List<String> _words = ['红', '绿', '蓝', '黄', '黑'];

  final List<Color> _wordsColor = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow.shade600,
    Colors.black,
    Colors.purple,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void didChangeDependencies() {
    widget.onResetControlChange?.call(_reset);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: 50,
          child: Text.rich(
            _isStart
                ? TextSpan(text: '任务进行中……')
                : TextSpan(children: [
                    TextSpan(text: '任务要求：请根据第一行彩色色词的'),
                    TextSpan(
                        text: '颜色', style: TextStyle(color: highlightColor)),
                    TextSpan(text: '选出对应的汉字(共 '),
                    TextSpan(
                      text: '${widget.count}',
                      style: TextStyle(color: highlightColor),
                    ),
                    TextSpan(text: ' 个）。'),
                  ]),
            style: TextStyle(fontSize: 18),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '您已完成题目个数：$_currentCount/${widget.count}',
              style: TextStyle(fontSize: 18),
            ),
            // if (!widget.isStart)
            //   TextButton(
            //       onPressed: _onClickReset,
            //       child: Text('reset',
            //           style: TextStyle(color: Colors.red, fontSize: 18))),
          ],
        ),
        const SizedBox(height: 10),
        Center(
            child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: '提示:根据'),
                  TextSpan(
                      text: '颜色',
                      style: TextStyle(
                          color: highlightColor, fontWeight: FontWeight.w500)),
                  TextSpan(text: '选汉字'),
                ]),
                style: TextStyle(
                    fontSize: 18,
                    color: textColor,
                    fontWeight: FontWeight.w400))),
        const SizedBox(height: 10),
        Container(
            alignment: Alignment.center,
            child: _buildOptionItem(
              0,
              _currentItem.titleOption,
              allowClick: false,
            )),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            _currentItem.options.length,
            (index) => _buildOptionItem(index, _currentItem.options[index]),
          ),
        ),
        if (!_isStart)
          Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 16),
              child: Text('开启时前可以尝试点击几个试下',
                  style: TextStyle(fontSize: 18, color: subtitleColor))),
        if (!_isStart)
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 20),
            child: FilledButton(
              onPressed: _onClickStart,
              style: FilledButton.styleFrom(
                backgroundColor: Color(0xff29BD59),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: const Text('开始测试', style: TextStyle(fontSize: 20)),
            ),
          ),
      ],
    );
  }

  Widget _buildOptionItem(int index, _Option option, {bool allowClick = true}) {
    final borderRadius = BorderRadius.circular(15);
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
      ),
      child: TextButton(
        onPressed: allowClick ? () => _onClickItem(index) : null,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: Text(
          _words[option.textIndex],
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.w900,
            color: _wordsColor[option.colorIndex],
          ),
        ),
      ),
    );
  }

  void _onClickItem(int index) {
    final isCorrect = (_currentItem.titleOption.colorIndex) ==
        (_currentItem.options[index].textIndex);
    if (!_isStart) {
      isCorrect ? '正确'.toast : '错误'.toast;
    }
    if (isCorrect) {
      _correctCount++;
    }
    if (_isStart && _currentCount + 1 >= widget.count) {
      widget.onFinish.call(_correctCount, widget.count);
      _reset(true);
      return;
    }
    _nextItem();
  }

  //彩色色词的颜色选出对应的汉字 题目生成
  void _nextItem({bool reset = false}) {
    if (reset) {
      _currentCount = 0;
      _correctCount = 0;
    } else {
      if (_currentCount < widget.count) {
        _currentCount++;
      }
    }
    Set<int> excludesText = {};
    Set<int> excludesColor = {};
    // 题目
    final correctTextIndex = _getRandomWordsIndex();
    final correctColorIndex = _getRandomWordsIndex();
    final titleOption = _Option(correctTextIndex, correctColorIndex);

    // 选项
    List<_Option> options = [];
    final randomColorIndex1 = _getRandomColorIndex(excludesColor);
    options.add(_Option(titleOption.colorIndex, randomColorIndex1));
    excludesText.add(titleOption.colorIndex);
    excludesColor.add(randomColorIndex1);

    while (options.length < 4) {
      final wordsIndex = _getRandomWordsIndex(excludesText);
      final colorIndex = _getRandomColorIndex(excludesColor);
      excludesText.add(wordsIndex);
      excludesColor.add(colorIndex);
      options.add(_Option(wordsIndex, colorIndex));
    }
    options.shuffle(Random());
    setState(() {
      _currentItem = _Topic(titleOption: titleOption, options: options);
    });
  }

  void _reset([bool isStart = false]) {
    if (mounted) {
      _isStart = isStart;
      _nextItem(reset: true);
    }
  }

  int _getRandomColorIndex([Set<int> excludes = const {}]) {
    int newIndex;
    do {
      newIndex = Random().nextInt(_wordsColor.length);
    } while (excludes.contains(newIndex));
    return newIndex;
  }

  int _getRandomWordsIndex([Set<int> excludes = const {}]) {
    int newIndex;
    do {
      newIndex = Random().nextInt(_words.length);
    } while (excludes.contains(newIndex));
    return newIndex;
  }

  void _onClickStart() => _reset(true);

  void _onClickReset() => _reset(false);
}

class _Topic {
  final _Option titleOption;
  final List<_Option> options;

  _Topic({
    required this.titleOption,
    required this.options,
  });

  @override
  String toString() {
    return '{titleOption: $titleOption, options: $options}';
  }
}

class _Option {
  final int textIndex;
  final int colorIndex;

  _Option(this.textIndex, this.colorIndex);

  @override
  String toString() {
    return '{textIndex: $textIndex, colorIndex: $colorIndex}';
  }
}
