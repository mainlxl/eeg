import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

typedef CreateViewModel<T> = T Function();

class ViewModelBuilder<T extends BaseViewModel> extends StatefulWidget {
  final CreateViewModel<T> create;
  final Widget child;

  const ViewModelBuilder(
      {super.key, required this.create, required this.child});

  @override
  State<StatefulWidget> createState() => _ViewModelBuilderState<T>();
}

class _ViewModelBuilderState<T extends BaseViewModel>
    extends State<ViewModelBuilder>
    with WidgetsBindingObserver, WindowListener {
  late T _viewModel;

  _ViewModelBuilderState();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this); // 注册观察者
    windowManager.addListener(this);
    _viewModel = widget.create() as T;
    _viewModel.init();
    _viewModel._mounted = () => mounted;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _viewModel.context = context;
    return ChangeNotifierProvider<T>(
      create: (context) => _viewModel,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    WidgetsBinding.instance.removeObserver(this);
    if (!_viewModel.isDisposed) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _viewModel.onPageResume();
        break;
      case AppLifecycleState.paused:
        _viewModel.onPagePause();
        break;
      default:
        break;
    }
  }

  @override
  void onWindowClose() async {
    if (ModalRoute.of(context)?.isCurrent == true) {
      bool isPreventClose = await windowManager.isPreventClose();
      if (isPreventClose && mounted) {
        if (!_viewModel.onClickClose()) {
          windowManager.destroy();
        }
      }
    }
  }
}

typedef Mounted = bool Function();

enum PagePopType { refreshData, deleteData }

abstract class BaseViewModel extends ChangeNotifier {
  bool _isDisposed = false;
  List<StreamSubscription> _subscriptions = [];

  bool get isDisposed => _isDisposed;
  late BuildContext context;

  late Mounted _mounted;

  /// 判断page是否位于树中
  bool get mounted => _mounted();

  void init() {}

  void onPageResume() {}

  void onPagePause() {}

  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  @mustCallSuper
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  Future<void> showLoading([String msg = '加载中...']) {
    return SmartDialog.showLoading(msg: msg, clickMaskDismiss: false);
  }

  bool isShowLoading() =>
      SmartDialog.checkExist(dialogTypes: const {SmartAllDialogType.loading});

  Future<void> hideLoading() {
    return SmartDialog.dismiss(status: SmartStatus.loading);
  }

  bool onClickClose() {
    return true;
  }
}

abstract class BasePage extends StatelessWidget {
  const BasePage({super.key});
}
