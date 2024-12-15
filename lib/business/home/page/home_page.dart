import 'package:eeg/business/home/viewmodel/home_viewmodel.dart';
import 'package:eeg/core/base/view_model_builder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ViewModelBuilder(
          create: () => HomeViewModel(),
          child: Consumer<HomeViewModel>(
            builder: (ctx, vm, _) => Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 50),
                child: LayoutBuilder(builder: (context, constraints) {
                  // 获取屏幕的宽度
                  double width = constraints.maxWidth;
                  int crossAxisCount = (width / 200).floor();
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    children: <Widget>[
                      buildCard('癫痫脑内电', Icons.electrical_services,
                          vm.onClickEpilepsyElectroencephalogram),
                      buildCard('生理性脑内电', Icons.grain,
                          vm.onClickEpilepsyElectroencephalogram),
                      buildCard('睡眠脑电', Icons.nights_stay,
                          vm.onClickEpilepsyElectroencephalogram),
                      buildCard('任务态脑电', Icons.task,
                          vm.onClickEpilepsyElectroencephalogram),
                      buildCard('产权与约定', Icons.assignment,
                          vm.onClickEpilepsyElectroencephalogram),
                      buildCard('账户管理', Icons.account_circle,
                          vm.onClickEpilepsyElectroencephalogram),
                    ],
                  );
                }),
              ),
            ),
          )),
    );
  }

  Widget buildCard(String title, IconData icon, GestureTapCallback? onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 50, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
