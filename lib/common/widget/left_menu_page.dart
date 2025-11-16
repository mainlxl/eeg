import 'package:flutter/material.dart';

typedef OnClickPanePageItem = bool Function(PanePageItem item, int index);

class PanePageController {
  int _selectedIndex = 0;
  _PanePageWidgetState? _state;
  OnClickPanePageItem? _onClickItem;

  int get selectedIndex => _selectedIndex;

  set onClickItem(OnClickPanePageItem onClickItem) {
    _onClickItem = onClickItem;
  }

  PanePageController();

  setSelectedIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      _state?.updateState();
    }
  }

  _dispose() {
    _selectedIndex = 0;
    _state = null;
    _onClickItem = null;
  }
}

class PanePageWidget extends StatefulWidget {
  final List<PanePageItem> items;
  final List<PanePageItem>? bottomItems;
  final double? contentTop;
  final PanePageController controller;

  PanePageWidget({
    Key? key,
    required this.items,
    this.bottomItems,
    this.contentTop,
    PanePageController? controller,
  })  : controller = controller ?? PanePageController(),
        super(key: key);

  @override
  _PanePageWidgetState createState() => _PanePageWidgetState();
}

class _PanePageWidgetState extends State<PanePageWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.controller._state = this;
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller._dispose();
  }

  void updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var menus = widget.items
        .asMap()
        .entries
        .map((entry) => _buildMenu(entry.key, entry.value))
        .toList();
    if (widget.bottomItems != null) {
      menus.add(Expanded(child: Container()));
      menus.addAll(widget.bottomItems!
          .asMap()
          .entries
          .map((item) => _buildMenu(item.key + menus.length, item.value))
          .toList());
    }
    var top = widget.contentTop;
    return Row(
      children: [
        Container(
          color: Colors.grey[200],
          constraints: const BoxConstraints(maxWidth: 300, minWidth: 0),
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
          child: IntrinsicWidth(child: Column(children: menus)),
        ),
        Expanded(
          child: Container(
            padding: top != null ? EdgeInsets.only(top: top) : null,
            color: const Color(0xFFF5F5F5),
            child: widget.items[widget.controller.selectedIndex].needSaveDate
                ? IndexedStack(
                    index: widget.controller.selectedIndex,
                    children: widget.items
                        .map((item) => item.body ?? Container())
                        .toList(),
                  )
                : widget.items[widget.controller.selectedIndex].body,
          ),
        ),
      ],
    );
  }

  Widget _buildMenu(int index, PanePageItem item) {
    var isSelect = index == widget.controller.selectedIndex;
    return TextButton(
      onPressed: () {
        if (item.onClick != null) {
          if (item.onClick!()) {
            return;
          }
        }
        if (widget.controller._onClickItem?.call(item, index) == true) {
          return;
        }
        if (!isSelect) {
          widget.controller.setSelectedIndex(index);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
        color: isSelect ? const Color(0x15303030) : Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 15, // 设置适当的高度
              width: 3,
              decoration: BoxDecoration(
                color: isSelect ? Colors.blue : Colors.transparent,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                    bottom: Radius.circular(20)), // 设置上下圆角
              ),
            ),
            const SizedBox(width: 5.0),
            item.iconWidget,
            const SizedBox(width: 10.0),
            Text(item.title),
          ],
        ),
      ),
    );
  }
}

typedef OnClickItem = bool Function();

class PanePageItem {
  final Widget iconWidget;
  final String title;
  final Widget? titleWidget;
  final Widget? body;
  final bool needSaveDate;
  OnClickItem? onClick;

  PanePageItem({
    required this.iconWidget,
    required this.title,
    this.body,
    this.titleWidget,
    this.needSaveDate = true,
    this.onClick,
  });
}
