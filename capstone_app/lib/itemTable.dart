import 'package:capstone_app/item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'item.dart';
import 'database_manager.dart';

class ItemTable extends StatefulWidget
{

  String _itemCategorySearch = "";


  ItemTable(this._itemCategorySearch);

  @override
  _ItemTableState createState() => _ItemTableState(_itemCategorySearch);
}

class _ItemTableState extends State<ItemTable>
{
  _ItemTableState(this.itemCategorySearch);

  List<DataRow> rows = []; // a list of rows of data

  String itemCategorySearch = "";

  int _sortColumnIndex = 0; // the index of the column that the table is sorting by
  bool _sortAscending = true; // boolean to specify ascending or descending sorting order

  TextEditingController _searchController = TextEditingController(); // Controller for search field
  String _searchQuery = ''; // Variable to hold the current search query

  bool _isLoading = false; // Indicates whether data is being fetched

  @override
  void initState()
  {
    super.initState();
    fetchData(); // fetch data when a UI update is called
  }

  // function to fetch table data
  Future<void> fetchData() async
  {
    setState(()
    {
      _isLoading = true; // set loading boolean to true
    });

    List<DataRow> newRows = await getDataRows(); // get rows

    setState(()
    {
      rows = newRows;
      _isLoading = false; // set loading to false
    });
  }

  // the column header objects, takes in the title and the column index
  DataColumn _dataColumn(String title, int columnIndex)
  {
    return DataColumn(
      label: Text(
        title,
        style: const TextStyle(fontStyle: FontStyle.italic),
      ),
      onSort: (columnIndex, ascending)
      {
        setState(()
        {
          // set the column to sort and asc/desc, then sort the rows
          _sortColumnIndex = columnIndex;
          _sortAscending = ascending;
          _sortRows(columnIndex, ascending);
        });
      },
    );
  }

  // get data from database
  Future<List<DataRow>> getDataRows() async
  {
    DatabaseManager dbm = DatabaseManager(); // database manager class
    await dbm.dbSetup(); // Ensure that database is set up

    // get the items from db
    List<Item> items = (itemCategorySearch == "All Items") ?
    await dbm.getAllItems() : await dbm.getItemsByCategory(itemCategorySearch);

    List<DataRow> rows = []; // list of data rows

    // iterate through each item in the dataset
    for (Item item in items)
    {
      // make a text style to be used by the table cells
      TextStyle rowTextStyle = const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold
      );

      // make a row for each item
      DataRow row = DataRow(
        cells: <DataCell>[
          DataCell(Text(item.name, style: rowTextStyle)),
          DataCell(Text(item.category, style: rowTextStyle))
        ],
      );

      rows.add(row); // add the row to the rows list
    }

    // sort rows if needed
    if (_sortColumnIndex != null)
    {
      _sortRows(_sortColumnIndex, _sortAscending);
    }

    // return the rows list
    return rows;
  }

  // function to sort table by column and if asc/desc
  void _sortRows(int columnIndex, bool ascending)
  {
    // sorts the rows
    rows.sort((a, b)
    {
      final aValue = a.cells[columnIndex].child.toString();
      final bValue = b.cells[columnIndex].child.toString();
      return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  // search table when search box is updated
  void _searchData(String query)
  {
    setState(() {
      _searchQuery = query.toLowerCase(); // set search query to search box text
    });
  }

  List<DataRow> _filteredRows()
  {
    // Filter rows based on search query
    if (_searchQuery.isEmpty)
    {
      return rows;
    }

    // filter the rows by the search query
    return rows.where((row)
    {
      // Check if any cell value contains the search query
      return row.cells.any((cell) =>
          cell.child
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()));
    }).toList();

  }

  @override
  Widget build(BuildContext context)
  {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            onChanged: _searchData,
            decoration: InputDecoration(
              labelText: 'Search',
              hintText: 'Search items...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ),
        Expanded(
          // add a loading circle if data is being fetched
          child: _isLoading ?
          const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  Text(
                    "Loading Items",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),
                  )
                ],
              )
          ) :
          // display text if rows are empty, otherwise display table
          rows.isEmpty ? const Center(
              child: Text(
                "No Custom Items!\n Press the '+' to add an item!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
              )
          ) : SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                columns: <DataColumn>[
                  _dataColumn("Name", 0),
                  _dataColumn("Category", 1)
                ],
                rows: _filteredRows(), // Use filtered rows
              ),
            ),
          ),
        ),
      ],
    );
  }


}
