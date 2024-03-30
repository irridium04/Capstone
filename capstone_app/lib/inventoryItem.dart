class InventoryItem
{
  String name;
  String category;
  DateTime purchaseDate;
  DateTime expDate;

  InventoryItem(this.name, this.category, this.purchaseDate, this.expDate);

  printItem()
  {
    print('$name \t $category \t $purchaseDate \t $expDate');
  }
}