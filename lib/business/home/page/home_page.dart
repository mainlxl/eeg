import 'package:eeg/business/home/page/feature_page.dart';
import 'package:eeg/business/home/viewmodel/home_viewmodel.dart';
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
          pane: NavigationPane(
            selected: vm.selectIndex,
            onItemPressed: vm.onItemPressed,
            onChanged: vm.onHomeTabChange,
            displayMode: vm.displayMode,
            items: [
              PaneItem(
                icon: const Icon(FluentIcons.area_chart),
                title: const Text('癫痫脑内电'),
                body: const DataTablePage(),
              ),
              PaneItem(
                icon: const Icon(FluentIcons.charticulator_plot_curve),
                title: const Text('生理性脑内电'),
                body: const _NavigationBodyItem(),
              ),
              PaneItem(
                icon: const Icon(FluentIcons.charticulator_linking_sequence),
                title: const Text('睡眠脑电'),
                body: const _NavigationBodyItem(),
              ),
              PaneItem(
                icon: const Icon(FluentIcons.charticulator_linking_data),
                title: const Text('任务态脑电'),
                body: const _NavigationBodyItem(),
              ),
              PaneItem(
                icon: const Icon(FluentIcons.line_chart),
                title: const Text('产权与约定'),
                body: const _NavigationBodyItem(),
              ),
            ],
            footerItems: [
              PaneItemAction(
                icon: const Icon(FluentIcons.account_management),
                title: const Text('账户管理'),
                onTap: vm.onClickSetting,
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

class _NavigationBodyItem extends StatelessWidget {
  final String? header;
  final Widget? content;

  const _NavigationBodyItem({this.header, this.content});

  @override
  Widget build(BuildContext context) {
    return content != null
        ? content!
        : Container(
            child: Text('111'),
          );
  }
}
