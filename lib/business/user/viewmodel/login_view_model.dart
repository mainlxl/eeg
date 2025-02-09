import 'package:eeg/business/user/page/register_page.dart';
import 'package:eeg/business/user/user_info.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:eeg/core/utils/crypto.dart';
import 'package:eeg/core/utils/router_utils.dart';
import 'package:eeg/core/utils/toast.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends BaseViewModel {
  final TextEditingController usernameInputController = TextEditingController();
  final TextEditingController passwordInputController = TextEditingController();

  void onClickLogin() async {
    var username = usernameInputController.text;
    var password = passwordInputController.text;
    if (username.isEmpty) {
      showToast("用户名/邮箱不x能为空");
      return;
    } else if (password.isEmpty) {
      showToast("密码不能为空");
      return;
    }
    showLoading("登录中...");
    var post = await HttpService.post('/api/v1/login',
        data: {"username": username, "password": password.md5});
    hideLoading();
    var responseData = post?.data as Map<String, dynamic>?;
    if (responseData != null) {
      if (await UserInfo.checkAndSaveLoginInfo(responseData)) {
        showToast("登录成功");
        context.pushReplacementNamed('/home');
        return;
      }
    }
    '登录失败,请检查用户名或密码'.toast;
  }

  void onClickRegister() {
    showDialog(context: context, builder: (context) => RegisterPage());
    // context?.pushPage('register');
  }
}
