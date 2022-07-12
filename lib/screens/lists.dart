import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_mule/constants.dart';
import 'package:grocery_mule/dev/collection_references.dart';
import 'package:grocery_mule/dev/migration.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:grocery_mule/providers/shopping_trip_provider.dart';
import 'package:grocery_mule/screens/createlist.dart';
import 'package:grocery_mule/screens/friend_screen.dart';
import 'package:grocery_mule/screens/user_info.dart';
import 'package:grocery_mule/screens/welcome_screen.dart';
import 'package:grocery_mule/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'editlist.dart';

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
          return Text('Howdy ${snapshot.data!['first_name']}!',
              style: TextStyle(fontSize: 25, color: Colors.black));
        });
  }
}

class ListsScreen extends StatefulWidget {
  final _auth = FirebaseAuth.instance;
  final User? curUser = FirebaseAuth.instance.currentUser;
  static String id = 'lists_screen';

  @override
  _ListsScreenState createState() => _ListsScreenState();
}

class ShoppingTripQuery extends StatefulWidget {
  final _auth = FirebaseAuth.instance;
  late String listUUID;

  ShoppingTripQuery(String listUUID, {required Key key}) : super(key: key) {
    this.listUUID = listUUID;
  }

  @override
  _ShoppingTripQueryState createState() => _ShoppingTripQueryState();
}

class _ShoppingTripQueryState extends State<ShoppingTripQuery> {
  late String listUUID;

  @override
  void initState() {
    listUUID = widget.listUUID;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StreamBuilder<DocumentSnapshot>(
        stream: tripCollection.doc(listUUID).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }
          if (snapshot.data!.data() != null) {
            String desc_short = snapshot.data!['description'];
            String title_short = snapshot.data!['title'];
            if (title_short.length > 30) {
              title_short = title_short.substring(0, 11) + "...";
            }
            if (desc_short.length > 50) {
              desc_short = desc_short.substring(0, 11) + "...";
            }

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 5.w),
              child: Card(
                elevation: 10,
                color: appColor,
                shadowColor: appOrange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                child: ListTile(
                  title: Container(
                    child: Text(
                      '${title_short}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  subtitle: Row(children: [
                    Text(
                      '${desc_short}\n\n'
                              '${(snapshot.data!['date'] as Timestamp).toDate().month}' +
                          '/' +
                          '${(snapshot.data!['date'] as Timestamp).toDate().day}' +
                          '/' +
                          '${(snapshot.data!['date'] as Timestamp).toDate().year}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                  ]),
                  onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditListScreen(listUUID)));
                  },
                  isThreeLine: true,
                ),
              ),
            );
          }
          return Container();
        });
  }
}

class _ListsScreenState extends State<ListsScreen> {
  final _auth = FirebaseAuth.instance;
  final User? curUser = FirebaseAuth.instance.currentUser;
  late Stream<DocumentSnapshot> personalTrip =
      userCollection.doc(curUser!.uid).snapshots();
  Future<void>? Cowsnapshot;
  List<String> dev = [
    "NYxh0dZXDya9VAdSYnOeWkY2wv83",
    "plXPxFNLEMbJclCzNsyJeE61RKT2",
    "nW7NnPdQGcXtj1775nrLdB1igjG2",
  ];
  @override
  void initState() {
    Cowsnapshot = _loadCurrentCowboy();
    super.initState();
  }

  Future<void> _loadCurrentCowboy() async {
    final DocumentSnapshot<Object?>? snapshot =
        await (_queryCowboy() as Future<DocumentSnapshot<Object?>?>);
    readInData(snapshot!);
    // final Stream<QuerySnapshot<Map<String, dynamic>>> tripstream = userCollection.doc(context.read<Cowboy>().uuid).collection('shopping_trips').snapshots();
  }

