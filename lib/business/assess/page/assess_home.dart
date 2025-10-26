import 'package:eeg/business/assess/viewmodel/assess_home_view_model.dart';
import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:eeg/common/widget/drag_to_move_area_widget.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AssessHomePage extends StatelessWidget {
  final Patient? patient;

  const AssessHomePage({super.key, this.patient});

  @override
  Widget build(BuildContext context) {
    return DragToMoveWidget(
      child: ViewModelBuilder(
        create: () => AssessHomeViewModel(patient),
        child: Consumer<AssessHomeViewModel>(
          builder: (ctx, vm, _) => _renderBody(ctx, vm),
        ),
      ),
    );
  }

  //根视图
  Widget _renderBody(BuildContext ctx, AssessHomeViewModel vm) {
    return Container(
      color: bgColor,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 40),
            color: bgColor,
            child: IndexedStack(
              index: vm.selectIndex,
              children: vm.items.map((e) => e.value).toList(),
            ),
          ),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.centerLeft,
            child: fluent.BreadcrumbBar<Widget>(
              items: vm.items,
              onItemPressed: vm.onSelectedIndex,
            ),
          )
        ],
      ),
    );
  }
}
