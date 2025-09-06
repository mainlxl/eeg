import 'package:eeg/business/chart/dialog/features_algorithm_dialog.dart';
import 'package:eeg/business/chart/mode/channel_alagorithm.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:flutter/material.dart';

class FeaturesAlgorithmSelectWidget extends ItemContainerWidget {
  final List<AlgorithmDatum> data;
  final void Function(AlgorithmDatum, int) onSelect;

  FeaturesAlgorithmSelectWidget({
    super.key,
    required this.data,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        return GridView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return TextButton(
              onPressed: () => onSelect(item, index),
              child: ListTile(
                leading: const Icon(
                  Icons.feed_outlined,
                  color: iconColor,
                ),
                title: Text(item.category),
              ),
            );
          },
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: (availableWidth / 3) / 100,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
        );
      },
    );
  }
}
