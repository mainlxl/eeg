import 'package:eeg/business/assess/mode/assess_data.dart';
import 'package:eeg/business/assess/viewmodel/assess_view_model.dart';
import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/common/widget/drag_to_move_area_widget.dart';
import 'package:eeg/common/widget/left_menu_page.dart';
import 'package:eeg/common/widget/video_widget.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:eeg/core/utils/router_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AssessPage extends StatelessWidget {
  final Patient patient;
  final AssessCategory selectedCategory;
  final AssessSubCategory selectedSubCategory;
  final AssessInspectionPoint assessInspectionPoint;

  const AssessPage(
      {super.key,
      required this.patient,
      required this.assessInspectionPoint,
      required this.selectedCategory,
      required this.selectedSubCategory});

  @override
  Widget build(BuildContext context) {
    return DragToMoveWidget(
      child: ViewModelBuilder<AssessViewModel>(
        create: () => AssessViewModel(patient, selectedCategory,
            selectedSubCategory, assessInspectionPoint),
        child: Consumer<AssessViewModel>(
          builder: (context, vm, _) => _renderBody(context, vm),
        ),
      ),
    );
  }

  Widget _renderBody(BuildContext context, AssessViewModel vm) {
    AssessData data = vm.data;
    return Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
        color: Color(0xffc7edcc),
        border: Border(
          top: const BorderSide(color: Color(0xFF1976D2), width: 20), // 上边框
          bottom: const BorderSide(color: Color(0xFF1976D2), width: 20), // 下边框
        ),
        borderRadius: BorderRadius.circular(5), // 圆角边框
      ),
      alignment: Alignment.center,
      child: PanePageWidget(
        items: data.dataList.map((item) {
          return PanePageItem(
            iconWidget: Icon(data.isImage
                ? Icons.image
                : (data.isGame ? Icons.view_compact : Icons.ondemand_video)),
            title: item,
            needSaveDate: data.isImage,
            body: _buildAssessWidget(data, vm, item),
          );
        }).toList(),
        controller: vm.controller,
        bottomItems: [
          if (vm.enableUploadData)
            PanePageItem(
              iconWidget: const Icon(Icons.upload_file),
              title: '上传评估数据',
              onClick: () {
                vm.onClickUploadData();
                return true;
              },
            ),
          if (data.isImage)
            PanePageItem(
              iconWidget: const Icon(Icons.podcasts),
              title:
                  '循环次数:${vm.currentImageCount.clamp(0, vm.imageCount)}/${vm.imageCount}',
              onClick: () => true,
            ),
          if (data.isImage)
            PanePageItem(
              iconWidget: const Icon(Icons.change_circle),
              title: '调整播放频率',
              onClick: () {
                vm.onClickChangeFrequency(data);
                return true;
              },
            ),
          PanePageItem(
            iconWidget: const Icon(Icons.transfer_within_a_station_outlined),
            title: '重新评估',
            onClick: () {
              vm.onClickRetryAssess();
              return true;
            },
          ),
          PanePageItem(
            iconWidget: const Icon(Icons.cancel_presentation),
            title: '退出评估',
            onClick: () {
              context.popPage();
              return true;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAssessWidget(AssessData data, AssessViewModel vm, String item) {
    final widget = data.isGame
        ? data.gameBuild!.call(vm.onGameFinish, vm.onResetControlChange)
        : _renderResource(vm, data, '${data.dataPath}/$item');
    if (vm.isImageTimerIntermittent) {
      return Stack(
        children: [widget, _buildTimerIntermittent(data, vm, item)],
      );
    }
    return widget;
  }

  Widget _renderResource(AssessViewModel vm, AssessData data, String url) {
    return data.isVideo
        ? VideoWidget(player: vm.player)
        : Container(
            constraints: BoxConstraints.expand(),
            padding: const EdgeInsets.all(60),
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: 500),
              child: Image.network(url, fit: BoxFit.cover),
            ),
          );
  }

  Widget _buildTimerIntermittent(
      AssessData data, AssessViewModel vm, String item) {
    return Container(
      constraints: BoxConstraints.expand(),
      alignment: Alignment.topCenter,
      color: Colors.black12,
      padding: const EdgeInsets.only(top: 10),
      child: Text('运动间歇中，请熟悉一下动作......',
          style: TextStyle(fontSize: 30, color: Colors.red.shade500)),
    );
  }
}
