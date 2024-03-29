//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_mule/dev/collection_references.dart';

class Cowboy with ChangeNotifier {
  String _uuid = '';
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _paypal = '';
  List<String> _shoppingTrips = [];
  List<String> _friends = []; // uuid
  List<String> _requests = []; // uuid

  // to call after user fields are updated
  fillUpdatedInfo(
      String firstName, String lastName, String email, String paypal) {
    this._firstName = firstName;
    this._lastName = lastName;
    this._email = email;
    this._paypal = paypal;
    updateCowboyFirst();
    updateCowboyLast();
    updateCowboyEmail();
    setCowboyPaypal();
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

  setCowboyPaypal() {
    userCollection.doc(_uuid).update({'paypal': _paypal});
  }

  updateCowboyPaypal(String new_link) {
    this._paypal = new_link;
    setCowboyPaypal();
  }

  fillFriendFields(List<String> friends, List<String> requests) {
    this._friends = friends;
    this._requests = requests;
  }

  // to initialize fields from StreamBuilder
  fillFields(String uuid, String firstName, String lastName, String email,
      List<String> shoppingTrips, List<String> friends, List<String> requests) {
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
  initializeCowboy(
      String? uuid, String firstName, String lastName, String email) {
    this._uuid = uuid!;
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
      'friends': _friends,
      'requests': _requests,
      'paypal': _paypal,
      'tier': "standard",
      'total expenditure': 0
    });
    userCollection
        .doc(_uuid)
        .collection('shopping_trips')
        .doc('dummy')
        .set({'uuid': 'dummy'});
  }

  // only to instantiate during email search
  initializeCowboyFriend(
      String uuid, String firstName, String lastName, String email) {
    this._uuid = uuid;
    this._firstName = firstName;
    this._lastName = lastName;
    this._email = email;
    notifyListeners();
  }

  setTrips(List<String> requests) {
    _requests = requests;
    // vvvv might need to comment
    // notifyListeners();
  }

  // getters since '_' identifier makes fields private
  String get uuid => _uuid;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  String get paypal => _paypal;
  List<String> get shoppingTrips => _shoppingTrips;
  List<String> get friends => _friends;
  List<String> get requests => _requests;

  // only called upon setup by system during trip creation or list share
  addTrip(String user_uuid, String trip_uuid, DateTime date) async {
    await userCollection
        .doc(user_uuid)
        .collection('shopping_trips')
        .doc(trip_uuid)
        .set({'date': date});
    if (user_uuid == _uuid) {
      _shoppingTrips.add(trip_uuid);
      notifyListeners();
    }
  }

  updateTripDate(String trip_uid, DateTime newDate) {}

  // only called upon cleanup by system after venmos are sent out or if user gets booted
  removeTrip(String user_uuid, String trip_uuid) {
    userCollection
        .doc(user_uuid)
        .collection('shopping_trips')
        .doc(trip_uuid)
        .delete();
    if (user_uuid == _uuid) {
      _shoppingTrips.remove(trip_uuid);
      notifyListeners();
    }
  }

  Future<List<String>> fetchFriendFriends(String friend_uuid) async {
    DocumentSnapshot friendShot = await userCollection.doc(friend_uuid).get();
    List<String> amigos = [];
    if (!(friendShot['friends'] as List<dynamic>).isEmpty) {
      (friendShot['friends'] as List<dynamic>).forEach((uid) {
        String fields = uid.toString().trim();
        amigos.add(fields);
      });
    }
    return amigos;
  }

  clearData() {
    _shoppingTrips.clear();
    _friends.clear(); // uuid to first name
    _requests.clear();
  }

  // removes friend from requests, adds friend, notifies listeners, updates database
  addFriend(String friend_uuid) {
    _requests.remove(friend_uuid);
    _friends.add(friend_uuid);
    updateCowboyRequestsRemove(friend_uuid);
    addBothCowboyFriends(friend_uuid);
    notifyListeners();
  }

  addBothCowboyFriends(String friendUUID) {
    userCollection.doc(_uuid).update({'friends': _friends});
    userCollection.doc(friendUUID).update({
      'friends': FieldValue.arrayUnion([_uuid])
    });
  }

  removeFriendRequest(String friendUUID) {
    _requests.remove(friendUUID);
    updateCowboyRequestsRemove(friendUUID);
    notifyListeners();
  }

  // removes friend, notifies listeners, and updates database
  removeFriend(String friendUUID) {
    print('friends: $_friends');
    friends.removeWhere((element) => (element==friendUUID));
    //_friends.remove(friendUUID);
    print('friends again: $_friends');
    updateCowboyFriendsRemove(friendUUID);
    userCollection.doc(friendUUID).update({
      'friends': FieldValue.arrayRemove([_uuid])
    });
    notifyListeners();
  }

  removeAllFriends() async {
    DocumentSnapshot user_shot = await userCollection.doc(_uuid).get();
    if (user_shot!=null && user_shot['friends']!=null) {
      _friends = [];
      (user_shot['friends'] as List<dynamic>).forEach((element) {
        _friends.add(element.toString().trim());
      });
    }
    print('current friends: $_friends');
    _friends.forEach((friend_uuid) async {
      // print('removing friend with uuid: $friend_uuid');
      await updateCowboyFriendsRemove(friend_uuid);
      await userCollection.doc(friend_uuid).update({
        'friends': FieldValue.arrayRemove([_uuid])
      });
    });
    _friends.removeWhere((element) => (_friends.contains(element)));
  }

  updateCowboyRequestsRemove(String friendUUID) {
    userCollection.doc(_uuid).update({'requests': _requests});
  }

  updateCowboyFriendsRemove(String friendUUID) async {
    userCollection.doc(_uuid).update({'friends': _friends});
    List<String> amigos = [];
    amigos = await fetchFriendFriends(friendUUID);
    print('amigos: $amigos');
    amigos.remove(_uuid);
    print('amigos: $amigos');
    userCollection.doc(friendUUID).update({'friends': amigos});
  }

  // adds friend request, notifies listeners, and updates database
  sendFriendRequest(String friendUUID) {
    // _requests.add(friendUUID);
    updateCowboyRequestsAdd(friendUUID);
    // notifyListeners();
  }

  updateCowboyRequestsAdd(String friendUUID) {
    userCollection.doc(friendUUID).update({
      'requests': FieldValue.arrayUnion([_uuid])
    });
  }
}
