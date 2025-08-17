import 'package:eeg/business/chart/mode/channel_alagorithm.dart';
import 'package:eeg/business/chart/widget/features_algorithm/algorithm_params.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:flutter/material.dart';

class AlgorithmParamsSelectWidget extends StatelessWidget {
  final AlgorithmDatum data;
  final void Function(AlgorithmDatum, int) onSelect;

  const AlgorithmParamsSelectWidget({
    super.key,
    required this.data,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
    // return AlgorithmParametersWidget(
    //   index: 0,
    //   onClick: (index, data) {},
    //   data: null,
    // );
  }
}
