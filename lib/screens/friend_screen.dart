import 'package:flutter/services.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:grocery_mule/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

final CollectionReference userCollection = FirebaseFirestore.instance.collection('updated_users_test');


class FriendScreen extends StatefulWidget {
  static String id = 'friend_screen';

  @override
  _FriendScreenState createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> with SingleTickerProviderStateMixin {
  String? searchQuery;
  int? num_requests;
  List<Cowboy>? searchResults; // search results
  Widget? searchResultsWidget; // widget to display upon search
  late Icon searchIcon; // changes between 'X' and search icon while searching
  var searchTextController = TextEditingController();
  @override
  void initState() {
    super.initState();
    num_requests = context.read<Cowboy>().requests.length;
    searchQuery = '';
    searchResults = <Cowboy>[];
    searchIcon = Icon(Icons.search);
  }

  loadCowboyProvider(DocumentSnapshot? snapshot) {
    if(snapshot==null) {
      print('snapshot null');
      return;
    }
    if(snapshot.data() == null) {
      print('snapshot data null');
      return;
    }
    if(snapshot.get('uuid') != null) {
      if(snapshot.get('uuid') != context.read<Cowboy>().uuid) {
        print('snapshot uuid does not match cowboy uuid');
        return;
      }
    } else {
      print('snapshot uuid null');
      return;
    }

    // error checking should be done, update coming fields as if they are 100% correct
    Map<String, String> trips = {};
    Map<String, String> friends = <String, String>{};
    Map<String, String> requests = <String, String>{};
    if(!(snapshot['shopping_trips'] as Map<String, dynamic>).isEmpty) {
      (snapshot['shopping_trips'] as Map<String, dynamic>).forEach((uid,entry) {
        String fields = entry.toString().trim();
        trips[uid.trim()] = fields;
      });
    }
    if(!(snapshot['friends'] as Map<String, dynamic>).isEmpty) {
      (snapshot['friends'] as Map<String, dynamic>).forEach((dynamicKey,
          dynamicValue) {
        friends[dynamicKey.toString()] = dynamicValue.toString();
      });
    }
    if(!(snapshot['requests'] as Map<String, dynamic>).isEmpty) {
      (snapshot['requests'] as Map<String, dynamic>).forEach((key, value) {
        requests[key.trim()] = value.toString().trim();
      });
    }

    context.read<Cowboy>().fillFields(snapshot.get('uuid'), snapshot.get('first_name'), snapshot.get('last_name'), snapshot.get('email'), trips, friends, requests);
  }
  Stream<DocumentSnapshot> _getCowboy() {
    return userCollection.doc(context.read<Cowboy>().uuid).snapshots();
  }

  List<List<String>> _loadDisplayNames() {
    List<String> uuids = context.read<Cowboy>().requests.keys.toList();
    List<String> pairs = context.read<Cowboy>().requests.values.toList();
    List<List<String>> dispnames = [];
    for(int i=0; i < pairs.length; i++) {
      List<String> split = pairs[i].split('|~|');
      if(split.length<2) continue;
      // extra step to ensure that split gets truncated to 2 spaces and put in reverse order
      dispnames.add([uuids[i], split[1], split[0]]);
    }
    return dispnames;
  }

  List<List<String>> _loadFriendNames() {
    List<String> uuids = context.read<Cowboy>().friends.keys.toList();
    List<String> pairs = context.read<Cowboy>().friends.values.toList();
    List<List<String>> dispnames = [];
    for(int i=0; i < pairs.length; i++) {
      List<String> split = pairs[i].split('|~|');
      if(split.length<2) continue;
      // extra step to ensure that split gets truncated to 2 spaces and put in reverse order
      dispnames.add([uuids[i], split[1], split[0]]);
    }
    return dispnames;
  }

  String lengthify(String str) {
    if(str.isEmpty) return '';
    if(str.length > 29) str = str.substring(0, 26) + '...';
    return str;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          //statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.red,
        ),
        iconTheme: IconThemeData(
          color: darker_beige,
        ),
        title: Text(
          'cowamigos',
          style: TextStyle(
            color: darker_beige,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
                          borderSide: BorderSide(color: dark_beige, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: darker_beige, width: 2.0),
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
                    if(searchQuery!.isNotEmpty) {
                      setState(() {
                        // requestsent = false;
                        if(searchIcon.icon == Icons.search) {
                          // actually search by setting searchResults
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
                StreamBuilder<DocumentSnapshot>(
                  stream: _getCowboy(),
                  builder: (context, snapshot) {
                    loadCowboyProvider(snapshot.data);
                    List<List<String>> displaynames = _loadDisplayNames();
                    return Badge(
                      // TODO add live update on number // old VVVVVV
                      badgeContent: Text(context.watch<Cowboy>().requests.length.toString()), // context.watch<Cowboy>().requests.length.toString()
                      child: TextButton(
                        child: Icon(Icons.notifications),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(orange),
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Container(
                                    width: double.maxFinite,
                                    height: 60.0+(context.watch<Cowboy>().requests.length*50.0),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 25.0,
                                          child: Text(
                                            'Friend Requests',
                                            style: TextStyle(fontSize: 20.0),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        ListView.separated(
                                            shrinkWrap: true,
                                            itemCount: context.watch<Cowboy>().requests.length,
                                            controller: ScrollController(),
                                            itemBuilder: (BuildContext context, int index) {
                                              return Container(
                                                padding: EdgeInsets.all(2.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      lengthify(displaynames[index][1])+'\n'+lengthify(displaynames[index][2]),
                                                      //lengthify(friendRequests[index].firstName+' '+friendRequests[index].lastName)+'\n'+lengthify(friendRequests[index].email),
                                                      //        8       16      24   29 // trim characters 27, 28, 29 to be '...'
                                                      //lengthify('asdfjkl;asdfjkl;asdfjkl;asdfj')+'\n'+lengthify('asdfjkl;asdfjkl;asdfjkl;asdfjkl;'),
                                                      style: TextStyle(fontSize: 15.0),
                                                    ),
                                                    Spacer(),
                                                    SizedBox(
                                                      // ACCEPT
                                                      width: 35.0,
                                                      child: TextButton(
                                                        onPressed: () {
                                                          context.read<Cowboy>().addFriend(displaynames[index][0], displaynames[index][2]+'|~|'+displaynames[index][1]);
                                                          Navigator.pop(context);
                                                        },
                                                        style: ButtonStyle(
                                                          backgroundColor: MaterialStateProperty.all<Color>(orange),
                                                          foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                                        ),
                                                        child: Icon(
                                                          Icons.done,
                                                          size: 18.0,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      // REJECT
                                                      width: 35.0,
                                                      child: TextButton(
                                                        onPressed: () {
                                                          context.read<Cowboy>().removeFriendRequest(displaynames[index][0]);
                                                          Navigator.pop(context);
                                                        },
                                                        style: ButtonStyle(
                                                          backgroundColor: MaterialStateProperty.all<Color>(red),
                                                          foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                                        ),
                                                        child: Icon(
                                                          Icons.close,
                                                          size: 18.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            separatorBuilder: (context, index) {
                                              return SizedBox(height: 2.0,);
                                            },
                                        ),
                                      ],
                                    ),
                                    // decoration: BoxDecoration(
                                    //   color: dark_beige,
                                    //   border: Border.all(
                                    //     color: darker_beige,
                                    //     width: 5.0,
                                    //   ),
                                    //   borderRadius: BorderRadius.circular(10),
                                    // ),
                                  ),
                                );
                              }
                          );
                        }, // onPressed
                      ),
                    );
                  },
                ),
                /*Badge(
                  badgeContent: Text(context.watch<Cowboy>().requests.length.toString()),
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(orange),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Container(
                                width: double.maxFinite,
                                height: 60.0+(context.watch<Cowboy>().requests.length*50.0),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 25.0,
                                      child: Text(
                                        'Friend Requests',
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    StreamBuilder<QuerySnapshot>(
                                      stream: _getRequestUsers(),
                                      builder: (context, snapshot) {
                                        List<QueryDocumentSnapshot> snapdata = <QueryDocumentSnapshot>[];
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return Text("Loading");
                                        }
                                        if (snapshot.hasData) {
                                          snapdata = snapshot.data.docs;
                                          print('len len: ${snapdata.length}');
                                        }
                                        return ListView.separated(
                                          shrinkWrap: true,
                                            itemCount: snapdata.length,
                                            controller: ScrollController(),
                                            itemBuilder: (BuildContext context, int index) {
                                              return Container(
                                                padding: EdgeInsets.all(2.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      lengthify(snapdata[index]['first_name']+snapdata[index]['last_name'])+'\n'+lengthify(snapdata[index]['email']),
                                                      //lengthify(friendRequests[index].firstName+' '+friendRequests[index].lastName)+'\n'+lengthify(friendRequests[index].email),
                                                      //        8       16      24   29 // trim characters 27, 28, 29 to be '...'
                                                      //lengthify('asdfjkl;asdfjkl;asdfjkl;asdfj')+'\n'+lengthify('asdfjkl;asdfjkl;asdfjkl;asdfjkl;'),
                                                      style: TextStyle(fontSize: 15.0),
                                                    ),
                                                    Spacer(),
                                                    SizedBox(
                                                      // ACCEPT
                                                      width: 35.0,
                                                      child: TextButton(
                                                        onPressed: () {
                                                          context.read<Cowboy>().addFriend(snapdata[index]['uuid'], snapdata[index]['first_name']);
                                                          Navigator.pop(context);
                                                        },
                                                        style: ButtonStyle(
                                                          backgroundColor: MaterialStateProperty.all<Color>(orange),
                                                          foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                                        ),
                                                        child: Icon(
                                                          Icons.done,
                                                          size: 18.0,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      // REJECT
                                                      width: 35.0,
                                                      child: TextButton(
                                                        onPressed: () {
                                                          context.read<Cowboy>().removeFriendRequest(snapdata[index]['uuid']);
                                                          Navigator.pop(context);
                                                        },
                                                        style: ButtonStyle(
                                                          backgroundColor: MaterialStateProperty.all<Color>(red),
                                                          foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                                        ),
                                                        child: Icon(
                                                          Icons.close,
                                                          size: 18.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            separatorBuilder: (context, index) {
                                              return SizedBox(height: 2.0,);
                                            },
                                        );
                                      }
                                    )
                                  ],
                                ),
                                // decoration: BoxDecoration(
                                //   color: dark_beige,
                                //   border: Border.all(
                                //     color: darker_beige,
                                //     width: 5.0,
                                //   ),
                                //   borderRadius: BorderRadius.circular(10),
                                // ),
                              ),
                              backgroundColor: dark_beige,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(
                                  width: 5.0,
                                  color: darker_beige,
                                ),
                              ),
                            );
                          }
                      );
                    },
                    child: Icon(Icons.notifications),
                  ),
                ), */
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
            if(context.watch<Cowboy>().friends.values.length != 0)...[SizedBox(
              height: 36.0,
              child: Text('Friends', style: TextStyle(fontSize: 24.0),),
            )],
            Container(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _getCowboy(),
                builder: (context, snapshot) {
                  loadCowboyProvider(snapshot.data);
                  List<List<String>> displaynames = [[]];
                  displaynames = _loadFriendNames();
                  return ListView.separated(
                    padding: const EdgeInsets.all(2.0),
                    // scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: context.read<Cowboy>().friends.length,
                    controller: ScrollController(),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          const xButton = Icon(Icons.done, size: 46);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(7.0),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.account_circle_outlined,
                                size: 46,
                                // color: orange,
                              ),
                              SizedBox(width: 10,),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displaynames[index][1],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 1.0,),
                                  Text(displaynames[index][2]),
                                ],
                              ),
                              Spacer(),
                              IconButton(
                                icon: new Icon(
                                  Icons.close,
                                  size:36,
                                ),
                                onPressed: () {
                                  showDialog(context: context, builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: dark_beige,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        side: BorderSide(
                                          width: 5.0,
                                          color: darker_beige,
                                        ),
                                      ),
                                      content: Container(
                                        width: 100,
                                        height: 40,
                                        child: Row(
                                          children: [
                                            Text(
                                              'Adios Amigo?',
                                              style: TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                            Spacer(),
                                            SizedBox(
                                              width: 35,
                                              child: TextButton(
                                                child: Icon(
                                                  Icons.done,
                                                  size: 24,
                                                ),
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all<Color>(orange),
                                                  foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                                ),
                                                onPressed: () {
                                                  context.read<Cowboy>().removeFriend(displaynames[index][0]);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              width: 35,
                                              child: TextButton(
                                                child: Icon(
                                                  Icons.close,
                                                  size: 24,
                                                ),
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all<Color>(red),
                                                  foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                                ),
                                                onPressed: () {
                                                  //print('nefarious holaing amigo deeds'); AKA jack shit
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                                },
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                            color: dark_beige,
                            // border: Border.all(color: Colors.deepOrange),
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
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
    _querySearchResults().then((QuerySnapshot? snapshot) {
      if(snapshot == null) {
        print('snapshot was null in fillSearchResults');
        return;
      }
      Map<String, dynamic> result = <String, dynamic>{};
      result = snapshot.docs[0].data() as Map<String, dynamic>;
      Cowboy friendboy = Cowboy();
      friendboy.initializeCowboyFriend(result['uuid'].toString(), result['first_name'].toString(), result['last_name'].toString(), result['email'].toString());
      print('cowboy: '+friendboy.firstName);
      searchResults!.add(friendboy);
      print('listboy length: '+searchResults!.length.toString());
      setState(() {
        searchResultsWidget = searchResultsList();
      });
    });
  }
  Future<QuerySnapshot?> _querySearchResults() async {
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
      if (searchResults!.length == 0) {
        return SizedBox(height: 0.0,);
      }
      return ListView.separated(
        shrinkWrap: true,
        itemCount: searchResults!.length,
        controller: ScrollController(),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: EdgeInsets.all(2.0),
            child: Row(
              children: [
                Icon(Icons.account_box_outlined, size: 45.0,),
                SizedBox(width: 10.0,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(searchResults![index].firstName+' '+searchResults![index].lastName, style: TextStyle(fontSize: 20),),
                    SizedBox(height: 1.0,),
                    Text(searchResults![index].email),
                  ],
                ),
                Spacer(),
                Container(
                  child: TextButton(
                    child: Icon(Icons.add, size: 35.0, color: Colors.black,),
                    onPressed: () {
                      // TODO give some sort of message that request has been sent
                      context.read<Cowboy>().sendFriendRequest(searchResults![index].uuid);
                      setState(() {
                        searchTextController.clear();
                        searchResults = <Cowboy>[];
                        searchResultsWidget = searchResultsList();
                      });
                    },
                  ),
                ),
                //SizedBox(width: 40,),
              ],
            ),
            decoration: BoxDecoration(
              color: dark_beige,
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(height: 5.0,);
        },
      );
    }
    return SizedBox(height: 0.0,);
  }
}