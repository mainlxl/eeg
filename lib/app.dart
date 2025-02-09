import 'package:easy_localization/easy_localization.dart';
import 'package:eeg/business/home/page/home_page.dart';
import 'package:eeg/business/user/page/login_page.dart';
import 'package:eeg/business/user/user_info.dart';
import 'package:eeg/common/font_family.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'core/base/module.dart';
import 'module.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

NavigatorState? get getAppNavigatorState => _navigatorKey.currentState;

BuildContext? get getAppContext => _navigatorKey.currentContext;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    /// Fluent_UI样式 https://bdlukaa.github.io/fluent_ui/#/inputs/buttons
    initModule();
    return FluentApp(
      debugShowCheckedModeBanner: false,
      // 关闭右上角的DEBUG标识
      navigatorKey: _navigatorKey,
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      onGenerateRoute: _generateRoute,
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      themeMode: ThemeMode.light,
      theme: FluentThemeData(
        accentColor: Colors.blue,
        fontFamily: mainFont,
        brightness: Brightness.light,
      ),
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    var name = settings.name;
    if (name != null) {
      if (name.startsWith('/')) {
        name = name.substring(1);
      }
      if (name.isNotEmpty) {
        RouteBuilder? routeBuilder = moduleRouteBuilders[name];
        if (routeBuilder != null) {
          return FluentPageRoute<dynamic>(
              builder: (context) => routeBuilder(context, settings));
        }
      }
    }
    if (UserInfo.isLogin()) {
      return FluentPageRoute(builder: (_) => const HomePage());
    } else {
      return FluentPageRoute(builder: (_) => const LoginPage());
    }
  }
}
//
// class _AppNavigatorObserver extends NavigatorObserver {
//   @override
//   void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
//     super.didPush(route, previousRoute);
//     print('didPush - ${route.settings.name}');
//   }
// }
