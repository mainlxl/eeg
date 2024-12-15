import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';

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
    extends State<ViewModelBuilder> with WidgetsBindingObserver {
  late T _viewModel;

  _ViewModelBuilderState();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this); // 注册观察者
    _viewModel = widget.create() as T;
    _viewModel.init();
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
    WidgetsBinding.instance.removeObserver(this); // 移除观察者
    if (!_viewModel.isDisposed) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 监听生命周期状态的变化
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
}

abstract class BaseViewModel extends ChangeNotifier {
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;
  BuildContext? context;

  void init() {}

  void onPageResume() {}

  void onPagePause() {}

  @mustCallSuper
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> showLoading([String msg = '加载中...']) {
    return SmartDialog.showLoading(msg: msg, clickMaskDismiss: false);
  }

  Future<void> dismissLoading() {
    return SmartDialog.dismiss(status: SmartStatus.loading);
  }
}

abstract class BasePage extends StatelessWidget {
  const BasePage({super.key});
}
