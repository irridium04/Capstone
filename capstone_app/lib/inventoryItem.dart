class InventoryItem
{
  String name;
  String category;
  DateTime purchaseDate;
  DateTime expDate;
  int id;

  InventoryItem(this.name, this.category, this.purchaseDate, this.expDate, this.id);

  printItem()
  {
    print('$name \t $category \t $purchaseDate \t $expDate');
  }
}