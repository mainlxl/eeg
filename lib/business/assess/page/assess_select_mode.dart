import 'package:eeg/business/assess/viewmodel/assess_select_mode_view_model.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AssessSelectModePage extends StatelessWidget {
  const AssessSelectModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AssessSelectModePageViewModel>(
      create: () => AssessSelectModePageViewModel(),
      child: Consumer<AssessSelectModePageViewModel>(
        builder: (context, vm, _) => _renderBody(context, vm),
      ),
    );
  }

  Widget _renderBody(BuildContext context, AssessSelectModePageViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: vm.onClickAssessMovement,
          child: const Card(
            elevation: 1,
            margin: EdgeInsets.all(30),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("运动功能"),
            ),
          ),
        ),
        const SizedBox(width: 100),
        GestureDetector(
          onTap: vm.onClickAssessCognitiveFunction,
          child: const Card(
            elevation: 1,
            margin: EdgeInsets.all(30),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("认知功能"),
            ),
          ),
        ),
      ],
    );
  }
}
