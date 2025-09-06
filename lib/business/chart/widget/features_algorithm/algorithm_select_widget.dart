import 'package:eeg/business/chart/dialog/features_algorithm_dialog.dart';
import 'package:eeg/business/chart/mode/channel_alagorithm.dart';
import 'package:eeg/common/app_colors.dart';
import 'package:flutter/material.dart';

class AlgorithmSelectWidget extends ItemContainerWidget {
  final AlgorithmDatum data;
  final void Function(AlgorithmFeature, int) onSelect;

  AlgorithmSelectWidget({
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
          itemCount: data.features.length,
          itemBuilder: (context, index) {
            final item = data.features[index];
            return TextButton(
              onPressed: () => onSelect(item, index),
              child: ListTile(
                leading: const Icon(
                  Icons.featured_video_sharp,
                  color: iconColor,
                ),
                title: Text(
                    '${item.name} ${item.description.isEmpty ? '' : ' - ${item.description}'}'),
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
