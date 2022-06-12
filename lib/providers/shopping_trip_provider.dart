import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
final CollectionReference tripCollection = FirebaseFirestore.instance.collection('shopping_trips_02');

// shopping trip provider
class ShoppingTrip with ChangeNotifier{
  String _uuid = ''; // shopping trip uuid
  String _title = '';
  DateTime _date = DateTime.now();
  String _description = '';
  String _host = ''; // host uuid
  List<String> _beneficiaries = [];
  List<String> itemUUID = [];
  late Receipt _receipt;

  // from user creation screen for metadata
  Future<void> initializeTrip(String title, DateTime date, String description, List<String> bene_list, String host) async {
    var uuider = Uuid();
    _uuid = uuider.v4();
    _title = title;
    _date = date;
    _description = description;
    _host = host;
    _beneficiaries = bene_list;
    print(_date);
    await initializeTripDB();
    await initializeSubCollection();
    notifyListeners();
  }

  Future<void> initializeSubCollection() async {
    await tripCollection.doc(_uuid).collection("items").doc("dummy").set({
      'uuid': "dummy"
    });
  }
  // takes in formatted data from snapshot to directly update the provider
  initializeTripFromDB(String uuid, String title, DateTime date, String description, String host, List<String> beneficiaries) {
    _uuid = uuid;
    _title = title;
    _date = date;
    _description = description;
    _host = host;
    _beneficiaries = beneficiaries;
  }

  initializeItemUIDFromDB(List<String> itemUUID) {
    itemUUID = itemUUID;
  }


  String get uuid => _uuid;
  String get title => _title;
  DateTime get date => _date;
  String get description => _description;
  List<String> get beneficiaries => _beneficiaries;
  String get host => _host;
  // metadata editing methods
  editTripTitle(String title) {
    _title = title;
    // notifyListeners();
  }
  editTripDate(DateTime date) {
    _date = date;
    // notifyListeners();
  }
  editTripDescription(String description) {
    _description = description;
    // notifyListeners();
  }
  clearCachedBene() {
    _beneficiaries.clear();
    // notifyListeners();
  }
  clearCachedItem() {
    itemUUID.clear();
    // notifyListeners();
  }
  // when date field is edited, this method should be called
  updateTripDate(DateTime date) {
    _date = date;
    updateTripDateDB();
    notifyListeners();
  }
  // when metadata update fields are called from first screen, this method should be called
  updateTripMetadata(String title, DateTime date, String description, List<String> beneficiary) {
    _title = title;
    _date = date;
    _description = description;
    _beneficiaries = beneficiary;
    updateTripMetadataDB();
    notifyListeners();
  }
  setBeneficiary(List<String> new_bene_list){
    _beneficiaries = new_bene_list;
  }
  // adds beneficiary, notifies listeners, updates database
  addBeneficiary(String beneficiary_uuid) {
    _beneficiaries.add(beneficiary_uuid);
    //add bene to every item document
    tripCollection.doc(_uuid).collection('items').get().then((collection) => {
      collection.docs.forEach((document) async {
        await document.reference.update(
          {
            "subitems.${beneficiary_uuid}": 0
          }
        );
      })
    });
    updateBeneficiaryDB();
    notifyListeners();
  }
  // removes beneficiary, notifies listeners, updates database
  removeBeneficiary(String beneficiary_uuid) {
    _beneficiaries.remove(beneficiary_uuid);
    tripCollection.doc(_uuid).collection('items').get().then((collection) => {
      collection.docs.forEach((document) async {
        Map<String,int> bene_items = {};
        (document.data()['subitems'] as Map<String,dynamic>).forEach((uuid, quantity) {
          bene_items[uuid] = int.parse(quantity.toString());
        });
        bene_items.remove(beneficiary_uuid);
        await document.reference.update(
          {
            "subitems":bene_items
          }
        );
      })
    });
    updateBeneficiaryDB();
    notifyListeners();
  }

  // user adds an item for first time
  addItem(String name, [int quantity=0]) {
    var uuider = Uuid();
    String item_uid = uuider.v4();
    Map<String,int> bene_subitem = {};
    _beneficiaries.forEach((bene) {
      bene_subitem[bene] =0;
    });
    tripCollection.doc(_uuid).collection('items').doc(item_uid).set(
      {
        'name': name,
        'quantity':0,
        'subitems': bene_subitem,
        'uuid': item_uid,
      }
    );
    itemUUID.add(item_uid);
    notifyListeners();
  }

  // edits individual item within list, notifies listeners, updates database
  editItem(String item_uid, int sum,String bene_uid, int bene_quantity) async {
    DocumentSnapshot old_data = await tripCollection.doc(_uuid).collection('items').doc(item_uid).get();
    Map<String,int> bene_value = {};
    (old_data['subitems'] as Map<String,dynamic>).forEach((bene, value) {
      bene_value[bene] = int.parse(value.toString());
    });
    bene_value[bene_uid] = bene_quantity;
    await tripCollection.doc(_uuid).collection('items').doc(item_uid).update(
        {
          "quantity": sum,
          "subitems": bene_value,
        }
    );
    //updateItemDB();
    notifyListeners();
  }
  // adds item, notifies listeners, updates database
  removeItem(String item_uid) async {
    await tripCollection.doc(_uuid).collection('items').doc(item_uid).delete();
    itemUUID.remove(item_uid);
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
        });
  }
  // only update trip date in db
  // TODO may need to make two more similar methods for date and description
  updateTripDateDB() {
    tripCollection.doc(_uuid).update({'date': _date});
  }

  deleteTripDB(){
    print(_uuid);
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
  }


  updateItemQuantity(String item_uid, String bene_uid, int quantity) async {
    await tripCollection.doc(_uuid).collection('items').doc(item_uid).update(
        {
          "subitems": {"${bene_uid}": quantity}
        }
    );
    //"subitems": {"${bene_uid}": bene_quantity}
  }

}

class Item {
  late String name;
  late int quantity;
  Map<String, int> subitems = <String, int>{}; // uuid to individual quantity needed
  Item(this.name, this.quantity, List<String> beneficiaries) {
    subitems = <String, int>{};
    beneficiaries.forEach((uid) {
      subitems[uid] = 0;
    });
  }

  Item.nothing();

  addBeneficiary(String beneficiary) {
    subitems[beneficiary] = 0;
  }
  removeBeneficiary(String beneficiary) {
    subitems.remove(beneficiary);
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
  late double total_price;

  ReceiptItem(this.name, this.price, this.quantity) {
    total_price = price*quantity;
  }
}