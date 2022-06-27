import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_mule/components/rounded_ button.dart';
import 'package:grocery_mule/constants.dart';
import 'dart:async';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:grocery_mule/providers/shopping_trip_provider.dart';
import 'package:grocery_mule/screens/checkout_screen.dart';
import 'package:grocery_mule/screens/personal_list.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'createlist.dart';
import 'package:grocery_mule/dev/collection_references.dart';

import 'lists.dart';

typedef StringVoidFunc = void Function(String, int);

class UserName extends StatefulWidget {
  late final String userUUID;
  UserName(String userUUID, [bool spec=false, bool strng=false]) {
    this.userUUID = userUUID;
  }

  @override
  _UserNameState createState() => _UserNameState();
}

class _UserNameState extends State<UserName> {
  late String userUUID;
  late Stream<DocumentSnapshot> personalshot;

  @override
  void initState() {
    userUUID = widget.userUUID;
    personalshot = userCollection.doc(userUUID).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: personalshot,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }
          // print('name for uuid ($userUUID): ' + snapshot.data!['first_name']);
          return Text(
            '${snapshot.data!['first_name']} ',
            style: TextStyle(fontSize: 20, color: Colors.black),
          );
        });
  }
}

class ItemsList extends StatefulWidget {
  late final String tripUUID;
  ItemsList(String tripUUID) {
    this.tripUUID = tripUUID;
  }
  @override
  _ItemsListState createState() => _ItemsListState();
}


class _ItemsListState extends State<ItemsList> {
  late String tripUUID;


  late Stream<QuerySnapshot> getItemsStream;

  @override
  void initState() {
    tripUUID = widget.tripUUID;
    getItemsStream =
        tripCollection.doc(tripUUID).collection('items').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: getItemsStream,
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> itemColQuery) {
          if (itemColQuery.hasError) {
            return const Text('Something went wrong');
          }
          if (itemColQuery.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }

          loadItemToProvider(itemColQuery.data!);
          return Container(
            height: 370,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: context.watch<ShoppingTrip>().itemUUID.length,
              itemBuilder: (context, int index){
                return IndividualItem(tripUUID,context.watch<ShoppingTrip>().itemUUID[index], index, key: Key(context.watch<ShoppingTrip>().itemUUID[index]));
              },
            ),
          );
        });
  }

  void loadItemToProvider(QuerySnapshot itemColQuery) {
    List<String> rawItemList = [];
    itemColQuery.docs.forEach((document) {
      String itemID = document['uuid'];
      if (itemID != 'dummy') rawItemList.add(itemID);
    });
    //check if every id from firebase is in local itemUUID
    rawItemList.forEach((itemID) {
      if (!context.read<ShoppingTrip>().itemUUID.contains(itemID))
        context.read<ShoppingTrip>().itemUUID.add(itemID);
    });
    List<String> tobeDeleted = [];
    //check if any local uuid needs to be deleted
    context.read<ShoppingTrip>().itemUUID.forEach((itemID) {
      if (!rawItemList.contains(itemID)) {
        tobeDeleted.add(itemID);
      }
    });
    context
        .read<ShoppingTrip>()
        .itemUUID
        .removeWhere((element) => tobeDeleted.contains(element));
  }


}
//ignore: must_be_immutable
class IndividualItem extends StatefulWidget {
  late Item curItem;
  late final String itemID;
  late final String tripID;
  late final int index;
  IndividualItem(this.tripID, this.itemID, this.index, { required Key key}): super(key: key);
  @override
  _IndividualItemState createState() => _IndividualItemState();
}

class _IndividualItemState extends State<IndividualItem> {
  late Item curItem;
  late final String itemID;
  late final String tripID;
  late final int index;
  late Stream<DocumentSnapshot> getItemStream = tripCollection.doc(tripID).collection('items').doc(itemID).snapshots();

  @override
  void initState() {
    itemID = widget.itemID;
    tripID = widget.tripID;
    index = widget.index;
    curItem = Item.nothing();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
        stream: getItemStream,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          }

