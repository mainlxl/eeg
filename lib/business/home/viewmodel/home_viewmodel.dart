import 'package:eeg/core/base/view_model_builder.dart';
import 'package:eeg/core/http/http_service.dart';
import 'package:eeg/core/utils/id_card_check_utils.dart';
import 'package:eeg/core/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class HomeViewModel extends BaseViewModel {
  final TextEditingController usernameInputController = TextEditingController();
  final TextEditingController emailInputController = TextEditingController();
  final TextEditingController idCardInputController = TextEditingController();
  final TextEditingController passwordInputController = TextEditingController();
  final TextEditingController passwordInputCheckController =
      TextEditingController();
  final register_info_dialog = "register_info_dialog";

  // 点击注册按钮的处理
  void onClickRegister() {
    idCardInputController.text = '130434199007080396';
    passwordInputController.text = '130434199007080396';
    passwordInputCheckController.text = '130434199007080396';
    String username = usernameInputController.text;
    if (username.isEmpty) {
      '用户名不能为空！'.toast;
      return;
    }
    if (username.length < 4) {
      '用户名长度至少为4个字符！'.toast;
      return;
    }
    var email = emailInputController.text;
    if (_isValidEmail(email)) {
      '请输入正确的邮箱！'.toast;
      return;
    }
    String idCard = idCardInputController.text;
    if (idCard.isEmpty) {
      '身份证不能为空！'.toast;
      return;
    }
    if (!IdCardUtils.idCardNumberCheck(idCard)) {
      showToast('请输入正确的身份证号！');
      return;
    }
    String password = passwordInputController.text;
    if (password.isEmpty) {
      showToast('密码不能为空！');
      return;
    }

    if (password.length < 6) {
      showToast('密码长度至少为6个字符！');
      return;
    }

    if (password != passwordInputCheckController.text) {
      showToast('两次密码输入不同！');
      return;
    }
    // 显示确认弹窗
    SmartDialog.show(
      tag: register_info_dialog,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认注册信息'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('用户名: $username'),
                Text('邮箱:: $email'),
                Text('密码: ${_obscurePassword(password)}'), // 隐藏密码
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                SmartDialog.dismiss(tag: register_info_dialog);
              },
            ),
            TextButton(
              child: const Text('确认'),
              onPressed: () {
                SmartDialog.dismiss(tag: register_info_dialog);
                _rawRegister(username, password, email);
              },
            ),
          ],
        );
      },
    );
  }

  // 处理密码模糊，中间部分用 * 代替
  String _obscurePassword(String password) {
    if (password.length < 4) {
      return '*' * password.length; // 密码长度小于4时全部用 * 代替
    }
    // 保留前两位和后两位，中间部分替换为 *
    return password.substring(0, 2) +
        '*' * (password.length - 4) +
        password.substring(password.length - 2);
  }

  // 校验邮箱的函数
  bool _isValidEmail(String email) {
    final RegExp regExp = RegExp(
        r'^[a-zA-Z0-9_+&*-]+(?:\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,7}$');
    return regExp.hasMatch(email);
  }

  void _rawRegister(String username, String password, String email) {
    SmartDialog.showLoading(msg: "注册中...", clickMaskDismiss: false);
    SmartDialog.dismiss(status: SmartStatus.loading);
    var post = HttpService.post('/registe',
        data: {"username": username, "email": email, "password": password});
    // context?.popPage();
  }

  void onClickEpilepsyElectroencephalogram() {
  }
}
