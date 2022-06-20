import 'package:flutter/services.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:grocery_mule/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:grocery_mule/dev/collection_references.dart';


class cowamigo extends StatefulWidget {
  String id = 'inidividual_friend';
  late String uuid;

  cowamigo(String uuid) {
    this.uuid = uuid;
  }

  @override
  _CowamigoState createState() => _CowamigoState();
}

class _CowamigoState extends State<cowamigo> with SingleTickerProviderStateMixin {
  late String uuid;
  String name = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    this.uuid = widget.uuid;
  }

  String lengthify(String str) {
    if(str.isEmpty) return '';
    if(str.length > 29) str = str.substring(0, 26) + '...';
    return str;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<DocumentSnapshot>(
        stream: userCollection.doc(uuid).snapshots(),
        builder: (context, snapshot) {
          Map<String, dynamic> result = snapshot.data?.data() as Map<String, dynamic>;
          if (result!=null && snapshot.data!=null) {
            name = result['first_name'].toString() + ' ' + result['last_name'].toString();
            email = result['email'].toString();
          }

          return Container(
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
                      name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 1.0,),
                    Text(email),
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
                                    context.read<Cowboy>().removeFriend(uuid);
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
          );
        },
      ),
    );
  }
}

class QueryAmigo extends StatefulWidget {
  String id = 'search_results';
  late String query;

  QueryAmigo(String query) {
    this.query = query;
    print('query check 1: '+this.query);
  }

  @override
  _QueryAmigoState createState() => _QueryAmigoState(this.query);
}

class _QueryAmigoState extends State<QueryAmigo> with SingleTickerProviderStateMixin {
  late String query;
  String uuid = '';
  String name = '';
  String email = '';
  Icon accountIcon = Icon(Icons.account_circle_outlined);

  @override
  void initState() {
    super.initState();
    this.query = widget.query;
    print('query check 2.5: '+this.query);
  }

  _QueryAmigoState(String query) {
    this.query = query;
    print('query check 2: '+this.query);
  }

  @override
  Widget build(BuildContext context) {
    this.query = widget.query;
    if (query=='') {
      // empty container if query is empty
      return Container();
    }
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: userCollection.where('email', isEqualTo: query).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('something went wrong !!');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          List<QueryDocumentSnapshot> result = snapshot.data?.docs as List<QueryDocumentSnapshot>;
          uuid = result[0]['uuid'].toString();
          name = result[0]['first_name'].toString() + ' ' + result[0]['last_name'].toString();
          email = result[0]['email'].toString();
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
                    Text(name, style: TextStyle(fontSize: 20),),
                    SizedBox(height: 1.0,),
                    Text(email),
                  ],
                ),
                Spacer(),
                Container(
                  child: TextButton(
                    child: Icon(Icons.add, size: 35.0, color: Colors.black,),
                    onPressed: () {
                      // TODO give some sort of message that request has been sent
                      context.read<Cowboy>().sendFriendRequest(uuid);
                      setState(() {
                        query = '';
                        // searchTextController.clear();
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
      ),
    );
    throw UnimplementedError();
  }
}

class RequestAmigo extends StatefulWidget {
  String id = 'request_cowboy';
  late String uuid;

  @override
  _RequestAmigoState createState() => _RequestAmigoState();

  RequestAmigo(String uuid) {
    this.uuid = uuid;
  }
}

class _RequestAmigoState extends State<RequestAmigo> with SingleTickerProviderStateMixin {
  String uuid = '';
  String name = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    this.uuid = widget.uuid;
  }

  String lengthify(String str) {
    if(str.isEmpty) return '';
    if(str.length > 29) str = str.substring(0, 26) + '...';
    return str;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<DocumentSnapshot>(
        stream: userCollection.doc(uuid).snapshots(),
        builder: (context, snapshot) {
          Map<String, dynamic> result = snapshot.data?.data() as Map<String, dynamic>;
          name = result['first_name'].toString() + ' ' + result['last_name'].toString();
          email = result['email'].toString();
          return Container(
            padding: EdgeInsets.all(2.0),
            child: Row(
              children: [
                Text(
                  lengthify(name),
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
                      context.read<Cowboy>().addFriend(uuid);
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
                      context.read<Cowboy>().removeFriendRequest(uuid);
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
      ),
    );
  }
}

class FriendScreen extends StatefulWidget {
  static String id = 'friend_screen';

  @override
  _FriendScreenState createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> with SingleTickerProviderStateMixin {
  late String searchQuery;
  late int num_requests;
  late List<Cowboy> searchResults; // search results
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
    List<String> friends = [];
    List<String> requests = [];

    if(!(snapshot['friends'] as List<dynamic>).isEmpty) {
      (snapshot['friends'] as List<dynamic>).forEach((dynamicKey) {
        friends.add(dynamicKey.toString().trim());
        print('added: '+dynamicKey.toString().trim());
      });
    } else {
      // print('no friends u bum');
    }
    if(!(snapshot['requests'] as List<dynamic>).isEmpty) {
      (snapshot['requests'] as List<dynamic>).forEach((key) {
        requests.add(key.toString().trim());
      });
    } else {
      // print('no requests u bum');
    }

    context.read<Cowboy>().fillFriendFields(friends, requests);
  }

  Stream<DocumentSnapshot> _getCowboy() {
    print('getting cowboy with uuid: '+context.read<Cowboy>().uuid);
    return userCollection.doc(context.read<Cowboy>().uuid).snapshots();
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
                        //print('changed searchQuery to: '+value);
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
                    if(searchQuery.isNotEmpty) {
                      setState(() {
                        // requestsent = false;
                        if(searchIcon.icon == Icons.search) {
                          // actually search by setting searchResults
                          // print('len results: '+searchResults.length.toString());
                          // searchResultsWidget = searchResultsList();
                          searchIcon = const Icon(Icons.cancel);
                        } else {
                          searchQuery = '';
                          searchIcon = const Icon(Icons.search);
                          searchTextController.clear();
                          searchResults = <Cowboy>[];
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
                                              return RequestAmigo(context.read<Cowboy>().requests[index]);
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
                    child: QueryAmigo(searchQuery),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.0,),
            if(context.watch<Cowboy>().friends.length != 0)...[SizedBox(
              height: 36.0,
              child: Text('friends', style: TextStyle(fontSize: 24.0),),
            )],
            Container(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _getCowboy(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('something went wrong !!');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  loadCowboyProvider(snapshot.data);
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
                        child: cowamigo(context.read<Cowboy>().friends[index]),
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
      if (searchResults.length == 0) {
        return SizedBox(height: 0.0,);
      }
      return ListView.separated(
        shrinkWrap: true,
        itemCount: searchResults.length,
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
                    Text(searchResults[index].firstName+' '+searchResults[index].lastName, style: TextStyle(fontSize: 20),),
                    SizedBox(height: 1.0,),
                    Text(searchResults[index].email),
                  ],
                ),
                Spacer(),
                Container(
                  child: TextButton(
                    child: Icon(Icons.add, size: 35.0, color: Colors.black,),
                    onPressed: () {
                      // TODO give some sort of message that request has been sent
                      context.read<Cowboy>().sendFriendRequest(searchResults[index].uuid);
                      setState(() {
                        searchTextController.clear();
                        searchResults = <Cowboy>[];
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