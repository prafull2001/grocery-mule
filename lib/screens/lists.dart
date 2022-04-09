import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_mule/components/rounded_ button.dart';
import 'package:grocery_mule/constants.dart';
import 'package:grocery_mule/screens/createlist.dart';
import 'package:grocery_mule/screens/friend_screen.dart';
import 'package:grocery_mule/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:grocery_mule/screens/user_info.dart';
import 'package:async/async.dart';
import 'package:provider/provider.dart';
import 'editlist.dart';
import 'dart:math';


class ListsScreen extends StatefulWidget {
  final _auth = FirebaseAuth.instance;
  final User curUser = FirebaseAuth.instance.currentUser;
  static String id = 'lists_screen';

  @override
  _ListsScreenState createState() => _ListsScreenState();
}


class _ListsScreenState extends State<ListsScreen> {

  final _auth = FirebaseAuth.instance;
  final User curUser = FirebaseAuth.instance.currentUser;
  CollectionReference userCollection = FirebaseFirestore.instance.collection('updated_users_test');
  Future<void> Cowsnapshot;

  @override
  void initState() {
    // TODO: implement initState
    Cowsnapshot = _loadCurrentCowboy();
    super.initState();
  }

  Future<void> _loadCurrentCowboy() async {
    final DocumentSnapshot snapshot = await _queryCowboy();
      if(snapshot != null) {
        List<String> shoppingTrips = <String>[];
        Map<String, String> friends = <String, String>{};
        List<String> requests = <String>[];
        // extrapolating data into provider
        if(!((snapshot.data() as Map<String, dynamic>)['shopping_trips'] as List<dynamic>).isEmpty) {
          ((snapshot.data() as Map<String, dynamic>)['shopping_trips'] as List<
              dynamic>).forEach((dynamicElement) {
            shoppingTrips.add(dynamicElement.toString());
          });
        }else{
          shoppingTrips.add('dummy');
        }
        if(!(snapshot['friends'] as Map<String, dynamic>).isEmpty) {
          (snapshot['friends'] as Map<String, dynamic>).forEach((dynamicKey,
              dynamicValue) {
            friends[dynamicKey.toString()] = dynamicValue.toString();
          });
        }
        if(!(snapshot['requests'] as List<dynamic>).isEmpty) {
          (snapshot['requests'] as List<dynamic>).forEach((dynamicElement) {
            requests.add(dynamicElement.toString());
          });
        }

          // reads and calls method
          context.read<Cowboy>().fillFields(snapshot['uuid'].toString(), snapshot['first_name'].toString(), snapshot['last_name'].toString(), snapshot['email'].toString(), shoppingTrips, friends, requests);
        print(context.read<Cowboy>().shoppingTrips);
      }
  }

  Future<DocumentSnapshot> _queryCowboy() async {
    if(curUser != null) {
      DocumentSnapshot tempShot;
      await userCollection.doc(curUser.uid).get().then((docSnapshot) {
        tempShot=docSnapshot;

         //print('L TYPE: '+docSnapshot.data['']);
      });

      return tempShot;
    } else {
      return null;
    }
  }



   final  Stream<QuerySnapshot<Map<String, dynamic>>> _list =  FirebaseFirestore.instance.collection('shopping_trips_test').snapshots();



  @override
  Widget build(BuildContext context) {
    print(context.watch<Cowboy>().shoppingTrips);
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Grocery Lists'),
            backgroundColor: const Color(0xFFbc5100),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: const Color(0xFFbc5100),
                  ),
                  child: Text(
                    'Menu Options',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20
                    ),
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
                  title: const Text('Log Out'),
                  onTap: () async {
                    var currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser != null) {
                      await _auth.signOut();
                      print('User signed out');
                    }
                    //Navigator.pop(context);
                    Navigator.of(context).popUntil((route){
                      return route.settings.name == WelcomeScreen.id;
                    });
                    Navigator.pushNamed(context, WelcomeScreen.id);
                  },
                ),
              ],
            ),
          ),

          body:

          FutureBuilder(
            future: Cowsnapshot,
            builder: (context, AsyncSnapshot<void> futSnap) {
              if (futSnap.hasError) {
                return Text('Something went wrong');
              }
              if (futSnap.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              return StreamBuilder <QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection(
                      'shopping_trips_test').where('uuid', whereIn: context
                      .watch<Cowboy>().shoppingTrips)
                      .orderBy('date',descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    return SafeArea(
                      child: Scrollbar(
                        isAlwaysShown: true,
                        child: GridView.builder(
                          padding: EdgeInsets.all(8),
                          itemCount: snapshot.data.docs.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 7),
                          itemBuilder: (context, int index) {
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFFf57f17),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFffab91),
                                    blurRadius: 3,
                                    offset: Offset(3, 6), // Shadow position
                                  ),
                                ],
                              ),


                              child: ListTile(
                                title: Text(
                                  '\n${snapshot.data.docs[index]['title']}\n'
                                      '${snapshot.data
                                      .docs[index]['description']}\n\n'
                                      '${(snapshot.data
                                      .docs[index]['date'] as Timestamp)
                                      .toDate()
                                      .month}' +
                                      '/' +
                                      '${(snapshot.data
                                          .docs[index]['date'] as Timestamp)
                                          .toDate()
                                          .day}' +
                                      '/' +
                                      '${(snapshot.data
                                          .docs[index]['date'] as Timestamp)
                                          .toDate()
                                          .year}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                                onTap: () async {
                                  String tripUUID = snapshot.data
                                      .docs[index]['uuid'];
                                  await Navigator.push(context,
                                      MaterialPageRoute(builder: (context) =>
                                          EditListScreen(tripUUID)));
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
              );
            },
          ),

          floatingActionButton: Container(
            height: 80,
            width: 80,
            child: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateListScreen(true))
                );

              },
            ),
          ),
        ),
    );
  }
}
