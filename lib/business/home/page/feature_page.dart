import 'package:eeg/core/base/view_model_builder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DataTablePage extends StatelessWidget {
  const DataTablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DataTableViewModel>(
      create: () => DataTableViewModel(),
      child: Consumer<DataTableViewModel>(
        builder: (context, vm, _) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: '搜索',
                  suffixIcon: Icon(Icons.search),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12.0), // 优化输入框高度
                ),
                onChanged: (value) {
                  vm.onSearchChanged(value);
                },
              ),
              SizedBox(height: 8), // 调整搜索框和表格之间的间距
              Expanded(
                child: SingleChildScrollView(
                  // 添加滚动功能
                  child: DataTable(
                    columnSpacing: 16.0, // 列之间的间距
                    columns: [
                      DataColumn(label: Text('姓名')),
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('年龄')),
                      DataColumn(label: Text('性别')),
                      DataColumn(label: Text('操作')),
                    ],
                    rows: vm.filteredPatients.map((patient) {
                      int index = vm.filteredPatients.indexOf(patient);
                      return DataRow(cells: [
                        DataCell(Text(patient['姓名'])),
                        DataCell(Text(patient['ID'])),
                        DataCell(Text(patient['年龄'].toString())),
                        DataCell(Text(patient['性别'])),
                        DataCell(Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly, // 对齐按钮
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => vm.onEditPatient(context, index),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => vm.onDeletePatient(index),
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DataTableViewModel extends BaseViewModel {
  // 原始患者数据
  List<Map<String, dynamic>> patients = [
    {'姓名': 's**', 'ID': 'awake1', '年龄': 41, '性别': '男'},
    {'姓名': 'd**', 'ID': 'data-1', '年龄': 38, '性别': '女'},
    {'姓名': 'sleep**', 'ID': 'sleep-1', '年龄': 26, '性别': '男'},
    // 更多数据...
  ];

  // 搜索查询字符串
  String searchQuery = "";

  // 获取过滤后的患者数据
  List<Map<String, dynamic>> get filteredPatients {
    return patients
        .where((patient) =>
            patient['姓名'].toString().toLowerCase().contains(searchQuery) ||
            patient['ID'].toString().toLowerCase().contains(searchQuery))
        .toList();
  }

  // 搜索时更新查询字符串
  void onSearchChanged(String query) {
    searchQuery = query.toLowerCase();
    notifyListeners(); // 更新 UI
  }

  // 编辑患者数据
  void onEditPatient(BuildContext context, int index) {
    final patient = patients[index];
    final nameController = TextEditingController(text: patient['姓名']);
    final idController = TextEditingController(text: patient['ID']);
    final ageController = TextEditingController(text: patient['年龄'].toString());

    // 使用 ViewModel 的性别选择状态
    String selectedGender = patient['性别'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("编辑患者"),
              content: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0), // 添加内边距
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: "姓名"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: idController,
                      decoration: InputDecoration(labelText: "ID"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: ageController,
                      decoration: InputDecoration(labelText: "年龄"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text("性别"),
                        Radio<String>(
                          value: '男',
                          groupValue: selectedGender,
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value!;
                            });
                          },
                        ),
                        Text('男'),
                        Radio<String>(
                          value: '女',
                          groupValue: selectedGender,
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value!;
                            });
                          },
                        ),
                        Text('女'),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("取消"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 更新患者数据
                    patients[index] = {
                      '姓名': nameController.text,
                      'ID': idController.text,
                      '性别': selectedGender,
                      '年龄': int.tryParse(ageController.text) ?? 0,
                    };
                    notifyListeners(); // 更新 UI
                    Navigator.pop(context);
                  },
                  child: Text("提交"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 删除患者数据
  void onDeletePatient(int index) {
    patients.removeAt(index);
    notifyListeners(); // 更新 UI
  }
}
