import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';



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
        await createItemTable(db);
      },

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


  // create the item table
  createItemTable(Database db) async
  {
    await db.execute("""
      
    CREATE TABLE tbl_item(
      name            TEXT,
      category        TEXT,
      purchase_date   TEXT,
      exp_date        TEXT,
      id              INTEGER PRIMARY KEY
    );
      
    """);
  }


  // insert an item into table
  insertItemIntoDB(String itemName, String itemCategory, DateTime purchaseDate, DateTime expDate) async
  {
    String purchaseDateString = dateTimeToString(purchaseDate);
    String expDateString = dateTimeToString(expDate);

    String xsql = """
    INSERT INTO tbl_item(name,category,purchase_date,exp_date) VALUES
      ('$itemName','$itemCategory','$purchaseDateString','$expDateString')
    """;

    await db.rawInsert(xsql);
  }


  // print data to console
  showData() async
  {
    // when you do a select query in sqflite
    // it will return a list of mapped data(key, value)
    // Think of it as each row of data is
    // a position in the list. And each record is a Map(key, value)
    List<Map<String, dynamic>> myDataset;

    myDataset = await getItemsInDB(); // put query results in a map

    // iterate through the map and print each item
    for(int i = 0; i < myDataset.length; i++)
    {
      print("${myDataset[i]['name']} ${myDataset[i]['category']} ${myDataset[i]['purchase_date']} ${myDataset[i]['exp_date']} ${myDataset[i]['id']}");
    }

  }


  // remove item from table
  removeItem(int id) async
  {
    String xsql = "DELETE FROM tbl_item WHERE id = $id";
    await db.execute(xsql);
  }


  // clear the table
  clearTable() async
  {
    String xsql = "DELETE FROM tbl_item";
    await db.execute(xsql);
  }


  // convert a date time value to a string of YYYY-MM-DD format
  String dateTimeToString(DateTime dt) => "${dt.year}-${dt.month}-${dt.day}";

  // get all items in table
  Future getItemsInDB() async => db.rawQuery("SELECT * FROM tbl_item ORDER BY id ASC");


}