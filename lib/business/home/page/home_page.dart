import 'package:eeg/business/assess/page/assess_home.dart';
import 'package:eeg/business/test/page/home_test_page.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:eeg/common/widget/title_bar.dart';
import 'package:eeg/core/utils/config.dart';
import 'package:eeg/core/utils/router_utils.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget? rightActionBar = null;
    if (isDebug) {
      rightActionBar = IconButton(
        icon: Icon(Icons.format_list_bulleted),
        onPressed: () {
          context.push((context) => TestHomePage());
        },
      );
    }
    return Container(
      color: bgColor,
      child: Column(
        children: [
          TitleBar(
            rightActionBar: rightActionBar,
            child: Center(
              child: Text(
                '上肢运动-认知协同康复训练及评估系统',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(child: AssessHomePage()),
        ],
      ),
    );
  }
}
