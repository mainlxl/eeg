import 'package:eeg/business/home/viewmodel/home_viewmodel.dart';
import 'package:eeg/business/patient/page/patient_list_page.dart';
import 'package:eeg/common/widget/title_bar.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder(
      create: () => HomeViewModel(),
      child: Consumer<HomeViewModel>(
        builder: (ctx, vm, _) => NavigationView(
          appBar: const NavigationAppBar(
            automaticallyImplyLeading: true,
            title: TitleBar(
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
          ),
          pane: NavigationPane(
            selected: vm.selectIndex,
            onItemPressed: vm.onItemPressed,
            onChanged: vm.onHomeTabChange,
            displayMode: vm.displayMode,
            items: [
              PaneItem(
                icon: const Icon(FluentIcons.line_chart),
                title: const Text('所有用户'),
                body: PatientListPage(),
              ),
            ],
            footerItems: [
              PaneItemAction(
                icon: const Icon(FluentIcons.account_management),
                title: const Text('添加用户'),
                onTap: vm.onClickAddPatient,
              ),
              PaneItemAction(
                icon: const Icon(FluentIcons.block_contact),
                title: const Text('退出登录'),
                onTap: vm.onClickSignOut,
              ),
              // PaneItemAction(
              //   icon: const Icon(FluentIcons.settings),
              //   title: const Text('设置'),
              //   onTap: vm.onClickSetting,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
