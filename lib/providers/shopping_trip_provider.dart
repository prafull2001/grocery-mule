import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_mule/dev/collection_references.dart';
import 'package:uuid/uuid.dart';

// shopping trip provider
class ShoppingTrip with ChangeNotifier {
  String _uuid = ''; // shopping trip uuid
  String _title = '';
  DateTime _date = DateTime.now();
  String _description = '';
  String _host = ''; // host uuid
  List<String> _beneficiaries = [];
  List<String> itemUUID = [];
  bool lock = false;

  void clearField() {
    _uuid = "";
    _host = "";
  }

  // from user creation screen for metadata
  Future<void> initializeTrip(String title, DateTime date, String description,
      List<String> bene_list, String host) async {
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
    // await tripCollection.doc(_uuid).collection("items").doc("dummy").set({'uuid': ""});
    await tripCollection
        .doc(_uuid)
        .collection("items")
        .doc("tax")
        .set({'price': "0.00", 'uuid': 'tax', 'name': 'tax'});
    await tripCollection
        .doc(_uuid)
        .collection("items")
        .doc("add. fees")
        .set({'price': "0.00", 'uuid': 'add. fees', 'name': 'add. fees'});
  }

  // takes in formatted data from snapshot to directly update the provider
  initializeTripFromDB(
      String uuid,
      String title,
      DateTime date,
      String description,
      String host,
      List<String> beneficiaries,
      bool raw_lock) {
    _uuid = uuid;
    _title = title;
    _date = date;
    _description = description;
    _host = host;
    _beneficiaries = beneficiaries;
    lock = raw_lock;
  }

  initializeItemUIDFromDB(List<String> itemUUID) {
    itemUUID = itemUUID;
  }

  updateItemPrice(String item_uid, double price) async {
    await tripCollection.doc(_uuid).collection('items').doc(item_uid).update({
      "price": price,
    });
    notifyListeners();
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
    notifyListeners();
  }

  editTripDate(DateTime date) {
    _date = date;
    //notifyListeners();
  }

  editTripDateSync(DateTime date) {
    _date = date;
    notifyListeners();
    // print('notif listeners: $_date');
  }

  editTripDescription(String description) {
    _description = description;
  }

  clearCachedBene() {
    _beneficiaries.clear();
    // notifyListeners();
  }

  clearCachedItem() {
    itemUUID.clear();
  }

  // when date field is edited, this method should be called
  updateTripDate(DateTime date) {
    _date = date;
    updateTripDateDB();
    notifyListeners();
  }

  updateDateForAll() {
    _beneficiaries.forEach((user) {
      userCollection
          .doc(user)
          .collection('shopping_trips')
          .doc(_uuid)
          .update({'date': _date});
    });
  }

  // when metadata update fields are called from first screen, this method should be called
  updateTripMetadata(String title, DateTime date, String description) {
    _title = title;
    _date = date;
    _description = description;
    updateTripMetadataDB();
    updateDateForAll();
    notifyListeners();
  }

  setBeneficiary(List<String> new_bene_list) {
    _beneficiaries = new_bene_list;
  }

  // adds beneficiary, notifies listeners, updates database
  addBeneficiary(String beneficiary_uuid) {
    _beneficiaries.add(beneficiary_uuid);
    userCollection
        .doc(beneficiary_uuid)
        .collection('shopping_trips')
        .doc(_uuid)
        .set({'date': _date});
    //add bene to every item document
    tripCollection.doc(_uuid).collection('items').get().then((collection) => {
          collection.docs.forEach((document) async {
            await document.reference
                .update({"subitems.${beneficiary_uuid}": 0});
          })
        });
    updateBeneficiaryDB();
    notifyListeners();
  }

  removeStaleTripUUIDS() {
    _beneficiaries.forEach((bene_uuid) {
      userCollection
          .doc(bene_uuid)
          .collection('shopping_trips')
          .doc(_uuid)
          .delete();
    });
  }

  removeBeneficiaries(List<String> bene_uuids) async {
    _beneficiaries.removeWhere((element) => bene_uuids.contains(element));
    await removeBeneficiariesFromItems(bene_uuids);
    await tripCollection.doc(_uuid).update({'beneficiaries': FieldValue.arrayRemove(bene_uuids)});
    bene_uuids.forEach((String bene_uuid) async {
      await userCollection.doc(bene_uuid).collection('shopping_trips').doc(_uuid).delete();
    });
    notifyListeners();
  }

  removeBeneficiariesFromItems(List<String> bene_uuids) async {
    QuerySnapshot items_shot = await tripCollection.doc(_uuid).collection('items').get();
    if (items_shot.docs != null && items_shot.docs.isNotEmpty) {
      itemUUID = [];
      items_shot.docs.forEach((item_uuid) {
        if (item_uuid.id.trim()!='tax' && item_uuid.id.trim()!='add. fees') {
          itemUUID.add(item_uuid.id.trim());
        }
      });
    }
    itemUUID.forEach((item) async {
      DocumentSnapshot item_shot = await tripCollection.doc(_uuid).collection('items').doc(item).get();
      int newtotal = 0;
      Map<String, int> bene_items = <String, int>{};
      (item_shot['subitems'] as Map<String, dynamic>).forEach((uuid, quantity) {
        bene_items[uuid] = int.parse(quantity.toString());
        if (!bene_uuids.contains(uuid)) {
          newtotal += int.parse(quantity.toString());
        }
      });
      bene_uuids.forEach((bene_uuid) {
        bene_items.remove(bene_uuid);
      });
      await tripCollection.doc(_uuid).collection('items').doc(item).update({'quantity': newtotal, 'subitems': bene_items});
    });
    notifyListeners();
  }

