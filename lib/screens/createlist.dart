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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:grocery_mule/dev/collection_references.dart';

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
                  primary:  Colors.amber,
                  onPrimary: Colors.white,
                  onSurface: Colors.black
              )
          ),
          child: child!,
        )
    );
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
          Text('$date'
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
              color: orange,
            ),
            onPressed: () => _selectDate(context, DateTime.now()),
          ),
        ],
      );
    }
    return FutureBuilder<DocumentSnapshot>(
      future: tripCollection.doc(tripid).get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

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
            Text('$tdate'
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
                color: orange,
              ),
              onPressed: () => _selectDate(context, context.read<ShoppingTrip>().date),
            ),
          ],
        );
      }
    );
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
        context
            .read<Cowboy>()
            .addTripToBene(friend, context.read<ShoppingTrip>().uuid);
        //addTripToBene(String bene_uuid, String trip_uuid)
      }
      //context.read<ShoppingTrip>().addBeneficiary(hostUUID);

      context.read<Cowboy>().addTrip(
            context.read<ShoppingTrip>().uuid,
          );
    } else {
      print(context.read<ShoppingTrip>().beneficiaries);
      print("starting to edit list");
      List<String> removeList = [];
      print(friend_bene);
      context.read<ShoppingTrip>().beneficiaries.forEach((old_bene) {
        if(!friend_bene.contains(old_bene) && old_bene != context.read<Cowboy>().uuid) {
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
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.data!.exists) {
                _loadCurrentTrip(snapshot.data!);
              }
              print(localTime);
              return Padding(
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
                                onChanged: (value) {
                                  context
                                      .read<ShoppingTrip>()
                                      .editTripTitle(value);
                                }),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 10.0,
                    ),

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
                        SizedBox(
                          width: 10.0,
                        ),
                        DatePicker(newList, trip_uuid),
                        // Text('${context.read<ShoppingTrip>().date}'
                        //       .split(' ')[0]
                        //       .replaceAll('-', '/'),
                        //   style: TextStyle(
                        //     fontSize: 20,
                        //     fontWeight: FontWeight.w400,
                        //   ),
                        // ),
                        // //SizedBox(width: 5.0,),
                        // IconButton(
                        //   icon: Icon(
                        //     Icons.calendar_today,
                        //     color: orange,
                        //   ),
                        //   onPressed: () => _selectDate(context),
                        // ),
                      ],
                    ),

                    SizedBox(
                      height: 10.0,
                    ),

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
                                onChanged: (value) {
                                  context
                                      .read<ShoppingTrip>()
                                      .editTripDescription(value);
                                }),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 10.0,
                    ),

                    // selected friends
                    Container(
                      child: StreamBuilder<QuerySnapshot>(
                          stream: userCollection
                              // .where('uuid',
                              //     whereIn:
                              //         context.read<Cowboy>().friends.isEmpty
                              //             ? ['']
                              //             : context.read<Cowboy>().friends)
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text('Something went wrong StreamBuilder');
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            List<MultiSelectItem<String>> friends = [];
                            //print("first friend: ${snapshot.data!.docs[1].get('uuid')}");

                            snapshot.data!.docs.forEach((document) {
                              if (context
                                  .read<Cowboy>()
                                  .friends
                                  .contains(document['uuid'])) {
                                friends.add(MultiSelectItem<String>(
                                    document['uuid'],
                                    document['first_name']));
                              }
                            });
                            return MultiSelectDialogField(
                              searchable: true,
                              items: friends,
                              initialValue:
                                  context.read<ShoppingTrip>().beneficiaries,
                              title: Text('Friends'),
                              selectedColor: dark_beige,
                              decoration: BoxDecoration(
                                color: dark_beige.withOpacity(0.25),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40)),
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
                                //print(results.toList());
                                /*
                                results.forEach((friend) {
                                  if (!friend_bene.contains(friend.toString()))
                                    friend_bene.add(friend.toString());
                                });

                                 */
                                friend_bene = results.map((e) => e.toString()).toList();
                                print(context.read<ShoppingTrip>().beneficiaries);
                              },
                            );
                          }),
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
                            child: (newList)
                                ? Text(
                                    'Create List',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  )
                                : Text(
                                    'Save Changes',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(orange),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0)),
                              ),
                            ),
                            onPressed: () async {
                              if (context.read<ShoppingTrip>().title != '') {
                                print("editing list");
                                await updateGridView(newList);
                                //setState(() {});
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
                                            // Navigator.pop(context);
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
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(red),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0)),
                              ),
                            ),
                            onPressed: () async {
                              await check_delete(context);
                              if (delete_list) {
                                if (!newList) {
                                  print('delete');
                                  context.read<ShoppingTrip>().removeStaleTripUUIDS();
                                  context.read<ShoppingTrip>().deleteTripDB();
                                  context.read<Cowboy>().removeTrip(
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
            })
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
                child: const Text("DELETE")),
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
