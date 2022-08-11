import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_mule/components/header.dart';
import 'package:grocery_mule/constants.dart';
import 'package:grocery_mule/dev/collection_references.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
//import 'package:grocery_mule/providers/shopping_trip_provider.dart';
import 'package:grocery_mule/screens/editlist.dart';
import 'package:grocery_mule/screens/lists.dart';
import 'package:grocery_mule/theme/colors.dart';
import 'package:grocery_mule/theme/text_styles.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../components/text_buttons.dart';
import '../components/text_fields.dart';

class UserName extends StatefulWidget {
  late final String userUUID;
  UserName(String userUUID) {
    this.userUUID = userUUID;
  }

  @override
  _UserNameState createState() => _UserNameState();
}

class _UserNameState extends State<UserName> {
  late String userUUID;
  late String name;

  @override
  void initState() {
    userUUID = widget.userUUID;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: userCollection.doc(userUUID).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          name = snapshot.data!['first_name'];
          return Text(
            '${snapshot.data!['first_name']} ',
            style: TextStyle(fontSize: 20, color: Colors.red),
          );
        });
  }

  String getName() {
    return name;
  }
}

class CreateListScreen extends StatefulWidget {
  final _auth = FirebaseAuth.instance;
  static String id = 'create_list_screen';
  late String trip_uuid;
  late String initTitle;

  late String initDescription;

  late DateTime initDate;
  late bool newList;

  //createList has the ids
  //when createList has a list that's already filled
  //keep a field of the original id, but generate a new id
  //in the return variable
  CreateListScreen(bool newList, String trip_id) {
    this.newList = newList;
    trip_uuid = trip_id;
  }

  @override
  _CreateListsScreenState createState() => _CreateListsScreenState();
}

class _CreateListsScreenState extends State<CreateListScreen> {
  final User? curUser = FirebaseAuth.instance.currentUser;
  late bool newList;
  late String trip_uuid;
  //////////////////////
  TextEditingController _tripTitleController = TextEditingController();
  var _tripDescriptionController;
  final String hostUUID = FirebaseAuth.instance.currentUser!.uid;
  final String? hostFirstName = FirebaseAuth.instance.currentUser!.displayName;
  //Map<String,Item_front_end> frontend_list = {}; // name to frontend item
  bool isAdd = false;
  bool delete_list = false;
  bool invite_guest = false;
  String newTitle = '';
  String newDesc = '';
  List<String> old_benes = [];
  List<String> friend_bene = [];
  //List<String> selected_friend = [];
  Map<String, String> friendsName = {};
  late DateTime localTime;

  @override
  void initState() {
    trip_uuid = widget.trip_uuid;

    newList = widget.newList;
    if (trip_uuid != "dummy") {
      _tripTitleController = TextEditingController(text: '');
      _tripDescriptionController = TextEditingController()..text = '';
      newList = false;
      //selected_friend = context.read<ShoppingTrip>().beneficiaries;
    } else {
      localTime = DateTime.now();
      newList = true;
    }
    super.initState();
  }

  Future<void> total_expenditure(String uid) async {
    double trip_total = 0;
    Map<String, double> total_per_user = {};
    friend_bene.forEach((uid) {
      total_per_user[uid] = 0;
    });
    QuerySnapshot items =
        await tripCollection.doc(uid).collection('items').get();
    items.docs.forEach((doc) {
      if (doc['uuid'] != 'tax' && doc['uuid'] != 'add. fees') {
        Map<String, dynamic> curSubitems = doc
            .get(FieldPath(['subitems'])); // get map of subitems for cur item
        double unit_price = doc['price'] / doc['quantity'];

        curSubitems.forEach((key, quantity) {
          // add item name & quantity if user UUIDs match & quantity > 0
          if (curSubitems[key] > 0) {
            total_per_user[key] = total_per_user[key]! + quantity * unit_price;
          }
        });
      } else {
        double unit_price =
            double.parse(doc['price'].toString()) / friend_bene.length;
        friend_bene.forEach((key) {
          total_per_user[key] = total_per_user[key]! + unit_price;
        });
      }
    });
    friend_bene.forEach((uid) async {
      DocumentSnapshot user = await userCollection.doc(uid).get();
      double cur_total = double.parse(user['total expenditure'].toString());
      cur_total += total_per_user[uid]!;
      await userCollection.doc(uid).update({
        'total expenditure': cur_total.toStringAsFixed(2),
      });
    });
    return;
  }

