import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_mule/components/rounded_ button.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:grocery_mule/screens/editlist.dart';
import 'dart:async';
import 'package:grocery_mule/screens/lists.dart';
import 'package:provider/provider.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:grocery_mule/providers/shopping_trip_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'dart:io';
import 'package:multi_select_flutter/multi_select_flutter.dart';


typedef StringVoidFunc = void Function(String,int);

class CreateListScreen extends StatefulWidget {
  final _auth = FirebaseAuth.instance;
  final User curUser = FirebaseAuth.instance.currentUser;
  static String id = 'create_list_screen';
  String trip_uuid;
  String initTitle;
  String initDescription;
  DateTime initDate;
  bool newList;
  //createList has the ids
  //when createList has a list that's already filled
  //keep a field of the original id, but generate a new id
  //in the return variable
  CreateListScreen(bool newList, [String trip_id = null]) {
    this.newList = newList;
    trip_uuid = trip_id;
  }

  @override
  _CreateListsScreenState createState() => _CreateListsScreenState();
}

class _CreateListsScreenState extends State<CreateListScreen> {
  final _auth = FirebaseAuth.instance;
  final User curUser = FirebaseAuth.instance.currentUser;
  bool newList;
  String trip_uuid;
  //////////////////////
  var _tripTitleController;
  CollectionReference shoppingTripCollection = FirebaseFirestore.instance.collection('shopping_trips_test');
  var _tripDescriptionController;
  final String hostUUID = FirebaseAuth.instance.currentUser.uid;
  String hostFirstName = FirebaseAuth.instance.currentUser.displayName;
  //Map<String,Item_front_end> frontend_list = {}; // name to frontend item
  bool isAdd = false;
  bool delete_list = false;
  bool invite_guest = false;
  ShoppingTrip cur_trip;
  Map<String,String> uid_name = {};
  List<MultiSelectItem<String>> friend_bene = [];
  List<String> selected_friend = [];

  @override
  void initState() {
    trip_uuid = widget.trip_uuid;
    _tripTitleController = TextEditingController()..text = widget.initTitle;
    _tripDescriptionController = TextEditingController()..text = widget.initDescription;
    newList = widget.newList;
    cur_trip = context.read<ShoppingTrip>();
    if(trip_uuid != null) {
      _loadCurrentTrip();
      _tripTitleController = TextEditingController()..text = cur_trip.title;
      _tripDescriptionController = TextEditingController()..text = cur_trip.description;
      newList = false;
    }else{
      clear_provider();
    }
    // full_list = trip.beneficiaries;
    //end test code
    super.initState();

    friend_bene = context.read<Cowboy>().friends.keys
        .map((uid) => MultiSelectItem<String>(uid,context.read<Cowboy>().friends[uid]))
        .toList();


  }
  
  void clear_provider(){
    context.read<ShoppingTrip>().editTripDate(DateTime.now());
    context.read<ShoppingTrip>().editTripDescription("");
    context.read<ShoppingTrip>().editTripTitle("");
    context.read<ShoppingTrip>().clearCachedBene();
    context.read<ShoppingTrip>().clearCachedItem();
  }

  void _loadCurrentTrip() {
    _queryCurrentTrip().then((DocumentSnapshot snapshot) {
      if(snapshot != null) {
        DateTime date = DateTime.now();
        List<String> beneficiaries = <String>[];
        Map<String, Item> items = <String, Item>{};
        date = (snapshot.data() as Map<String, dynamic>)['date'].toDate();
        (snapshot['beneficiaries'] as Map<String,dynamic>).forEach((uid,name) {
          uid_name[uid.toString()] = name.toString();
        });
        ((snapshot.data() as Map<String, dynamic>)['items'] as Map<String, dynamic>).forEach((name, dynamicItem) {
          items[name] = Item.fromMap(dynamicItem as Map<String, dynamic>);
          items[name].isExpanded = false;
          //add each item to the panel (for expandable items presented to user)
          //frontend_list[name] = new Item_front_end(name, items[name]);
        });

        setState(() {
          cur_trip.initializeTripFromDB(snapshot['uuid'],
              (snapshot.data() as Map<String, dynamic>)['title'], date,
              (snapshot.data() as Map<String, dynamic>)['description'],
              (snapshot.data() as Map<String, dynamic>)['host'],
              uid_name, items);

        });
      }else{
        uid_name[hostUUID] = hostFirstName;
        uid_name['NpGPpb8B0Te8OZyywLr69f3WEwn1'] = 'Praf';
        uid_name['yTWmoo2Qskf3wFcbxaJYUt9qrZM2'] = 'Dhruv';

      }
    });
  }

