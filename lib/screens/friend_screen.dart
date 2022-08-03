import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:grocery_mule/theme/colors.dart';
import 'package:grocery_mule/theme/text_styles.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:grocery_mule/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

class _CowamigoState extends State<cowamigo>
    with SingleTickerProviderStateMixin {
  late String uuid;
  String name = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    this.uuid = widget.uuid;
  }

  String lengthify(String str) {
    if (str.isEmpty) return '';
    if (str.length > 29) str = str.substring(0, 26) + '...';
    return str;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<DocumentSnapshot>(
        stream: userCollection.doc(uuid).snapshots(),
        builder: (context, snapshot) {
          Map<String, dynamic> result =
              snapshot.data?.data() as Map<String, dynamic>;
          if (result != null && snapshot.data != null) {
            name = result['first_name'].toString() +
                ' ' +
                result['last_name'].toString();
            email = result['email'].toString();
          }

          return Card(
            elevation: 3,
            color: appColorLight,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.account_circle_outlined,
                    size: 46,
                    color: appOrange,
                    // color: orange,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: appFontStyle.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: 1.0,
                      ),
                      Text(
                        email,
                        style: appFontStyle.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    icon: new Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 28,
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
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
                                      style: appFontStyle.copyWith(
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
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  appOrange),
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.black),
                                        ),
                                        onPressed: () {
                                          context
                                              .read<Cowboy>()
                                              .removeFriend(uuid);
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
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  red),
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.black),
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
            ),
          );
        },
      ),
    );
  }
}

class QueryAmigoDelegate extends SearchDelegate {
  String uuid = '';
  String name = '';
  String email = '';

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(
      onPressed: () {close(context, null);},
      icon: Icon(Icons.clear),
    ),
  ];

  @override
  Widget? buildLeading(BuildContext context) => (
    IconButton(
      onPressed: () {
        if (query == '') {
          close(context, null);
        } else {
          query = '';
        }
      },
      icon: Icon(Icons.arrow_back),
    )
  );

  @override
  Widget buildResults(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          Icons.account_box_outlined,
          size: 40,
          color: Colors.black,
          // color: orange,
        ),
        SizedBox(
          width: 10,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: appFontStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 1.0,
            ),
            Text(
              email,
              style: appFontStyle.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Spacer(),
        IconButton(
          onPressed: () {
            context.read<Cowboy>().sendFriendRequest(uuid);
            close(context, null);
            Fluttertoast.showToast(msg: 'Friend Request Sent!');
          },
          icon: Icon(Icons.add, size: 35,)
        )
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length<=4) {return Container();}
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: userCollection.where('email', isGreaterThanOrEqualTo: query).where('email', isLessThanOrEqualTo: query+ '\uf88f').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('something went wrong !!');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          List<QueryDocumentSnapshot> result = snapshot.data?.docs as List<QueryDocumentSnapshot>;
          if (result.isEmpty) {
            return Text('sorry, nobody with that email', style: appFontStyle.copyWith(fontSize: 18.sp),);
          }
          List<List<String>> queries = [];
          int index = 0;
          result.forEach((QueryDocumentSnapshot snapshot) {
            queries.add([result[index]['uuid'].toString(), result[index]['first_name'].toString()+' '+result[index]['last_name'].toString(), result[index]['email'].toString()]);
            index++;
          });
          return ListView.separated(
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(queries[index][1]+'\n'+queries[index][2]),
                onTap: () {
                  uuid = queries[index][0];
                  name = queries[index][1];
                  email = queries[index][2];

                  showResults(context);
                },
              );
            },
            separatorBuilder: (context, index) {return SizedBox(height: 4.0,);},
            itemCount: queries.length
          );
        },
      ),
    );
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

