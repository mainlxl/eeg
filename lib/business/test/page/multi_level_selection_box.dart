import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MultiLevelSelectionBox extends StatelessWidget {
  MultiLevelSelectionBox({super.key});

  ShadSelectController<String> controller1 = ShadSelectController();
  ShadSelectController<String> controller2 = ShadSelectController();
  ShadSelectController<String> controller3 = ShadSelectController();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        ShadSelect<String>(
          placeholder: const Text('选择上肢部位'),
          options: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 6, 6, 6),
              child: Text(
                '上肢',
                style: theme.textTheme.muted.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.popoverForeground,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            ShadOption(value: "碗关节", child: Text('碗关节')),
            ShadOption(value: "肘关节", child: Text('肘关节')),
            ShadOption(value: "肩关节", child: Text('肩关节')),
            ShadOption(value: "多关节", child: Text('多关节')),
          ],
          selectedOptionBuilder: (context, value) => Text(value),
          controller: controller1,
          onChanged: (selected) {},
        ),
        ShadSelect<String>(
          placeholder: const Text('选择上肢部位'),
          options: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 6, 6, 6),
              child: Text(
                '上肢',
                style: theme.textTheme.muted.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.popoverForeground,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            ShadOption(value: "碗关节", child: Text('碗关节')),
            ShadOption(value: "肘关节", child: Text('肘关节')),
            ShadOption(value: "肩关节", child: Text('肩关节')),
            ShadOption(value: "多关节", child: Text('多关节')),
          ],
          selectedOptionBuilder: (context, value) => Text(value),
          controller: controller2,
          onChanged: print,
        ),
        ShadSelect<String>(
          placeholder: const Text('选择上肢部位'),
          options: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 6, 6, 6),
              child: Text(
                '上肢',
                style: theme.textTheme.muted.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.popoverForeground,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            ShadOption(value: "碗关节", child: Text('碗关节')),
            ShadOption(value: "肘关节", child: Text('肘关节')),
            ShadOption(value: "肩关节", child: Text('肩关节')),
            ShadOption(value: "多关节", child: Text('多关节')),
          ],
          selectedOptionBuilder: (context, value) => Text(value),
          onChanged: print,
          controller: controller3,
        ),
      ],
    );
  }
}
