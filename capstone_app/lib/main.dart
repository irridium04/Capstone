import 'dart:math';

import 'package:capstone_app/scaffolds.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// import other dart files
import 'database_manager.dart';
import 'item.dart';
import 'inventoryItem.dart';
import 'scaffolds.dart';



// main function
void main() => runApp(const MyApp());

/*
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async
{

  WidgetsFlutterBinding.ensureInitialized();
  const InitializationSettings initializationSettings =
  InitializationSettings(
    android: AndroidInitializationSettings('ic_launcher'),
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}
*/
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
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>
      {
        "/HomePage": (BuildContext context) => const MyHomePage(title: 'My Pantry'),
        "/ItemCategoryPage": (BuildContext context) => const ItemCategoryPage(title: 'Add Item To Pantry'),
        "/ItemAddPage": (BuildContext context) => ItemAddPage('Add Item To Pantry', "", Theme.of(context).colorScheme.inversePrimary),
        "/ItemOptionsPage": (BuildContext context) => ItemOptionsPage("", Item("", "", 0)),
        "/CustomItemPage": (BuildContext context) => const CustomItemPage(title: "")
      }
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
    //dbm.clearInventory();
    //insertRandomData(200);
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
          ),
        -1
      );

      //item.printItem();

      dbm.addItemToInventory(item);

      Navigator.of(context).pushNamed("/HomePage");

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
    return inventoryScaffold(context);
  }

}

class ItemCategoryPage extends StatefulWidget
{
  const ItemCategoryPage({super.key, required this.title});


  final String title;

  @override
  State<ItemCategoryPage> createState() => _ItemCategoryPageState();
}

class _ItemCategoryPageState extends State<ItemCategoryPage>
{
  DatabaseManager dbm = DatabaseManager();

  _ItemCategoryPageState()
  {
    initializeDatabase();
  }

  initializeDatabase() async
  {
    await dbm.dbSetup();
  }

  @override
  Widget build(BuildContext context)
  {
    return itemCategoriesScaffold(context);
  }
}

class ItemAddPage extends StatefulWidget
{

  final String title;
  String category = "";
  Color bannerColor;

  ItemAddPage(this.title, this.category, this.bannerColor);

  @override
  State<ItemAddPage> createState() => _ItemAddPageState(category, bannerColor);


}

class _ItemAddPageState extends State<ItemAddPage>
{
  DatabaseManager dbm = DatabaseManager();
  String category;
  Color bannerColor;

  _ItemAddPageState(this.category, this.bannerColor)
  {
    initializeDatabase();
  }

  initializeDatabase() async
  {
    await dbm.dbSetup();
  }

  @override
  Widget build(BuildContext context)
  {
    return itemListScaffold(context, category, bannerColor);
  }
}

class ItemOptionsPage extends StatefulWidget
{

  final String title;
  Item item;

  ItemOptionsPage(this.title, this.item);

  @override
  State<ItemOptionsPage> createState() => _ItemOptionsPageState(item);


}

class _ItemOptionsPageState extends State<ItemOptionsPage>
{
  DatabaseManager dbm = DatabaseManager();
  Item item;
  static DateTime purchaseDate = DateTime.now();
  static DateTime expDate = DateTime.now().add(Duration(days: 7));

  String purchaseDateString = "${
      purchaseDate.month.toString()}/"
      "${purchaseDate.day.toString()}/"
      "${purchaseDate.year.toString()}";

  String expDateString = "${
      expDate.month.toString()}/"
      "${expDate.day.toString()}/"
      "${expDate.year.toString()}";

  _ItemOptionsPageState(this.item)
  {
    dbm.dbSetup();
  }

  PurchaseDatePicker(BuildContext context) async
  {
    purchaseDate = (await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1970),
        lastDate: DateTime.now()
    ))!;

    setState(()
    {
      purchaseDateString = "${
          purchaseDate.month.toString()}/"
          "${purchaseDate.day.toString()}/"
          "${purchaseDate.year.toString()}";

    });
  }

  ExpDatePicker(BuildContext context) async
  {
    expDate = (await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(Duration(days: 7)),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100)
    ))!;

    setState(()
    {
      expDateString = "${
          expDate.month.toString()}/"
          "${expDate.day.toString()}/"
          "${expDate.year.toString()}";
    });
  }

  SetupDBEntry(Item item)
  {
    expDate = (item.shelfLife != 0) ? purchaseDate.add(Duration(days: item.shelfLife)) : expDate;

    InventoryItem inventoryItem = InventoryItem(item.name, item.category, purchaseDate, expDate, -1);

    inventoryItem.printItem();

    dbm.addItemToInventory(inventoryItem);

    Navigator.of(context).pushNamed("/HomePage");
  }

  // convert a string of YYYY-MM-DD format to datetime
  DateTime _stringToDateTime(String s)
  {
    List<String> parts = s.split('/');
    int month = int.parse(parts[0]);
    int day = int.parse(parts[1]);
    int year = int.parse(parts[2]);

    return DateTime(year, month, day);
  }

  List<Widget> buildColumnChildren()
  {
    List<Widget> list = [];

    list.add(
    Text(
      "Add ${item.name} to Pantry",
      style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 40
      ),
    )
    );

    list.add(
      ElevatedButton(
        style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        )
      ),
      onPressed: () {
        setState(() {
          PurchaseDatePicker(context);
          });
        },
        child: Text("Enter Purchase / Opening Date ($purchaseDateString)")
      )
    );


    if(item.shelfLife == 0) {
      list.add(
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                  )
              ),
              onPressed: () {
                setState(() {
                  ExpDatePicker(context);
                });
              },
              child: Text("Enter Expiration Date On Package ($expDateString)")
          )
      );
    }


    list.add(
      ElevatedButton(
        style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        )
        ),
        onPressed: () {
          setState(() {
            SetupDBEntry(item);
          });
        },
        child: const Text("Add Item To Pantry")
      )
    );

    return list;
  }


  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(
                item.name,
                style: const TextStyle(

                    fontWeight: FontWeight.bold
                )
            )
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: buildColumnChildren(),
        )
      )
    );
  }
}


class CustomItemPage extends StatefulWidget
{
  const CustomItemPage({super.key, required this.title});


  final String title;

  @override
  State<CustomItemPage> createState() => _CustomItemPageState();
}

class _CustomItemPageState extends State<CustomItemPage>
{
  DatabaseManager dbm = DatabaseManager();

  _CustomItemPageState()
  {
    initializeDatabase();
  }

  initializeDatabase() async
  {
    await dbm.dbSetup();
  }

  @override
  Widget build(BuildContext context)
  {
    return CustomItemsScaffold(context);
  }
}