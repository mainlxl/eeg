import 'package:flutter/material.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyPaginatedDataTable();
  }
}

class MyPaginatedDataTable extends StatelessWidget {
  final List<MyData> _data = List.generate(
    200,
    (index) => MyData(index, 'Name $index', index * 2),
  );

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable(
      header: Text('示例数据表'),
      columns: [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('名称')),
        DataColumn(label: Text('值')),
      ],
      source: MyDataSource(_data),
      onPageChanged: (int page) {
        print("Current page: $page");
      },
    );
  }
}

class MyData {
  final int id;
  final String name;
  final int value;

  MyData(this.id, this.name, this.value);
}

class MyDataSource extends DataTableSource {
  final List<MyData> _data;

  MyDataSource(this._data);

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _data.length) return null!;
    final myData = _data[index];
    return DataRow(cells: [
      DataCell(Text(myData.id.toString())),
      DataCell(Text(myData.name)),
      DataCell(Text(myData.value.toString())),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}