  void _loadCurrentTrip(DocumentSnapshot snapshot) {
    DateTime date = DateTime.now();
    date = (snapshot.data() as Map<String, dynamic>)['date'].toDate();
    localTime = date;
    _tripTitleController = TextEditingController(text: snapshot['title']);
    newTitle = snapshot['title'];
    _tripDescriptionController = TextEditingController()
      ..text = snapshot['description'];
    newDesc = snapshot['description'];
    (snapshot['beneficiaries'] as List<dynamic>).forEach((uid) {
      friend_bene.add(uid);
      old_benes.add(uid);
    });
  }

  removeBeneficiaries(List<String> bene_uuids) async {
    old_benes.removeWhere((element) => bene_uuids.contains(element));
    await removeBeneficiariesFromItems(bene_uuids);
    await tripCollection
        .doc(trip_uuid)
        .update({'beneficiaries': FieldValue.arrayRemove(bene_uuids)});
    bene_uuids.forEach((String bene_uuid) async {
      await userCollection
          .doc(bene_uuid)
          .collection('shopping_trips')
          .doc(trip_uuid)
          .delete();
    });
  }

  removeBeneficiariesFromItems(List<String> bene_uuids) async {
    QuerySnapshot items_shot =
        await tripCollection.doc(trip_uuid).collection('items').get();
    List<String> itemUUID = [];
    if (items_shot.docs != null && items_shot.docs.isNotEmpty) {
      items_shot.docs.forEach((item_uuid) {
        if (item_uuid.id.trim() != 'tax' &&
            item_uuid.id.trim() != 'add. fees') {
          itemUUID.add(item_uuid.id.trim());
        }
      });
    }
    itemUUID.forEach((item) async {
      DocumentSnapshot item_shot = await tripCollection
          .doc(trip_uuid)
          .collection('items')
          .doc(item)
          .get();
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
      await tripCollection
          .doc(trip_uuid)
          .collection('items')
          .doc(item)
          .update({'quantity': newtotal, 'subitems': bene_items});
    });
  }

  addBeneficiary(List<String> bene_uuids) async {
    bene_uuids.forEach((String bene_uuid) async {
      await userCollection
          .doc(bene_uuid)
          .collection('shopping_trips')
          .doc(trip_uuid)
          .set({'date': localTime});
    });
    await tripCollection
        .doc(trip_uuid)
        .update({'beneficiaries': FieldValue.arrayUnion(bene_uuids)});
    //add bene to every item document
    QuerySnapshot items_shot =
        await tripCollection.doc(trip_uuid).collection('items').get();
    List<String> itemUUID = [];
    if (items_shot.docs != null && items_shot.docs.isNotEmpty) {
      items_shot.docs.forEach((item_uuid) {
        if (item_uuid.id.trim() != 'tax' &&
            item_uuid.id.trim() != 'add. fees') {
          itemUUID.add(item_uuid.id.trim());
        }
      });
    }
    itemUUID.forEach((item) async {
      Map<String, int> bene_items = <String, int>{};
      bene_uuids.forEach((bene_uuid) {
        bene_items[bene_uuid] = 0;
      });
      await tripCollection
          .doc(trip_uuid)
          .collection('items')
          .doc(item)
          .update({'subitems': bene_items});
    });
  }

