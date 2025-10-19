import 'package:eeg/business/chart/dialog/features_algorithm_dialog.dart';
import 'package:eeg/business/chart/mode/channel_alagorithm.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AlgorithmParamsSelectWidget extends ItemContainerWidget {
  final AlgorithmFeature data;
  final AlgorithmViewModel parentViewModel;
  final void Function(AlgorithmFeature) onComputer;

  AlgorithmParamsSelectWidget({
    super.key,
    required this.data,
    required this.parentViewModel,
    required this.onComputer,
  });

  @override
  Widget build(BuildContext context) {
    return AlgorithmParametersWidget(index: 0, data: data);
  }

  @override
  void onStartShowWidget() {
    actionButtonsController?.notifyActionWidgets([
      fluent.Button(
        child: const Text('计算'),
        onPressed: () => onComputer(data),
      ),
    ]);
  }
}

class AlgorithmParametersWidget extends StatelessWidget {
  final AlgorithmFeature data;
  final int index;

  AlgorithmParametersWidget({required this.index, required this.data})
      : super(key: Key('$index'));

  @override
  Widget build(BuildContext context) {
    var checked = data.checked ?? true;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: Icon(Icons.fiber_smart_record,
                      // color: checked ? iconColor : subtitleColor),
                      color: iconColor),
                ),
                SizedBox(width: 10),
                Text(
                    '${data.name}${data.description.isNotEmpty ? ' - (${data.description})' : ''}',
                    style: TextStyle(
                        // color: checked ? textColor : subtitleColor,
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            if (checked) SizedBox(height: 10),
            if (checked)
              ...List.generate(
                  data.parameters.length,
                  (index) =>
                      _buildFeaturesParametersItem(data.parameters[index])),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesParametersItem(AlgorithmParameter param) {
    if (param.enumList.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _renderPrefix(param),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 20),
              child: ShadSelect<String>(
                  placeholder: Text(param.value),
                  options: param.enumList.map((e) => ShadOption(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      value: e,
                      child: Text(e))),
                  selectedOptionBuilder: (context, value) => Text(value),
                  onChanged: (value) => param.value = value ?? ''),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: TextField(
        style: TextStyle(fontSize: 16, height: 1.0),
        inputFormatters: param.getInputFormatters(),
        controller: param.controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: _renderPrefix(param),
        ),
      ),
    );
  }

  Widget _renderPrefix(AlgorithmParameter param) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
            color: iconColor, fontSize: 18, fontWeight: FontWeight.bold),
        children: [
          TextSpan(text: param.name),
          TextSpan(
            text:
                " (${param.description},${param.type}默认值: ${param.defaultValue})",
            style: TextStyle(color: subtitleColor, fontSize: 12),
          ),
          TextSpan(
            text: ' : ',
          ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
