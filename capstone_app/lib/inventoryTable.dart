import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'inventoryItem.dart';
import 'database_manager.dart';


class InventoryTable extends StatefulWidget
{
  const InventoryTable({super.key});

  @override
  _InventoryTableState createState() => _InventoryTableState();
}


class _InventoryTableState extends State<InventoryTable>
{
  List<DataRow> rows = []; // a list of rows of data
  int _sortColumnIndex = 0; // the index of the column that the table is sorting by
  bool _sortAscending = true; // boolean to specify ascending or descending sorting order

  TextEditingController _searchController = TextEditingController(); // Controller for search field
  String _searchQuery = ''; // Variable to hold the current search query

  bool _isLoading = false; // Indicates whether data is being fetched

  DatabaseManager dbm = DatabaseManager();


  _InventoryTableState()
  {
    dbm.dbSetup();
  }

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
    List<InventoryItem> items = await dbm.getInventory(); // get the items from db

    List<DataRow> rows = []; // list of data rows

    // iterate through each item in the dataset
    for (InventoryItem item in items)
    {
      // make a text style to be used by the table cells
      // text is red if the item is within two days of expiring
      TextStyle rowTextStyle = TextStyle(
          color: (_isWithinTwoDays(item.expDate)) ? Colors.red : Colors.black,
          fontWeight: FontWeight.bold
      );


      // make a row for each item
      DataRow row = DataRow(
        cells: <DataCell>[
          DataCell(Text(item.name, style: rowTextStyle)),
          DataCell(Text(item.category, style: rowTextStyle)),
          DataCell(Text(_formatDate(item.purchaseDate), style: rowTextStyle)),
          DataCell(Text(_formatDate(item.expDate), style: rowTextStyle)),
          DataCell(
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: ()
                  {
                    // Implement your edit functionality here
                    // You can navigate to a new screen or show a dialog to edit the item
                    print('Edit button pressed for ${item.name}');
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: ()
                  {
                      dbm.removeItemFromInventory(item.id);
                  },
                )
              ],
            )

          )
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

  // function to format datetime int YYYY-MM-DD format
  String _formatDate(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);

  // function to check if a datetime is less than 2 days away
  bool _isWithinTwoDays(DateTime dt)
  {
    DateTime now = DateTime.now();
    DateTime twoDaysFromNow = now.add(const Duration(days: 2));

    return (dt.isBefore(twoDaysFromNow));
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
                  "Loading Pantry",
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
                "Your Pantry Is Empty!\n Press the '+' to add an item!",
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
                  _dataColumn("Category", 1),
                  _dataColumn("Purchase Date", 2),
                  _dataColumn("Exp Date", 3),
                  const DataColumn(label: Text(""))
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
