import 'package:eeg/business/chart/widget/base_close_dialog.dart';
import 'package:eeg/core/utils/size.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';

class ChannelFilterDialog extends BaseCloseDialog<Map<String, bool>> {
  final Map<String, bool> channelSelect;
  final GlobalKey<ChannelSelectorState> _key = GlobalKey();

  ChannelFilterDialog({
    super.key,
    required this.channelSelect,
  });

  @override
  Widget buildContentWidget() {
    return ChannelSelector(key: _key, channelSelect: channelSelect);
  }

  @override
  List<Widget> actionsWidget() {
    return [
      fluent.Button(onPressed: _onClickSelectAll, child: const Text('全选')),
      fluent.Button(onPressed: _onClickCancelAll, child: const Text('全取消')),
    ];
  }

  @override
  Map<String, bool>? buildResult() {
    return channelSelect;
  }

  @override
  Widget? buildTitleWidget() {
    return const Text("通道筛选");
  }

  void _onClickSelectAll() {
    channelSelect.forEach((key, value) {
      channelSelect[key] = true;
    });
    _key.currentState?.notification();
  }

  void _onClickCancelAll() {
    channelSelect.forEach((key, value) {
      channelSelect[key] = false;
    });
    _key.currentState?.notification();
  }
}

typedef UpdateSelector = void Function(VoidCallback updateUi);

class ChannelSelector extends StatefulWidget {
  final Map<String, bool> channelSelect;

  const ChannelSelector({super.key, required this.channelSelect});

  @override
  ChannelSelectorState createState() => ChannelSelectorState();
}

class ChannelSelectorState extends State<ChannelSelector> {
  void notification() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var channels = widget.channelSelect.keys.toList();
    var width = SizeUtils.screenWidth * 0.4;
    final crossAxisCount = _calculateChildCrossAxisCount(width);
    final childAspectRatio = _calculateChildAspectRatio(width, crossAxisCount);
    return channels.isEmpty
        ? Center(child: Text('没有频道可供选择'))
        : SizedBox(
            width: width,
            height: _calculateTotalHeight(),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 12, // 与计算时使用的间距一致
                mainAxisSpacing: 8, // 行间距
              ),
              itemCount: channels.length,
              itemBuilder: (context, index) {
                String channelName = channels[index];
                return CustomCheckboxListTile(
                  title: channelName,
                  value: widget.channelSelect[channelName] ?? false,
                  onChanged: (String channel, bool value) {
                    setState(() {
                      widget.channelSelect[channel] = value;
                    });
                  },
                );
              },
            ),
          );
  }

  int _calculateChildCrossAxisCount(double containerWidth) {
    const double minItemWidth = 80; // 最小项宽度
    const double maxItemWidth = 300; // 最大项宽度
    const double spacing = 12; // 列间距
    const double horizontalPadding = 20; // 水平两侧总留白
    final double availableWidth = containerWidth - horizontalPadding;

    // 计算可能的列数范围
    int maxCount = (availableWidth / (minItemWidth + spacing)).floor();
    int minCount = (availableWidth / (maxItemWidth + spacing)).ceil();
    // 取合理值并限制范围
    return (maxCount + minCount) ~/
        2 // 取中间值
            .clamp(1, 6); // 限制1-6列防止过度拥挤
  }

  double _calculateChildAspectRatio(double containerWidth, int crossAxisCount) {
    const double fixedHeight = 32; // 固定高度
    const double spacing = 12; // 列间距
    const double horizontalPadding = 20; // 水平两侧总留白
    final double availableWidth = containerWidth - horizontalPadding;
    final double totalSpacing = (crossAxisCount - 1) * spacing;

    // 计算实际项宽度
    final double itemWidth = (availableWidth - totalSpacing) / crossAxisCount;

    // 返回宽高比（宽度/固定高度）
    return itemWidth / fixedHeight;
  }

  double _calculateTotalHeight() {
    const double verticalPadding = 20; // 上下边距
    const double horizontalPadding = 20; // 左右边距
    const double mainAxisSpacing = 8; // 行间距
    final int itemCount = widget.channelSelect.keys.length;
    if (itemCount == 0) return 200; // 空状态默认高度
    // 获取容器实际可用宽度
    final double containerWidth =
        SizeUtils.screenWidth * 0.4 - horizontalPadding * 2;

    // 计算列数
    final int crossAxisCount = _calculateChildCrossAxisCount(containerWidth);

    // 计算行数
    final int rowCount = (itemCount / crossAxisCount).ceil();
    // 计算单个子项尺寸
    final double totalSpacing = (crossAxisCount - 1) * 12; // 列间距总和
    final double itemWidth = (containerWidth - totalSpacing) / crossAxisCount;
    final double itemHeight =
        itemWidth / _calculateChildAspectRatio(containerWidth, crossAxisCount);
    // 计算总高度
    return ((rowCount * itemHeight) +
            ((rowCount - 1) * mainAxisSpacing) +
            (verticalPadding * 2))
        .clamp(200, SizeUtils.screenHeight * 0.8);
  }
}

typedef ValueChanged = void Function(String name, bool value);

class CustomCheckboxListTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged onChanged;

  const CustomCheckboxListTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged.call(title, !value),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (check) => onChanged(title, check ?? false),
          ),
          Expanded(
            child: Text(title),
          ),
        ],
      ),
    );
  }
}
