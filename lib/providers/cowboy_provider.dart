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
  List<String> _requests = <String>[]; // uuid to first_last

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
  // to initialize fields after empty constructor has been called by provider init
  fillFields(String uuid, String firstName, String lastName, String email, Map<String,String> shoppingTrips, Map<String, String> friends, List<String> requests) {
    this._uuid = uuid;
    this._firstName = firstName;
    this._lastName = lastName;
    this._email = email;
    this._shoppingTrips = shoppingTrips;
    this._friends = friends;
    this._requests = requests;
    // updateCowboyAll();
    //notifyListeners();
  }
  // to initialize account creation
  initializeCowboy(String uuid, String firstName, String lastName, String email) {
    this._uuid = uuid;
    this._firstName = firstName;
    this._lastName = lastName;
    this._email = email;
    intializeCowboyDB();
    notifyListeners();
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
  List<String> get requests => _requests;

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

  clearData(){
    _shoppingTrips.clear();
     _friends.clear(); // uuid to first name
     _requests.clear();
  }
  // removes friend from requests, adds friend, notifies listeners, updates database
  addFriend(String friend_uuid, String friend_name) {
    _requests.remove(friend_uuid);
    _friends[friend_uuid] = friend_name;
    updateCowboyRequestsRemove(friend_uuid);
    addBothCowboyFriends(friend_uuid);
    notifyListeners();
  }
  addBothCowboyFriends(String friendUUID) {
    userCollection.doc(_uuid).update({'friends': _friends});
    userCollection.doc(friendUUID).update({'friends': FieldValue.arrayUnion([_uuid])});
  }
  // removes friend, notifies listeners, and updates database
  removeFriend(String friend_uuid) {
    _friends.remove(friend_uuid);
    updateCowboyFriendsRemove(friend_uuid);
    notifyListeners();
  }
  updateCowboyFriendsRemove(String friend_uuid) {
    userCollection.doc(_uuid).update({'friends': _friends});
    userCollection.doc(friend_uuid).update({'friends': FieldValue.arrayRemove([_uuid])});
  }

  // updates from database
  updateCowboyRequests(List<String> newRequests) {
    _requests = newRequests;
    notifyListeners();
  }

  addTripToBene(String bene_uuid, String trip_uuid, String title, DateTime date, String desc ){
    String entry = title+ "|~|" + date.toString() + "|~|" + desc;
    userCollection.doc(bene_uuid).update({'shopping_trips.${trip_uuid}': entry});
  }
  //change this to overwrite
  RemoveTripFromBene(String bene_uuid, String trip_uuid){
    userCollection.doc(bene_uuid).update({'shopping_trips': FieldValue.arrayRemove([trip_uuid])});
  }
  // adds friend request, notifies listeners, and updates database
  sendFriendRequest(String friendUUID) {
    // _requests.add(friendUUID);
    updateCowboyRequestsAdd(friendUUID);
    // notifyListeners();
  }
  // removes friend request, notifies listeners, and updates database
  removeFriendRequest(String friendUUID) {
    _requests.remove(friendUUID);
    updateCowboyRequestsRemove(friendUUID);
    notifyListeners();
  }
  updateCowboyRequestsAdd(String friendUUID) {
    userCollection.doc(friendUUID).update({'requests': FieldValue.arrayUnion([_uuid])});
  }
  updateCowboyRequestsRemove(String friendUUID) {
    print('requests remove db called with uuid: '+friendUUID);
    userCollection.doc(_uuid).update({'requests': FieldValue.arrayRemove([friendUUID])});
  }
}