  Future<DocumentSnapshot> _queryCurrentTrip() async {
    if(trip_uuid != '') {
      DocumentSnapshot tempShot;
      await shoppingTripCollection.doc(trip_uuid).get().then((docSnapshot) => tempShot=docSnapshot);
      print(tempShot.data());
      return tempShot;
    } else {
      return null;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: context.read<ShoppingTrip>().date,
        firstDate: DateTime(2022),
        lastDate: DateTime(2050),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light().copyWith(
                primary: const Color(0xFFbc5100),
              ),
            ),
            child: child,
          );
        }
    );
    if (picked != null && picked != context.read<ShoppingTrip>().date) {
      context.read<ShoppingTrip>().editTripDate(picked);
    }
  }

  Future<void> updateGridView(bool new_trip) async {
      if(new_trip) {
        print("made here");
        await context.read<ShoppingTrip>().initializeTrip(
            context.read<ShoppingTrip>().title,
            context.read<ShoppingTrip>().date,
            context.read<ShoppingTrip>().description,
            uid_name,
            curUser.uid);


        context.read<ShoppingTrip>().addBeneficiary(hostUUID,hostFirstName);
        for(var friend in selected_friend) {
          context.read<ShoppingTrip>().addBeneficiary(friend, context.read<Cowboy>().friends[friend]);
        }

        // context.read<ShoppingTrip>().addBeneficiary('NpGPpb8B0Te8OZyywLr69f3WEwn1','Praf');
        // context.read<ShoppingTrip>().addBeneficiary('yTWmoo2Qskf3wFcbxaJYUt9qrZM2','Dhruv');

        context.read<Cowboy>().addTrip(context.read<ShoppingTrip>().uuid);
        print(context.read<Cowboy>().shoppingTrips);
      } else {
        context.read<ShoppingTrip>().updateTripMetadata(
            context.read<ShoppingTrip>().title,
            context.read<ShoppingTrip>().date,
            context.read<ShoppingTrip>().description);
        // await DatabaseService(uuid: trip.uuid).updateShoppingTrip(trip);
      }
  }

  @override
  Widget build(BuildContext context) {
    String hostUUID = context.read<Cowboy>().uuid;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Create List'),
        backgroundColor: const Color(0xFFbc5100),
      ),
      body: SafeArea(
        child: Scrollbar(
          child: ListView(
              padding: const EdgeInsets.all(25),
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'List Name',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          child: TextField(
                              keyboardType: TextInputType.text,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black),
                              controller: _tripTitleController,
                              onChanged: (value){
                                context.read<ShoppingTrip>().editTripTitle(value);
                              }

                          ),
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Date of Trip',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("${context.read<ShoppingTrip>().date.toLocal()}".split(' ')[0]),
                      SizedBox(
                        height: 20.0,
                      ),
                      RoundedButton(
                        onPressed: () => _selectDate(context),
                        title: 'Select Date',
                      ),
                    ],
                  ),
                ]),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          child: TextField(
                              keyboardType: TextInputType.emailAddress,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black),
                              controller: _tripDescriptionController,
                              onChanged: (value){
                                context.read<ShoppingTrip>().editTripDescription(value);
                              }
                          ),
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  child:
                  MultiSelectDialogField(
                    searchable: true,
                    items: friend_bene,
                    title: Text("Friends"),
                    selectedColor: const Color(0xFFbc5100),
                    decoration: BoxDecoration(
                      color: const Color(0xFFbc5100).withOpacity(0.1),
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                      border: Border.all(
                        color: const Color(0xFFbc5100),
                        width: 2,
                      ),
                    ),
                    buttonIcon: Icon(
                      Icons.person,
                      color: const Color(0xFFbc5100),
                    ),
                    buttonText: Text(
                      "Selected friends",
                      style: TextStyle(
                        color: const Color(0xFFbc5100),
                        fontSize: 16,
                      ),
                    ),
                    onConfirm: (results) {
                      selected_friend = results;
                      print(selected_friend);
                    },
                  ),

                ),
                Container(
                  height: 70,
                  width: 5,
                  child: RoundedButton(
                    onPressed: () async {
                      if(context.read<ShoppingTrip>().title != '') {
                        await updateGridView(newList);
                        Navigator.pop(context);
                        //Navigator.pushNamed(context, ListsScreen.id);
                        /*
                        if(newList)
                          Navigator.push(context, MaterialPageRoute(builder: (context) => EditListScreen(context.read<Cowboy>().uuid)));
                         */

                      } else {
                        // print("triggered");
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("List name cannot be empty"),
                              actions: [
                                TextButton(
                                  child: Text("OK"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    title: "Create List",
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 70,
                  width: 150,
                  child: RoundedButton(
                    onPressed: () async {
                      await check_delete(context);
                      if(delete_list) {
                        if(!newList) {
                          print("delete");
                          context.read<ShoppingTrip>().deleteTripDB();
                          context.read<Cowboy>().removeTrip(context
                              .read<ShoppingTrip>()
                              .uuid);
                        }
                        Navigator.of(context).popUntil((route){
                          return route.settings.name == ListsScreen.id;
                        });
                        Navigator.pushNamed(context, ListsScreen.id);
                      }
                    },
                    title: "Delete List",
                  ),
                )
              ],
            ),
        ),
      ),
    );
  }

  check_delete(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure you wish to delete this list?"),
          actions: <Widget>[
            FlatButton(
                onPressed: () => {
                  delete_list = true,
                  Navigator.of(context).pop(),
                  },
                child: const Text("DELETE")
            ),
            FlatButton(
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