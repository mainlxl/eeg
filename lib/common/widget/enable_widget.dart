import 'package:flutter/material.dart';

class EnableWidget extends StatelessWidget {
  final Widget child;
  final bool enable;

  const EnableWidget({super.key, required this.child, required this.enable});

  @override
  Widget build(BuildContext context) {
    return enable
        ? child
        : IgnorePointer(child: Opacity(opacity: 0.3, child: child));
  }
}
