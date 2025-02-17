import 'package:flutter/material.dart';

class StatusPageWidget extends StatelessWidget {
  final bool loading;
  final bool isErrorOrEmpty;
  final VoidCallback? retryCall;
  final String hintText;
  final Widget child;

  StatusPageWidget({
    required this.loading,
    this.hintText = '数据开小差了，请点击重试',
    this.isErrorOrEmpty = false,
    this.retryCall,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: Container(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black, // 设置容器的背景颜色为黑色
              borderRadius: BorderRadius.circular(10), // 设置圆角半径
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 1,
              color: Colors.white,
            ),
          ),
        ),
      );
    } else if (isErrorOrEmpty) {
      return Center(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: retryCall,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset(
                'images/background/login.png',
                height: 100,
              ),
              Visibility(
                visible: hintText.isNotEmpty,
                child: Text(
                  hintText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFEF5350),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return child;
  }
}
