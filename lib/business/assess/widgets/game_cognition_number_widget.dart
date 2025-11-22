import 'dart:math';

import 'package:eeg/business/assess/mode/assess_data.dart';
import 'package:eeg/business/assess/widgets/game_cognition_color_widget.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:flutter/material.dart';

class GameCognitionNumberWidget extends StatefulWidget {
  final int count;
  final OnGameCognitionFinish onFinish;
  final OnGameResetControl? onResetControlChange;
  final bool isStart;

  static AssessData createAssessData() => AssessData(
        id: 'GameCognitionNumberWidget',
        dataType: 'game',
        dataList: ['数字计算'],
        dataPath: '',
        dataDescription: '',
        gameBuild: (finish, onResetControl) => GameCognitionNumberWidget(
            onFinish: finish, onResetControlChange: onResetControl),
      );

  const GameCognitionNumberWidget(
      {super.key,
      this.count = 30,
      required this.onFinish,
      this.onResetControlChange,
      this.isStart = false});

  @override
  State<StatefulWidget> createState() => _GameCognitionNumberWidgetState();
}

class _GameCognitionNumberWidgetState extends State<GameCognitionNumberWidget> {
  late bool _isStart = widget.isStart;
  late _Topic _currentItem;
  int _currentCount = 0;
  int _correctCount = 0;
  final List<int> options = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

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
              TextSpan(text: '提示:根据提示点击'),
              TextSpan(
                text: '上1题结果',
                style: TextStyle(
                  color: highlightColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(text: '的结果'),
            ]),
            style: TextStyle(
                fontSize: 18, color: textColor, fontWeight: FontWeight.w400),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            '${_currentItem.num1} + ${_currentItem.num2} = ?',
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: 30),
        if (_isStart)
          Center(
            child: SizedBox(
              width: 520,
              child: Wrap(
                spacing: 30,
                runSpacing: 30,
                children: List.generate(
                    options.length, (index) => _buildOptionItem(index)),
              ),
            ),
          ),
        if (!_isStart)
          Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 16),
              child: Text('记住计算结果后再点击开始按钮',
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

  Widget _buildOptionItem(int index, {bool allowClick = true}) {
    final borderRadius = BorderRadius.circular(15);
    return SizedBox(
      width: 80,
      height: 80,
      child: FilledButton(
        onPressed: allowClick ? () => _onClickItem(index) : null,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.all(10),
          backgroundColor: Color(0xff29BD59),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: Text(
          '${options[index]}',
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _onClickItem(int index) {
    var previous = _currentItem.previous;
    if (previous == null) {
      return;
    }
    final isCorrect = (previous.num1 + previous.num2) == options[index];
    if (isCorrect) {
      _correctCount++;
      // '正确'.toast;
    } else {
      // '错误'.toast;
    }
    if (_isStart && _currentCount + 1 >= widget.count) {
      widget.onFinish.call(_correctCount, widget.count);
      _reset(true);
      return;
    }
    _nextItem(previous: _currentItem);
  }

  //彩色色词的颜色选出对应的汉字 题目生成
  void _nextItem({bool reset = false, _Topic? previous}) {
    if (reset) {
      _currentCount = 0;
      _correctCount = 0;
      final num1 = Random().nextInt(11);
      final num2 = Random().nextInt((10 - num1).clamp(0, 10));
      _currentItem = _Topic(num1: num1, num2: num2);
    } else {
      if (_currentCount < widget.count) {
        _currentCount++;
      }
    }
    final num1 = Random().nextInt(10);
    final num2 = Random().nextInt(10 - num1);
    setState(() {
      _currentItem = _Topic(num1: num1, num2: num2, previous: previous);
    });
  }

  void _reset([bool isStart = false]) {
    _isStart = isStart;
    _nextItem(reset: true, previous: _isStart ? _currentItem : null);
  }

  void _onClickStart() => _reset(true);

  void _onClickReset() => _reset(false);
}

class _Topic {
  final int num1;
  final int num2;
  _Topic? previous;

  _Topic({
    required this.num1,
    required this.num2,
    this.previous,
  });
}
