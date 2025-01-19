import 'dart:math';

import 'package:eeg/business/chart/viewmodel/chart_line_view_model.dart';
import 'package:eeg/business/chart/widget/chart_horizontal_axis_widget.dart';
import 'package:eeg/business/chart/widget/chart_line_widget.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:eeg/core/utils/config.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';

class EegLineChart extends StatelessWidget {
// 构造函数
  EegLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder(
      create: () => ChartLineViewModel(),
      child: Consumer<ChartLineViewModel>(builder: (ctx, vm, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            var maxWidth = constraints.maxWidth;
            var maxHeight = constraints.maxHeight;
            int countByWidth = (maxWidth / vm.pointGap).ceil();
            double lineHeight = vm.lineTargetHeight ??=
                min(maxHeight / vm.totalLine, vm.lineHeightMin);
            var canvasWidth = vm.canvasWidth;
            return Column(
              children: [
                SizedBox(
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _buildOption(context, vm),
                  ),
                ),
                SizedBox(
                  width: maxWidth,
                  height: maxHeight - 30,
                  child: Scrollbar(
                    controller: vm.scrollHorizontalController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: vm.scrollHorizontalController,
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
                                child: vm.channels == null
                                    ? Container()
                                    : ScrollConfiguration(
                                        behavior: NoScrollBehavior(), //隐藏滑动条
                                        child: ListView.builder(
                                          controller:
                                              vm.scrollVerticalController,
                                          itemCount: vm.totalLine,
                                          itemBuilder: (context, index) =>
                                              CustomPaint(
                                            size: Size(canvasWidth, lineHeight),
                                            painter: ChannelLineChartPainter(
                                              data: vm.channels!.data[index],
                                              contentWidth: maxWidth,
                                              scrollOffset: vm.scrollOffset,
                                              isScroll: vm.isHorezentalScrell,
                                              pointGap: vm.pointGap,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              CustomPaint(
                                size: Size(canvasWidth, 40),
                                painter: HorizontalAxisChartPainter(
                                  contentWidth: maxWidth,
                                  scrollOffset:
                                      vm.scrollHorizontalController.hasClients
                                          ? vm.scrollHorizontalController.offset
                                          : 0,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
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

  // 上一次鼠标的位置
  Offset? _lastMousePosition;
  VelocityTracker? _velocityTracker;

  Widget _buildTargetCharWidget(
      {required Widget child,
      required ChartLineViewModel viewModel,
      required double maxWidth,
      required double width}) {
    if (isWindows) {
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

    return child;
  }

  Widget _dropDownButtonItems(
      {required String leading,
      required String title,
      required List<MenuFlyoutItemBase> items}) {
    return DropDownButton(
      leading: Text(leading),
      title: Text(title),
      items: items,
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
      Button(
          onPressed: vm.onClickChangeWidth, child: Text('横坐标间隔${vm.pointGap}')),
      Button(
          onPressed: vm.onClickChangeHeight,
          child: Text('单通道高度${vm.lineTargetHeight?.toStringAsFixed(0)}')),
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
