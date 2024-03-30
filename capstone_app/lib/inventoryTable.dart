import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'inventoryItem.dart';
import 'database_manager.dart';

class InventoryTable extends StatefulWidget
{
  @override
  _InventoryTableState createState() => _InventoryTableState();
}

/*
class _InventoryTableState extends State<InventoryTable>
{
  List<DataRow> rows = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async
  {
    List<DataRow> newRows = await getDataRows();
    setState(() {
      rows = newRows;
    });
  }

  @override
  Widget build(BuildContext context)
  {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: <DataColumn>[
          _dataColumn("Name"),
          _dataColumn("Category"),
          _dataColumn("Purchase Date"),
          _dataColumn("Exp Date")
        ],
        rows: rows,
      ),
    );
  }

  DataColumn _dataColumn(String title)
  {
    return DataColumn(
      label: Text(
        title,
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }

  Future<List<DataRow>> getDataRows() async
  {
    DatabaseManager dbm = DatabaseManager();
    await dbm.dbSetup(); // Ensure that database is set up
    List<InventoryItem> items = await dbm.getInventory();

    List<DataRow> rows = [];



    for (InventoryItem item in items)
    {

      TextStyle rowTextStyle = TextStyle(
          color: (_isWithinTwoDays(item.expDate)) ? Colors.red : Colors.black,
          fontWeight: FontWeight.bold
      );

      DataRow row = DataRow(
        cells: <DataCell>[
          DataCell(Text(item.name, style: rowTextStyle)),
          DataCell(Text(item.category, style: rowTextStyle)),
          DataCell(Text(_formatDate(item.purchaseDate), style: rowTextStyle)),
          DataCell(Text(_formatDate(item.expDate), style: rowTextStyle))
        ],

      );

      rows.add(row);
    }

    return rows;
  }

  String _formatDate(DateTime dt) => DateFormat.yMMMd('en_US').format(dt);

  bool _isWithinTwoDays(DateTime dt) {
    DateTime now = DateTime.now();
    DateTime twoDaysFromNow = now.add(Duration(days: 2));

    return (dt.isBefore(twoDaysFromNow));

  }
}
*/

class _InventoryTableState extends State<InventoryTable> {
  List<DataRow> rows = [];
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    List<DataRow> newRows = await getDataRows();
    setState(() {
      rows = newRows;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        columns: <DataColumn>[
          _dataColumn("Name", 0),
          _dataColumn("Category", 1),
          _dataColumn("Purchase Date", 2),
          _dataColumn("Exp Date", 3)
        ],
        rows: rows,
      ),
    );
  }

  DataColumn _dataColumn(String title, int columnIndex) {
    return DataColumn(
      label: Text(
        title,
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
      onSort: (columnIndex, ascending) {
        setState(() {
          _sortColumnIndex = columnIndex;
          _sortAscending = ascending;
          _sortRows(columnIndex, ascending);
        });
      },
    );
  }

  Future<List<DataRow>> getDataRows() async {
    DatabaseManager dbm = DatabaseManager();
    await dbm.dbSetup(); // Ensure that database is set up
    List<InventoryItem> items = await dbm.getInventory();

    List<DataRow> rows = [];

    for (InventoryItem item in items) {
      TextStyle rowTextStyle = TextStyle(
          color: (_isWithinTwoDays(item.expDate)) ? Colors.red : Colors.black,
          fontWeight: FontWeight.bold);

      DataRow row = DataRow(
        cells: <DataCell>[
          DataCell(Text(item.name, style: rowTextStyle)),
          DataCell(Text(item.category, style: rowTextStyle)),
          DataCell(Text(_formatDate(item.purchaseDate), style: rowTextStyle)),
          DataCell(Text(_formatDate(item.expDate), style: rowTextStyle))
        ],
      );

      rows.add(row);
    }

    if (_sortColumnIndex != null) {
      _sortRows(_sortColumnIndex, _sortAscending);
    }

    return rows;
  }

  String _formatDate(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);

  bool _isWithinTwoDays(DateTime dt) {
    DateTime now = DateTime.now();
    DateTime twoDaysFromNow = now.add(Duration(days: 2));

    return (dt.isBefore(twoDaysFromNow));
  }

  void _sortRows(int columnIndex, bool ascending) {
    rows.sort((a, b) {
      final aValue = a.cells[columnIndex].child.toString();
      final bValue = b.cells[columnIndex].child.toString();
      return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }
}