  void readInData(DocumentSnapshot snapshot) {
    List<String> shoppingTrips = [];

    List<String> friends = [];
    List<String> requests = [];
    // extrapolating data into provider
    if (!(snapshot['friends'] as List<dynamic>).isEmpty) {
      (snapshot['friends'] as List<dynamic>).forEach((dynamicKey) {
        friends.add(dynamicKey.toString());
      });
    }
    if (!(snapshot['requests'] as List<dynamic>).isEmpty) {
      (snapshot['requests'] as List<dynamic>).forEach((key) {
        requests.add(key.toString().trim());
      });
    }

    // reads and calls method
    context.read<Cowboy>().fillFields(
        snapshot['uuid'].toString(),
        snapshot['first_name'].toString(),
        snapshot['last_name'].toString(),
        snapshot['email'].toString(),
        shoppingTrips,
        friends,
        requests);
    //print(context.read<Cowboy>().shoppingTrips);
  }

  Future<DocumentSnapshot?> _queryCowboy() async {
    if (curUser != null) {
      DocumentSnapshot? tempShot;
      await userCollection.doc(curUser!.uid).get().then((docSnapshot) {
        tempShot = docSnapshot;

        //print('L TYPE: '+docSnapshot.data['']);
      });
      return tempShot;
    } else {
      return null;
    }
  }

  List<String> readInShoppingTripsData(QuerySnapshot tripshot) {
    List<String> shopping_trips = [];
    if (tripshot.docs == null || tripshot.docs.isEmpty) {
      return [];
    }
    tripshot.docs.forEach((element) {
      if (element.id != 'dummy') {
        shopping_trips.add(element.id.trim());
      }
    });
    context.read<Cowboy>().setTrips(shopping_trips);
    return shopping_trips;
  }

  @override
  Widget build(BuildContext context) {
    //print(context.watch<Cowboy>().shoppingTrips);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: UserName(curUser!.uid),
          backgroundColor: light_orange,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
          ),
          iconTheme: IconThemeData(
            color: darker_beige,
          ),
          elevation: 0,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: light_orange,
                ),
                child: Text(
                  'Menu Options',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              // Text(context.watch<Cowboy>().first_name),
              ListTile(
                title: const Text('Cowamigos'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, FriendScreen.id);
                },
              ),
              ListTile(
                title: const Text('Edit Profile'),
                onTap: () {
                  //Navigator.pop(context);
                  Navigator.pushNamed(context, UserInfoScreen.id);
                },
              ),
              ListTile(
                title: const Text('Report a 🐞'),
                onTap: () async {
                  Fluttertoast.showToast(
                      msg: 'Google Sign in required to upload bug report');
                  String paypalStr = "https://forms.gle/xHy3ixadwacFuFMi9";
                  Uri paypal_link = Uri.parse(paypalStr);
                  if (await canLaunchUrl(paypal_link)) {
                    launchUrl(paypal_link);
                  }
                },
              ),
              ListTile(
                title: const Text('Log Out'), //
                onTap: () async {
                  var currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    //clearUserField();
                    context.read<Cowboy>().clearData();
                    context.read<ShoppingTrip>().clearField();
                    await _auth.signOut();
                    print('User signed out');
                  }
                  //Navigator.pop(context);
                  Navigator.of(context).popUntil((route) {
                    return route.settings.name == WelcomeScreen.id;
                  });
                  Navigator.pushNamed(context, WelcomeScreen.id);
                },
              ),
              if (dev.contains(context.watch<Cowboy>().uuid))
                ListTile(
                  title: const Text('Dev only'),
                  onTap: () {
                    //Navigator.pop(context);
                    Navigator.pushNamed(context, Migration.id);
                  },
                ),
            ],
          ),
        ),
        body: StreamBuilder<QuerySnapshot<Object?>>(
            stream: userCollection
                .doc(curUser!.uid)
                .collection('shopping_trips')
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong StreamBuilder');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              return SafeArea(
                child: ListView.builder(
                  //scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, int index) {
                    return new ShoppingTripQuery(
                        snapshot.data!.docs.toList()[index].id,
                        key: Key(snapshot.data!.docs.toList()[index].id));
                  },
                ),
                // ),
              );
              ;
            }),
        floatingActionButton: Container(
          height: 80,
          width: 80,
          child: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateListScreen(true, "dummy")));
            },
          ),
        ),
      ),
    );
  }
}
