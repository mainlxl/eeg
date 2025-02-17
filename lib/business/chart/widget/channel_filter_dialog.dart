import 'package:eeg/business/chart/mode/channels_meta_data.dart';
import 'package:eeg/business/chart/widget/base_close_dialog.dart';
import 'package:flutter/material.dart';

class ChannelFilterDialog extends BaseCloseDialog {
  final ChannelMeta channelMeta;

  ChannelFilterDialog({
    super.key,
    required this.channelMeta,
  });

  @override
  Widget buildContentWidget() {
    return ChannelSelector(channels: channelMeta.channels ?? []);
  }

  @override
  Widget? buildTitleWidget() {
    return const Text("通道筛选");
  }
}

class ChannelSelector extends StatefulWidget {
  final List<String>? channels;

  ChannelSelector({Key? key, required this.channels}) : super(key: key);

  @override
  _ChannelSelectorState createState() => _ChannelSelectorState();
}

class _ChannelSelectorState extends State<ChannelSelector> {
  List<bool> _selectedChannels = [];

  @override
  void initState() {
    super.initState();
    // 初始化复选框状态
    if (widget.channels != null) {
      _selectedChannels = List<bool>.filled(widget.channels!.length, false);
    }
  }

  // 获取最终选择的频道
  List<String> getSelectedChannels() {
    List<String> selected = [];
    for (int i = 0; i < _selectedChannels.length; i++) {
      if (_selectedChannels[i]) {
        selected.add(widget.channels![i]);
      }
    }
    return selected;
  }

  @override
  Widget build(BuildContext context) {
    var channels = widget.channels;
    return channels == null || channels.isEmpty
        ? Center(child: Text('没有频道可供选择'))
        : SizedBox(
            width: 300,
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 每行2个频道
                childAspectRatio: 2, // 控制宽高比
              ),
              itemCount: widget.channels!.length,
              itemBuilder: (context, index) {
                return CustomCheckboxListTile(
                  title: channels[index],
                  value: _selectedChannels[index],
                  onChanged: (bool? value) {
                    setState(() {
                      _selectedChannels[index] = value ?? false;
                    });
                  },
                );
              },
            ),
          );
  }
}

class CustomCheckboxListTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const CustomCheckboxListTile({
    Key? key,
    required this.title,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
          ),
          Expanded(
            child: Text(title),
          ),
        ],
      ),
    );
  }
}
