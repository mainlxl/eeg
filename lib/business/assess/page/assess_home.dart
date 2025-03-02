import 'package:eeg/business/assess/viewmodel/assess_home_view_model.dart';
import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class AssessHomePage extends StatelessWidget {
  Patient? patient;

  AssessHomePage({super.key, this.patient});

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: ViewModelBuilder(
        create: () => AssessHomeViewModel(patient),
        child: Consumer<AssessHomeViewModel>(
          builder: (ctx, vm, _) => _renderBody(ctx, vm),
        ),
      ),
    );
  }

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
    // return fluent.NavigationView(
    //   pane: fluent.NavigationPane(
    //       selected: vm.selectIndex,
    //       onItemPressed: vm.onItemPressed,
    //       onChanged: vm.onHomeTabChange,
    //       displayMode: vm.displayMode,
    //       items: [
    //         fluent.PaneItem(
    //           icon: const Icon(fluent.FluentIcons.info),
    //           title: const Text('基本信息'),
    //           body: PatientDetailPage(patient: patient, embed: true),
    //         ),
    //         fluent.PaneItem(
    //           icon: const Icon(fluent.FluentIcons.document),
    //           title: const Text('评估方案'),
    //           body: const AssessSelectModePage(),
    //         ),
    //         fluent.PaneItem(
    //           icon: const Icon(fluent.FluentIcons.build),
    //           title: const Text('训练策略'),
    //           body: const AssessSelectModePage(),
    //         ),
    //         fluent.PaneItem(
    //           icon: const Icon(fluent.FluentIcons.line_chart),
    //           title: const Text('数据分析'),
    //           body: const AssessSelectModePage(),
    //         ),
    //         fluent.PaneItem(
    //           icon: const Icon(Icons.report),
    //           title: const Text('康复报告'),
    //           body: const AssessSelectModePage(),
    //         ),
    //       ],
    //       footerItems: [
    //         fluent.PaneItemAction(
    //           icon: const Icon(fluent.FluentIcons.settings),
    //           title: const Text('设置'),
    //           onTap: vm.onClickSetting,
    //         ),
    //       ]),
    // );
  }
}