  Future<void> updateGridView(bool new_trip) async {
    if (new_trip) {
      friend_bene.add(hostUUID);
      print('selected friends: $friend_bene');
      /*
      await context.read<ShoppingTrip>().initializeTrip(
          context.read<ShoppingTrip>().title,
          context.read<ShoppingTrip>().date,
          context.read<ShoppingTrip>().description,
          friend_bene,
          curUser!.uid);
       */

      var tripId = Uuid().v4();
      await tripCollection.doc(tripId).set({
        'uuid': tripId,
        'title': newTitle,
        'date': localTime,
        'description': newDesc,
        'host': curUser!.uid,
        'beneficiaries': friend_bene,
        'lock': false,
      });
      await tripCollection
          .doc(tripId)
          .collection("items")
          .doc("tax")
          .set({'price': "0.00", 'uuid': 'tax', 'name': 'tax'});
      await tripCollection
          .doc(tripId)
          .collection("items")
          .doc("add. fees")
          .set({'price': "0.00", 'uuid': 'add. fees', 'name': 'add. fees'});
      friend_bene.remove(hostUUID);
      for (var friend in friend_bene) {
        //context.read<ShoppingTrip>().addBeneficiary(friend, true);
        context.read<Cowboy>().addTrip(friend, tripId, localTime);
        //addTripToBene(String bene_uuid, String trip_uuid)
      }
      context
          .read<Cowboy>()
          .addTrip(context.read<Cowboy>().uuid, tripId, localTime);
    } else {
      List<String> removeList = [];
      old_benes.forEach((old_bene) {
        if (!friend_bene.contains(old_bene) &&
            old_bene != context.read<Cowboy>().uuid) {
          removeList.add(old_bene);
        }
      });

      removeBeneficiaries(removeList);
      // print('friend bene in updategridview: $friend_bene');
      List<String> addList = [];
      //check if new bene need to be added
      for (var friend in friend_bene) {
        if (!old_benes.contains(friend)) {
          addList.add(friend);
        }
      }
      addBeneficiary(addList);
      tripCollection.doc(trip_uuid).update(
          {'title': newTitle, 'date': localTime, 'description': newDesc});
      friend_bene.forEach((user) {
        userCollection
            .doc(user)
            .collection('shopping_trips')
            .doc(trip_uuid)
            .update({'date': localTime});
      });
    }
  }

