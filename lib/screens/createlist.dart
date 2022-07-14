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
import 'package:grocery_mule/providers/shopping_trip_provider.dart';
import 'package:grocery_mule/screens/editlist.dart';
import 'package:grocery_mule/screens/lists.dart';
import 'package:grocery_mule/theme/colors.dart';
import 'package:grocery_mule/theme/text_styles.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';

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

typedef StringVoidFunc = void Function(String, int);

class DatePicker extends StatefulWidget {
  bool newlist = false;
  String tripuuid = '';

  DatePicker(bool newlist, String tripuuid) {
    this.newlist = newlist;
    this.tripuuid = tripuuid;
  }

  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  bool newlist = false;
  String tripid = '';
  DateTime date = DateTime.now();
  bool clicked = false;

  @override
  void initState() {
    super.initState();
    this.newlist = widget.newlist;
    this.tripid = widget.tripuuid;
  }

  _selectDate(BuildContext context, DateTime initdate) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initdate,
        firstDate: DateTime(2022),
        lastDate: DateTime(2050),
        builder: (context, child) => Theme(
              data: ThemeData().copyWith(
                  colorScheme: ColorScheme.light(
                      primary: Colors.amber,
                      onPrimary: Colors.white,
                      onSurface: Colors.black)),
              child: child!,
            ));
    if (picked != null && picked != context.read<ShoppingTrip>().date) {
      context.read<ShoppingTrip>().editTripDate(picked);
      setState(() {
        // print('setted state uwu');
        date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (newlist) {
      return Row(
        children: [
          Text(
            '$date'.split(' ')[0].replaceAll('-', '/'),
            style: appFontStyle.copyWith(color: Colors.black),
          ),
          //SizedBox(width: 5.0,),
          IconButton(
            icon: Icon(
              Icons.calendar_today,
              color: orange,
            ),
            onPressed: () => _selectDate(context, DateTime.now()),
          ),
        ],
      );
    }
    return FutureBuilder<DocumentSnapshot>(
        future: tripCollection.doc(tripid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          String tdate = context.read<ShoppingTrip>().date.toString();
          if (!clicked) {
            tdate = (snapshot.data!['date'] as Timestamp).toDate().toString();
            clicked = true;
          }
          return Row(
            children: [
              Text(
                '$tdate'.split(' ')[0].replaceAll('-', '/'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              //SizedBox(width: 5.0,),
              IconButton(
                icon: Icon(
                  Icons.calendar_today,
                  color: orange,
                ),
                onPressed: () =>
                    _selectDate(context, context.read<ShoppingTrip>().date),
              ),
            ],
          );
        });
  }
}

class CreateListScreen extends StatefulWidget {
  final _auth = FirebaseAuth.instance;
  final User? curUser = FirebaseAuth.instance.currentUser;
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
  final _auth = FirebaseAuth.instance;
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
  late ShoppingTrip cur_trip;
  //List<String> uid_name = [];
  List<String> friend_bene = [];
  //List<String> selected_friend = [];
  Map<String, String> friendsName = {};
  DateTime localTime = DateTime.now();

  @override
  void initState() {
    trip_uuid = widget.trip_uuid;

    newList = widget.newList;
    context.read<ShoppingTrip>().clearField();
    cur_trip = context.read<ShoppingTrip>();
    if (trip_uuid != "dummy") {
      _tripTitleController = TextEditingController(text: cur_trip.title);
      _tripDescriptionController = TextEditingController()
        ..text = cur_trip.description;
      newList = false;
      //selected_friend = context.read<ShoppingTrip>().beneficiaries;
    } else {
      clear_provider();
      newList = true;
    }
    super.initState();
  }

  void clear_provider() {
    context.read<ShoppingTrip>().editTripDate(DateTime.now());
    context.read<ShoppingTrip>().editTripDescription("");
    context.read<ShoppingTrip>().editTripTitle("");
    context.read<ShoppingTrip>().clearCachedBene();
    context.read<ShoppingTrip>().clearCachedItem();
    _tripTitleController = TextEditingController()..text = "";
    _tripDescriptionController = TextEditingController()..text = "";
  }

  void _loadCurrentTrip(DocumentSnapshot snapshot) {
    DateTime date = DateTime.now();
    List<String> beneficiaries = <String>[];
    //Map<String, Item> items = <String, Item>{};
    date = (snapshot.data() as Map<String, dynamic>)['date'].toDate();
    localTime = date;

    (snapshot['beneficiaries'] as List<dynamic>).forEach((uid) {
      friend_bene.add(uid);
    });
    friend_bene.forEach((element) {
      beneficiaries.add(element);
    });
    // setState(() {
    cur_trip.initializeTripFromDB(
      snapshot['uuid'],
      snapshot['title'],
      date,
      snapshot['description'],
      snapshot['host'],
      beneficiaries,
      snapshot['lock'] as bool,
    );
    // });
    print(context.read<ShoppingTrip>().beneficiaries);
  }

  Future<void> updateGridView(bool new_trip) async {
    if (new_trip) {
      print("made here");
      friend_bene.add(hostUUID);
      await context.read<ShoppingTrip>().initializeTrip(
          context.read<ShoppingTrip>().title,
          context.read<ShoppingTrip>().date,
          context.read<ShoppingTrip>().description,
          friend_bene,
          curUser!.uid);
      friend_bene.remove(hostUUID);
      for (var friend in friend_bene) {
        //context.read<ShoppingTrip>().addBeneficiary(friend, true);
        context.read<Cowboy>().addTrip(
            friend,
            context.read<ShoppingTrip>().uuid,
            context.read<ShoppingTrip>().date);
        //addTripToBene(String bene_uuid, String trip_uuid)
      }
      //context.read<ShoppingTrip>().addBeneficiary(hostUUID);

      context.read<Cowboy>().addTrip(context.read<Cowboy>().uuid,
          context.read<ShoppingTrip>().uuid, context.read<ShoppingTrip>().date);
    } else {
      print(context.read<ShoppingTrip>().beneficiaries);
      print("starting to edit list");
      List<String> removeList = [];
      print(friend_bene);
      context.read<ShoppingTrip>().beneficiaries.forEach((old_bene) {
        if (!friend_bene.contains(old_bene) &&
            old_bene != context.read<Cowboy>().uuid) {
          print("remove: " + old_bene);
          removeList.add(old_bene);
        }
      });

      //check if any bene needs to be removed
      print("removeList: " + removeList.toString());
      context.read<ShoppingTrip>().removeBeneficiaries(removeList);

      //check if new bene need to be added
      for (var friend in friend_bene) {
        if (!context.read<ShoppingTrip>().beneficiaries.contains(friend)) {
          //print(friend);
          print("adding new bene: " + friend);
          context.read<ShoppingTrip>().addBeneficiary(friend);
          //context.read<Cowboy>().addTripToBene(friend, context.read<ShoppingTrip>().uuid,);
        }
        // addTripToBene(String bene_uuid, String trip_uuid)
      }
      print(context.read<ShoppingTrip>().beneficiaries);
      context.read<ShoppingTrip>().updateTripMetadata(
            context.read<ShoppingTrip>().title,
            context.read<ShoppingTrip>().date,
            context.read<ShoppingTrip>().description,
            context.read<ShoppingTrip>().beneficiaries,
          );
      // await DatabaseService(uuid: trip.uuid).updateShoppingTrip(trip);
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
    TextEditingController textControl = TextEditingController();
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
          backgroundColor: light_orange,
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
              print(localTime);

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
                                  initialValue: context
                                      .read<ShoppingTrip>()
                                      .beneficiaries,
                                  title: Text('Friends'),
                                  selectedColor: dark_beige,
                                  decoration: BoxDecoration(
                                    color: dark_beige.withOpacity(0.25),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    // border: Border.all(
                                    //   color: darker_beige,
                                    //   width: 2,
                                    // ),
                                  ),
                                  buttonIcon: Icon(
                                    Icons.person,
                                    color: Colors.blueGrey,
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
                                    print(context
                                        .read<ShoppingTrip>()
                                        .beneficiaries);
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
                              context.read<ShoppingTrip>().editTripTitle(value);
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
                              context
                                  .read<ShoppingTrip>()
                                  .editTripDescription(value);
                            },
                            suffix: Container(),
                            onTap1: () {},
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: HomeHeader(
                          title: "Date",
                          color: appOrange,
                          textColor: Colors.white),
                    ),
                    Center(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DatePicker(newList, trip_uuid),
                      ],
                    )),

                    // create/delete buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 180,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: RectangularTextButton(
                            buttonColor: Colors.green,
                            textColor: Colors.white,
                            onPressed: () async {
                              if (context.read<ShoppingTrip>().title != '') {
                                print("editing list");
                                await updateGridView(newList);
                                Navigator.pop(context);
                                if (newList) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditListScreen(
                                              context
                                                  .read<ShoppingTrip>()
                                                  .uuid)));
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
                          height: 50,
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
                                  print('delete');
                                  context
                                      .read<ShoppingTrip>()
                                      .removeStaleTripUUIDS();
                                  context.read<ShoppingTrip>().deleteTripDB();
                                  context.read<Cowboy>().removeTrip(
                                      context.read<Cowboy>().uuid,
                                      context.read<ShoppingTrip>().uuid);
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
