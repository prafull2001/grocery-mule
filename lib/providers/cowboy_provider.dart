// @dart=2.9

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference userCollection = FirebaseFirestore.instance.collection('updated_users_test');

class Cowboy with ChangeNotifier {
  String _uuid = '';
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  Map<String,String> _shoppingTrips = {};
  Map<String, String> _friends = <String, String>{}; // uuid to first name
  Map<String, String> _requests = <String, String>{}; // uuid to first_last

  // to call after user fields are updated
  fillUpdatedInfo(String firstName, String lastName, String email) {
    this._firstName = firstName;
    this._lastName = lastName;
    this._email = email;
    updateCowboyFirst();
    updateCowboyLast();
    updateCowboyEmail();
    notifyListeners();
  }
  updateCowboyFirst() {
    userCollection.doc(_uuid).update({'first_name': _firstName});
  }
  updateCowboyLast() {
    userCollection.doc(_uuid).update({'last_name': _lastName});
  }
  updateCowboyEmail() {
    userCollection.doc(_uuid).update({'email': _email});
  }
  // to initialize fields from StreamBuilder
  fillFields(String uuid, String firstName, String lastName, String email, Map<String, String> shoppingTrips, Map<String, String> friends, Map<String, String> requests) {
    this._uuid = uuid;
    this._firstName = firstName;
    this._lastName = lastName;
    this._email = email;
    this._shoppingTrips = shoppingTrips;
    this._friends = friends;
    this._requests = requests;
    // notifyListeners();
  }
  // to initialize account creation
  initializeCowboy(String uuid, String firstName, String lastName, String email) {
    this._uuid = uuid;
    this._firstName = firstName;
    this._lastName = lastName;
    this._email = email;
    intializeCowboyDB();
    //notifyListeners();
  }
  // initialize cowboy in database for first time
  intializeCowboyDB() {
    userCollection.doc(_uuid).set({
      'uuid': _uuid,
      'first_name': _firstName,
      'last_name': _lastName,
      'email': _email,
      'shopping_trips': _shoppingTrips,
      'friends': _friends,
      'requests': _requests,
    });
  }
  // only to instantiate during email search
  initializeCowboyFriend(String uuid, String firstName, String lastName, String email) {
    this._uuid = uuid;
    this._firstName = firstName;
    this._lastName = lastName;
    this._email = email;
    notifyListeners();
  }

  // getters since '_' identifier makes fields private
  String get uuid => _uuid;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  Map<String,String> get shoppingTrips => _shoppingTrips;
  Map<String, String> get friends => _friends;
  Map<String, String> get requests => _requests;

  // only called upon setup by system during trip creation or list share
  addTrip(String trip_uuid, String title,  DateTime date,String desc) {
    String entry = title+ "|~|" + date.toString() + "|~|" + desc.toString();
    _shoppingTrips[trip_uuid] = entry;
    updateCowboyTrips();
    notifyListeners();
  }
  // only called upon cleanup by system after venmos are sent out or if user gets booted
  removeTrip(String trip_uuid) {
    _shoppingTrips.remove(trip_uuid);
    updateCowboyTrips();
    notifyListeners();
  }
  updateCowboyTrips() {
    userCollection.doc(_uuid).update({'shopping_trips': _shoppingTrips});
    //delete trip from the shopping trip collection
  }

  updateTripForAll(String uuid, String entry, List<String> beneList){
    //for the host
    _shoppingTrips[uuid] = entry;
    updateCowboyTrips();
    beneList.forEach((bene) async {
      Map<String,String> shoppingTrips = await fetchBeneTrip( bene);
      shoppingTrips[uuid] = entry;
      print(entry);
      userCollection.doc(bene).update({'shopping_trips': shoppingTrips});
    });
  }

  Future<Map<String, String>> fetchBeneTrip(String bene) async {
    DocumentSnapshot beneShot = await userCollection.doc(bene).get();
    Map<String,String> shoppingTrips = {};
    if(!(beneShot['shopping_trips'] as Map<String, dynamic>).isEmpty) {
      (beneShot['shopping_trips'] as Map<String, dynamic>)
          .forEach((uid,entry) {
        String fields = entry.toString().trim();
        shoppingTrips[uid.trim()] = fields;
      });
    }
    return shoppingTrips;
  }
  Future<Map<String, String>> fetchFriendFriends(String friend_uuid) async {
    DocumentSnapshot friendShot = await userCollection.doc(friend_uuid).get();
    Map<String,String> amigos = {};
    if(!(friendShot['friends'] as Map<String, dynamic>).isEmpty) {
      (friendShot['friends'] as Map<String, dynamic>)
          .forEach((uid,entry) {
        String fields = entry.toString().trim();
        amigos[uid.trim()] = fields;
      });
    }
    return amigos;
  }
  clearData(){
    _shoppingTrips.clear();
     _friends.clear(); // uuid to first name
     _requests.clear();
  }
  // removes friend from requests, adds friend, notifies listeners, updates database
  addFriend(String friend_uuid, String friend_string) {
    _requests.remove(friend_uuid);
    _friends[friend_uuid] = friend_string;
    updateCowboyRequestsRemove(friend_uuid);
    addBothCowboyFriends(friend_uuid);
    notifyListeners();
  }
  addBothCowboyFriends(String friendUUID) {
    userCollection.doc(_uuid).update({'friends': _friends});
    userCollection.doc(friendUUID).update({'friends.${_uuid}': (_email+'|~|'+_firstName+' '+_lastName)});
  }

  removeFriendRequest(String friendUUID) {
    _requests.remove(friendUUID);
    updateCowboyRequestsRemove(friendUUID);
    notifyListeners();
  }
  // removes friend, notifies listeners, and updates database
  removeFriend(String friendUUID) {
    print('friends: $_friends');
    _friends.remove(friendUUID);
    print('friends again: $_friends');
    updateCowboyFriendsRemove(friendUUID);
    notifyListeners();
  }
  updateCowboyRequestsRemove(String friendUUID) {
    userCollection.doc(_uuid).update({'requests': _requests});
  }
  updateCowboyFriendsRemove(String friendUUID) async {
    userCollection.doc(_uuid).update({'friends': _friends});
    Map<String, String> amigos = {};
    amigos = await fetchFriendFriends(friendUUID);
    print('amigos: $amigos');
    amigos.remove(_uuid);
    print('amigos: $amigos');
    userCollection.doc(friendUUID).update({'friends': amigos});
  }

  addTripToBene(String bene_uuid, String trip_uuid, String title, DateTime date, String desc ){
    String entry = title+ "|~|" + date.toString() + "|~|" + desc;
    userCollection.doc(bene_uuid).update({'shopping_trips.${trip_uuid}': entry});
  }
  //change this to overwrite
  RemoveTripFromBene(String bene_uuid, String trip_uuid) async {
    Map<String,String> shoppingTrips = await fetchBeneTrip(bene_uuid);
    shoppingTrips.remove(trip_uuid);
    userCollection.doc(bene_uuid).update({'shopping_trips': shoppingTrips});
  }
  // adds friend request, notifies listeners, and updates database
  sendFriendRequest(String friendUUID) {
    // _requests.add(friendUUID);
    updateCowboyRequestsAdd(friendUUID);
    // notifyListeners();
  }
  updateCowboyRequestsAdd(String friendUUID) {
    userCollection.doc(friendUUID).update({'requests.${_uuid}': (_email+'|~|'+_firstName+' '+lastName)});
  }
}