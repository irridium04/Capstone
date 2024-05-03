import 'package:capstone_app/notification_manager.dart';
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
  var db; // database variable
  var path; // path variable


  // database setup function
  dbSetup() async
  {
    // get databases dath
    var databasesPath = await getDatabasesPath();


    // join the database to the path
    path = join(databasesPath, dbname);



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
  addItemToInventory(InventoryItem item) async
  {
    String purchaseDateString = _dateTimeToString(item.purchaseDate);
    String expDateString = _dateTimeToString(item.expDate);


    String xsql = """
    INSERT INTO tbl_inventory(name,category,purchase_date,exp_date) VALUES
      ('${item.name}','${item.category}','$purchaseDateString','$expDateString')
    """;

    int itemId = await db.rawInsert(xsql);

    await NotificationManager().createNotification(
        itemId,
        item.name,
        item.expDate.subtract(const Duration(days: 2))
    );
  }


  // get all the items in the inventory as a list of inventory item objects
  Future<List<InventoryItem>> getInventory() async
  {
    // when you do a select query in sqflite
    // it will return a list of mapped data(key, value)
    // Think of it as each row of data is
    // a position in the list. And each record is a Map(key, value)
    List<Map<String, dynamic>> myDataset;
    List<InventoryItem> items = <InventoryItem>[];

    myDataset = await _getItemsInInventory(); // put query results in a map

    // iterate through the map and print each item
    for(int i = 0; i < myDataset.length; i++)
    {
      InventoryItem item = InventoryItem(
          myDataset[i]['name'],
          myDataset[i]['category'],
          _stringToDateTime(myDataset[i]['purchase_date']),
          _stringToDateTime(myDataset[i]['exp_date']),
          myDataset[i]['id']
      );
      items.add(item);

      //print("Getting item: ${myDataset[i]['name']} ${myDataset[i]['category']} ${myDataset[i]['purchase_date']} ${myDataset[i]['exp_date']} ${myDataset[i]['id']}");
    }

    return items;
  }

  // get items in category
  Future<List<Item>> getItemsByCategory(String category) async
  {
    // when you do a select query in sqflite
    // it will return a list of mapped data(key, value)
    // Think of it as each row of data is
    // a position in the list. And each record is a Map(key, value)
    List<Map<String, dynamic>> myDataset;
    List<Item> items = <Item>[];

    myDataset = await _getItemsByCategory(category); // put query results in a map

    // iterate through the map and print each item
    for (int i = 0; i < myDataset.length; i++) {
      Item item = Item(
          myDataset[i]['name'],
          myDataset[i]['category'],
          myDataset[i]['shelf_life']
      );
      items.add(item);
    }

    return items;
  }

  // gets the list of all items
  Future<List<Item>> getAllItems() async
  {
    // when you do a select query in sqflite
    // it will return a list of mapped data(key, value)
    // Think of it as each row of data is
    // a position in the list. And each record is a Map(key, value)
    List<Map<String, dynamic>> myDataset;

    List<Item> items = <Item>[];

    myDataset = await _getItemsInItemsList(); // put query results in a map

    // iterate through the map and print each item
    for (int i = 0; i < myDataset.length; i++) {
      Item item = Item(
          myDataset[i]['name'],
          myDataset[i]['category'],
          myDataset[i]['shelf_life']
      );
      items.add(item);
    }

    return items;

  }

  // remove item from inventory
  removeItemFromInventory(int id) async
  {
    // deletion SQL query
    String xsql = "DELETE FROM tbl_inventory WHERE id = $id";

    // remove the expiration notification
    await NotificationManager().cancelNotification(id);

    await db.execute(xsql); // execute the sql query
  }

  // clear the inventory
  clearInventory() async
  {
    String xsql = "DELETE FROM tbl_inventory";
    await db.execute(xsql);
  }


  // convert a date time value to a string of YYYY-MM-DD format
  String _dateTimeToString(DateTime dt) => "${dt.year}-${dt.month}-${dt.day}";

  // convert a string of YYYY-MM-DD format to datetime
  DateTime _stringToDateTime(String s)
  {
    List<String> parts = s.split('-');
    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int day = int.parse(parts[2]);

    return DateTime(year, month, day);
  }

  // get all items in table
  Future _getItemsInInventory() async => db.rawQuery("SELECT * FROM tbl_inventory ORDER BY name ASC");

  Future _getItemsByCategory(String category) async
  {
    return db.rawQuery(
        "SELECT * FROM tbl_itemslist "
        "WHERE category LIKE '$category' "
        "ORDER BY name ASC"
    );
  }

  Future _getIdFromItemName(String name) async => db.rawQuery("SELECT id FROM tbl_inventory WHERE name LIKE '$name'");

  Future _getItemsInItemsList() async => db.rawQuery("SELECT * FROM tbl_itemslist ORDER BY name ASC");


}