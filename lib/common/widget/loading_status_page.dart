import 'package:eeg/common/app_colors.dart';
import 'package:eeg/common/widget/drag_to_move_area_widget.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum PageStatus { idle, loading, error, empty, loadingSuccess }

abstract class LoadingPageStatusViewModel extends BaseViewModel {
  PageStatus _pageStatus = PageStatus.idle;

  PageStatus get pageStatus => _pageStatus;

  void setPageStatus(PageStatus status, [bool refreshPage = true]) {
    _pageStatus = status;
    if (refreshPage) {
      notifyListeners();
    }
  }

  void onClickRetryLoadingData();
}

typedef BuildPageContent<T> = Widget Function(
    BuildContext context, T viewModel);

class LoadingPageStatusWidget<T extends LoadingPageStatusViewModel>
    extends StatelessWidget {
  final CreateViewModel<T> createOrGetViewMode;
  final BuildPageContent<T> buildPageContent;
  final bool enableDragToMove;
  final bool needViewModelBuild;

  final String? networkBlockedDesc;
  final String? errorDesc;

  const LoadingPageStatusWidget(
      {super.key,
      required this.createOrGetViewMode,
      required this.buildPageContent,
      this.networkBlockedDesc,
      this.enableDragToMove = false,
      this.needViewModelBuild = true,
      this.errorDesc});

  @override
  Widget build(BuildContext context) {
    var content = needViewModelBuild
        ? ViewModelBuilder<T>(
            create: createOrGetViewMode,
            child: Consumer<T>(
              builder: (ctx, vm, _) => _buildStatusPageContent(context, vm),
            ),
          )
        : _buildStatusPageContent(context, createOrGetViewMode());
    return enableDragToMove ? DragToMoveWidget(child: content) : content;
  }

  Widget _buildStatusPageContent(BuildContext context, T viewModel) {
    if (viewModel._pageStatus == PageStatus.loading) {
      return _buildLoadingView();
    } else if (viewModel._pageStatus == PageStatus.error) {
      return _buildGeneralTapView(
        assetImage: "images/loading/icon_network_blocked.png",
        desc: networkBlockedDesc ?? '加载失败, 请确保网络畅通后重试',
        onTap: viewModel.onClickRetryLoadingData,
      );
    } else if (viewModel._pageStatus == PageStatus.empty) {
      return _buildGeneralTapView(
        assetImage: "images/loading/icon_empty.png",
        desc: "暂无数据",
        onTap: null,
      );
    }
    return buildPageContent(context, viewModel);
  }
}

Widget _buildLoadingView() {
  return SizedBox(
    width: double.maxFinite,
    height: double.maxFinite,
    child: Center(
      child: SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
        ),
      ),
    ),
  );
}

/// 编译通用页面
Container _buildGeneralTapView({
  required String assetImage,
  required String desc,
  required VoidCallback? onTap,
}) {
  return Container(
    color: bgColor,
    child: Center(
      child: SizedBox(
        height: 250,
        child: Column(
          children: [
            Image.asset(assetImage, width: 140, height: 99),
            SizedBox(height: 20),
            Text(
              desc,
              style: TextStyle(color: subtitleColor, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 20),
            if (onTap != null)
              BorderRedBtnWidget(content: "重新加载", onClick: onTap),
          ],
        ),
      ),
    ),
  );
}

class BorderRedBtnWidget extends StatelessWidget {
  const BorderRedBtnWidget({
    super.key,
    @required content,
    @required onClick,
  })  : _content = content,
        _onClick = onClick;

  final String _content;
  final VoidCallback _onClick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {},
      behavior: HitTestBehavior.opaque,
      child: TextButton(
        onPressed: _onClick,
        child: Text(_content),
      ),
    );
  }
}