          if (snapshot.hasError) return const CircularProgressIndicator();
          loadItem(snapshot.data!);
          return simple_item();

        });
  }

  //this function loads stream snapshots into item
  void loadItem(DocumentSnapshot snapshot) {
    curItem.name = snapshot['name'];
    curItem.quantity = snapshot['quantity'];
    curItem.subitems = {};
    curItem.check = snapshot['check'] as bool;
    (snapshot['subitems'] as Map<String, dynamic>).forEach((uid, value) {
      int count = curItem.subitems.keys.length;
      // print('loadItem (individual) called with uid: {$uid}, value: {$value}, length: {$count}');
      curItem.subitems[uid] = int.parse(value.toString());
    });
  }

  Widget simple_item() {
    String name = curItem.name;
    int quantity = curItem.subitems[context.read<Cowboy>().uuid]!;

    return Card(
      color: (context.watch<ShoppingTrip>().lock == true && context.watch<Cowboy>().uuid != context.watch<ShoppingTrip>().host)?
          beige:
      (index % 2 == 0 )? card_yellow : card_orange,
      key: Key(itemID),
      child: ListTile(
        title: Container(
          child: Text(
            '${name}',
            style: TextStyle(color: Colors.black,
              fontSize: 20,
            ),
          ),
        ),
        subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if(context.read<ShoppingTrip>().lock == false)...[
            Container(
                child: IconButton(
                    icon: const Icon(Icons.remove_circle),
                    onPressed: () => (setState(() {
                      updateUsrQuantity(context.read<Cowboy>().uuid, max(0, quantity -1));
                    })
                    )
                )
            ),
            ],
            Container(
              child:
                Text(
                    '${quantity}'
                ),
            ),
            if(context.read<ShoppingTrip>().lock == false)...[
            Container(
                child: IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: () {
                      setState(() {
                        updateUsrQuantity(context.read<Cowboy>().uuid, quantity +1);
                      });
                    })),
            ],
          ],

        ),
        trailing: (context.read<Cowboy>().uuid == context.read<ShoppingTrip>().host)?
        (context.read<ShoppingTrip>().lock == false)?
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: (){setState(() {
              context.read<ShoppingTrip>().removeItem(itemID);
            });},
          ) :
        Checkbox(
          checkColor: Colors.white,
          fillColor: MaterialStateProperty.resolveWith(getColor),
          value: curItem.check,
          onChanged: (bool? value) {
            setState(() {
              curItem.check = value!;
              context.read<ShoppingTrip>().changeItemCheck(itemID);
            });
          },
        )

        :SizedBox.shrink()
        ,
        isThreeLine: true,
      ),
    );
  }
  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.green;
  }
  void updateUsrQuantity(String person, int number) {
    curItem.subitems[person] = number;
    context.read<ShoppingTrip>().editItem(
        itemID,
        curItem.subitems.values.reduce((sum, element) => sum + element),
        person,
        number);
    // TODO update database here for quant
  }
}


class EditListScreen extends StatefulWidget {
  static String id = 'edit_list_screen';
  String? tripUUID;
  User? curUser = FirebaseAuth.instance.currentUser;
  final String hostUUID = FirebaseAuth.instance.currentUser!.uid;

  // simple constructor, just takes in tripUUID
  EditListScreen(String? tripUUID) {
    this.tripUUID = tripUUID;
    if (this.tripUUID == null) {
      throw Exception('editlist.dart: Invalid tripUUID was passed');
    }
  }

  @override
  _EditListsScreenState createState() => _EditListsScreenState();
}

class _EditListsScreenState extends State<EditListScreen> {
  var _tripTitleController;
  var _tripDescriptionController;
  User? curUser = FirebaseAuth.instance.currentUser;
  late String tripUUID;

  bool isAdd = false;
  bool invite_guest = false;
  late String hostFirstName;

  static bool reload = true;
  bool leave_list = false;
  late Stream<DocumentSnapshot<Object?>>? listStream;

