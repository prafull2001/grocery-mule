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


typedef StringVoidFunc = void Function(String,int);

var userNameTextGroup = AutoSizeGroup();

class UserName extends StatefulWidget {
  late final String userUUID;
  UserName(String userUUID){
    this.userUUID = userUUID;
  }

  @override
  _UserNameState createState() => _UserNameState();
}

class _UserNameState extends State<UserName>{
  late String userUUID;
  CollectionReference userCollection = FirebaseFirestore.instance.collection('users_02');
  @override
  void initState(){
    userUUID = widget.userUUID;
  }
  @override
  Widget build(BuildContext context){
    return StreamBuilder<DocumentSnapshot>(
        stream: userCollection.doc(userUUID).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          return
            Text(
              '${snapshot.data!['first_name']} ',
              style: TextStyle(
                fontSize: 20,
                color: Colors.red
              ),
            );
        }
    );
  }
}

class ItemsList extends StatefulWidget {
  late final String tripUUID;
  ItemsList(String tripUUID){
    this.tripUUID = tripUUID;
  }
  @override
  _ItemsListState createState() => _ItemsListState();
}


Map<String,Map<IndividualItem,IndividualItemExpanded>> itemObjList = {};
class _ItemsListState extends State<ItemsList>{
  late String tripUUID;
  CollectionReference tripCollection = FirebaseFirestore.instance.collection('shopping_trips_02');

  @override
  void initState(){
    tripUUID = widget.tripUUID;
  }
  @override
  Widget build(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
        stream: tripCollection.doc(tripUUID).collection('items').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> itemColQuery) {
          if (itemColQuery.hasError) {
            return const Text('Something went wrong');
          }
          if (itemColQuery.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          loadItemToProvider(itemColQuery.data!);
          //print(context.read<ShoppingTrip>().itemUUID);
          updateitemHash();
          return
            ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                //it takes the uuid of the item  at the index in the panellist,
                //Then use the mapping from uuid to the current instance of the IndividualItem object; this object allows us
                //to flip the isExpanded field of the item that is associated to the uuid
                itemObjList[context.read<ShoppingTrip>().itemUUID[index]]!.keys.first.isExpanded = !isExpanded;
                //TODO: rewrite autp_collapse
                //auto_collapse(context.read<ShoppingTrip>().items[context.read<ShoppingTrip>().items.keys.toList()[index]]);
              });
            },
            children:
            context.watch<ShoppingTrip>().itemUUID.map((uid) {
              return ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return itemObjList[uid]!.keys.first;
                },
                body:
                itemObjList[uid]!.values.first,
                isExpanded: itemObjList[uid]!.keys.first.isExpanded,
              );
            }).toList(),
          );;
        }
          );
  }

  void loadItemToProvider(QuerySnapshot itemColQuery){
    List<String> rawItemList = [];
    itemColQuery.docs.forEach((document) {
        String itemID = document['uuid'];
        if(itemID!= 'dummy')
          rawItemList.add(itemID);
    });
    //check if every id from firebase is in local itemUUID
    rawItemList.forEach((itemID) {
      if(!context.read<ShoppingTrip>().itemUUID.contains(itemID))
        context.read<ShoppingTrip>().itemUUID.add(itemID);
    });
    List<String> tobeDeleted = [];
    //check if any local uuid needs to be deleted
    context.read<ShoppingTrip>().itemUUID.forEach((itemID) {
      if(!rawItemList.contains(itemID)) {
        print("should be here");
        tobeDeleted.add(itemID);
      }
    });
    context
        .read<ShoppingTrip>()
        .itemUUID.removeWhere((element) => tobeDeleted.contains(element));
  }

  //For each new item uid, it is mapped to a collpased item-to-expanded item mapping
  void updateitemHash(){
    context.watch<ShoppingTrip>().itemUUID.forEach((item_uuid) {
      if(!itemObjList.containsKey(item_uuid)) {
        itemObjList[item_uuid] = Map<IndividualItem,IndividualItemExpanded>();
        itemObjList[item_uuid]![IndividualItem(context.read<ShoppingTrip>().uuid, item_uuid)] = IndividualItemExpanded(context.read<ShoppingTrip>().uuid, item_uuid);
        print('made here 2');
        print(itemObjList[item_uuid]!.keys.first.itemID);
      }
    });
    //check if any objmapping needs to be removed
    List<String> tobeDeleted = [];
    itemObjList.forEach((key, value) {
      if(!context.read<ShoppingTrip>().itemUUID.contains(key)) {
        print("should be here1");
        tobeDeleted.add(key);
      }
    });
    itemObjList.removeWhere((key, value) => tobeDeleted.contains(key));
  }
}

