import 'package:flutter/material.dart';

import 'app_colors.dart';

enum DialogType { info, warning, error, success }

class CommonDialog extends StatelessWidget {
  final String title;
  final String content;
  final DialogType type;
  final String? confirmButtonText;
  final String? cancelButtonText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final List<Widget>? actions; // 自定义底部按钮

  const CommonDialog({
    super.key,
    required this.title,
    required this.content,
    this.type = DialogType.info,
    this.confirmButtonText,
    this.cancelButtonText,
    this.onConfirm,
    this.onCancel,
    this.actions,
  });

  Color _getDialogColor(DialogType type) {
    switch (type) {
      case DialogType.error:
        return Colors.red.shade200;
      default:
        return bgColor; // 默认颜色
    }
  }

  Icon _getDialogIcon(DialogType type) {
    switch (type) {
      case DialogType.info:
        return Icon(Icons.info_outline, color: Colors.blue, size: 40);
      case DialogType.warning:
        return Icon(Icons.warning_amber_outlined,
            color: Colors.orange, size: 40);
      case DialogType.error:
        return Icon(Icons.error_outline, color: Colors.red, size: 40);
      case DialogType.success:
        return Icon(Icons.check_circle_outline, color: Colors.green, size: 40);
      default:
        return Icon(Icons.info_outline, color: Colors.blue, size: 40);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _getDialogColor(type),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      title: Row(
        children: [
          _getDialogIcon(type),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Text(
          content,
          style: TextStyle(fontSize: 16),
        ),
      ),
      actions: actions ??
          <Widget>[
            if (cancelButtonText != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onCancel?.call();
                },
                child: Text(cancelButtonText!),
              ),
            if (confirmButtonText != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm?.call();
                },
                child: Text(confirmButtonText!),
              ),
          ],
    );
  }

  // 快捷显示方法
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String content,
    DialogType type = DialogType.info,
    String? confirmButtonText = "确定",
    String? cancelButtonText = "取消",
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true, // 点击外部是否可关闭
    List<Widget>? actions,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return CommonDialog(
          title: title,
          content: content,
          type: type,
          confirmButtonText: confirmButtonText,
          cancelButtonText: cancelButtonText,
          onConfirm: onConfirm,
          onCancel: onCancel,
          actions: actions,
        );
      },
    );
  }
}
