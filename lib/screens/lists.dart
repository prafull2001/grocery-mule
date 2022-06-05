import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_mule/constants.dart';
import 'package:grocery_mule/screens/createlist.dart';
import 'package:grocery_mule/screens/friend_screen.dart';
import 'package:grocery_mule/screens/welcome_screen.dart';
import 'package:grocery_mule/dev/migration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:grocery_mule/screens/user_info.dart';
import 'package:async/async.dart';
import 'package:provider/provider.dart';
import 'editlist.dart';
import 'dart:math';


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

  ShoppingTripQuery(String listUUID){
    this.listUUID = listUUID;
  }

  @override
  _ShoppingTripQueryState createState() => _ShoppingTripQueryState();
}

class _ShoppingTripQueryState extends State<ShoppingTripQuery>{
  final CollectionReference shoppingTripCollection = FirebaseFirestore.instance.collection('shopping_trips_02');
  late String listUUID;

  @override
  void initState(){
    listUUID = widget.listUUID;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StreamBuilder<DocumentSnapshot>(
        stream: shoppingTripCollection.doc(listUUID).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }
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
                '\n${snapshot.data!['title']}\n'
                    '${snapshot.data!['description']}\n\n'
                    '${(snapshot.data!['date'] as Timestamp)
                    .toDate()
                    .month}' +
                    '/' +
                    '${(snapshot.data!['date'] as Timestamp)
                        .toDate()
                        .day}' +
                    '/' +
                    '${(snapshot.data!['date'] as Timestamp)
                        .toDate()
                        .year}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
              onTap: () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (context) =>
                        EditListScreen(listUUID)));
              },
            ),
          );
        }
    );
  }

}
class _ListsScreenState extends State<ListsScreen> {

  final _auth = FirebaseAuth.instance;
  final User? curUser = FirebaseAuth.instance.currentUser;
  CollectionReference userCollection = FirebaseFirestore.instance.collection('users_02');
  CollectionReference tripCollection = FirebaseFirestore.instance.collection('shopping_trips_test');
  Future<void>? Cowsnapshot;
  List<String> dev = ["NYxh0dZXDya9VAdSYnOeWkY2wv83","yTWmoo2Qskf3wFcbxaJYUt9qrZM2","nW7NnPdQGcXtj1775nrLdB1igjG2"];
  @override
  void initState() {
    // TODO: implement initState
    Cowsnapshot = _loadCurrentCowboy();
    super.initState();
  }

  Future<void> _loadCurrentCowboy() async {
    final DocumentSnapshot<Object?>? snapshot = await (_queryCowboy() as Future<DocumentSnapshot<Object?>?>);
    readInData(snapshot!);
  }
  void readInData(DocumentSnapshot snapshot){
    List<String> shoppingTrips = [];

    List<String> friends = [];
    List<String> requests = [];
    // extrapolating data into provider
    if(!(snapshot['shopping_trips'] as List<dynamic>).isEmpty) {
      (snapshot['shopping_trips'] as List<dynamic>)
          .forEach((uid) {
            if(!shoppingTrips.contains(uid))
              shoppingTrips.add(uid.trim());
      });
    }
    if(!(snapshot['friends'] as List<dynamic>).isEmpty) {
      (snapshot['friends'] as List<dynamic>).forEach((dynamicKey) {
        friends.add(dynamicKey.toString());
      });
    }
    if(!(snapshot['requests'] as List<dynamic>).isEmpty) {
      (snapshot['requests'] as List<dynamic>).forEach((key) {
        requests.add(key.toString().trim());
      });
    }

    // reads and calls method
    context.read<Cowboy>().fillFields(snapshot['uuid'].toString(), snapshot['first_name'].toString(), snapshot['last_name'].toString(), snapshot['email'].toString(), shoppingTrips, friends, requests);
    //print(context.read<Cowboy>().shoppingTrips);

  }

  Future<DocumentSnapshot?> _queryCowboy() async {
    if(curUser != null) {
      DocumentSnapshot? tempShot;
      await userCollection.doc(curUser!.uid).get().then((docSnapshot) {
        tempShot=docSnapshot;

        //print('L TYPE: '+docSnapshot.data['']);
      });
      return tempShot;
    } else {
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    //print(context.watch<Cowboy>().shoppingTrips);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Howdy ${curUser!.displayName!.split(" ")[0]}!', style: TextStyle(fontSize: 24, color: Colors.black),),
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
                  color: dark_beige,
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
                    //clearUserField();
                    context.read<Cowboy>().clearData();
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
              if(dev.contains(context.watch<Cowboy>().uuid))
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
        body:

        StreamBuilder <DocumentSnapshot<Object?>>(
            stream: userCollection.doc(curUser!.uid).snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot<Object?>> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong StreamBuilder');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              readInData(snapshot.data!);

              return SafeArea(
                child: Scrollbar(
                  isAlwaysShown: true,
                  child: GridView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount:  context.watch<Cowboy>().shoppingTrips.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 7),
                    itemBuilder: (context, int index) {

                      return new ShoppingTripQuery(context.watch<Cowboy>().shoppingTrips[index]);//renderList(context.watch<Cowboy>().shoppingTrips[index]);
                    },
                  ),
                ),
              );
            }
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