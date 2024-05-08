import 'dart:math';

import 'package:capstone_app/scaffolds.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

// import other dart files
import 'database_manager.dart';
import 'item.dart';
import 'inventoryItem.dart';
import 'notification_manager.dart';




void main() async
{
  await AwesomeNotifications().initialize(
    null, // default flutter icon
    [
      // create a notification channel for sending notifications
      NotificationChannel(
        channelGroupKey: "my_channel_group",
        channelKey: "my_channel",
        channelName: "Notification Channel",
        channelDescription: "My Notification Channel")
    ],

    // create a notification channel group
    channelGroups: [
      NotificationChannelGroup(
          channelGroupKey: "my_channel_group",
          channelGroupName: "Notification Group")
    ]
  );

  // check if notifications are allowed by the user
  bool isAllowedNotification = await AwesomeNotifications().isNotificationAllowed();

  // prompt the user to enable notifications if they aren't enabled
  if(!isAllowedNotification)
  {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

  // run the app
  runApp(const MyApp());
}


class MyApp extends StatefulWidget
{
  const MyApp({super.key});

  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
{
  // set the listener functions for different notification events when app is initialized
  @override
  void initState() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationManager.onActionReceivedMethod,
      onDismissActionReceivedMethod: NotificationManager.onDismissActionReceivedMethod,
      onNotificationCreatedMethod: NotificationManager.onNotificationCreatedMethod,
      onNotificationDisplayedMethod: NotificationManager.onNotificationDisplayedMethod
    );

    super.initState();
  }


  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      title: 'Pantry Tracker App', // the app name

        // sets the app theme color to red
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'My Pantry'), // define the homepage route
      debugShowCheckedModeBanner: false, // disable the debug banner in the corner
      routes: <String, WidgetBuilder> // define the routes of the app
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
  // create a reference to the database manager
  DatabaseManager dbm = DatabaseManager();

  _MyHomePageState()
  {
    initializeDatabase();
  }


  // setup the database
  initializeDatabase() async => await dbm.dbSetup();

  // display the inventory list scaffold
  @override
  Widget build(BuildContext context) => inventoryScaffold(context);

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

  initializeDatabase() async => await dbm.dbSetup();

  @override
  Widget build(BuildContext context) => itemCategoriesScaffold(context);
}

class ItemAddPage extends StatefulWidget
{

  final String title;
  String category = "";
  Color bannerColor;

  ItemAddPage(this.title, this.category, this.bannerColor, {super.key});

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

  initializeDatabase() async => await dbm.dbSetup();

  @override
  Widget build(BuildContext context) => itemListScaffold(context, category, bannerColor);
}

class ItemOptionsPage extends StatefulWidget
{

  final String title;
  Item item;

  ItemOptionsPage(this.title, this.item, {super.key});

  @override
  State<ItemOptionsPage> createState() => _ItemOptionsPageState(item);

}

class _ItemOptionsPageState extends State<ItemOptionsPage>
{

  DatabaseManager dbm = DatabaseManager(); // database manager
  Item item; // the item selected
  static DateTime purchaseDate = DateTime.now(); // the current date
  static DateTime expDate = DateTime.now().add(const Duration(days: 30)); // 30 days after current date

  // convert date to MM/DD/YYYY string format
  String purchaseDateString = "${
      purchaseDate.month.toString()}/"
      "${purchaseDate.day.toString()}/"
      "${purchaseDate.year.toString()}";

  // convert date to MM/DD/YYYY string format
  String expDateString = "${
      expDate.month.toString()}/"
      "${expDate.day.toString()}/"
      "${expDate.year.toString()}";

  _ItemOptionsPageState(this.item)
  {
    dbm.dbSetup(); // setup database in constructor
  }

  // date picker widget for purchase date
  purchaseDatePicker(BuildContext context) async
  {
    purchaseDate = (await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1970),
        lastDate: DateTime.now()
    ))!;

    // update purchase date string when new date clicked
    setState(()
    {
      purchaseDateString = "${
          purchaseDate.month.toString()}/"
          "${purchaseDate.day.toString()}/"
          "${purchaseDate.year.toString()}";

    });
  }

  // date picker widget for expiration date
  expDatePicker(BuildContext context) async
  {
    expDate = (await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 30)),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100)
    ))!;

    // update expiration date string when new date clicked
    setState(()
    {
      expDateString = "${
          expDate.month.toString()}/"
          "${expDate.day.toString()}/"
          "${expDate.year.toString()}";
    });
  }

  // setup the item to enter into the database
  setupDBEntry(Item item)
  {
    // automatically calculates the exp date if the item has a specified shelf life,
    // an item has a specified shelf life if the number is not 0,
    // otherwise use the exp date from the user
    expDate = (item.shelfLife != 0) ? purchaseDate.add(Duration(days: item.shelfLife)) : expDate;

    // create an inventory item, requires -1 as a placeholder id
    InventoryItem inventoryItem = InventoryItem(item.name, item.category, purchaseDate, expDate, -1);

    dbm.addItemToInventory(inventoryItem); // add the item to the inventory

    Navigator.of(context).pushNamed("/HomePage"); // navigate back to homepage
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

  // builds the menu for adding an item to the database
  List<Widget> buildColumnChildren()
  {
    List<Widget> list = [];

    // title text
    list.add(
    Text(
      "Add ${item.name} to Pantry",
      style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 40
      ),
    )
    );

    // purchase date picker
    list.add(
      ElevatedButton(
        style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        )
      ),
      onPressed: () {
        setState(() {
          purchaseDatePicker(context);
          });
        },
        child: Text("Enter Purchase / Opening Date ($purchaseDateString)")
      )
    );

    // only add exp date picker if the item does not have a preset shelf life
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
                  expDatePicker(context);
                });
              },
              child: Text("Enter Expiration Date On Package ($expDateString)")
          )
      );
    }

    // add item button
    list.add(
      ElevatedButton(
        style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        )
        ),
        onPressed: () {
          setState(() {
            setupDBEntry(item);
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
                style: const TextStyle(fontWeight: FontWeight.bold)
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

  initializeDatabase() async => await dbm.dbSetup();

  @override
  Widget build(BuildContext context) => CustomItemsScaffold(context);
}