  @override
  void initState() {
    tripUUID = widget.tripUUID!;
    listStream = tripCollection.doc(tripUUID).snapshots();
    hostFirstName = context.read<Cowboy>().firstName;

    // null value problem here???

    // TODO: implement initState
    _tripTitleController = TextEditingController()
      ..text = context.read<ShoppingTrip>().title;
    _tripDescriptionController = TextEditingController()
      ..text = context.read<ShoppingTrip>().description;
    super.initState();
    if (reload) {
      reload = false;
      (context as Element).reassemble();
    }
  }

  void _queryCurrentTrip(DocumentSnapshot curTrip) {
    List<String> bene_uid = [];
    DateTime date = DateTime.now();
    date = (curTrip['date'] as Timestamp).toDate();
    List<String> temp_bene_uid = [];
    (curTrip['beneficiaries'] as List<dynamic>).forEach((uid) {
      temp_bene_uid.add(uid.toString());
      if (!bene_uid.contains(uid)) bene_uid.add(uid.toString());
    });

    bene_uid = temp_bene_uid;
    //bool cur_lock = curTrip['lock'] as bool;
    context.read<ShoppingTrip>().initializeTripFromDB(
        curTrip['uuid'],
        curTrip['title'],
        date,
        curTrip['description'],
        curTrip['host'],
        bene_uid,
        curTrip['lock'] as bool
    );
  }

  Widget create_item() {
    String food = '';
    //auto_collapse(null);
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: beige,
      ),
      child: (Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            child: Text(
              'Enter Item',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            padding: EdgeInsets.all(20),
          ),
          Container(
            height: 45,
            width: 100,
            child: TextField(
              style: TextStyle(color: darker_beige),
              cursorColor: darker_beige,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: darker_beige,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: darker_beige, width: 2),
                ),
                hintText: 'EX: Apple',
              ),
              onChanged: (text) {
                food = text;
              },
            ),
          ),
          Container(
              child: IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: () {
                    if (food != '')
                      setState(() {
                        context.read<ShoppingTrip>().addItem(food);
                        isAdd = false;
                      });
                  })),
          Container(
              child: IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => (setState(() {
                        isAdd = false;
                      })))),
        ],
      )),
    );
  }
  check_leave(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure you wish to leave this trip?"),
          actions: <Widget>[
            FlatButton(
              onPressed: () => {
                leave_list = false,
                Navigator.of(context).pop(),
              },
              child: const Text("CANCEL"),
            ),
            FlatButton(
                onPressed: () => {
                  leave_list = true,
                  Navigator.of(context).pop(),
                },
                child: const Text("LEAVE")),
          ],
        );
      },
    );
  }
  Future<void> handleClick(int item) async {
    switch (item) {
      case 1:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreateListScreen(
                    false, context.read<ShoppingTrip>().uuid))).then((_) => setState(() {}));
        break;
      case 2:
        await check_leave(context);
        if(leave_list){
          context.read<Cowboy>().leaveTrip(context.read<ShoppingTrip>().uuid);
          context.read<ShoppingTrip>().removeBeneficiary(context.read<Cowboy>().uuid);
          Navigator.of(context).pop();

    }
  }}



    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Edit List',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: light_orange,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        actions: <Widget>[
          PopupMenuButton<int>(
            onSelected: (item) => {
              handleClick(item),
            },
            itemBuilder: (context) => [
              (context.read<Cowboy>().uuid == context.read<ShoppingTrip>().host)?
              PopupMenuItem<int>(value: 1, child: Text('Trip Settings')):
              PopupMenuItem<int>(value: 2, child: Text('Leave Trip')),
            ],
          ),
        ],


      ),
      body: Container(
        child: StreamBuilder<DocumentSnapshot<Object?>>(
            stream: listStream,
            builder:
                (context, AsyncSnapshot<DocumentSnapshot<Object?>> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong StreamBuilder');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox.shrink();
              }
              //readInData(snapshot.data!);
              _queryCurrentTrip(snapshot.data!);
              if(!context.watch<ShoppingTrip>().beneficiaries.contains(context.read<Cowboy>().uuid)) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                'You have been removed from this trip',
                                style: TextStyle(
                                  fontSize: 40.0,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
              }
              return SingleChildScrollView(
                child: Container(
                    child: Column(
                  //padding: const EdgeInsets.all(25),
                  children: [
                    SizedBox(
                      height: 20,
                    ),

                    Row(
                      children: [
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          //'Host - ${context.watch<ShoppingTrip>().beneficiaries[context.read<ShoppingTrip>().host]?.split("|~|")[1].split(' ')[0]}',
                          // https://pub.dev/documentation/provider/latest/provider/ReadContext/read.html
                          'Host - ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        UserName(context.read<ShoppingTrip>().host, false, true),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Card(
                      color: light_cream,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            color: Color.fromARGB(255, 0, 0, 0), width: 2.0),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: Text(
                            "Beneficiaries",
                          ),
                          children: [
                            // TODO error right vvvvvvv should be watching beneficaries from firebase not from context
                            for (String name in context.watch<ShoppingTrip>().beneficiaries)
                              ListTile(
                                title: UserName(name, false, true),
                              )
                          ],
                        ),
                      ),
                    ),
                    //Segregated the Widget into two parts so that the state of the changing widget in maintained inside and changing the widget wont change the state of the whole screen
                    ItemsAddition(
                      tripUUID: tripUUID,
                    )

                    //SizedBox(height: 10),
                  ],
                )
                ),
              );
            }),
      ),
    );
  }
}

