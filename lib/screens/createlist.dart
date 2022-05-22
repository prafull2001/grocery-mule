import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_mule/constants.dart';
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
  final User? curUser = FirebaseAuth.instance.currentUser;
  static String id = 'create_list_screen';
  String? trip_uuid;
  late String initTitle = '';
  late String initDescription = '';
  bool? newList;
  //createList has the ids
  //when createList has a list that's already filled
  //keep a field of the original id, but generate a new id
  //in the return variable
  CreateListScreen(bool newList, [String? trip_id = null]) {
    this.newList = newList;
    trip_uuid = trip_id;
  }

  @override
  _CreateListsScreenState createState() => _CreateListsScreenState();
}

class _CreateListsScreenState extends State<CreateListScreen> {
  final _auth = FirebaseAuth.instance;
  final User? curUser = FirebaseAuth.instance.currentUser;
  bool? newList;
  String? trip_uuid;
  //////////////////////
  var _tripTitleController;
  CollectionReference shoppingTripCollection = FirebaseFirestore.instance.collection('shopping_trips_test');
  var _tripDescriptionController;
  final String hostUUID = FirebaseAuth.instance.currentUser!.uid;
  String? hostFirstName = FirebaseAuth.instance.currentUser!.displayName;
  //Map<String,Item_front_end> frontend_list = {}; // name to frontend item
  bool isAdd = false;
  bool delete_list = false;
  bool invite_guest = false;
  late ShoppingTrip cur_trip;
  Map<String,String?> uid_name = {};
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
      selected_friend = context.read<ShoppingTrip>().beneficiaries.keys.toList();
    }else{
      clear_provider();
    }
    // full_list = trip.beneficiaries;
    //end test code
    super.initState();
    print(context.read<Cowboy>().friends['nW7NnPdQGcXtj1775nrLdB1igjG2']!.split("|~|")[1].split(" ")[0]);
    friend_bene = context.read<Cowboy>().friends.keys
        .map((uid) => MultiSelectItem<String>(uid,context.read<Cowboy>().friends[uid]!.split("|~|")[1].split(" ")[0]))
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
    _queryCurrentTrip().then((DocumentSnapshot? snapshot) {
      if(snapshot != null) {
        DateTime? date = DateTime.now();
        List<String> beneficiaries = <String>[];
        Map<String, Item> items = <String, Item>{};
        date = (snapshot.data() as Map<String, dynamic>)['date'].toDate();
        (snapshot['beneficiaries'] as Map<String,dynamic>).forEach((uid,name) {
          uid_name[uid.toString()] = name.toString();
        });
        ((snapshot.data() as Map<String, dynamic>)['items'] as Map<String, dynamic>).forEach((name, dynamicItem) {
          items[name] = Item.fromMap(dynamicItem as Map<String, dynamic>);
          items[name]!.isExpanded = false;
          //add each item to the panel (for expandable items presented to user)
          //frontend_list[name] = new Item_front_end(name, items[name]);
        });

        setState(() {
          cur_trip.initializeTripFromDB(snapshot['uuid'],
              (snapshot.data() as Map<String, dynamic>)['title'], date!,
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

  Future<DocumentSnapshot?> _queryCurrentTrip() async {
    if(trip_uuid != '') {
      DocumentSnapshot? tempShot;
      await shoppingTripCollection.doc(trip_uuid).get().then((docSnapshot) => tempShot=docSnapshot);
      print(tempShot!.data());
      return tempShot;
    } else {
      return null;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: context.read<ShoppingTrip>().date,
        firstDate: DateTime(2022),
        lastDate: DateTime(2050),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light().copyWith(
                primary: dark_beige,
              ),
            ),
            child: child!,
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
            curUser!.uid);
        context.read<ShoppingTrip>().addBeneficiary(hostUUID,hostFirstName!);
        for(var friend in selected_friend) {
          context.read<ShoppingTrip>().addBeneficiary(friend, context.read<Cowboy>().friends[friend]!);
          context.read<Cowboy>().addTripToBene(friend,
              context.read<ShoppingTrip>().uuid,
              context.read<ShoppingTrip>().title,
              context.read<ShoppingTrip>().date,
              context.read<ShoppingTrip>().description
          );
               //addTripToBene(String bene_uuid, String trip_uuid)
        }
        context.read<Cowboy>().addTrip(context.read<ShoppingTrip>().uuid,
            context.read<ShoppingTrip>().title,
            context.read<ShoppingTrip>().date,
            context.read<ShoppingTrip>().description
            );
        print(context.read<Cowboy>().shoppingTrips);
      } else {
        Map<String,String> new_bene_list = {};
        //check if any bene needs to be removed
        context.read<ShoppingTrip>().beneficiaries.forEach((uid, name) {
          if(!selected_friend.contains(uid)){
            //below doesn't work
            context.read<Cowboy>().RemoveTripFromBene(uid,context.read<ShoppingTrip>().uuid);
            //context.read<ShoppingTrip>().removeBeneficiary(uid);
          }else{
            new_bene_list[uid] = name;
          }
        });
        context.read<ShoppingTrip>().setBeneficiary(new_bene_list);
        //check if new bene need to be added
        for(var friend in selected_friend) {
          if(!context.read<ShoppingTrip>().beneficiaries.containsKey(friend)) {
            context.read<ShoppingTrip>().addBeneficiary(friend, context
                .read<Cowboy>()
                .friends[friend]!);
            context.read<Cowboy>().addTripToBene(friend,
                context.read<ShoppingTrip>().uuid,
                context.read<ShoppingTrip>().title,
                context.read<ShoppingTrip>().date,
                context.read<ShoppingTrip>().description
            );

          }
          //addTripToBene(String bene_uuid, String trip_uuid)
        }
        context.read<ShoppingTrip>().updateTripMetadata(
            context.read<ShoppingTrip>().title,
            context.read<ShoppingTrip>().date,
            context.read<ShoppingTrip>().description,
            context.read<ShoppingTrip>().beneficiaries,
        );
        String entry = context.read<ShoppingTrip>().title
            + "|~|" + context.read<ShoppingTrip>().date.toString()
            + "|~|" + context.read<ShoppingTrip>().description;
        context.read<Cowboy>().updateTripForAll(context.read<ShoppingTrip>().uuid, entry, context.read<ShoppingTrip>().beneficiaries.keys.toList());

        // await DatabaseService(uuid: trip.uuid).updateShoppingTrip(trip);
      }
  }

  @override
  Widget build(BuildContext context) {
    String hostUUID = context.read<Cowboy>().uuid;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: (newList!)? const Text(
          'Create List',
          style: TextStyle(color: Colors.black),
        ):
        Text(
          'List Settings',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: light_orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            // list name
            Row(
              children: [
                Text(
                  'List Name:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Expanded(
                  child: Container(
                    child: TextField(
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          fillColor: darker_beige,
                        ),
                        controller: _tripTitleController,
                        onChanged: (value){
                          context.read<ShoppingTrip>().editTripTitle(value);
                        }
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.0,),

            // trip date
            Row(
              children: [
                Text(
                  'Trip Date:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 10.0,),
                Text(
                  '${context.watch<ShoppingTrip>().date.toLocal()}'.split(' ')[0].replaceAll('-', '/'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                //SizedBox(width: 5.0,),
                IconButton(
                  icon: Icon(Icons.calendar_today, color: orange,),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),

            SizedBox(height: 10.0,),

            // description header
            Row(
              children: [
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),

            // description body
            Row(
              children: [
                Expanded(
                  child: Container(
                    child: TextField(
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          fillColor: darker_beige,
                        ),
                        controller: _tripDescriptionController,
                        onChanged: (value){
                          context.read<ShoppingTrip>().editTripDescription(value);
                        }
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.0,),

            // selected friends
            Container(
              child:
              MultiSelectDialogField(
                searchable: true,
                items: friend_bene,
                initialValue: context.read<ShoppingTrip>().beneficiaries.keys.toList(),
                title: Text('Friends'),
                selectedColor: dark_beige,
                decoration: BoxDecoration(
                  color: dark_beige.withOpacity(0.25),
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                  border: Border.all(
                    color: darker_beige,
                    width: 2,
                  ),
                ),
                buttonIcon: Icon(
                  Icons.person,
                  color: orange,
                ),
                buttonText: Text(
                  'Selected Friends',
                  style: TextStyle(
                    color: darker_beige,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                onConfirm: (results) {
                  selected_friend = results as List<String>;
                  print(selected_friend);
                },
              ),
            ),

            // spacer
            Spacer(),

            // create/delete buttons
            Row(
              children: [
                Container(
                  width: 180,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: TextButton(
                    child: newList!? Text(
                      'Create List',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ):Text(
                      'Edit List',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(orange),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                      ),
                    ),
                    onPressed: () async {
                      if(context.read<ShoppingTrip>().title != '') {
                        await updateGridView(newList!);
                        setState(() {});
                        Navigator.pop(context);
                        if(newList!) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) =>
                                  EditListScreen(context
                                      .read<ShoppingTrip>()
                                      .uuid)));
                        }
                      } else {
                        // print("triggered");
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('List name cannot be empty'),
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
                  ),
                ),
                Spacer(),
                Container(
                  width: 180,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: TextButton(
                    child: Text(
                      'Delete List',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(red),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                      ),
                    ),
                    onPressed: () async {
                      await check_delete(context);
                      if(delete_list) {
                        if(!newList!) {
                          print('delete');
                          context.read<ShoppingTrip>().deleteTripDB();
                          context.read<Cowboy>().removeTrip(context.read<ShoppingTrip>().uuid);
                        }
                        Navigator.of(context).popUntil((route){
                          return route.settings.name == ListsScreen.id;
                        });
                        Navigator.pushNamed(context, ListsScreen.id);
                      }
                    },
                  ),
                ),
                SizedBox(height: 200.0,),
              ],
            ),
          ],
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