import 'package:eeg/business/assess/mode/assess_data.dart';
import 'package:eeg/business/assess/viewmodel/assess_view_model.dart';
import 'package:eeg/business/chart/page/chart_page.dart';
import 'package:eeg/business/patient/mode/patient_info_mode.dart';
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
    return DragToMoveArea(
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
    return PanePageWidget(
      items: data.dataList.map((item) {
        return PanePageItem(
          iconWidget: Icon(data.isImage ? Icons.image : Icons.ondemand_video),
          title: item,
          needSaveDate: data.isImage,
          body: Container(
            constraints: BoxConstraints.expand(),
            color: Colors.white,
            alignment: Alignment.center,
            child: _renderResource(vm, data, '${data.dataPath}/${item}'),
          ),
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
    );
  }

  Widget _renderResource(AssessViewModel vm, AssessData data, String url) {
    return data.isVideo
        ? VideoWidget(player: vm.player)
        : Image.network(url, fit: BoxFit.cover);
  }
}
