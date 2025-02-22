import 'package:eeg/business/assess/page/assess_home.dart';
import 'package:eeg/business/home/viewmodel/home_viewmodel.dart';
import 'package:eeg/business/patient/page/patient_list_page.dart';
import 'package:eeg/common/widget/left_menu_page.dart';
import 'package:eeg/common/widget/title_bar.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: Container(
        color: const Color(0xFFF5F5F5),
        child: ViewModelBuilder(
          create: () => HomeViewModel(),
          child: Consumer<HomeViewModel>(
            builder: (ctx, vm, _) => Stack(
              children: [
                PanePageWidget(
                  contentTop: 40,
                  items: [
                    PanePageItem(
                      iconWidget: const Icon(FluentIcons.account_browser),
                      title: '人员列表',
                      body: PatientListPage(key: vm.assessPageKey),
                    ),
                    PanePageItem(
                      iconWidget: const Icon(FluentIcons.pivot_chart),
                      title: '评估',
                      body: AssessHomePage(key: vm.patientListKey),
                    )
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
                const TitleBar(
                  child: Center(
                    child: Text(
                      '上肢运动-认知协同康复训练及评估系统',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
