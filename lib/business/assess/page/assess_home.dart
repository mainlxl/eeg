import 'package:eeg/business/assess/viewmodel/assess_home_view_model.dart';
import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/business/patient/page/patient_list_select_page.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'assess_select_mode.dart';

class AssessHomePage extends StatelessWidget {
  Patient? patient;

  AssessHomePage({super.key, this.patient});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder(
      create: () => AssessHomeViewModel(patient),
      child: Consumer<AssessHomeViewModel>(
        builder: (ctx, vm, _) => Scaffold(
          body: _renderBody(ctx, vm),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // 在这里添加按钮的点击事件
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('加号按钮被点击')),
              );
            },
            shape: RoundedRectangleBorder(
              // 设置为矩形形状
              borderRadius: BorderRadius.circular(50), // 设置圆角
            ),
            tooltip: '添加用户',
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  Widget _renderBody(BuildContext ctx, AssessHomeViewModel vm) {
    var patient = vm.patient;
    if (patient == null) {
      return PatientListSelectPage(onSelect: vm.onSelectPatient);
    }
    return NavigationView(
      pane: NavigationPane(
          selected: vm.selectIndex,
          onItemPressed: vm.onItemPressed,
          onChanged: vm.onHomeTabChange,
          displayMode: vm.displayMode,
          items: [
            PaneItem(
              icon: const Icon(FluentIcons.info),
              title: const Text('基本信息'),
              body: const AssessSelectModePage(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.document),
              title: const Text('评估方案'),
              body: const AssessSelectModePage(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.build),
              title: const Text('训练策略'),
              body: const AssessSelectModePage(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.line_chart),
              title: const Text('数据分析'),
              body: const AssessSelectModePage(),
            ),
            PaneItem(
              icon: const Icon(material.Icons.report),
              title: const Text('康复报告'),
              body: const AssessSelectModePage(),
            ),
          ],
          footerItems: [
            PaneItemAction(
              icon: const Icon(FluentIcons.settings),
              title: const Text('设置'),
              onTap: vm.onClickSetting,
            ),
          ]),
    );
  }
}
