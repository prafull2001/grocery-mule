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
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'createlist.dart';
import 'package:grocery_mule/dev/collection_references.dart';

typedef StringVoidFunc = void Function(String, int);

var userNameTextGroup = AutoSizeGroup();

class UserName extends StatefulWidget {
  late final String userUUID;
  UserName(String userUUID, [bool spec=false, bool strng=false]) {
    // if (spec) print('spec uuid: $userUUID');
    // if (strng) print('strng uuid: $userUUID');
    this.userUUID = userUUID;
  }

  @override
  _UserNameState createState() => _UserNameState();
}

class _UserNameState extends State<UserName> {
  late String userUUID;


  @override
  void initState() {
    userUUID = widget.userUUID;
  }

  @override
  Widget build(BuildContext context) {
    print("actual streamed: ${userUUID}");
    return StreamBuilder<DocumentSnapshot>(
        stream: userCollection.doc(userUUID).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          // print('name for uuid ($userUUID): ' + snapshot.data!['first_name']);
          return Text(
            '${snapshot.data!['first_name']} ',
            style: TextStyle(fontSize: 20, color: Colors.red),
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

Map<String, Map<IndividualItem, IndividualItemExpanded>> itemObjList = {};

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
            return const CircularProgressIndicator();
          }

          loadItemToProvider(itemColQuery.data!);
          //print(context.read<ShoppingTrip>().itemUUID);
          updateitemHash();
          return ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                //it takes the uuid of the item  at the index in the panellist,
                //Then use the mapping from uuid to the current instance of the IndividualItem object; this object allows us
                //to flip the isExpanded field of the item that is associated to the uuid
                itemObjList[context.read<ShoppingTrip>().itemUUID[index]]!
                    .keys
                    .first
                    .isExpanded = !isExpanded;
                //TODO: rewrite autp_collapse
                //auto_collapse(context.read<ShoppingTrip>().items[context.read<ShoppingTrip>().items.keys.toList()[index]]);
              });
            },
            children: context.watch<ShoppingTrip>().itemUUID.map((uid) {
              return ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return itemObjList[uid]!.keys.first;
                },
                body: itemObjList[uid]!.values.first,
                isExpanded: itemObjList[uid]!.keys.first.isExpanded,
              );
            }).toList(),
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

  //For each new item uid, it is mapped to a collpased item-to-expanded item mapping
  void updateitemHash() {
    context.watch<ShoppingTrip>().itemUUID.forEach((item_uuid) {
      if (!itemObjList.containsKey(item_uuid)) {
        itemObjList[item_uuid] = Map<IndividualItem, IndividualItemExpanded>();
        itemObjList[item_uuid]![
                IndividualItem(context.read<ShoppingTrip>().uuid, item_uuid)] =
            IndividualItemExpanded(
                context.read<ShoppingTrip>().uuid, item_uuid);
        //print(itemObjList[item_uuid]!.keys.first.itemID);
      }
    });
    //check if any objmapping needs to be removed
    List<String> tobeDeleted = [];
    itemObjList.forEach((key, value) {
      if (!context.read<ShoppingTrip>().itemUUID.contains(key)) {
        tobeDeleted.add(key);
      }
    });
    itemObjList.removeWhere((key, value) => tobeDeleted.contains(key));
  }
}

class IndividualItem extends StatefulWidget {
  late Item curItem;
  late final String itemID;
  late final String tripID;
  bool isExpanded = false;
  IndividualItem(this.tripID, this.itemID);
  @override
  _IndividualItemState createState() => _IndividualItemState();
}

class _IndividualItemState extends State<IndividualItem> {
  late Item curItem;
  late final String itemID;
  late final String tripID;
  bool isExpanded = false;


  @override
  void initState() {
    itemID = widget.itemID;
    tripID = widget.tripID;
    curItem = Item.nothing();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: tripCollection
            .doc(tripID)
            .collection('items')
            .doc(itemID)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
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
    (snapshot['subitems'] as Map<String, dynamic>).forEach((uid, value) {
      int count = curItem.subitems.keys.length;
      // print('loadItem (individual) called with uid: {$uid}, value: {$value}, length: {$count}');
      curItem.subitems[uid] = int.parse(value.toString());
    });
  }

  Widget simple_item() {
    String name = curItem.name;
    int quantity = 0;
    curItem.subitems.forEach((name, count) {
      quantity = quantity + count;
    });

    return Dismissible(
      key: Key(name),
      onDismissed: (direction) {
        context.read<ShoppingTrip>().removeItem(itemID);
        itemObjList.remove(itemID);
        // Remove the item from the data source.
      },
      confirmDismiss: (DismissDirection direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm"),
              content: const Text("Are you sure you wish to delete this item?"),
              actions: <Widget>[
                FlatButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text("DELETE")),
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("CANCEL"),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: dark_beige,
        ),
        child: (Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              child: Text(
                '$name',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              padding: EdgeInsets.all(20),
            ),
            Container(
              child: Text(
                'x$quantity',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        )),
      ),
      background: Container(color: red),
    );
  }
}

class IndividualItemExpanded extends StatefulWidget {
  late Item curItem;
  late final String itemID;
  late final String tripID;
  IndividualItemExpanded(this.tripID, this.itemID);
  @override
  _IndividualItemExpandedState createState() => _IndividualItemExpandedState();
}

