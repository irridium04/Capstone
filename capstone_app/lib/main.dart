import 'dart:math';

import 'package:capstone_app/scaffold.dart';
import 'package:flutter/material.dart';

// import other dart files
import 'database_manager.dart';
import 'item.dart';
import 'inventoryItem.dart';
import 'scaffold.dart';


// main function
void main()
{
  runApp(const MyApp());
}


class MyApp extends StatelessWidget
{
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      title: 'Pantry Tracker App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'My Pantry'),
    );
  }
}

class MyHomePage extends StatefulWidget
{
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
{
  DatabaseManager dbm = DatabaseManager();

  _MyHomePageState()
  {
    initializeDatabase();
  }


  initializeDatabase() async
  {
    await dbm.dbSetup(); // Await the asynchronous method
    dbm.clearInventory();
    insertRandomData(200);
  }



  // function to populate test data into db
  insertRandomData(int amountToInsert)
  {
    for(int i = 0; i < amountToInsert; i++)
    {
      Random RNG = Random();

      InventoryItem item = InventoryItem(
          "test$i",
          "testCategory$i",
          DateTime.now().subtract(
              Duration(
                  days: RNG.nextInt(30)
              )
          ),
          DateTime.now().add(
              Duration(
                  days: RNG.nextInt(365)
              )
          )
      );

      //item.printItem();

      dbm.addItemToInventory(item);



    }
  }

  printInventory() async
  {
    List<InventoryItem> items = await dbm.getInventory();

    for(InventoryItem item in items)
    {
      item.printItem();
    }
  }


  @override
  Widget build(BuildContext context)
  {
    return myScaffold(context);
  }

}

