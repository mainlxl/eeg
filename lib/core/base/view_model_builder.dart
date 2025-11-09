import 'dart:async';

import 'package:eeg/app.dart';
import 'package:eeg/core/utils/app_logger.dart';
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
  void didChangeDependencies() {
    _viewModel.didChangeDependencies();
    super.didChangeDependencies();
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
    _viewModel.didChangeAppLifecycleState(state);
  }

  @override
  void deactivate() {
    _viewModel.deactivate();
    super.deactivate();
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

abstract class EventViewModel extends BaseViewModel {
  void onEvent<T>(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    addSubscription(eventBus.on<T>().listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError));
  }

  void fireEvent(event) => eventBus.fire(event);
}

abstract class BaseViewModel extends ChangeNotifier {
  bool _isDisposed = false;
  List<StreamSubscription> _subscriptions = [];

  bool get isDisposed => _isDisposed;
  late BuildContext context;

  late Mounted _mounted;

  /// 判断page是否位于树中
  bool get mounted => _mounted();

  @mustCallSuper
  void init() {}

  /// 1. 初始化阶段：当 State 对象第一次创建并插入到树中时，didChangeDependencies 也会被调用。因此，你可以在这里执行一些与父组件或与 InheritedWidget 相关的数据初始化。
  /// 2. InheritedWidget 的依赖项变化时：当 State 对象依赖的 InheritedWidget 发生变化时，这个方法会被触发。例如，如果你使用 Provider、InheritedModel 等来管理状态，当这些数据发生变化时，didChangeDependencies 会被调用。
  void didChangeDependencies() {
    logi('Page didChangeDependencies: $runtimeType');
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {}

  /// 从树中移除时调用，通常在导航等操作中
  void deactivate() {}

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
