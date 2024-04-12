import 'package:capstone_app/database_manager.dart';
import 'package:capstone_app/itemTable.dart';
import 'package:capstone_app/main.dart';
import 'package:flutter/material.dart';

import 'inventoryTable.dart';
import 'database_manager.dart';

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

      floatingActionButton: FloatingActionButton.large(
        onPressed: () => Navigator.of(context).pushNamed("/ItemCategoryPage"),
        tooltip: 'Add Item',
        shape: const CircleBorder(),
        child: const Icon(
            Icons.add,
          size: 60,
        )
      ),
  );
}

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
                  builder: (context) => ItemAddPage("Custom Item", "Custom", Colors.cyan),
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
        onPressed: () => Navigator.of(context).pushNamed("/ItemCategoryPage"),
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