  // user adds an item for first time
  addItem(String name, String defaultUser) {
    var uuider = Uuid();
    String item_uid = uuider.v4();
    Map<String, int> bene_subitem = {};
    _beneficiaries.forEach((bene) {
      if (bene == defaultUser) {
        bene_subitem[bene] = 1;
      } else {
        bene_subitem[bene] = 0;
      }
    });
    tripCollection.doc(_uuid).collection('items').doc(item_uid).set({
      'name': name,
      'quantity': 1,
      'subitems': bene_subitem,
      'uuid': item_uid,
      'timeStamp': DateTime.now().microsecondsSinceEpoch,
      'check': false,
      'price': 0.0,
    });
    itemUUID.add(item_uid);
    notifyListeners();
  }

  // edits individual item within list, notifies listeners, updates database
  editItem(String item_uid, int sum, String bene_uid, int bene_quantity) async {
    DocumentSnapshot old_data =
        await tripCollection.doc(_uuid).collection('items').doc(item_uid).get();
    Map<String, int> bene_value = {};
    (old_data['subitems'] as Map<String, dynamic>).forEach((bene, value) {
      bene_value[bene] = int.parse(value.toString());
    });
    bene_value[bene_uid] = bene_quantity;
    await tripCollection.doc(_uuid).collection('items').doc(item_uid).update({
      "quantity": sum,
      "subitems": bene_value,
    });
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
    await tripCollection.doc(_uuid).set({
      'uuid': _uuid,
      'title': _title,
      'date': _date,
      'description': _description,
      'host': _host,
      'beneficiaries': _beneficiaries,
      'lock': false,
    });
  }

  // only update trip date in db
  // TODO may need to make two more similar methods for date and description
  updateTripDateDB() {
    tripCollection.doc(_uuid).update({'date': _date});
  }

  changeTripLock() async {
    //switch lock
    lock = !lock;
    await tripCollection.doc(_uuid).update({'lock': lock});
  }

  setAllCheckFalse() async {
    tripCollection.doc(_uuid).collection('items').get().then((collection) => {
          collection.docs.forEach((doc) {
            tripCollection
                .doc(_uuid)
                .collection('items')
                .doc(doc['uuid'])
                .update({'check': false});
          })
        });
  }

  changeItemCheck(String itemID) async {
    DocumentSnapshot item =
        await tripCollection.doc(_uuid).collection('items').doc(itemID).get();
    bool curCheck = item['check'];
    //switch the checkmark
    curCheck = !curCheck;
    await tripCollection
        .doc(_uuid)
        .collection('items')
        .doc(itemID)
        .update({'check': curCheck});
  }

  deleteTripDB() async {
    print(_uuid);
    QuerySnapshot items_snapshot = await tripCollection.doc(_uuid).collection('items').get();
    items_snapshot.docs.forEach((item_doc) {
      item_doc.reference.delete();
    });
    // itemUUID.forEach((uid) {
    //   tripCollection.doc(_uuid).collection('items').doc(uid).delete();
    // });
    // tripCollection.doc(_uuid).collection('items').doc('dummy').delete();
    // tripCollection.doc(_uuid).collection('items').doc('tax').delete();
    // tripCollection.doc(_uuid).collection('items').doc('add. fees').delete();
    _beneficiaries.forEach((bene) {
      userCollection.doc(bene).collection('shopping_trips').doc(_uuid).delete();
    });
    tripCollection.doc(_uuid).delete();
    notifyListeners();
  }

  // only updates trip metadata in db
  updateTripMetadataDB() {
    // print('benes: $_beneficiaries');
    tripCollection.doc(_uuid).update({'title': _title});
    tripCollection.doc(_uuid).update({'date': _date});
    tripCollection.doc(_uuid).update({'description': _description});
    //tripCollection.doc(_uuid).update({'beneficiaries': _beneficiaries});
  }

  // updates after a beneficiary has been added
  updateBeneficiaryDB() {
    tripCollection.doc(_uuid).update({'beneficiaries': _beneficiaries});
  }

  updateItemQuantity(String item_uid, String bene_uid, int quantity) async {
    await tripCollection.doc(_uuid).collection('items').doc(item_uid).update({
      "subitems": {"${bene_uid}": quantity}
    });
    //"subitems": {"${bene_uid}": bene_quantity}
  }
}

class Item {
  late String name;
  late int quantity;
  late bool check;
  Map<String, int> subitems =
      <String, int>{}; // uuid to individual quantity needed
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

  setSubitems(Map<String, int> subs) {
    this.subitems = subs;
  }
}