class IndividualItem extends StatefulWidget{
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
  CollectionReference shoppingTripCollection = FirebaseFirestore.instance.collection('shopping_trips_02');
  @override
  void initState(){
    itemID = widget.itemID;
    tripID = widget.tripID;
    curItem = Item.nothing();
  }
  @override
  Widget build(BuildContext context){
      return StreamBuilder(
        stream: shoppingTripCollection.doc(tripID).collection('items').doc(itemID).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            loadItem(snapshot.data!);
            return simple_item();

          }
      );
  }
  //this function loads stream snapshots into item
  void loadItem(DocumentSnapshot snapshot){
    curItem.name = snapshot['name'];
    curItem.quantity = snapshot['quantity'];
    (snapshot['subitems'] as Map<String, dynamic>).forEach((uid, value) {
        curItem.subitems[uid] = int.parse(value.toString());
    });
  }

  Widget simple_item(){
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
                    child: const Text("DELETE")
                ),
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

        child: (
            Row(
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

class IndividualItemExpanded extends StatefulWidget{
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
  CollectionReference shoppingTripCollection = FirebaseFirestore.instance.collection('shopping_trips_02');
  @override
  void initState(){
    itemID = widget.itemID;
    tripID = widget.tripID;
    curItem = Item.nothing();
  }
  @override
  Widget build(BuildContext context){
    return StreamBuilder(
        stream: shoppingTripCollection.doc(tripID).collection('items').doc(itemID).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (!snapshot.hasData)
            return const CircularProgressIndicator();
          loadItem(snapshot.data!);
          return expanded_item();

        }
    );
  }
  //this function loads stream snapshots into item
  void loadItem(DocumentSnapshot snapshot){
    curItem.name = snapshot['name'];
    curItem.quantity = snapshot['quantity'];
    (snapshot['subitems'] as Map<String, dynamic>).forEach((uid, value) {
      curItem.subitems[uid] = int.parse(value.toString());
    });
  }

  Widget indie_item(String uid, int number,StringVoidFunc callback){
    return Container(
      color: beige,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              child: UserName(uid),
              padding: EdgeInsets.all(20),
            ),
            Container(
              child:
              NumberInputWithIncrementDecrement(
                initialValue: number,
                controller: TextEditingController(),
                onIncrement: (num newlyIncrementedValue) {
                  callback(uid,newlyIncrementedValue as int);
                },
                onDecrement: (num newlyDecrementedValue) {
                  callback(uid,newlyDecrementedValue as int);
                },
              ),
              height: 60,
              width: 105,

            ),
          ]
      ),

    );
  }

  Widget expanded_item(){
    void updateUsrQuantity(String person, int number){
      setState(() {
        curItem.subitems[person] = number;
        context.read<ShoppingTrip>().editItem(itemID,curItem.subitems.values.reduce((sum, element) => sum + element),person,number);
        // TODO update database here for quant
      });
    };
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: beige,
      ),

      child: Column(
        children: [
          for(var entry in curItem.subitems.entries)
            indie_item(entry.key,entry.value,updateUsrQuantity)
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
  CollectionReference shoppingTripCollection = FirebaseFirestore.instance.collection('shopping_trips_02');
  bool isAdd = false;
  bool invite_guest = false;
  late String hostFirstName;
  List<String> bene_uid = [];
  static bool reload = true;

  @override
  void initState() {
    setState(() {});
    tripUUID = widget.tripUUID!;
    hostFirstName = context.read<Cowboy>().firstName;

    // null value problem here???

    // TODO: implement initState
    _tripTitleController = TextEditingController()..text = context.read<ShoppingTrip>().title;
    _tripDescriptionController = TextEditingController()..text = context.read<ShoppingTrip>().description;
    super.initState();
    if(reload){
      reload = false;
      (context as Element).reassemble();
    }

  }


  void _queryCurrentTrip(DocumentSnapshot curTrip)  {

    DateTime date = DateTime.now();
    date = (curTrip['date'] as Timestamp).toDate();
    (curTrip['beneficiaries'] as List<dynamic>).forEach((uid) {
      if(!bene_uid.contains(uid))
      bene_uid.add(uid.toString());
    });

    context.read<ShoppingTrip>().initializeTripFromDB(curTrip['uuid'],
        curTrip['title'], date,
        curTrip['description'],
        curTrip['host'],
        bene_uid);
  }



  Widget create_item(){
    String food = '';
    //auto_collapse(null);
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: beige,
      ),

      child: (
          Row(
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
                      borderSide: BorderSide(color: darker_beige,),
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
                      onPressed:
                          () {
                        if (food != '')
                          setState(() {
                            context.read<ShoppingTrip>().addItem(food);
                            isAdd = false;
                          });
                      }
                  )
              ),
              Container(
                  child: IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed:
                          () =>(
                          setState(() {isAdd = false; }))
                  )
              ),
            ],
          )),
    );
  }
  void handleClick(int item) {
    switch (item) {
      case 1:
        Navigator.push(context,MaterialPageRoute(builder: (context) => CreateListScreen(false,context.read<ShoppingTrip>().uuid)));
        setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Masterlist(context);
  }

  Widget Masterlist(BuildContext context){
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
              PopupMenuItem<int>(value: 1, child: Text('Trip Settings')),
            ],
          ),
        ],
      ),

      body:
      StreamBuilder<DocumentSnapshot<Object?>>(
          stream: shoppingTripCollection.doc(tripUUID).snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot<Object?>> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong StreamBuilder');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            //readInData(snapshot.data!);
            _queryCurrentTrip(snapshot.data!);
            return Container(
              child: Column(
                //padding: const EdgeInsets.all(25),
                children: [
                  SizedBox(
                    height: 20,
                  ),

                  Row(
                    children: [
                      SizedBox(width: 10.0,),
                      Text(


                        //'Host - ${context.watch<ShoppingTrip>().beneficiaries[context.read<ShoppingTrip>().host]?.split("|~|")[1].split(' ')[0]}',
                        // https://pub.dev/documentation/provider/latest/provider/ReadContext/read.html
                        'Host - ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                      UserName(context.read<ShoppingTrip>().host),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      SizedBox(width: 10.0,),
                      Text(
                        'Beneficiaries -',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(width: 10.0,),
                      Row(
                        children: [
                          for(String name in context.select((
                              ShoppingTrip cur_trip) => cur_trip.beneficiaries))
                            UserName(name)
                        ],

                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.add_circle), onPressed: () {},),
                    ],
                  ),
                  //SizedBox(height: 10),
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
                          )
                      ),
                    ],
                  ),
                  if(isAdd)
                    create_item(),

                  ItemsList(tripUUID),
                  SizedBox(height: 10.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //comment
                      SizedBox(width: 40.0,),
                      Container(
                        height: 70,
                        width: 150,
                        child: RoundedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, PersonalListScreen.id);
                          },
                          title: "Personal List", color: Colors.blueAccent,
                        ),
                      ),
                      Spacer(),
                      if(context
                          .read<ShoppingTrip>()
                          .host == context
                          .read<Cowboy>()
                          .uuid)...[
                        Container(
                          height: 70,
                          width: 150,
                          child: RoundedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, CheckoutScreen.id);
                            },
                            title: "Checkout", color: Colors.blueAccent,
                          ),
                        ),
                      ],
                      SizedBox(width: 40.0,),
                    ],
                  ),
                ],
              )
          );
          }
      ),
    );
  }
}