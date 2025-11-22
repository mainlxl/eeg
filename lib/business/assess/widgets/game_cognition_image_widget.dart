import 'dart:math';

import 'package:eeg/business/assess/mode/assess_data.dart';
import 'package:eeg/business/assess/widgets/game_cognition_color_widget.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:flutter/material.dart';

class GameCognitionImageWidget extends StatefulWidget {
  final int count;
  final OnGameCognitionFinish onFinish;
  final OnGameResetControl? onResetControlChange;
  final bool isStart;

  static AssessData createAssessData() => AssessData(
        id: 'GameCognitionImageWidget',
        dataType: 'game',
        dataList: ['图片记忆'],
        dataPath: '',
        dataDescription: '',
        gameBuild: (finish, onResetControl) => GameCognitionImageWidget(
            onFinish: finish, onResetControlChange: onResetControl),
      );

  const GameCognitionImageWidget(
      {super.key,
      this.count = 30,
      required this.onFinish,
      this.onResetControlChange,
      this.isStart = false});

  @override
  State<StatefulWidget> createState() => _GameCognitionNumberWidgetState();
}

class _GameCognitionNumberWidgetState extends State<GameCognitionImageWidget> {
  late bool _isStart = widget.isStart;
  late _Topic _currentItem;
  int _currentCount = 0;
  int _correctCount = 0;
  final List<String> images = [
    'images/assess/1.png',
    'images/assess/2.png',
    'images/assess/3.png',
    'images/assess/4.png',
    'images/assess/5.png',
    'images/assess/6.png',
    'images/assess/7.png',
    'images/assess/8.png',
    'images/assess/9.png',
    'images/assess/10.png',
    'images/assess/11.png',
    'images/assess/12.png',
    'images/assess/13.png',
    'images/assess/14.png',
    'images/assess/15.png',
    'images/assess/16.png',
    'images/assess/17.png',
    'images/assess/18.png',
    'images/assess/19.png',
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
            child:
                _buildOptionItem(_currentItem.imageIndex, allowClick: false)),
        const SizedBox(height: 10),
        Center(
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: '提示:根据回忆点击'),
              TextSpan(
                text: '上一张',
                style: TextStyle(
                  color: highlightColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(text: '图片'),
            ]),
            style: TextStyle(
                fontSize: 18, color: textColor, fontWeight: FontWeight.w400),
          ),
        ),
        // 当前题目，允许点击
        const SizedBox(height: 30),
        if (_isStart && _currentItem.options.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 30,
            children: List.generate(_currentItem.options.length,
                (index) => _buildOptionItem(_currentItem.options[index])),
          ),
        if (!_isStart)
          Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 16),
              child: Text('请记住第一张图片后点击开始',
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

  Widget _buildOptionItem(int imageIndex, {bool allowClick = true}) {
    final borderRadius = BorderRadius.circular(15);
    return TextButton(
      onPressed: allowClick ? () => _onClickItem(imageIndex) : null,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
      child: Image.asset(
        images[imageIndex],
        width: 120,
        height: 120,
        fit: BoxFit.fill,
      ),
    );
  }

  void _onClickItem(int index) {
    var previous = _currentItem.previous;
    if (previous == null) {
      return;
    }
    final isCorrect = previous.imageIndex == index;
    if (isCorrect) {
      _correctCount++;
    } else {}
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
      _currentItem = _Topic(imageIndex: 0, options: []);
    } else {
      if (_currentCount < widget.count) {
        _currentCount++;
      }
    }
    final previousIndex = previous?.imageIndex ?? 0;
    final excludes = {previousIndex};
    final titleIndex = _getRandomImageIndex(excludes);
    excludes.add(previousIndex);
    final options = [previousIndex];
    while (options.length < 4) {
      final index = _getRandomImageIndex(excludes);
      excludes.add(index);
      options.add(index);
    }
    options.shuffle();
    setState(() {
      _currentItem =
          _Topic(imageIndex: titleIndex, options: options, previous: previous);
    });
  }

  void _reset([bool isStart = false]) {
    _isStart = isStart;
    _nextItem(reset: true, previous: _isStart ? _currentItem : null);
  }

  void _onClickStart() => _reset(true);

  void _onClickReset() => _reset(false);

  int _getRandomImageIndex([Set<int> excludes = const {}]) {
    int newIndex;
    do {
      newIndex = Random().nextInt(images.length);
    } while (excludes.contains(newIndex));
    return newIndex;
  }
}

class _Topic {
  final int imageIndex;
  final List<int> options;
  _Topic? previous;

  _Topic({
    required this.imageIndex,
    required this.options,
    this.previous,
  });
}