class _IndividualItemExpandedState extends State<IndividualItemExpanded> {
  late Item curItem;
  late final String itemID;
  late final String tripID;

  @override
  void initState() {
    itemID = widget.itemID;
    tripID = widget.tripID;
    curItem = Item.nothing();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: tripCollection
            .doc(tripID)
            .collection('items')
            .doc(itemID)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) return const CircularProgressIndicator();
          loadItem(snapshot.data!);
          print(curItem.subitems.length);
          void updateUsrQuantity(String person, int number) {
            //setState(() {
            //curItem.subitems = {};
            curItem.subitems[person] = number;
            context.read<ShoppingTrip>().editItem(
                itemID,
                curItem.subitems.values.reduce((sum, element) => sum + element),
                person,
                number);
            // TODO update database here for quant
          }
          //);}
              ;

          print(curItem.subitems);
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: beige,
            ),
            child: Column(
              children: [
                for (var entry in curItem.subitems.entries)
                  indie_item(entry.key, entry.value, updateUsrQuantity)
              ],
            ),
          );
        });
  }

  //this function loads stream snapshots into item
  void loadItem(DocumentSnapshot snapshot) {
    Item temp = Item.nothing();
    temp.name = snapshot['name'];
    temp.quantity = snapshot['quantity'];
    temp.subitems = {};
    List<String> bene_list = [];
    (snapshot['subitems'] as Map<String, dynamic>).forEach((uid, value) {
      bene_list.add(uid);
      temp.subitems[uid] = int.parse(value.toString());
    });

    if(temp != curItem){
      //setState(() {
        curItem = temp;
       // });
    }
    //context.read<ShoppingTrip>().setBeneficiary(bene_list);
  }

  Widget indie_item(String uid, int number, StringVoidFunc callback) {
    print("this user: " + uid);
    // print('uid of user (indie_item): ${uid}');
    return Container(
      color: beige,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Container(
          child: UserName(uid, true),
          padding: EdgeInsets.all(20),
        ),
        Container(
          child: (context.read<Cowboy>().uuid == uid)
              ? NumberInputWithIncrementDecrement(
                  initialValue: number,
                  controller: TextEditingController(),
                  onIncrement: (num newlyIncrementedValue) {
                    callback(uid, newlyIncrementedValue as int);
                  },
                  onDecrement: (num newlyDecrementedValue) {
                    callback(uid, newlyDecrementedValue as int);
                  },
                )
          // TODO vvvv--- maybe issue here???
              : Center(
                child: Text(
                    'x$number',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
              ),
          height: 60,
          width: 105,
        )
      ]),
    );
  }

  Widget expanded_item() {
    void updateUsrQuantity(String person, int number) {
      //setState(() {
      //curItem.subitems = {};
        curItem.subitems[person] = number;
        context.read<ShoppingTrip>().editItem(
            itemID,
            curItem.subitems.values.reduce((sum, element) => sum + element),
            person,
            number);
        // TODO update database here for quant
        }
      //);}
    ;
    print(curItem.subitems);
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: beige,
      ),
      child: Column(
        children: [
          for (var entry in curItem.subitems.entries)
            indie_item(entry.key, entry.value, updateUsrQuantity)
        ],
      ),
    );
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
  List<String> bene_uid = [];
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
    DateTime date = DateTime.now();
    date = (curTrip['date'] as Timestamp).toDate();
    List<String> temp_bene_uid = [];
    (curTrip['beneficiaries'] as List<dynamic>).forEach((uid) {
      temp_bene_uid.add(uid.toString());
      if (!bene_uid.contains(uid)) bene_uid.add(uid.toString());
    });
    bene_uid = temp_bene_uid;

    context.read<ShoppingTrip>().initializeTripFromDB(
        curTrip['uuid'],
        curTrip['title'],
        date,
        curTrip['description'],
        curTrip['host'],
        bene_uid);
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
    }
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
                  leave_list = true,
                  Navigator.of(context).pop(),
                },
                child: const Text("Leave")),
            FlatButton(
              onPressed: () => {
                leave_list = false,
                Navigator.of(context).pop(),
              },
              child: const Text("CANCEL"),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Masterlist(context);
  }

  Widget Masterlist(BuildContext context) {
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
      body: StreamBuilder<DocumentSnapshot<Object?>>(
          stream: tripCollection.doc(tripUUID).snapshots(),
          builder:
              (context, AsyncSnapshot<DocumentSnapshot<Object?>> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong StreamBuilder');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            //readInData(snapshot.data!);
            _queryCurrentTrip(snapshot.data!);
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
              )),
            );
          }),
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
                child: IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: () {
                setState(() {
                  isAdd = true;
                });
              },
            )),
          ],
        ),
        if (isAdd) create_item(),
        ItemsList(widget.tripUUID),
        SizedBox(
          height: 10.0,
        ),
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
                  Navigator.pushNamed(context, PersonalListScreen.id);
                },
                title: "Personal List",
                color: Colors.blueAccent,
              ),
            ),
            Spacer(),
            if (context.read<ShoppingTrip>().host ==
                context.read<Cowboy>().uuid) ...[
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
            ],
            SizedBox(
              width: 40.0,
            ),
          ],
        ),
      ],
    );
  }
}
