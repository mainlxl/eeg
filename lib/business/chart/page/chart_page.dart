import 'dart:math';

import 'package:eeg/business/chart/mode/channels_meta_data.dart';
import 'package:eeg/business/chart/viewmodel/chart_line_view_model.dart';
import 'package:eeg/business/chart/widget/chart_line_widget.dart';
import 'package:eeg/common/widget/drag_to_move_area_widget.dart';
import 'package:eeg/common/widget/loading_status_page.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class EegLineChart extends StatelessWidget {
  final ChannelMeta channelMeta;
  final String title;

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
                final maxWidth = constraints.maxWidth;
                final maxHeight = constraints.maxHeight;
                // int countByWidth = (maxWidth / vm.pointGap).ceil();
                final channels = vm.channels;
                final totalLine = channels.length;
                double lineHeight = vm.lineTargetHeight ??=
                    max(maxHeight / totalLine, vm.lineHeightMin);
                final canvasWidth = vm.canvasWidth;
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
                            vm: vm,
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
                                              itemCount: channels.length,
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
                    DragToMoveWidget(
                      enableDoubleTap: true,
                      child: SizedBox(
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: _buildOption(context, vm),
                        ),
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
      title: DragToMoveWidget(
          enableDoubleTap: true,
          child: fluent.SizedBox(width: double.infinity, child: Text(title))),
      actions: [
        Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.info), // 使用帮助图标
            onPressed: () {
              SmartDialog.showToast('''
类型: ${channelMeta.dataType}
数据id: ${channelMeta.dataId}
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

  Widget _buildTargetCharWidget(
      {required Widget child,
      required ChartLineViewModel vm,
      required double maxWidth,
      required double width}) {
    var maxScrollPositionX = maxWidth - width;
    return Listener(
      onPointerMove: (event) => vm.onPointerMove(event, maxScrollPositionX),
      onPointerDown: vm.onPointerDown,
      onPointerUp: (event) => vm.onPointerUp(event, maxScrollPositionX),
      child: child,
    );
  }

  List<Widget> _buildOption(BuildContext context, ChartLineViewModel vm) {
    return [
      fluent.Button(
          onPressed: vm.onClickChangeWidth, child: Text('横坐标间隔${vm.pointGap}')),
      fluent.Button(
          onPressed: vm.onClickChangeHeight,
          child: Text('单通道高度${vm.lineTargetHeight?.toStringAsFixed(0)}')),
      fluent.Button(onPressed: vm.onClickChannelFilter, child: Text('通道筛选')),
      fluent.Button(onPressed: vm.onClickAlgorithm, child: Text('信号预处理')),
      fluent.Button(onPressed: vm.onClickAlgorithm, child: Text('特征处理计算')),
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
