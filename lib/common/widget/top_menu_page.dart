import 'package:flutter/material.dart';

class TopPanePageWidget extends StatefulWidget {
  final List<PanePageItem> items;
  final List<PanePageItem>? endItems;

  const TopPanePageWidget({super.key, required this.items, this.endItems});

  @override
  _TopPanePageWidgetState createState() => _TopPanePageWidgetState();
}

class _TopPanePageWidgetState extends State<TopPanePageWidget> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var menus = widget.items
        .asMap()
        .entries
        .map((entry) => _buildMenu(entry.key, entry.value))
        .toList();
    if (widget.endItems != null) {
      menus.add(const Expanded(
        child: Spacer(),
      ));
      menus.addAll(widget.endItems!
          .asMap()
          .entries
          .map((item) => _buildMenu(item.key + menus.length, item.value))
          .toList());
    }
    return Column(
      children: [
        Container(
          color: Colors.grey[200],
          constraints: const BoxConstraints(maxHeight: 150, minWidth: 0),
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
          child: Row(
            children: menus,
          ),
        ),
        Expanded(
          child: Container(
            color: const Color(0xFFF5F5F5),
            child: IndexedStack(
              index: _selectedIndex,
              children:
                  widget.items.map((item) => item.body ?? Container()).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenu(int index, PanePageItem item) {
    var isSelect = index == _selectedIndex;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (item.onClick != null) {
          if (item.onClick!()) {
            return;
          }
        }
        if (!isSelect) {
          setState(() {
            _selectedIndex = index;
          });
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
  OnClickItem? onClick;

  PanePageItem({
    required this.iconWidget,
    required this.title,
    this.body,
    this.titleWidget,
    this.onClick,
  });
}
