import 'package:eeg/business/chart/widget/base_close_dialog.dart';
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
    return channels.isEmpty
        ? Center(child: Text('没有频道可供选择'))
        : SizedBox(
            width: 300,
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 每行2个频道
                childAspectRatio: 2, // 控制宽高比
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
