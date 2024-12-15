import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

Future<void> showToast(String message,
    {SmartToastType? displayType, Alignment? alignment}) {
  return SmartDialog.showToast(
    message,
    displayType: displayType ?? SmartToastType.onlyRefresh,
    builder: (context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 24.0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 16.0),
      ),
    ),
    alignment: alignment ?? Alignment.center,
  );
}

Future<void> _showToast(String message) {
  return showToast(message);
}

extension ToastStringExtensions on String {
  void showToast() {
    _showToast(this);
  }

  Future<void> get toast => _showToast(this);
}
