import 'package:eeg/app_router.dart';
import 'package:eeg/business/home/page/home_page.dart';
import 'package:eeg/business/user/page/login_page.dart';
import 'package:eeg/core/utils/login.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => _checkLoginStatus(context));
    return Container();
  }

  void _checkLoginStatus(BuildContext context) {
    if (LoginUtills.isLogin()) {
      context.pushReplacement(HomePage());
    } else {
      context.pushReplacement(LoginPage());
    }
  }
}
