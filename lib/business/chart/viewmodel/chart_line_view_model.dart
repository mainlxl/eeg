import 'dart:convert';
import 'dart:math';

import 'package:eeg/business/chart/dialog/channel_filter_dialog.dart';
import 'package:eeg/business/chart/dialog/features_algorithm_dialog.dart';
import 'package:eeg/business/chart/dialog/preprocessing_algorithm_dialog.dart';
import 'package:eeg/business/chart/mode/channel_alagorithm.dart';
import 'package:eeg/business/chart/mode/channel_page_data.dart';
import 'package:eeg/business/chart/mode/channels_meta_data.dart';
import 'package:eeg/business/chart/mode/preporcessing.dart';
import 'package:eeg/common/widget/loading_status_page.dart';
import 'package:eeg/common/widget/slider_dialog.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:eeg/core/utils/toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChartLineViewModel extends LoadingPageStatusViewModel {
  final ScrollController scrollHorizontalController = ScrollController();
  final ScrollController scrollVerticalController = ScrollController();
  double? lineTargetHeight;
  List<Channel> _channels = [];
  Map<String, bool> _channelsSelect = {};

  List<Channel> get channels {
    if (_channelsSelect.isEmpty) {
      return _channels;
    }
    return _channels
        .where((name) => _channelsSelect[name.channelName] ?? false)
        .toList();
  }

  set channels(List<Channel> value) {
    _channels = value;
    _channelsSelect = {};
  }

  int totalPoints = 0;
  int pointGap = 3;
  double lineHeightMin = 30;
  double lineHeightMax = 300;

  // 通道元数据
  ChannelMeta channelMeta;
  int _dataSecond = 0;
  int _page_size = 9;

  bool get _hasMore => _dataSecond < channelMeta.totalSecond;

  int get _nextPage => (_dataSecond / _page_size).toInt() + 1;
  bool _isLoadingMore = false;

  ChartLineViewModel(this.channelMeta);

  double get canvasWidth => (totalPoints * pointGap).toDouble();

  // 特征算法
  List<AlgorithmDatum>? algorithmDatumData;

  @override
  void init() async {
    super.init();
    scrollHorizontalController.addListener(onScrollHorizontal);
    initData();
  }

  @override
  void onClickRetryLoadingData() => initData();

  /// page_size 页数据大小 10为10秒数据
  void initData() async {
    setPageStatus(PageStatus.loading);
    var response = await _rawLoadData(
        page_size: min(channelMeta.totalSecond - _dataSecond, _page_size),
        page: 1);
    if (response.ok) {
      var dataSeg = response.data?['DataSeg'];
      if (dataSeg != null) {
        Channels channelsData = Channels.fromJson(dataSeg);
        _channels = channelsData.data;
        if (_channels.isEmpty) {
          setPageStatus(PageStatus.empty);
          return;
        }
        totalPoints = _channels.isEmpty
            ? 0
            : _channels
                .reduce((curr, next) =>
                    curr.data.length > next.data.length ? curr : next)
                .data
                .length;
        _dataSecond = _page_size;
        setPageStatus(PageStatus.loadingSuccess);
      } else {
        setPageStatus(PageStatus.empty);
      }
    } else {
      setPageStatus(PageStatus.error);
    }
  }

  int lastPage = 0;

  Future<ResponseData> _rawLoadData(
      {required int page, required int page_size}) async {
    lastPage = page;
    //第一次请求3页
    final data = {
      'patient_evalution_data': {
        "data_type": channelMeta.dataType,
        "data_id": channelMeta.dataId,
        "patient_evaluation_id": channelMeta.patientEvaluationId,
        'show_data_info': {
          "page": page,
          "drop_rate": 1,
          "page_size": 9,
          "channels": channelMeta.channelJoin,
        }
      }
    };
    // 如果有预处理算法 则捎带上
    final list = getPreporcessingParam();
    if (list.isNotEmpty) {
      data['patient_evalution_data']?['preprocess_algorithm'] = list.isNotEmpty
          ? List<dynamic>.from(list.map((x) => x.toJson()))
          : [];
    }
    return HttpService.post('/api/v2/data/detail', data: data);
  }

  //获取预处理算法参数
  List<PreporcessingAlgorithm> getPreporcessingParam() {
    if (usePreporcessingAlgorithm) {
      return preporcessingAlgorithmList
              ?.where((e) => e.checked)
              .where((e) => e.available())
              .toList() ??
          [];
    }
    return [];
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

  void onClickChannelFilter() async {
    if (_channelsSelect.isEmpty) {
      _channelsSelect = {
        for (var channel in _channels) channel.channelName: true
      };
    }
    await ChannelFilterDialog(channelSelect: _channelsSelect).show(context);
    notifyListeners();
  }

  // 特征算法
  void onClickFeaturesAlgorithm() {
    FeaturesAlgorithmDialog(
            parentViewModel: this, onClickOneKey: onClickOneKeyAlgorithm)
        .show(context);
  }

  // 预处理算法
  void onClickPreprocessingAlgorithm() async {
    PreprocessingAlgorithmDialog(
      parentViewModel: this,
    ).show(context);
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

  void onScrollHorizontal() {
    // final position = scrollHorizontalController.position;
    // // 当滚动到距离底部 200 像素时触发加载

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
    var response = await _rawLoadData(page_size: _page_size, page: _nextPage);
    if (response.ok && response.data?['DataSeg'] != null) {
      _channels = mergeChannels(
          _channels, Channels.fromJson(response.data?['DataSeg']).data);
      totalPoints = _channels.isEmpty
          ? 0
          : _channels
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
    Map<String, Channel> channelMap = {};

    // 遍历第一个列表，将元素添加到 Map 中
    for (var channel in list1) {
      channelMap[channel.channelName] = channel;
    }

    // 遍历第二个列表，检查是否已经存在于 Map 中
    for (var channel in list2) {
      if (channelMap.containsKey(channel.channelName)) {
        // 合并 data 列表
        var existingChannel = channelMap[channel.channelName];

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
        channelMap[channel.channelName] = channel;
      }
    }

    // 返回合并后的结果
    return channelMap.values.toList();
  }

  void onClickOneKeyAlgorithm() {
    '一键应用算法'.toast;
  }

//---------------------------------------------------------------------------

  // 上一次鼠标的位置
  Offset? lastMousePosition;
  VelocityTracker? velocityTracker;

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

  // 预处理算法
  bool _usePreporcessingAlgorithm = false;

  bool get usePreporcessingAlgorithm => _usePreporcessingAlgorithm;
  List<PreporcessingAlgorithm>? preporcessingAlgorithmList;

  // 应用预处理算法
  void applicationPreprocessingAlgorithm({required bool enable}) {
    _usePreporcessingAlgorithm = enable;
    initData();
  }

  void onPointerDown(PointerDownEvent event) {
    lastMousePosition = event.position;
    velocityTracker = VelocityTracker.withKind(event.kind);
  }

  // 鼠标移动事件
  void onPointerMove(PointerMoveEvent event, double maxScrollPositionX) {
    velocityTracker?.addPosition(event.timeStamp, event.position);
    final currentPosition = event.position;
    if (lastMousePosition != null) {
      var translateToX = (currentPosition.dx - lastMousePosition!.dx);
      var translateToY = (currentPosition.dy - lastMousePosition!.dy);
      translateToX = scrollHorizontalController.offset - translateToX;
      if (translateToX > 0 && translateToX <= maxScrollPositionX) {
        forceHorezentalScrell = true;
        scrollHorizontalController.jumpTo(translateToX);
      }
      if (translateToY != 0) {
        forceHorezentalScrell = true;
        scrollVerticalController
            .jumpTo(scrollVerticalController.offset - translateToY);
      }
    }
    // 更新上一次的鼠标位置
    lastMousePosition = currentPosition;
  }

  void onPointerUp(PointerUpEvent event, double maxScrollPositionX) {
    final velocity = velocityTracker!.getVelocity();
    final dxVelocityX = velocity.pixelsPerSecond.dx;
    final dxVelocityY = velocity.pixelsPerSecond.dy;
    var absX = dxVelocityX.abs();
    var absY = dxVelocityY.abs();
    if (absX > 300 && absX > absY) {
      double targetOffset =
          scrollHorizontalController.offset - (dxVelocityX > 0 ? 1000 : -1000);
      scrollHorizontalController.animateTo(
        targetOffset.clamp(0.0, maxScrollPositionX),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
    if (absY > 300 && absY > absX) {
      double targetOffset =
          scrollVerticalController.offset - (dxVelocityY > 0 ? 800 : -800);
      scrollVerticalController.animateTo(
        targetOffset.clamp(0.0, maxScrollPositionX),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
    velocityTracker = null;
    lastMousePosition = null;
    forceHorezentalScrell = false;
  }
}
