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
  List<String> _shoppingTrips = <String>[];
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
  // to initialize fields after empty constructor has been called by provider init
  fillFields(String uuid, String firstName, String lastName, String email, List<String> shoppingTrips, Map<String, String> friends, List<String> requests) {
    this._uuid = uuid;
    this._firstName = firstName;
    this._lastName = lastName;
    this._email = email;
    this._shoppingTrips = shoppingTrips;
    this._friends = friends;
    this._requests = requests;
    // updateCowboyAll();
    notifyListeners();
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
  List<String> get shoppingTrips => _shoppingTrips;
  Map<String, String> get friends => _friends;
  List<String> get requests => _requests;

  // only called upon setup by system during trip creation or list share
  addTrip(String trip_uuid) {
    _shoppingTrips.add(trip_uuid);
    updateCowboyTrips();
    notifyListeners();
  }
  // only called upon cleanup by system after venmos are sent out or if user gets booted
  removeTrip(String trip_uuid) {
    _shoppingTrips.remove(trip_uuid);
    updateCowboyTrips();
    notifyListeners();
  }

  // removes friend from requests, adds friend, notifies listeners, updates database
  addFriend(String friend_uuid, String friend_name) {
    _requests.remove(friend_uuid);
    _friends[friend_uuid] = friend_name;
    updateCowboyRequestsRemove(friend_uuid);
    updateCowboyFriends();
    notifyListeners();
  }
  // updates friend, notifies listeners, and updates database
  updateFriend(String friend_uuid, String friend_name) {
    _friends[friend_uuid] = friend_name;
    updateCowboyFriends();
    notifyListeners();
  }
  // removes friend, notifies listeners, and updates database
  removeFriend(String friend_uuid) {
    _friends.remove(friend_uuid);
    updateCowboyFriends();
    notifyListeners();
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

  // initialize cowboy in database for first time
  intializeCowboyDB() {
    userCollection.doc(_uuid).set({
      'uuid': _uuid,
      'first_name': _firstName,
      'last_name': _lastName,
      'email': _email,
      'trips': _shoppingTrips,
      'friends': _friends,
      'requests': _requests,
    });
  }
  // UPDATE FUNCTIONS
  // only update one field each, straight to firestore, completes in background
  // TODO maybe need to add a check to call update() or set()
  updateCowboyFirst() {
    userCollection.doc(_uuid).update({'first_name': _firstName});
  }
  updateCowboyLast() {
    userCollection.doc(_uuid).update({'last_name': _lastName});
  }
  updateCowboyEmail() {
    userCollection.doc(_uuid).update({'email': _email});
  }
  updateCowboyTrips() {
    userCollection.doc(_uuid).update({'shopping_trips': _shoppingTrips});
    //delete trip from the shopping trip collection
  }
  updateCowboyFriends() {
    userCollection.doc(_uuid).update({'friends': _friends});
  }
  updateCowboyRequestsAdd(String friendUUID) {
    userCollection.doc(friendUUID).update({'requests': FieldValue.arrayUnion([_uuid])});
  }
  updateCowboyRequestsRemove(String friendUUID) {
    userCollection.doc(friendUUID).update({'requests': FieldValue.arrayRemove([_uuid])});
  }

}