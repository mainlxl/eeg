import 'package:eeg/common/widget/drag_to_move_area_widget.dart';
import 'package:eeg/core/utils/config.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

class TitleBar extends StatelessWidget {
  final Widget? child;
  final double height;
  final Widget? rightActionBar;

  const TitleBar(
      {super.key, this.child, this.rightActionBar, this.height = 40});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              alignment: Alignment.center,
              width: constraints.maxWidth,
              height: height,
              child: isWeb
                  ? child
                  : DragToMoveWidget(
                      enableDoubleTap: true,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: height,
                        child: child,
                      ),
                    ),
            );
          },
        ),
        ...actionBar(),
        isDesktop
            ? Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: SizedBox(
                  width: 138,
                  height: height,
                  child: WindowCaption(
                    brightness: FluentTheme.of(context).brightness,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  List<Widget> actionBar() {
    if (rightActionBar != null) {
      return [
        Positioned(
          right: 138,
          top: 0,
          bottom: 0,
          child: SizedBox(
            height: height,
            child: rightActionBar,
          ),
        )
      ];
    }
    return [];
  }
}
