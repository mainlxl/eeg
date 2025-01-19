import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:provider/provider.dart';

class SliderDialog extends StatelessWidget {
  final sliderProvider = _SliderProvider();
  final ValueChanged<double> onChanged;
  final String title;
  final double min;
  final double max;

  SliderDialog({
    super.key,
    required double value,
    required this.title,
    this.min = 0.0,
    this.max = 100.0,
    required this.onChanged,
  }) {
    sliderProvider._value = value;
  }

  void addAction(Iterable<Widget> iterable) {
    sliderProvider.actions.addAll(iterable);
  }

  void addSelectValueAction(Iterable<double> iterable, {bool isClose = false}) {
    sliderProvider.actions.addAll(iterable.map(
      (value) => Button(
          child: Text('${value.ceil()}'),
          onPressed: () {
            onChanged(value);
            sliderProvider.updateHeight(value);
            if (isClose) {
              Navigator.pop(sliderProvider.context!);
            }
          }),
    ));
  }

  @override
  Widget build(BuildContext context) {
    sliderProvider.context = context;
    return material.AlertDialog(
      title: Text(title),
      content: ChangeNotifierProvider(
        create: (context) => sliderProvider,
        child: Consumer<_SliderProvider>(builder: (ctx, vm, _) {
          var value = sliderProvider._value.ceil();
          return IntrinsicHeight(
            child: Slider(
              label: value.toString(),
              value: value.toDouble(),
              min: min,
              max: max,
              onChanged: (value) {
                onChanged(value);
                sliderProvider.updateHeight(value);
              },
            ),
          );
        }),
      ),
      actions: [
        ...sliderProvider.actions,
        Button(child: const Text('关闭'), onPressed: () => Navigator.pop(context))
      ],
    );
  }

  show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => this,
    );
  }

  void updateValue(double newValue) {
    sliderProvider.updateHeight(newValue);
  }
}

class _SliderProvider extends ChangeNotifier {
  double _value = 0.0; // 默认值
  late List<Widget> actions = [];
  BuildContext? context;

  void updateHeight(double newHeight) {
    _value = newHeight;
    notifyListeners(); // 通知监听者更新
  }
}
