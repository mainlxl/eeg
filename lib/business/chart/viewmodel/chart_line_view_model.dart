import 'dart:convert';
import 'dart:math';

import 'package:eeg/business/chart/mode/channel_page_data.dart';
import 'package:eeg/business/chart/mode/channels_meta_data.dart';
import 'package:eeg/business/chart/widget/algorithm_dialog.dart';
import 'package:eeg/business/chart/widget/channel_filter_dialog.dart';
import 'package:eeg/common/widget/slider_dialog.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:eeg/core/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class ChartLineViewModel extends BaseViewModel {
  bool loading = true;

  bool get pageError => !loading && channels == null;
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
  List<Channel> channels = [];
  int pointGap = 3;
  double lineHeightMin = 30;
  double lineHeightMax = 300;
  ChannelMeta channelMeta;
  int _dataSecond = 0;
  int _page_size = 3;

  bool get _hasMore => _dataSecond < channelMeta.second;

  int get _nextPage => (_dataSecond / _page_size).toInt() + 1;

  bool _isLoadingMore = false;

  ChartLineViewModel(this.channelMeta);

  double get canvasWidth => (totalPoints * pointGap).toDouble();

  @override
  void init() async {
    super.init();
    scrollHorizontalController.addListener(onScrollHorizontal);
    initData();
  }

  /// page_size 页数据大小 10为10秒数据
  Future<void> initData() async {
    var rawloadData = await _rawloadData(
        page_size: min(channelMeta.second - _dataSecond, _page_size), page: 1);
    if (rawloadData != null && rawloadData.data.isNotEmpty) {
      this.channels = rawloadData.data;
      totalLine = channels.length;
      totalPoints = channels.isEmpty
          ? 0
          : channels
              .reduce((curr, next) =>
                  curr.data.length > next.data.length ? curr : next)
              .data
              .length;
      _dataSecond = _page_size;
      this.loading = false;
      notifyListeners();
    } else {
      this.loading = false;
      notifyListeners();
    }
  }

  Future<Channels?> _rawloadData(
      {required int page, required int page_size}) async {
    var response = await HttpService.post('/api/v1/eeg-data', data: {
      "data_id": channelMeta.data_id,
      "page": page,
      "drop_rate": 1,
      "page_size": page <= 1 ? _page_size * 3 : _page_size, //第一次请求3页
      "data_type": channelMeta.data_type,
      "channels": channelMeta.channelJoin
    });
    if (response.ok && response.data != null) {
      Channels channelsData = Channels.fromJson(response.data!);
      return channelsData;
    }
    return null;
  }

  // Future<void> _loadFileFromAssets() async {
  //   showLoading();
  //   notifyListeners();
  //   var resData = await loadFileFromAssets();
  //   final status = resData['status'] as int? ?? -1;
  //   var chanelPageData = resData['data'] as Map<String, dynamic>?;
  //   Channels channelsData = Channels.fromJson(chanelPageData!);
  //   var channels = channelsData.data;
  //   channels[2].data[500] = 500;
  //   for (int i = 0; i < 128; i++) {
  //     channels.add(channels[i % 3]);
  //   }
  //   totalLine = channels.length;
  //   totalPoints = channels.isEmpty
  //       ? 0
  //       : channels
  //           .reduce((curr, next) =>
  //               curr.data.length > next.data.length ? curr : next)
  //           .data
  //           .length;
  //   this.channels = channelsData;
  //   hideLoading();
  //   notifyListeners();
  // }

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

  void onClickChannelFilter() {
    ChannelFilterDialog(channelMeta: channelMeta).show(context);
  }

  void onClickAlgorithm() {
    AlgorithmDialog(
            channelMeta: channelMeta, onClickOneKey: onClickOneKeyAlgorithm)
        .show(context);
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

  void onClickHelp() {
    SmartDialog.showToast('''
类型: ${channelMeta.data_type}
数据id: ${channelMeta.data_id}
通道: ${channelMeta.channels}

Tips:       
      1.鼠标横向滚动查看: 按住[shift]+键拨动滚轮
      2.支持按住拖动
        ''',
        displayTime: const Duration(seconds: 3), alignment: Alignment.center);
  }

  void onScrollHorizontal() {
    final position = scrollHorizontalController.position;
    // 当滚动到距离底部 200 像素时触发加载

    if (scrollHorizontalController.hasClients) {
      var position = scrollHorizontalController.position;
      if (position.pixels >= position.maxScrollExtent &&
          !_isLoadingMore &&
          _hasMore) {
        _isLoadingMore = true;
        _loadMoreData();
      }
    }
    notifyListeners();
  }

  void _loadMoreData() async {
    showLoading();
    var rawloadData =
        await _rawloadData(page_size: _page_size, page: _nextPage);
    if (rawloadData != null && rawloadData.data.isNotEmpty) {
      this.channels = mergeChannels(this.channels, rawloadData.data);
      totalLine = channels.length;
      totalPoints = channels.isEmpty
          ? 0
          : channels
              .reduce((curr, next) =>
                  curr.data.length > next.data.length ? curr : next)
              .data
              .length;
      _dataSecond += _page_size;
      _isLoadingMore = false;
      notifyListeners();
      hideLoading();
    } else {
      _isLoadingMore = false;
      hideLoading();
    }
  }

  List<Channel> mergeChannels(List<Channel> list1, List<Channel> list2) {
    Map<int, Channel> channelMap = {};

    // 遍历第一个列表，将元素添加到 Map 中
    for (var channel in list1) {
      channelMap[channel.channel] = channel;
    }

    // 遍历第二个列表，检查是否已经存在于 Map 中
    for (var channel in list2) {
      if (channelMap.containsKey(channel.channel)) {
        // 合并 data 列表
        var existingChannel = channelMap[channel.channel];

        existingChannel!.data.addAll(channel.data);
        // 计算新的 max 和 min
        existingChannel.max = existingChannel.max > channel.max
            ? existingChannel.max
            : channel.max;
        existingChannel.min = existingChannel.min < channel.min
            ? existingChannel.min
            : channel.min;
      } else {
        // 如果不存在，则添加到 Map 中
        channelMap[channel.channel] = channel;
      }
    }

    // 返回合并后的结果
    return channelMap.values.toList();
  }

  void onClickOneKeyAlgorithm() {
    '一键应用算法'.toast;
  }
}
