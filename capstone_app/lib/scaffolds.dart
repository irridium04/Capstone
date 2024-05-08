import 'package:capstone_app/database_manager.dart';
import 'package:capstone_app/itemTable.dart';
import 'package:capstone_app/main.dart';
import 'package:flutter/material.dart';

import 'inventoryTable.dart';
import "item.dart";

// the scaffold for the inventory list
Scaffold inventoryScaffold(BuildContext context)
{
  return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
            "My Pantry",
            style: TextStyle(
              fontWeight: FontWeight.bold
            )
        )
      ),
      body: InventoryTable(),

      // add item button
      floatingActionButton: FloatingActionButton.large(
        onPressed: () async
        {
          Navigator.of(context).pushNamed("/ItemCategoryPage");
        },
        tooltip: 'Add Item',
        shape: const CircleBorder(),
        child: const Icon(
            Icons.add,
          size: 60,
        )
      ),
  );
}

// item categories page
Scaffold itemCategoriesScaffold(BuildContext context)
{
  TextStyle cardTextStyle()
  {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 25
    );
  }

  Card itemCategorycard(String categoryName, Color c)
  {
    return Card(
      color: c,
      child: InkWell(
        onTap: ()
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemAddPage(categoryName, categoryName, c),
            ),
          );
        },
        child: Container(
          width: 180,
          height: 140,
          child: Center(
            child: Text(
              categoryName,
              textAlign: TextAlign.center,
              style: cardTextStyle(),
            )
          )
        )
      )
    );
  }



  return Scaffold(
    appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
            "Add Item To Panrty",
            style: TextStyle(
                fontWeight: FontWeight.bold
            )
        )
    ),
    body: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(

              children: [
                itemCategorycard('All Items', Colors.pinkAccent),
                itemCategorycard('Refrigerated', Colors.lightBlueAccent),
                itemCategorycard('Meat', Colors.redAccent),
                itemCategorycard('Baking', Colors.purpleAccent),
              ],
            ),
            Column(
              children: [
                itemCategorycard('Produce', Colors.yellowAccent),
                itemCategorycard('Frozen', Colors.blueAccent),
                itemCategorycard('Herbs / Spices', Colors.greenAccent),
                itemCategorycard('Pantry', Colors.orangeAccent),
              ],
            ),

          ],
        ),
        Card(
          color: Colors.cyan,
          child: InkWell(
            onTap: ()
            {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItemAddPage("Custom Items", "Custom", Colors.cyan),
                ),
              );
            },
            child: Container(
              width: 320,
              height: 120,
              child: Center(
                child: Text(
                  "Your Custom Items",
                  textAlign: TextAlign.center,
                  style: cardTextStyle(),
                )
              )
            )
          )
        )
      ]
    )
  );
}


// the scaffold for displaying the list of items that user can add
Scaffold itemListScaffold(BuildContext context, String category, Color bannerColor)
{
  // return scaffold with add button only if category is custom
  return (category == "Custom") ? Scaffold(
    appBar: AppBar(
        backgroundColor: bannerColor,
        title: Text(
            category,
            style: TextStyle(
                fontWeight: FontWeight.bold
            )
        )
    ),
    body: ItemTable(category),

    floatingActionButton: FloatingActionButton.large(
      backgroundColor: bannerColor,
        onPressed: () => Navigator.of(context).pushNamed("/CustomItemPage"),
        tooltip: 'Add Item',
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          size: 60,
        )
    )
  ) :

  Scaffold(
      appBar: AppBar(
          backgroundColor: bannerColor,
          title: Text(
              category,
              style: TextStyle(
                  fontWeight: FontWeight.bold
              )
          )
      ),
      body: ItemTable(category),
  );

}

Scaffold CustomItemsScaffold(BuildContext context)
{
  TextEditingController _itemNameTextController = TextEditingController();

  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.cyan,
      title: const Text(
        "Add A Custom Item",
        style: TextStyle(
        fontWeight: FontWeight.bold
        )
      )
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Enter Item Name",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _itemNameTextController,
              decoration: InputDecoration(
                labelText: 'Enter custom item name',
                hintText: 'Enter custom item name...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                DatabaseManager dbm = DatabaseManager();
                await dbm.dbSetup();

                Item item = Item(_itemNameTextController.text, "Custom", 0);

                dbm.insertIntoListTable(item, dbm.db);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemAddPage("Custom Items", "Custom", Colors.cyan),
                  ),
                );

              },
              child: Text("Add Custom Item")
          )

        ],
      )
    )
  );
}