class _RequestAmigoState extends State<RequestAmigo>
    with SingleTickerProviderStateMixin {
  String uuid = '';
  String name = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    this.uuid = widget.uuid;
  }

  String lengthify(String str) {
    if (str.isEmpty) return '';
    if (str.length > 29) str = str.substring(0, 26) + '...';
    return str;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<DocumentSnapshot>(
        stream: userCollection.doc(uuid).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.data == null){
            return CircularProgressIndicator();
          }
          Map<String, dynamic> result =
              snapshot.data!.data() as Map<String, dynamic>;
          name = result['first_name'].toString() +
              ' ' +
              result['last_name'].toString();
          email = result['email'].toString();
          return Container(
            padding: EdgeInsets.all(2.0),
            child: Row(
              children: [
                Text(
                  lengthify(name),
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
                      backgroundColor: MaterialStateProperty.all<Color>(appOrange),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.black),
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
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.black),
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

class _FriendScreenState extends State<FriendScreen>
    with SingleTickerProviderStateMixin {
  late int num_requests;
  late List<Cowboy> searchResults; // search results
  late Icon searchIcon; // changes between 'X' and search icon while searching
  var searchTextController = TextEditingController();
  @override
  void initState() {
    super.initState();
    num_requests = context.read<Cowboy>().requests.length;
    searchResults = <Cowboy>[];
    searchIcon = Icon(Icons.search);
  }

  loadCowboyProvider(DocumentSnapshot? snapshot) {
    if (snapshot == null) {
      print('snapshot null');
      return;
    }
    if (snapshot.data() == null) {
      print('snapshot data null');
      return;
    }
    if (snapshot.get('uuid') != null) {
      if (snapshot.get('uuid') != context.read<Cowboy>().uuid) {
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

    if (!(snapshot['friends'] as List<dynamic>).isEmpty) {
      (snapshot['friends'] as List<dynamic>).forEach((friendName) {
        friends.add(friendName.toString().trim());
      });
      // print('loaded in cowboy friends: $friends');
    } else {
      // print('no friends u bum');
    }
    if (!(snapshot['requests'] as List<dynamic>).isEmpty) {
      (snapshot['requests'] as List<dynamic>).forEach((key) {
        requests.add(key.toString().trim());
      });
    } else {
      // print('no requests u bum');
    }

    context.read<Cowboy>().fillFriendFields(friends, requests);
  }

  Stream<DocumentSnapshot> _getCowboy() {
    return userCollection.doc(context.read<Cowboy>().uuid).snapshots();
  }

  String lengthify(String str) {
    if (str.isEmpty) return '';
    if (str.length > 29) str = str.substring(0, 26) + '...';
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
        title: Row(
          children: [
            Text('Cowamigos', style: appFontStyle.copyWith(color: Colors.black)),
            Spacer(),
            IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: QueryAmigoDelegate(),
                );
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
                  badgeContent: Text(context
                      .watch<Cowboy>()
                      .requests
                      .length
                      .toString()), // context.watch<Cowboy>().requests.length.toString()
                  child: TextButton(
                    child: Icon(
                      FontAwesomeIcons.userGroup,
                      color: appColorLight,
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(appOrange),
                      foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Container(
                                width: double.maxFinite,
                                height: 60.0 +
                                    (context
                                        .watch<Cowboy>()
                                        .requests
                                        .length *
                                        50.0),
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
                                      itemCount: context
                                          .watch<Cowboy>()
                                          .requests
                                          .length,
                                      controller: ScrollController(),
                                      itemBuilder: (BuildContext context,
                                          int index) {
                                        return RequestAmigo(context
                                            .read<Cowboy>()
                                            .requests[index]);
                                      },
                                      separatorBuilder: (context, index) {
                                        return SizedBox(
                                          height: 2.0,
                                        );
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
                          });
                    }, // onPressed
                  ),
                );
              },
            ),
            // maybe don't need the sized box vvvv (just for spacing)
            SizedBox(width: 5),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 12.0,
            ),
            SizedBox(height: 40,),
            Container(
              child: StreamBuilder<DocumentSnapshot>(
                  stream: _getCowboy(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('uh-oh,something went wrong!');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    loadCowboyProvider(snapshot.data);
                    if (context.watch<Cowboy>().friends.length == 0) {
                      return SizedBox(
                        height: 36.0,
                        child: Text(
                          'no friends :(',
                          style: appFontStyle.copyWith(
                              fontSize: 18.sp, fontWeight: FontWeight.w500),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(2.0),
                      // scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: context.watch<Cowboy>().friends.length,
                      controller: ScrollController(),
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          key: Key(context.watch<Cowboy>().friends[index]),
                          onTap: () {
                            const xButton = Icon(Icons.done, size: 46);
                          },
                          child: cowamigo(context.watch<Cowboy>().friends[index]),
                        );
                      }, // itemBuilder
                      separatorBuilder: (context, int index) {
                        return SizedBox(
                          height: 5.0,
                        );
                      },
                    );
                  }),
            ), // container for listview of friends list
          ],
        ),
      ),
    );
    throw UnimplementedError();
  }

  Widget searchResultsList() {
    if (searchResults != null) {
      if (searchResults.length == 0) {
        return SizedBox(
          height: 0.0,
        );
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
                Icon(
                  Icons.account_box_outlined,
                  size: 45.0,
                ),
                SizedBox(
                  width: 10.0,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      searchResults[index].firstName +
                          ' ' +
                          searchResults[index].lastName,
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    Text(searchResults[index].email),
                  ],
                ),
                Spacer(),
                Container(
                  child: TextButton(
                    child: Icon(
                      Icons.add,
                      size: 35.0,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      // TODO give some sort of message that request has been sent
                      context
                          .read<Cowboy>()
                          .sendFriendRequest(searchResults[index].uuid);
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
          return SizedBox(
            height: 5.0,
          );
        },
      );
    }
    return SizedBox(
      height: 0.0,
    );
  }
}
