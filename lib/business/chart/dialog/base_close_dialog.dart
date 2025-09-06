import 'package:eeg/core/utils/size.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';

abstract class BaseCloseDialog<T> extends StatelessWidget {
  BaseCloseDialog({super.key});

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: buildTitleWidget(),
      content: buildContentWidget(),
      actions: [
        ...actionsWidget(),
        fluent.Button(
            child: const Text('关闭'), onPressed: () => _onClickClose(context))
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
    closeDialog(context);
  }

  void closeDialog(BuildContext context) {
    Navigator.pop(context, buildResult());
    onCloseDialog();
  }

  void onCloseDialog() {}

  T? buildResult() {
    return null;
  }
}

typedef _UpdateActions = void Function();

class DialogActionsController {
  List<Widget> actionWidgets = [];
  _UpdateActions? _updateAction;

  void notifyActionWidgets([List<Widget>? actionWidgets]) {
    if (actionWidgets != null) {
      this.actionWidgets = actionWidgets;
    }
    _updateAction?.call();
  }
}

class StatefulActionsWidget extends StatefulWidget {
  final DialogActionsController controller;

  const StatefulActionsWidget({super.key, required this.controller});

  @override
  State<StatefulWidget> createState() => _StatefulActionsWidget();
}

class _StatefulActionsWidget extends State<StatefulActionsWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller._updateAction = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: SizeUtils.screenWidth * 0.6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: widget.controller.actionWidgets,
      ),
    );
  }
}
