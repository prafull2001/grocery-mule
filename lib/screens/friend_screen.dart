import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:grocery_mule/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';


final CollectionReference userCollection = FirebaseFirestore.instance.collection('updated_users_test');

class FriendScreen extends StatefulWidget {
  static String id = 'friend_screen';

  @override
  _FriendScreenState createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> with SingleTickerProviderStateMixin {
  String searchQuery;
  int num_requests;
  Stream<QuerySnapshot> friendData;
  List<Cowboy> searchResults; // search results
  List<Cowboy> friendRequests; // friend requests
  Widget searchResultsWidget; // widget to display upon search
  Icon searchIcon; // changes between 'X' and search icon while searching
  var searchTextController = TextEditingController();
  @override
  void initState() {
    super.initState();
    num_requests = context.read<Cowboy>().requests.length;
    friendData = getFriendData();
    searchQuery = '';
    searchResults = <Cowboy>[];
    searchIcon = Icon(Icons.search);
    friendRequests = <Cowboy>[];
    _loadCurrentRequests();
  }
  void _loadCurrentRequests() {
    // TODO once code is being change to null safety, remove this line and return Future<Null> from _getRequestUsers()
    if(context.read<Cowboy>().requests.isEmpty) {
      return;
    }
    _getRequestUsers().then((QuerySnapshot snapshot) {
      if(snapshot != null) {
        snapshot.docs.forEach((QueryDocumentSnapshot qds) {
          Cowboy requestBoy = Cowboy();
          requestBoy.initializeCowboyFriend(qds['uuid'], qds['first_name'], qds['last_name'], qds['email']);
          setState(() {
            if(requestBoy != null) {
              friendRequests.add(requestBoy);
            }
          });
        });
      }
    });
  }
  Future<QuerySnapshot> _getRequestUsers() {
    if(context.read<Cowboy>().requests.isEmpty) {
      return null;
    }
    if(context.read<Cowboy>().requests.length > 10) {
      return userCollection.where('uuid', whereIn: context.read<Cowboy>().requests.sublist(1, 11)).get();
    } else {
      return userCollection.where('uuid', whereIn: context.read<Cowboy>().requests).get();
    }
  }
  Stream<QuerySnapshot> getFriendData() {
    List<String> friendUUIDs = context.read<Cowboy>().friends.keys.toList();
    if(friendUUIDs.length>10) {
      return userCollection.where('uuid', whereIn: friendUUIDs.sublist(1, 11)).snapshots();
    } else {
      return userCollection.where('uuid', whereIn: friendUUIDs).snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('cowamigos'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange.shade800,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: Container(
                    child: TextField(
                      controller: searchTextController,
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.left,
                      onChanged: (value) {
                        searchQuery = value;
                      },
                      decoration: kTextFieldDecoration.copyWith(
                        hintText: 'search by email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepOrangeAccent, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepOrangeAccent, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        ),
                        hintStyle: TextStyle(
                          fontSize: 20.0,
                          height: 0.85,
                        ),
                      ),
                    ),
                    height: 36.0,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    //print('check 1');
                    if(searchQuery.isNotEmpty) {
                      // print('check 2');
                      setState(() {
                        // requestsent = false;
                        if(searchIcon.icon == Icons.search) {
                          // actually search by setting searchResults
                          // print('check 3');
                          fillSearchResults();
                          // print('len results: '+searchResults.length.toString());
                          // searchResultsWidget = searchResultsList();
                          searchIcon = const Icon(Icons.cancel);
                        } else {
                          searchIcon = const Icon(Icons.search);
                          searchTextController.clear();
                          searchResults = <Cowboy>[];
                          searchResultsWidget = searchResultsList();
                        }
                      });
                    }
                  },
                  icon: searchIcon,
                  tooltip: 'search',
                ),
                Badge(
                  badgeContent: Text(friendRequests.length.toString()),
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.deepOrangeAccent),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Container(
                                width: double.maxFinite,
                                height: double.maxFinite,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 20.0,
                                      child: Text('Friend Requests'),
                                    ),
                                    ListView.separated(
                                      shrinkWrap: true,
                                        itemCount: friendRequests.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          return Container(
                                            padding: EdgeInsets.all(2.0),
                                            child: Row(
                                              children: [
                                                Text(
                                                    friendRequests[index].firstName+' '+friendRequests[index].firstName+'\n'+friendRequests[index].email,
                                                  style: TextStyle(fontSize: 10.0),
                                                ),
                                                TextButton(onPressed:(){}, child: Text('Accept Request')),
                                              ],
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, index) {
                                          return SizedBox(height: 2.0,);
                                        },
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                      );
                    },
                    child: Text('Requests'),
                  ),
                ),
              ], // end of row children
            ), // search bar and request button
            SizedBox(height: 12.0,),
            Row(
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Container(
                    constraints: BoxConstraints(
                      //maxHeight: 200,
                    ),
                    child: searchResultsWidget,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.0,),
            SizedBox(
              height: 36.0,
              child: Text('Friends', style: TextStyle(fontSize: 24.0),),
            ),
            Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: friendData,
                builder: (context, AsyncSnapshot<QuerySnapshot> listsnapshot) {
                  List<QueryDocumentSnapshot> snapshot_data = <QueryDocumentSnapshot>[];
                  if (listsnapshot.hasData) {
                    snapshot_data = listsnapshot.data.docs;
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(2.0),
                    // scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: snapshot_data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        padding: const EdgeInsets.all(7.0),
                        child: Row(
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(snapshot_data[index]['first_name']+' '+snapshot_data[index]['last_name']),
                                SizedBox(height: 1.0,),
                                Text(snapshot_data[index]['email']),
                              ],
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.shade400,
                          // border: Border.all(color: Colors.deepOrange),
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        ),
                      );
                    }, // itemBulider
                    separatorBuilder: (context, int index) {
                      return SizedBox(height: 5.0,);
                    },
                  );
                }
              ),
            ), // container for listview of friends list
          ],
        ),
      ),
    );
    throw UnimplementedError();
  }

  fillSearchResults() {
    _querySearchResults().then((QuerySnapshot snapshot) {
      if(snapshot == null) {
        print('snapshot was null in fillSearchResults');
        return;
      }
      Map<String, dynamic> result = <String, dynamic>{};
      result = snapshot.docs[0].data();
      Cowboy friendboy = Cowboy();
      friendboy.initializeCowboyFriend(result['uuid'].toString(), result['first_name'].toString(), result['last_name'].toString(), result['email'].toString());
      print('cowboy: '+friendboy.firstName);
      searchResults.add(friendboy);
      print('listboy length: '+searchResults.length.toString());
      setState(() {
        searchResultsWidget = searchResultsList();
      });
    });
  }
  Future<QuerySnapshot> _querySearchResults() async {
    // print('query: '+searchQuery);
    if(searchQuery != '') {
      Future<QuerySnapshot> tempShot = userCollection.where('email', isEqualTo: searchQuery).get();
      if(tempShot != null) {return tempShot;}
      return null;
    } else {
      return null;
    }
  }

  Widget searchResultsList() {
    if(searchResults != null) {
      if (searchResults.length == 0) {
        return SizedBox(height: 0.0,);
      }
      return ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: Row(
              children: [
                Column(
                  children: [
                    Text(searchResults[index].firstName+' '+searchResults[index].lastName),
                    SizedBox(height: 1.0,),
                    Text(searchResults[index].email),
                  ],
                ),
                Container(
                  child: TextButton(
                    child: Text('Add Friend'),
                    onPressed: () {
                      context.read<Cowboy>().sendFriendRequest(searchResults[index].uuid);
                    },
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(height: 5.0,);
        },
        itemCount: searchResults.length,
      );
    }
    return SizedBox(height: 0.0,);
  }
}