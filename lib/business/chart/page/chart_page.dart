import 'dart:math';

import 'package:eeg/business/chart/mode/channels_meta_data.dart';
import 'package:eeg/business/chart/viewmodel/chart_line_view_model.dart';
import 'package:eeg/business/chart/widget/chart_line_widget.dart';
import 'package:eeg/common/widget/loading_status_page.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:window_manager/window_manager.dart';

class EegLineChart extends StatelessWidget {
  ChannelMeta channelMeta;
  String title;

  EegLineChart({super.key, required this.title, required this.channelMeta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: LoadingPageStatusWidget(
          createOrGetViewMode: () => ChartLineViewModel(channelMeta),
          buildPageContent: (ctx, vm) {
            return LayoutBuilder(
              builder: (context, constraints) {
                var maxWidth = constraints.maxWidth;
                var maxHeight = constraints.maxHeight;
                // int countByWidth = (maxWidth / vm.pointGap).ceil();
                double lineHeight = vm.lineTargetHeight ??=
                    max(maxHeight / vm.totalLine, vm.lineHeightMin);
                var canvasWidth = vm.canvasWidth;
                var channels = vm.channels;
                return Column(
                  children: [
                    SizedBox(
                      width: maxWidth,
                      height: maxHeight - 30,
                      child: Scrollbar(
                        controller: vm.scrollHorizontalController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: vm.scrollHorizontalController,
                          physics: ClampingScrollPhysics(), // 去掉弹性效果
                          scrollDirection: Axis.horizontal,
                          child: _buildTargetCharWidget(
                            maxWidth: vm.canvasWidth,
                            viewModel: vm,
                            width: maxWidth,
                            child: SizedBox(
                              width: vm.canvasWidth,
                              height: maxHeight,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: channels.isEmpty
                                        ? Container()
                                        : ScrollConfiguration(
                                            behavior:
                                                NoScrollBehavior(), //隐藏滑动条
                                            child: ListView.builder(
                                              controller:
                                                  vm.scrollVerticalController,
                                              physics:
                                                  ClampingScrollPhysics(), // 去掉弹性效果
                                              itemCount: vm.totalLine,
                                              itemBuilder: (context, index) =>
                                                  CustomPaint(
                                                size: Size(
                                                    canvasWidth, lineHeight),
                                                painter:
                                                    ChannelLineChartPainter(
                                                  data: channels[index],
                                                  contentWidth: maxWidth,
                                                  scrollOffset: vm.scrollOffset,
                                                  isScroll:
                                                      vm.isHorezentalScrell,
                                                  pointGap: vm.pointGap,
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                  // CustomPaint(
                                  //   size: Size(canvasWidth, 5),
                                  //   painter: HorizontalAxisChartPainter(
                                  //     contentWidth: maxWidth,
                                  //     scrollOffset: vm.scrollHorizontalController
                                  //             .hasClients
                                  //         ? vm.scrollHorizontalController.offset
                                  //         : 0,
                                  //   ),
                                  // )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: _buildOption(context, vm),
                      ),
                    ),
                  ],
                );
              },
            );
          }),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: DragToMoveArea(
          child: fluent.SizedBox(width: double.infinity, child: Text(title))),
      actions: [
        Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.info), // 使用帮助图标
            onPressed: () {
              SmartDialog.showToast('''
类型: ${channelMeta.data_type}
数据id: ${channelMeta.data_id}
通道: ${channelMeta.channels}
Tips:       
    1.鼠标横向滚动查看: 按住[shift]+键拨动滚轮
    2.支持按住拖动
      ''',
                  displayTime: const Duration(seconds: 3),
                  alignment: Alignment.center);
            },
          );
        })
      ],
    );
  }

  // 上一次鼠标的位置
  Offset? _lastMousePosition;
  VelocityTracker? _velocityTracker;

  Widget _buildTargetCharWidget(
      {required Widget child,
      required ChartLineViewModel viewModel,
      required double maxWidth,
      required double width}) {
    var maxScrollPositionX = maxWidth - width;
    return Listener(
      // 鼠标移动事件
      onPointerMove: (PointerMoveEvent event) {
        _velocityTracker?.addPosition(event.timeStamp, event.position);
        final currentPosition = event.position;
        if (_lastMousePosition != null) {
          var translateToX = (currentPosition.dx - _lastMousePosition!.dx);
          var translateToY = (currentPosition.dy - _lastMousePosition!.dy);
          translateToX =
              viewModel.scrollHorizontalController.offset - translateToX;
          if (translateToX > 0 && translateToX <= maxScrollPositionX) {
            viewModel.forceHorezentalScrell = true;
            viewModel.scrollHorizontalController.jumpTo(translateToX);
          }
          if (translateToY != 0) {
            viewModel.forceHorezentalScrell = true;
            viewModel.scrollVerticalController.jumpTo(
                viewModel.scrollVerticalController.offset - translateToY);
          }
        }
        // 更新上一次的鼠标位置
        _lastMousePosition = currentPosition;
      },
      // 鼠标按下时初始化位置
      onPointerDown: (PointerDownEvent event) {
        _lastMousePosition = event.position;
        _velocityTracker = VelocityTracker.withKind(event.kind);
      },
      onPointerUp: (PointerUpEvent event) {
        final velocity = _velocityTracker!.getVelocity();
        final dxVelocityX = velocity.pixelsPerSecond.dx;
        final dxVelocityY = velocity.pixelsPerSecond.dy;
        var absX = dxVelocityX.abs();
        var absY = dxVelocityY.abs();
        if (absX > 300 && absX > absY) {
          double targetOffset = viewModel.scrollHorizontalController.offset -
              (dxVelocityX > 0 ? 1000 : -1000);
          viewModel.scrollHorizontalController.animateTo(
            targetOffset.clamp(0.0, maxScrollPositionX),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
        if (absY > 300 && absY > absX) {
          double targetOffset = viewModel.scrollVerticalController.offset -
              (dxVelocityY > 0 ? 800 : -800);
          viewModel.scrollVerticalController.animateTo(
            targetOffset.clamp(0.0, maxScrollPositionX),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
        _velocityTracker = null;
        _lastMousePosition = null;
        viewModel.forceHorezentalScrell = false;
      },
      child: child,
    );
  }

  List<Widget> _buildOption(BuildContext context, ChartLineViewModel vm) {
    return [
      // _dropDownButtonItems(
      //   leading: '横坐标间隔',
      //   title: '${vm.pointGap}',
      //   items: List<MenuFlyoutItem>.generate(
      //     10,
      //     (index) {
      //       var size = (index + 1) * 3;
      //       return MenuFlyoutItem(
      //         text: Text('${size}'),
      //         onPressed: () => vm.onPointGapChange(size),
      //       );
      //     },
      //   ),
      // ),
      fluent.Button(
          onPressed: vm.onClickChangeWidth, child: Text('横坐标间隔${vm.pointGap}')),
      fluent.Button(
          onPressed: vm.onClickChangeHeight,
          child: Text('单通道高度${vm.lineTargetHeight?.toStringAsFixed(0)}')),
      fluent.Button(onPressed: vm.onClickChannelFilter, child: Text('通道筛选')),
      fluent.Button(onPressed: vm.onClickAlgorithm, child: Text('算法')),
    ];
  }
}

// 自定义 ScrollBehavior 类
class NoScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child; // 返回子部件，不显示滑动条
  }

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child; // 返回子部件，不显示过度滚动指示器
  }
}

class DragToMoveArea extends StatelessWidget {
  const DragToMoveArea({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (details) {
        windowManager.startDragging();
      },
      onDoubleTap: () async {
        bool isMaximized = await windowManager.isMaximized();
        if (!isMaximized) {
          windowManager.maximize();
        } else {
          windowManager.unmaximize();
        }
      },
      child: child,
    );
  }
}
