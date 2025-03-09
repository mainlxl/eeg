import 'package:eeg/business/home/page/home_page.dart';
import 'package:eeg/business/test/page/test_widget.dart';
import 'package:eeg/business/test/viewmodel/home_test_viewmodel.dart';
import 'package:eeg/common/widget/left_menu_page.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class TestHomePage extends StatelessWidget {
  const TestHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
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
