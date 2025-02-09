import 'package:easy_localization/easy_localization.dart';
import 'package:eeg/business/user/viewmodel/register_viewmodel.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends BasePage {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: fluent.Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // 背景颜色
            borderRadius: const BorderRadius.all(Radius.circular(20)), // 圆角半径
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // 阴影颜色
                spreadRadius: 2, // 阴影扩散半径
                blurRadius: 5, // 模糊半径
                offset: const Offset(0, 3), // 阴影偏移
              ),
            ],
          ),
          padding: const EdgeInsets.all(50),
          child: ViewModelBuilder<RegisterViewModel>(
            create: () => RegisterViewModel(),
            child: Consumer<RegisterViewModel>(
              builder:
                  (BuildContext context, RegisterViewModel vm, Widget? child) {
                return IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "注册",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildTextField(
                        controller: vm.usernameInputController,
                        label: "用户名",
                        keyboardType: TextInputType.text,
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 30),
                      _buildTextField(
                        controller: vm.emailInputController,
                        label: "邮箱",
                        keyboardType: TextInputType.text,
                        icon: Icons.email,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        obscureText: true,
                        controller: vm.passwordInputController,
                        label: "密码".tr(),
                        keyboardType: TextInputType.text,
                        icon: Icons.lock,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        obscureText: true,
                        controller: vm.passwordInputCheckController,
                        label: "确认密码".tr(),
                        keyboardType: TextInputType.text,
                        icon: Icons.lock,
                      ),
                      const SizedBox(height: 20),
                      _buildRegisterButton(vm),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // 注册按钮
  Widget _buildRegisterButton(RegisterViewModel vm) {
    return fluent.FilledButton(
      onPressed: vm.onClickRegister,
      child: fluent.Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 50.0),
        child: Text(
          "注   册".tr(),
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  // 输入框构建方法
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
}
