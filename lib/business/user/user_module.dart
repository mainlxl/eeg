import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eeg/business/user/page/login_page.dart';
import 'package:eeg/business/user/page/register_page.dart';
import 'package:eeg/business/user/user_info.dart';
import 'package:eeg/core/base/module.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:eeg/core/utils/config.dart';
import 'package:eeg/core/utils/toast.dart';

class UserModule extends BaseModule {
  @override
  void onAppCreate() {
    super.onAppCreate();
    HttpService().addInterceptors(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (UserInfo.token.isNotEmpty) {
            options.headers['Authorization'] = UserInfo.token;
          }
          if (UserInfo.userId.isNotEmpty) {
            options.headers['id'] = UserInfo.userId;
          }
          return handler.next(options); // continue
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == HttpStatus.unauthorized) {
            onServerUnauthorized(e.requestOptions.path);
          }
          // 处理错误xRXWW
          print('错误: ${e.message}');
          return handler.next(e); // continue
        },
      ),
    );
  }

  @override
  Map<String, RouteBuilder>? routeBuilders() {
    return {
      'login': (ctx, settings) => const LoginPage(),
      'register': (ctx, settings) => const RegisterPage(),
    };
  }

  //服务器返回未登录时
  void onServerUnauthorized(String path) {
    if (isDebug) {
      return;
    }
    if (!path.endsWith('/login')) {
      '登录已过期'.showToast();
      UserInfo.cleanTaskAndPushLoginPage();
    }
  }
}
