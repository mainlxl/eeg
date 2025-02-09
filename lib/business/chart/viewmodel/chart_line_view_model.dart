import 'dart:convert';

import 'package:eeg/business/chart/mode/channel_page_data.dart';
import 'package:eeg/common/widget/slider_dialog.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

class ChartLineViewModel extends BaseViewModel {
  final ScrollController scrollHorizontalController = ScrollController();
  final ScrollController scrollVerticalController = ScrollController();

  get scrollOffset => scrollHorizontalController.hasClients
      ? scrollHorizontalController.offset
      : 0;

  bool _forceHorezentalScrell = false;

  set forceHorezentalScrell(bool value) {
    if (value != _forceHorezentalScrell) {
      _forceHorezentalScrell = value;
      notifyListeners();
    }
  }

  bool get isHorezentalScrell =>
      _forceHorezentalScrell ||
      (scrollHorizontalController.hasClients
          ? scrollHorizontalController.position.isScrollingNotifier.value
          : false);

  int totalPoints = 0;
  int totalLine = 0;
  double? lineTargetHeight;
  Channels? channels;
  int pointGap = 3;
  double lineHeightMin = 30;
  double lineHeightMax = 300;

  double get canvasWidth => (totalPoints * pointGap).toDouble();

  @override
  void init() async {
    super.init();
    scrollHorizontalController.addListener(notifyListeners);
    _loadData();
  }

  Future<void> _loadData() async {
    showLoading();
    notifyListeners();
    var resData = await loadFileFromAssets();
    final status = resData['status'] as int? ?? -1;
    var chanelPageData = resData['data'] as Map<String, dynamic>?;
    Channels channelsData = Channels.fromJson(chanelPageData!);
    var channels = channelsData.data;
    channels[2].data[500] = 500;
    for (int i = 0; i < 128; i++) {
      channels.add(channels[i % 3]);
    }
    totalLine = channels.length;
    totalPoints = channels.isEmpty
        ? 0
        : channels
            .reduce((curr, next) =>
                curr.data.length > next.data.length ? curr : next)
            .data
            .length;
    this.channels = channelsData;
    hideLoading();
    notifyListeners();
  }

  @override
  void dispose() {
    scrollHorizontalController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> loadFileFromAssets() async {
    try {
      var loadString = await rootBundle.loadString('assets/data.json');
      return json.decode(loadString);
    } catch (e) {
      return {};
    }
  }

  void onClickChangeHeight() {
    lineTargetHeight ??= lineHeightMin;
    var sliderDialog = SliderDialog(
        value: lineTargetHeight!,
        title: '请滑动选择通道[高度]',
        min: 10,
        max: 1000,
        onChanged: (size) {
          lineTargetHeight = size;
          notifyListeners();
        });
    sliderDialog.addSelectValueAction([
      10,
      30,
      50,
      100,
      200,
    ]);
    sliderDialog.show(context);
  }

  void onClickChangeWidth() {
    SliderDialog(
        value: pointGap.toDouble(),
        title: '请滑动选择通道[横坐标间隔]',
        min: 1,
        max: 150,
        onChanged: (size) {
          pointGap = size.ceil();
          notifyListeners();
        })
      ..addSelectValueAction([1, 2, 3, 5, 10, 30])
      ..show(context);
  }
}
