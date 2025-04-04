import 'package:eeg/business/assess/mode/assess_data.dart';
import 'package:eeg/business/assess/viewmodel/assess_select_view_model.dart';
import 'package:eeg/business/patient/mode/patient_info_mode.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:eeg/common/widget/drag_to_move_area_widget.dart';
import 'package:eeg/common/widget/enable_widget.dart';
import 'package:eeg/common/widget/loading_status_page.dart';
import 'package:eeg/core/utils/router_utils.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AssessSelectPage extends StatelessWidget {
  final Patient patient;

  const AssessSelectPage({required this.patient, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return DragToMoveWidget(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: context.popPage,
        child: GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.vertical(top: const Radius.circular(15.0)),
              color: bgColor,
            ),
            child: _buildLoadingStatusWidget(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingStatusWidget(ShadThemeData theme) {
    return LoadingPageStatusWidget<AssessSelectViewModel>(
      createOrGetViewMode: () => AssessSelectViewModel(patient),
      buildPageContent: (ctx, vm) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTitle(),
          SizedBox(height: 30),
          _buildSelectors(theme, vm),
          SizedBox(height: 30),
          EnableWidget(
            enable: vm.selectedCategory != null &&
                vm.selectedSubCategory != null &&
                vm.selectedInspectionPoint != null,
            child: ShadButton(
              onPressed: vm.onClickStartAssess,
              gradient: const LinearGradient(colors: [
                Colors.cyan,
                Colors.indigo,
              ]),
              shadows: [
                BoxShadow(
                  color: Colors.blue.withOpacity(.4),
                  spreadRadius: 4,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
              child: const Text('开始评估'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      '请选择需要评估的部位',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSelectors(ShadThemeData theme, AssessSelectViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCategorySelector(theme, vm),
        if (vm.selectedCategory?.data.isNotEmpty == true)
          _buildSubCategorySelector(theme, vm),
        if (vm.selectedSubCategory?.data.isNotEmpty == true)
          _buildInspectionPointSelector(theme, vm),
      ],
    );
  }

  Widget _buildCategorySelector(ShadThemeData theme, AssessSelectViewModel vm) {
    return ShadSelect<AssessCategory>(
      placeholder: const Text('选择评测类目'),
      options: vm.data
          .map((e) => ShadOption(
                value: e,
                child: _renderItemText(e.name, theme),
              ))
          .toList(),
      selectedOptionBuilder: (context, value) =>
          _renderItemText(value.name, theme),
      onChanged: vm.onCategoryChanged,
    );
  }

  Widget _buildSubCategorySelector(
      ShadThemeData theme, AssessSelectViewModel vm) {
    return ShadSelect<AssessSubCategory>(
      placeholder: const Text('选择部位'),
      options: vm.selectedCategory!.data
          .map((e) => ShadOption(
                value: e,
                child: _renderItemText(e.name, theme),
              ))
          .toList(),
      selectedOptionBuilder: (context, value) =>
          _renderItemText(value.name, theme),
      onChanged: vm.onSubCategoryChanged,
      controller: vm.controllerSubCategory,
    );
  }

  Widget _buildInspectionPointSelector(
      ShadThemeData theme, AssessSelectViewModel vm) {
    return ShadSelect<AssessInspectionPoint>(
      placeholder: const Text('选择子部位'),
      options: vm.selectedSubCategory!.data
          .map((e) => ShadOption(
                value: e,
                child: _renderItemText(e.name, theme),
              ))
          .toList(),
      selectedOptionBuilder: (context, value) =>
          _renderItemText(value.name, theme),
      onChanged: vm.onAssessInspectionPointChanged,
      controller: vm.controllerInspectionPoint,
    );
  }

  Text _renderItemText(String name, ShadThemeData theme) {
    return Text(
      name,
      style: theme.textTheme.muted.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.popoverForeground,
      ),
      textAlign: TextAlign.start,
    );
  }
}
