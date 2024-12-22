import 'package:eeg/business/user/page/login_page.dart';
import 'package:eeg/business/user/page/register_page.dart';
import 'package:eeg/core/base/module.dart';

class UserModule extends BaseModule {
  @override
  Map<String, RouteBuilder>? routeBuilders() {
    return {
      'login': (ctx, settings) => const LoginPage(),
      'register': (ctx, settings) => const RegisterPage(),
    };
  }
}
