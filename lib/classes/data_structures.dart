import 'package:uuid/uuid.dart';

class ShoppingTrip {
  String uuid;
  String title;
  DateTime date;
  String description;
  String host;
  List<String> beneficiaries;
  List<Item> items;
  Receipt receipt;

  ShoppingTrip(this.title, this.date, this.description, this.host, this.beneficiaries) {
    var uuider = new Uuid();
    uuid = uuider.v4();
    items = <Item>[];
  }

  addReceipt(Receipt receipt) {
    this.receipt = receipt;
  }
}

class Cowboy {
  String uuid;
  String first_name;
  String last_name;
  String email;
  List<String> shopping_trips;
  // map<String><String> friends (uuid->first name map)

  Cowboy(this.uuid, this.first_name, this.last_name, this.email) {
    shopping_trips = <String>[];
  }
}

class Item {
  String name;
  int quantity;
  List<SubItem> subitems;

  Item(this.name, this.quantity, String init_user) {
    subitems = List.filled(quantity, new SubItem([init_user]));
  }
}

class SubItem {
  List<String> buyers;

  SubItem(this.buyers);
}

class Receipt {
  List<ReceiptItem> items;
  double final_total;
  double final_tax;

  Receipt(this.items, this.final_total, this.final_tax);
}

class ReceiptItem {
  String name;
  double price;
  int quantity;
  double total_price;

  ReceiptItem(this.name, this.price, this.quantity) {
    total_price = price*quantity;
  }
}