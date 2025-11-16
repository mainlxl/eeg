import 'package:eeg/business/assess/widgets/game_cognition_color_widget.dart';
import 'package:eeg/business/assess/widgets/game_cognition_image_widget.dart';
import 'package:eeg/business/assess/widgets/game_cognition_number_widget.dart';
import 'package:eeg/business/home/page/home_page.dart';
import 'package:eeg/business/test/page/test_widget.dart';
import 'package:eeg/business/test/viewmodel/home_test_viewmodel.dart';
import 'package:eeg/common/widget/drag_to_move_area_widget.dart';
import 'package:eeg/common/widget/left_menu_page.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:eeg/core/utils/toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

class TestHomePage extends StatelessWidget {
  const TestHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DragToMoveWidget(
      child: Container(
        color: const Color(0xFFF5F5F5),
        child: ViewModelBuilder(
          create: () => TestViewModel(),
          child: Consumer<TestViewModel>(
            builder: (ctx, vm, _) => Stack(
              children: [
                PanePageWidget(
                  items: [
                    PanePageItem(
                      iconWidget: const Icon(FluentIcons.pivot_chart),
                      title: '评估游戏0',
                      body: GameCognitionImageWidget(
                        onResetControlChange: (reset) {},
                        onFinish: (correctCount, count) {
                          '评估完成，正确率：${correctCount / count}'.toast;
                        },
                      ),
                    ),
                    PanePageItem(
                      iconWidget: const Icon(FluentIcons.pivot_chart),
                      title: '评估游戏1',
                      body: GameCognitionNumberWidget(
                        onResetControlChange: (reset) {},
                        onFinish: (correctCount, count) {
                          '评估完成，正确率：${correctCount / count}'.toast;
                        },
                      ),
                    ),
                    PanePageItem(
                      iconWidget: const Icon(FluentIcons.pivot_chart),
                      title: '评估游戏2',
                      body: GameCognitionColorWidget(
                        onResetControlChange: (reset) {},
                        onFinish: (correctCount, count) {
                          '评估完成，正确率：${correctCount / count}'.toast;
                        },
                      ),
                    ),
                    PanePageItem(
                      iconWidget: const Icon(FluentIcons.pivot_chart),
                      title: 'TestPage',
                      body: TestPage(),
                    ),
                    PanePageItem(
                      iconWidget: const Icon(FluentIcons.pivot_chart),
                      title: '测试首页',
                      body: HomePage(key: vm.patientListKey),
                    ),
                  ],
                  bottomItems: [
                    PanePageItem(
                      iconWidget: const Icon(FluentIcons.add),
                      title: '添加用户',
                      onClick: () {
                        vm.onClickAddPatient();
                        return true;
                      },
                    ),
                    PanePageItem(
                      iconWidget: const Icon(FluentIcons.block_contact),
                      title: '退出登录',
                      onClick: () {
                        vm.onClickSignOut();
                        return true;
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
