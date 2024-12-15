import 'package:easy_localization/easy_localization.dart';
import 'package:eeg/business/user/viewmodel/login_view_model.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends BasePage {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30.0),
        alignment: Alignment.center,
        child: ViewModelBuilder<LoginViewModel>(
          create: () => LoginViewModel(),
          child: Consumer<LoginViewModel>(
            builder:
                (BuildContext context, LoginViewModel vm, Widget? child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/icon/head1.png',
                    width: 200,
                  ),
                  const Text(
                    "上肢运动-认知协同康复训练及评估系统",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
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
              );
            },
          ),
        ),
      ),
    );
  }

  // 新增注册按钮的方法
  Widget _buildRegisterButton(LoginViewModel vm) {
    return TextButton(
      onPressed: vm.onClickRegister,
      child: Text(
        "没有账号？点击注册".tr(), // 这里可以使用翻译
        style: const TextStyle(color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
    required IconData icon,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: TextField(
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
    return ElevatedButton(
      onPressed: vm.onClickLogin,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
      ),
      child: Text(
        "登录".tr(),
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
