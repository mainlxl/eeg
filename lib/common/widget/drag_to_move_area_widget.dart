import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class DragToMoveWidget extends StatelessWidget {
  final bool enableDoubleTap;
  final Widget child;

  const DragToMoveWidget(
      {super.key, required this.child, this.enableDoubleTap = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (details) {
        windowManager.startDragging();
      },
      onDoubleTap: enableDoubleTap
          ? () async {
              bool isMaximized = await windowManager.isMaximized();
              if (!isMaximized) {
                windowManager.maximize();
              } else {
                windowManager.unmaximize();
              }
            }
          : null,
      child: child,
    );
  }
}
