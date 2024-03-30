import 'package:capstone_app/database_manager.dart';
import 'package:flutter/material.dart';

import 'inventoryTable.dart';
import 'database_manager.dart';

Scaffold myScaffold(BuildContext context)
{
  void addItem()
  {
    print("Add Item");
  }

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
      body: ListView(
          children: [
            InventoryTable()
          ]
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: addItem,
        tooltip: 'Add Item',
        shape: const CircleBorder(),
        child: const Icon(
            Icons.add,
          size: 60,
        )
      ),
  );
}

