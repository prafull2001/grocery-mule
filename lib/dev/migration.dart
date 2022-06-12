/*
This class is used for dev purpose only. This class serves as a migration to move documents from collection to another
It's purpose is that when the data organization is changed for a collection, like when a extra field needs to be added, so all current
documents in such collection needs to be modified, dev can simply modify the changes needed here, and invoke the program on the
simulator in menu options (only dev can see this tab in the menu)
This migration tool assumes that the destination collection exists, and the document id is the same from source and destination
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

import '../components/rounded_ button.dart';

class Migration extends StatefulWidget {
  final _auth = FirebaseAuth.instance;
  //final User? curUser = FirebaseAuth.instance.currentUser;
  static String id = 'migration';

  @override
  _MigrationState createState() => _MigrationState();
}


class Cow_user{
   String email;
   String firstName;
   String lastName;
  //Map<String,String> prevFriends = {};
  List<String> friends;
  //Map<String,String> prevRequestss = {};
  List<String> requests ;
  //Map<String,String> prevtrips = {};
  List<String> trips;
  String user_uuid;
  Cow_user(this.email, this.firstName, this.lastName, this.friends, this.requests, this.trips, this.user_uuid);
}

class _MigrationState extends State<Migration> {
  FirebaseAuth auth = FirebaseAuth.instance;
  //change your source & destination here
  //CollectionReference userSource = FirebaseFirestore.instance.collection('updated_users_test');
  CollectionReference tripSource = FirebaseFirestore.instance.collection('shopping_trips_test');
  //CollectionReference userdest = FirebaseFirestore.instance.collection('users_02');
  CollectionReference tripdest = FirebaseFirestore.instance.collection('shopping_trip_02');

  //modify the variables here, ok I get it is not the best way to do it, but I can't be arsed
  late String email;
  late String firstName;
  late String lastName;

  //Map<String,String> prevFriends = {};
  List<String> friends = [];
  //Map<String,String> prevRequestss = {};
  List<String> requests = [];
  //Map<String,String> prevtrips = {};
  List<String> trips = [];
  late String user_uuid;

  //no change needed, maybe the source variable
  Future<void> workFlow() async {
      //first fetch all the documents in one go from source
    QuerySnapshot collectionSource = await tripSource.get();
    collectionSource.docs.forEach((document) async {
      user_uuid = document['uuid'];
      //only migrate the document if the
      if(!(await isDocExist(user_uuid))) {
        insertData(document);
        print(user_uuid);
        insertDocToDest();
        cleanFields();
      }
    });
    //then iterate through each document in the collection, and filter through the data
  }

  //This method checks if the source document already exists in the dest colleciton
  //no change needed
  Future<bool> isDocExist(String uuid) async {
    DocumentSnapshot testDoc = await tripdest.doc(uuid).get();
    if(testDoc.exists)
      return true;
    return false;
  }
  //read fields from source documents into fields
  //you will have to arrange how the fields map the variable
  void insertData(DocumentSnapshot curDoc){
    user_uuid = curDoc['uuid'];
    email = curDoc['email'];
    firstName = curDoc['first_name'];
    lastName = curDoc['last_name'];
    //loop over friends
    (curDoc['friends'] as Map<String,dynamic>).forEach((uid,name) {
      friends.add(uid);
    });
    (curDoc['requests'] as Map<String,dynamic>).forEach((uid,name) {
      requests.add(uid);
    });
    (curDoc['shopping_trips'] as Map<String,dynamic>).forEach((uid,name) {
      trips.add(uid);
    });
    print(email + " " + firstName + " " + lastName);
  }

  //create a new document in the dest collection
  //you will have to modify how the data is arranged here
  Future<void> insertDocToDest() async {
    await tripdest.doc(user_uuid).set({
      'uuid': user_uuid,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'shopping_trips': trips,
      'friends': friends,
      'requests': requests,
    });
  }

  //clean your variables here after each doc
  void cleanFields(){
    friends.clear();
    requests.clear();
    trips.clear();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: RoundedButton(
        color: Colors.amber,
        onPressed:  () async {
          workFlow();
        },
        title: 'migration',
      ),
    );
  }


}