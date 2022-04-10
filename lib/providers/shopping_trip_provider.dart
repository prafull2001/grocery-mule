import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference tripCollection = FirebaseFirestore.instance.collection('shopping_trips_test');

// shopping trip provider
class ShoppingTrip with ChangeNotifier{
  String _uuid = ''; // shopping trip uuid
  String _title = '';
  DateTime _date = DateTime.now();
  String _description = '';
  String _host = ''; // host uuid
  Map<String,String> _beneficiaries = {};
  Map<String, Item> _items = <String, Item>{}; // name to item
  Receipt _receipt;

  // from user creation screen for metadata
  Future<void> initializeTrip(String title, DateTime date, String description, Map<String,String> uid_name, String host) async {
    var uuider = Uuid();
    _uuid = uuider.v4();
    _title = title;
    _date = date;
    _description = description;
    _host = host;
    _beneficiaries = uid_name;
    print(_date);
    await initializeTripDB();
    notifyListeners();
  }
  // takes in formatted data from snapshot to directly update the provider
  initializeTripFromDB(String uuid, String title, DateTime date, String description, String host, Map<String,String> beneficiaries, Map<String, Item> items) {
    _uuid = uuid;
    _title = title;
    _date = date;
    _description = description;
    _host = host;
    _beneficiaries = beneficiaries;
    _items = items;
    notifyListeners();
  }

  String get uuid => _uuid;
  String get title => _title;
  DateTime get date => _date;
  String get description => _description;
  Map<String,String> get beneficiaries => _beneficiaries;
  Map<String, Item> get items => _items;
  String get host => _host;

  // metadata editing methods
  editTripTitle(String title) {
    _title = title;
    notifyListeners();
  }
  editTripDate(DateTime date) {
    _date = date;
    notifyListeners();
  }
  editTripDescription(String description) {
    _description = description;
    notifyListeners();
  }
  clearCachedBene() {
    _beneficiaries.clear();
    notifyListeners();
  }
  clearCachedItem() {
    items.clear();
    notifyListeners();
  }
  // when date field is edited, this method should be called
  updateTripDate(DateTime date) {
    _date = date;
    updateTripDateDB();
    notifyListeners();
  }
  // when metadata update fields are called from first screen, this method should be called
  updateTripMetadata(String title, DateTime date, String description) {
    _title = title;
    _date = date;
    _description = description;
    updateTripMetadataDB();
    notifyListeners();
  }

  // adds beneficiary, notifies listeners, updates database
  addBeneficiary(String beneficiary_uuid, String name) {
    _beneficiaries[beneficiary_uuid] = name;
    if(_items.isNotEmpty) {
      _items.forEach((name, item) {
        item.addBeneficiary(beneficiary_uuid);
      });
    }
    updateBeneficiaryDB();
    notifyListeners();
  }
  // removes beneficiary, notifies listeners, updates database
  removeBeneficiary(String beneficiary_uuid) {
    _beneficiaries.remove(beneficiary_uuid);
    if(_items.isNotEmpty) {
      _items.forEach((name, item) {
        item.removeBeneficiary(beneficiary_uuid);
      });
    }
    updateBeneficiaryDB();
    notifyListeners();
  }

  // user adds an item for first time
  addItem(String name, [int quantity=0]) {
    _items[name] = Item(name, quantity, _beneficiaries);
    updateItemDB();
    notifyListeners();
  }
  // adds item from database?
  addItemDirect(Item item) {
    _items[item.name] = item;
    // TODO if you only call this method from pulling from database, remove this line
  }
  // edits individual item within list, notifies listeners, updates database
  editItem(String name, int quantity, Map<String, int> subitems) {
    _items[name] = Item.withSubitems(name, quantity, subitems);
    updateItemDB();
    notifyListeners();
  }
  // adds item, notifies listeners, updates database
  removeItem(String name) {
    _items.remove(name);
    updateItemDB();
    notifyListeners();
  }

  // for initializing the trip within the database

  Future<void> initializeTripDB() async {
     await tripCollection.doc(_uuid).set(
        {'uuid': _uuid,
          'title': _title,
          'date': _date,
          'description': _description,
          'host': _host,
          'beneficiaries': _beneficiaries,
          'items': itemsToMap(),
        });
  }
  // only update trip date in db
  // TODO may need to make two more similar methods for date and description
  updateTripDateDB() {
    tripCollection.doc(_uuid).update({'date': _date});
  }

  deleteTripDB(){
    tripCollection.doc(_uuid).delete();
    notifyListeners();
  }
  // only updates trip metadata in db
  updateTripMetadataDB() {
    tripCollection.doc(_uuid).update({'title': _title});
    tripCollection.doc(_uuid).update({'date': _date});
    tripCollection.doc(_uuid).update({'description': _description});
  }
  // updates after a beneficiary has been added
  updateBeneficiaryDB() {
    tripCollection.doc(_uuid).update({'beneficiaries': _beneficiaries});
    tripCollection.doc(_uuid).update({'items': itemsToMap()});
  }
  // updates items only in DB
  updateItemDB() {
    tripCollection.doc(_uuid).update({'items': itemsToMap()});
  }

  // toMap func for publishing to database
  Map<String, Map<String,dynamic>> itemsToMap() {
    Map<String, Map<String,dynamic>> ret_map = <String, Map<String,dynamic>>{};
    _items.forEach((name, item) {
      ret_map[name] = item.toMap();
    });
    return ret_map;
  }
}

class Item {
  String name;
  int quantity;
  Map<String, int> subitems = <String, int>{}; // uuid to individual quantity needed
  bool isExpanded;
  Item(this.name, this.quantity, Map<String,String> beneficiaries) {
    subitems = <String, int>{};
    beneficiaries.forEach((uid,name) {
      subitems[uid] = 0;
    });

    this.isExpanded = false;
  }
  Item.withSubitems(this.name, this.quantity, this.subitems){
    this.isExpanded = true;
  }

  Item.fromMap(Map<String, dynamic> itemMap) {
    this.name = itemMap['name'].toString();
    this.quantity = int.parse(itemMap['quantity'].toString());
    (itemMap['subitems'] as Map<String, dynamic>).forEach((name, indivQuantity) {
      this.subitems[name.toString()] = int.parse(indivQuantity.toString());
    });
    this.isExpanded = false;
  }

  addBeneficiary(String beneficiary) {
    subitems[beneficiary] = 0;
  }
  removeBeneficiary(String beneficiary) {
    subitems.remove(beneficiary);
  }

  incrementBeneficiary(String beneficiary) {
    subitems[beneficiary]++;
  }
  decrementBeneficiary(String beneficiary) {
    subitems[beneficiary]--;
  }

  Map<String,dynamic> toMap() {
    return {
      "name": name,
      "quantity": quantity,
      "subitems": subitems,
    };
  }
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