//Moved the changing widget into the a tree on the downward heririary of the masterTree branch

class ItemsAddition extends StatefulWidget {
  final String tripUUID;
  const ItemsAddition({Key? key, required this.tripUUID}) : super(key: key);

  @override
  State<ItemsAddition> createState() => _ItemsAdditionState();
}

class _ItemsAdditionState extends State<ItemsAddition> {
  Widget create_item() {
    String food = '';
    //auto_collapse(null);
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: beige,
      ),
      child: (Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            child: Text(
              'Enter Item',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            padding: EdgeInsets.all(20),
          ),
          Container(
            height: 45,
            width: 100,
            child: TextField(
              style: TextStyle(color: darker_beige),
              cursorColor: darker_beige,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: darker_beige,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: darker_beige, width: 2),
                ),
                hintText: 'EX: Apple',
              ),
              onChanged: (text) {
                food = text;
              },
            ),
          ),
          Container(
              child: IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: () {
                    if (food != '')
                      setState(() {
                        context.read<ShoppingTrip>().addItem(food);
                        isAdd = false;
                      });
                  })),
          Container(
              child: IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => (setState(() {
                        isAdd = false;
                      })))),
        ],
      )),
    );
  }

  bool isAdd = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 40,
          width: double.maxFinite,
          child: Divider(
            color: Colors.black,
            thickness: 1.5,
            indent: 75,
            endIndent: 75,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              child: Text(
                'Add Item',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
            Container(
                child: (context.read<ShoppingTrip>().lock == false)?
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: () {
                    setState(() {
                      isAdd = true;
                    });
                  },
                ):
                 const Icon(Icons.lock_outlined),
            )
          ],
        ),
        if (isAdd) create_item(),
        ItemsList(widget.tripUUID),
        SizedBox(
          height: 10.0,
        ),
    if (context.read<ShoppingTrip>().host ==
    context.read<Cowboy>().uuid) ...[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //comment
            SizedBox(
              width: 40.0,
            ),
            Container(
              height: 70,
              width: 150,
              child: RoundedButton(
                onPressed: () {
                  context.read<ShoppingTrip>().changeTripLock();
                  context.read<ShoppingTrip>().setAllCheckFalse();
                },
                title: (context.watch<ShoppingTrip>().lock == false)? "Shopping Mode"
                    : "Unlock Trip"
                ,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            Container(
                height: 70,
                width: 150,
                child: RoundedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, CheckoutScreen.id);
                  },
                  title: "Checkout",
                  color: Colors.blueAccent,
                ),
              ),
            Spacer(),
            SizedBox(
              width: 40.0,
            ),
          ],
        ),
    ]
      ],
    );
  }
}
