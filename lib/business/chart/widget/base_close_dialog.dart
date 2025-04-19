import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;

abstract class BaseCloseDialog<T> extends StatelessWidget {
  BaseCloseDialog({super.key});

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    return material.AlertDialog(
      title: buildTitleWidget(),
      content: buildContentWidget(),
      actions: [
        ...actionsWidget(),
        Button(child: const Text('关闭'), onPressed: () => _onClickClose(context))
      ],
    );
  }

  Future<T?> show(BuildContext context) async {
    T? res = await showDialog<T>(
      barrierDismissible: true,
      context: context,
      builder: (ctx) => this,
    );
    onCloseDialog();
    return res;
  }

  List<Widget> actionsWidget() {
    return [];
  }

  Widget buildContentWidget();

  Widget? buildTitleWidget() => null;

  void _onClickClose(BuildContext context) {
    Navigator.pop(context, buildResult());
    onCloseDialog();
  }

  void onCloseDialog() {}

  T? buildResult() {
    return null;
  }
}
