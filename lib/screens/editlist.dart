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
import 'createlist.dart';


typedef StringVoidFunc = void Function(String,int);

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
  CollectionReference shoppingTripCollection = FirebaseFirestore.instance.collection('shopping_trips_test');
  bool isAdd = false;
  bool invite_guest = false;
  late String hostFirstName;
  Map<String,String> uid_name = {};
  static bool reload = true;
  List<String> beneficiary_names = [];

  @override
  void initState() {
    setState(() {});
    tripUUID = widget.tripUUID!;
    hostFirstName = context.read<Cowboy>().firstName;
    _queryCurrentTrip();

    // null value problem here???

    // TODO: implement initState
    _tripTitleController = TextEditingController()..text = context.read<ShoppingTrip>().title;
    _tripDescriptionController = TextEditingController()..text = context.read<ShoppingTrip>().description;
    super.initState();
    if(reload){
      reload = false;
      (context as Element).reassemble();
    }

    // for(String name in context.watch<ShoppingTrip>().beneficiaries.values)
    //   Text(
    //     '${name.split("|~|")[1].split(" ")[0]} ',
    //     style: TextStyle(
    //       color: Colors.black,
    //       fontSize: 15,
    //     ),
    //   )

    // for(String name in context.read<ShoppingTrip>().beneficiaries.values) {
    //   String bene_name = name.split("|~|")[1].split(" ")[0];
    //   beneficiary_names.add(bene_name);
    // }
    //
    // print(beneficiary_names);

  }





  Future<void> _queryCurrentTrip() async {
    DocumentSnapshot tempShot = await shoppingTripCollection.doc(tripUUID).get();
    DateTime date = DateTime.now();
    Map<String, Item> items = <String, Item>{};
    date = (tempShot['date'] as Timestamp).toDate();
    //print(raw_date);
    (tempShot['beneficiaries'] as Map<String,dynamic>).forEach((uid,name) {
      uid_name[uid.toString()] = name.toString();
    });
    ((tempShot.data() as Map<String, dynamic>)['items'] as Map<String, dynamic>).forEach((name, dynamicItem) {
      items[name] = Item.fromMap(dynamicItem as Map<String, dynamic>);
      items[name]!.isExpanded = false;
      print('expandability set fine');
      //add each item to the panel (for expandable items presented to user)
      //frontend_list[name] = new Item_front_end(name, items[name]);
    });

    context.read<ShoppingTrip>().initializeTripFromDB(tempShot['uuid'],
        (tempShot.data() as Map<String, dynamic>)['title'], date,
        (tempShot.data() as Map<String, dynamic>)['description'],
        (tempShot.data() as Map<String, dynamic>)['host'],
        uid_name, items);
    return;
  }


  void auto_collapse(Item? ignore){
    context.read<ShoppingTrip>().items.values.forEach((item) {
      setState(() {
        if(item != ignore)
          item.isExpanded = false;
      });
    });
  }



  Widget simple_item(Item item){
    print('trying to get simple_item');
    String name = item.name!;
    print('simple_item name set fine');
    int quantity = 0;
    item.subitems.forEach((name, count) {
      quantity = quantity + count;
    });

    return Dismissible(
      key: Key(name),
      onDismissed: (direction) {
        context.read<ShoppingTrip>().removeItem(name);
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
  Widget indie_item(String uid, int number,StringVoidFunc callback){
    String name = uid_name[uid]!;
    print('indie_item set fine');
    return Container(
      color: beige,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              child: Text(
                '${name.split("|~|")[1].split(" ")[0]}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),

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

  Widget expanded_item(Item item){
    void updateUsrQuantity(String person, int number){
      setState(() {
        item.subitems[person] = number;
        context.read<ShoppingTrip>().editItem(item.name!,item.subitems.values.reduce((sum, element) => sum + element),item.subitems);
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
          for(var entry in item.subitems.entries)
            indie_item(entry.key,entry.value,updateUsrQuantity)
        ],
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          context.read<ShoppingTrip>().items[context.read<ShoppingTrip>().items.keys.toList()[index]]!.isExpanded = !isExpanded;
          auto_collapse(context.read<ShoppingTrip>().items[context.read<ShoppingTrip>().items.keys.toList()[index]]);
        });
      },
      children:
      context.watch<ShoppingTrip>().items.values.toList().map((item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return simple_item(item);
          },
          body:
          expanded_item(item),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }

  Widget create_item(){
    String food = '';
    auto_collapse(null);
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
      Container(
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
                    'Host - ${context.select((ShoppingTrip cur_trip) => cur_trip.beneficiaries[cur_trip.host]?.split("|~|")[1].split(' ')[0])}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
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
                      for(String name in context.select((ShoppingTrip cur_trip) => cur_trip.beneficiaries.values))
                        Text(
                          '${name.split("|~|")[1].split(" ")[0]} ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                    ],

                  ),
                  Spacer(),
                  IconButton(icon: Icon(Icons.add_circle), onPressed: () {  },),
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
              //single_item(grocery_list[1]),
              _buildPanel(),
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
                  if(context.read<ShoppingTrip>().host == context.read<Cowboy>().uuid)...[
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
      ),
    );
  }
}