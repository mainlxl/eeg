import 'package:eeg/business/user/page/register_page.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:eeg/core/utils/router_utils.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/toast.dart';

class LoginViewModel extends BaseViewModel {
  final TextEditingController usernameInputController = TextEditingController();
  final TextEditingController passwordInputController = TextEditingController();

  @override
  void init() {}

  @override
  void dispose() {
    super.dispose();
  }

  void onClickLogin() {
    if (usernameInputController.text.isEmpty) {
      showToast("用户名/邮箱不能为空");
      return;
    } else if (passwordInputController.text.isEmpty) {
      showToast("密码不能为空");
      return;
    }
    showToast("登录成功");
    context.pushReplacementNamed('/home');
  }

  void onClickRegister() {
    showDialog(context: context, builder: (context) => RegisterPage());
    // context?.pushPage('register');
  }
}