  deleteTripDB() async {
    QuerySnapshot items_snapshot =
        await tripCollection.doc(trip_uuid).collection('items').get();
    items_snapshot.docs.forEach((item_doc) {
      item_doc.reference.delete();
    });
    friend_bene.forEach((bene) {
      userCollection
          .doc(bene)
          .collection('shopping_trips')
          .doc(trip_uuid)
          .delete();
    });
    tripCollection.doc(trip_uuid).delete();
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: localTime,
        firstDate: DateTime(2022),
        lastDate: DateTime(2050),
        builder: (context, child) => Theme(
              data: ThemeData().copyWith(
                  colorScheme: ColorScheme.light(
                      primary: appOrange,
                      onPrimary: Colors.white,
                      onSurface: Colors.black)),
              child: child!,
            ));
    if (picked != null && picked != localTime) {
      setState(() {
        localTime = picked;
      });
    }
  }

  List<MultiSelectItem<String>> loadFriendsName(QuerySnapshot snapshot) {
    snapshot.docs.forEach((document) {
      friendsName[document['uuid']] = document['first_name'];
    });
    return friendsName.keys
        .toList()
        .map((uid) => MultiSelectItem<String>(uid, friendsName[uid]!))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: (newList)
              ? const Text(
                  'Create List',
                  style: TextStyle(color: Colors.black),
                )
              : Text(
                  'List Settings',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
          ),
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          backgroundColor: appOrange,
        ),
        body: FutureBuilder<DocumentSnapshot>(
            future: tripCollection.doc(trip_uuid).get(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: const CircularProgressIndicator());
              }
              if (snapshot.data!.exists) {
                _loadCurrentTrip(snapshot.data!);
              }

              return Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    // list name

                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                      color: appColorLight,
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: StreamBuilder<QuerySnapshot>(
                              stream: userCollection
                                  .where('friends',
                                      arrayContains:
                                          context.read<Cowboy>().uuid)
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return Text(
                                      'Something went wrong StreamBuilder');
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }
                                List<MultiSelectItem<String>> friends = [];
                                //print("first friend: ${snapshot.data!.docs[1].get('uuid')}");

                                snapshot.data!.docs.forEach((document) {
                                  friends.add(MultiSelectItem<String>(
                                      document['uuid'],
                                      document['first_name']));
                                });

                                return MultiSelectDialogField(
                                  searchable: true,
                                  items: friends,
                                  initialValue: old_benes,
                                  title: Text('Friends'),
                                  selectedColor: dark_beige,
                                  decoration: BoxDecoration(
                                    color: dark_beige.withOpacity(0.25),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                  buttonIcon: Icon(
                                    Icons.person,
                                    color: Colors.black,
                                  ),
                                  buttonText: Text(
                                    'Selected Friends',
                                    style: appFontStyle.copyWith(
                                        color: Colors.black),
                                  ),
                                  onConfirm: (results) {
                                    //print(results.toList());
                                    friend_bene = results
                                        .map((e) => e.toString())
                                        .toList();
                                    print('updated benes: $friend_bene');
                                  },
                                );
                              }),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: HomeHeader(
                          title: "Trip Details",
                          color: appOrange,
                          textColor: Colors.white),
                    ),

                    // spacer
                    Row(
                      children: [
                        Expanded(
                          child: TextFields(
                            inSquare: false,
                            controller: _tripTitleController,
                            borderColor: appOrange,
                            context: context,
                            enabled: true,
                            focusColor: Colors.black,
                            helpText: "List Name",
                            hintText: "",
                            show: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.verified_user_outlined)),
                            icon: Tab(icon: Icon(Icons.abc_outlined)),
                            input: TextInputType.text,
                            secureText: false,
                            onChanged: (value) {
                              newTitle = value;
                              print('title is now: ${newTitle}');
                            },
                            suffix: Container(),
                            onTap1: () {},
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 10.h,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: TextFields(
                            inSquare: false,
                            controller: _tripDescriptionController,
                            borderColor: appOrange,
                            context: context,
                            enabled: true,
                            focusColor: Colors.black,
                            helpText: "Description",
                            hintText: "",
                            show: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.verified_user_outlined)),
                            icon: Tab(icon: Icon(Icons.abc_outlined)),
                            input: TextInputType.text,
                            secureText: false,
                            onChanged: (value) {
                              newDesc = value;
                            },
                            suffix: Container(),
                            onTap1: () {},
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 10.h,
                    ),

                    Center(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //DatePicker(newList, trip_uuid),
                        Row(
                          children: [
                            Text(
                              'Date:  ' +
                                  '${localTime.toString()}'
                                      .split(' ')[0]
                                      .replaceAll('-', '/'),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            //SizedBox(width: 5.0,),
                            IconButton(
                              icon: Icon(
                                Icons.calendar_today,
                                color: appOrange,
                              ),
                              onPressed: () => _selectDate(context),
                            ),
                          ],
                        ),
                      ],
                    )),
                    // create/delete buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 180,
                          height: MediaQuery.of(context).size.height / 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: RectangularTextButton(
                            buttonColor: Colors.green,
                            textColor: Colors.white,
                            onPressed: () async {
                              if (newTitle != '') {
                                await updateGridView(newList);
                                Navigator.pop(context);
                                if (newList) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              EditListScreen(trip_uuid)));
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg: 'List name cannot be empty');
                              }
                            },
                            text: (newList) ? 'Create List' : 'Save Changes',
                          ),
                        ),
                        Spacer(),
                        Container(
                          width: 180,
                          height: MediaQuery.of(context).size.height / 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: RectangularTextButton(
                            buttonColor: Colors.redAccent,
                            textColor: Colors.white,
                            text: "Delete List",
                            onPressed: () async {
                              await check_delete(context);
                              if (delete_list) {
                                if (!newList) {
                                  await total_expenditure(trip_uuid);
                                  deleteTripDB();
                                }
                                Navigator.of(context).popUntil((route) {
                                  return route.settings.name == ListsScreen.id;
                                });
                                Navigator.pushNamed(context, ListsScreen.id);
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          height: 200.0,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }));
  }

  check_delete(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure you wish to delete this list?"),
          actions: <Widget>[
            TextButton(
                onPressed: () => {
                      delete_list = true,
                      Navigator.of(context).pop(),
                    },
                child: const Text("DELETE")),
            TextButton(
              onPressed: () => {
                delete_list = false,
                Navigator.of(context).pop(),
              },
              child: const Text("CANCEL"),
            ),
          ],
        );
      },
    );
  }
}
