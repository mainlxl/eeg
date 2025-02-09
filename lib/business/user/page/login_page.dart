import 'package:easy_localization/easy_localization.dart';
import 'package:eeg/business/user/viewmodel/login_view_model.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:eeg/common/font_family.dart';
import 'package:eeg/common/widget/title_bar.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends BasePage {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/background/login.png'), // 请确保图片路径正确
          opacity: 0.5,
          fit: BoxFit.cover, // 图片填充方式
        ),
        gradient: LinearGradient(
          colors: [
            Color(0xffa1c6ff),
            Color(0xffe3e7ff),
          ],
          begin: Alignment.topLeft, // 渐变开始位置
          end: Alignment.bottomRight, // 渐变结束位置
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          const TitleBar(),
          Expanded(
            child: ViewModelBuilder<LoginViewModel>(
              create: () => LoginViewModel(),
              child: Consumer<LoginViewModel>(
                builder:
                    (BuildContext context, LoginViewModel vm, Widget? child) {
                  return fluent.Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'logo/logo.png',
                          width: 200,
                        ),
                        const Text(
                          "上肢运动\n认知协同康复训练及评估系统",
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildTextField(
                          controller: vm.usernameInputController,
                          label: "用户名/邮箱",
                          keyboardType: TextInputType.phone,
                          icon: Icons.phone,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          obscureText: true,
                          controller: vm.passwordInputController,
                          label: "密码".tr(),
                          keyboardType: TextInputType.number,
                          icon: Icons.lock,
                        ),
                        const SizedBox(height: 20),
                        _buildLoginButton(vm),
                        const SizedBox(height: 20),
                        _buildRegisterButton(vm),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 新增注册按钮的方法
  Widget _buildRegisterButton(LoginViewModel vm) {
    return TextButton(
      onPressed: vm.onClickRegister,
      child: Text(
        "没有账号？点击注册".tr(), // 这里可以使用翻译
        style: const TextStyle(color: Colors.blueAccent, fontFamily: mainFont),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
    required IconData icon,
    bool obscureText = false,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: TextField(
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildLoginButton(LoginViewModel vm) {
    return fluent.Button(
      onPressed: vm.onClickLogin,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 50.0),
        child: Text(
          "登      录".tr(),
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
