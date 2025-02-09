import 'package:eeg/business/home/home_module.dart';
import 'package:eeg/business/patient/patient_module.dart';
import 'package:eeg/business/user/user_module.dart';
import 'package:eeg/core/base/module.dart';

final Map<String, RouteBuilder> _routeBuilders = {};

Map<String, RouteBuilder> get moduleRouteBuilders => _routeBuilders;

void registerModule(BaseModule module) {
  module.onAppCreate();
  var route = module.routeBuilders();
  if (route != null) {
    _routeBuilders.addAll(route);
  }
}

/// 注册对应module
void initModule() {
  registerModule(HomeModule());
  registerModule(UserModule());
  registerModule(PatientModule());
}
