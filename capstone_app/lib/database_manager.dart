import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;


import 'item.dart';
import 'inventoryItem.dart';

class DatabaseManager
{
  static String dbname = "pantry.db"; // database name
  static var db; // database variable
  var path; // path variable


  // database setup function
  dbSetup() async
  {
    // get databases dath
    var databasesPath = await getDatabasesPath();

    // join the database to the path
    path = join(databasesPath, dbname);

    // db exists
    if(await File(path).exists())
    {
      print("DB exists");
    }

    // open the database
    db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async
      {
        await createInventoryTable(db);
        await createItemsListTable(db);
        await addJSONIntoItemsList(db);
      }
    );


  }


  /*
  SQLite data types

  NULL. The value is a NULL value.

  INTEGER. The value is a signed integer, stored in 0, 1, 2, 3, 4, 6, or 8 bytes depending on the magnitude of the value.

  REAL. The value is a floating point value, stored as an 8-byte IEEE floating point number.

  TEXT. The value is a text string, stored using the database encoding (UTF-8, UTF-16BE or UTF-16LE).

  BLOB. The value is a blob of data, stored exactly as it was input.
  */


  // create the inventory table
  createInventoryTable(Database db) async
  {
    await db.execute("""
      
    CREATE TABLE tbl_inventory(
      name            TEXT,
      category        TEXT,
      purchase_date   TEXT,
      exp_date        TEXT,
      id              INTEGER PRIMARY KEY
    );
      
    """);
  }

  // create the item table
  createItemsListTable(Database db) async
  {
    await db.execute("""
      
    CREATE TABLE tbl_itemslist(
      name            TEXT,
      category        TEXT,
      shelf_life      INTEGER,
      id              INTEGER PRIMARY KEY
    );
      
    """);
  }


  addJSONIntoItemsList(Database db) async
  {
    try
    {
      String jsonString = await rootBundle.loadString('data/items.json');
      var data = jsonDecode(jsonString);

      for (int i = 0; i < data.length; i++)
      {
        Item item = Item(data[i]['Name'], data[i]['Category'], data[i]['Shelf Life']);

        await insertIntoListTable(item, db);
      }
    }
    catch (e)
    {
      print('Error loading JSON: $e');
    }
  }

  // insert an item into item list table
  insertIntoListTable(Item item, Database db) async
  {

    String xsql = """
    INSERT INTO tbl_itemslist(name,category,shelf_life) VALUES
      ('${item.name}','${item.category}','${item.shelfLife}')
    """;

    await db.rawInsert(xsql);
  }


  // insert an item into inventory table
  insertIntoInventoryTable(InventoryItem item) async
  {
    String purchaseDateString = dateTimeToString(item.purchaseDate);
    String expDateString = dateTimeToString(item.expDate);

    String xsql = """
    INSERT INTO tbl_inventory(name,category,purchase_date,exp_date) VALUES
      ('${item.name}','${item.category}','$purchaseDateString','$expDateString')
    """;

    await db.rawInsert(xsql);
  }


  // print inventory to console
  showInventory() async
  {
    // when you do a select query in sqflite
    // it will return a list of mapped data(key, value)
    // Think of it as each row of data is
    // a position in the list. And each record is a Map(key, value)
    List<Map<String, dynamic>> myDataset;

    myDataset = await getItemsInInventory(); // put query results in a map

    // iterate through the map and print each item
    for(int i = 0; i < myDataset.length; i++)
    {
      print("${myDataset[i]['name']} ${myDataset[i]['category']} ${myDataset[i]['purchase_date']} ${myDataset[i]['exp_date']} ${myDataset[i]['id']}");
    }
  }

  // print inventory to console
  showCategory(String category) async
  {
    // when you do a select query in sqflite
    // it will return a list of mapped data(key, value)
    // Think of it as each row of data is
    // a position in the list. And each record is a Map(key, value)
    List<Map<String, dynamic>> myDataset;

    myDataset = await getItemsByCategory(category); // put query results in a map

    // iterate through the map and print each item
    // iterate through the map and print each item
    for(int i = 0; i < myDataset.length; i++)
    {
      print("${myDataset[i]['name']} ${myDataset[i]['category']} ${myDataset[i]['shelf_life']} ${myDataset[i]['id']}");
    }
  }

  // print items list to console
  showItemsList() async
  {
    // when you do a select query in sqflite
    // it will return a list of mapped data(key, value)
    // Think of it as each row of data is
    // a position in the list. And each record is a Map(key, value)
    List<Map<String, dynamic>> myDataset;

    myDataset = await getItemsInItemsList(); // put query results in a map

    // iterate through the map and print each item
    for(int i = 0; i < myDataset.length; i++)
    {
      print("${myDataset[i]['name']} ${myDataset[i]['category']} ${myDataset[i]['shelf_life']} ${myDataset[i]['id']}");
    }

  }

  // remove item from inventory
  removeItemFromInventory(int id) async
  {
    String xsql = "DELETE FROM tbl_inventory WHERE id = $id";
    await db.execute(xsql);
  }


  // clear the inventory
  clearInventory() async
  {
    String xsql = "DELETE FROM tbl_inventory";
    await db.execute(xsql);
  }

  // clear the items list
  clearItemsList() async
  {
    String xsql = "DELETE FROM tbl_itemslist";
    await db.execute(xsql);
  }


  // convert a date time value to a string of YYYY-MM-DD format
  String dateTimeToString(DateTime dt) => "${dt.year}-${dt.month}-${dt.day}";

  // get all items in table
  Future getItemsInInventory() async => db.rawQuery("SELECT * FROM tbl_inventory ORDER BY name ASC");

  Future getItemsByCategory(String category) async
  {
    return db.rawQuery(
        "SELECT * FROM tbl_itemslist "
        "WHERE category LIKE '$category' "
        "ORDER BY name ASC"
    );
  }

  Future getItemsInItemsList() async => db.rawQuery("SELECT * FROM tbl_itemslist ORDER BY name ASC");


}