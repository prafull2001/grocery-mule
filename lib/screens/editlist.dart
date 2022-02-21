import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_mule/components/rounded_ button.dart';
import 'dart:async';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:grocery_mule/providers/shopping_trip_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'createlist.dart';
typedef StringVoidFunc = void Function(String,int);

class EditListScreen extends StatefulWidget {
  static String id = 'edit_list_screen';
  String tripUUID;
  User curUser = FirebaseAuth.instance.currentUser;
  final String hostUUID = FirebaseAuth.instance.currentUser.uid;

  // simple constructor, just takes in tripUUID
  EditListScreen(String tripUUID) {
    this.tripUUID = tripUUID;
  }

  @override
  _EditListsScreenState createState() => _EditListsScreenState();
}



class _EditListsScreenState extends State<EditListScreen> {
  var _tripTitleController;
  var _tripDescriptionController;
  User curUser = FirebaseAuth.instance.currentUser;
  String tripUUID;
  CollectionReference shoppingTripCollection = FirebaseFirestore.instance.collection('shopping_trips_test');
  List<String> full_list; // host and beneficiaries
  bool isAdd = false;
  bool invite_guest = false;
  String hostFirstName;
  @override
  void initState() {
    tripUUID = widget.tripUUID;
    hostFirstName = context.read<Cowboy>().firstName;
    _loadCurrentTrip();
    // TODO: implement initState
    _tripTitleController = TextEditingController()..text = context.read<ShoppingTrip>().title;
    _tripDescriptionController = TextEditingController()..text = context.read<ShoppingTrip>().description;
    super.initState();
  }

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  List<Widget> _widgetOptions = <Widget>[
    //Masterlist(context),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  void _loadCurrentTrip() {
    _queryCurrentTrip().then((DocumentSnapshot snapshot) {
      if(snapshot != null) {
        DateTime date = DateTime.now();
        List<String> beneficiaries = <String>[];
        Map<String, Item> items = <String, Item>{};
        date = (snapshot['date'] as Timestamp).toDate();
        //print(raw_date);
        ((snapshot.data() as Map<String, dynamic>)['beneficiaries'] as List<dynamic>).forEach((dynamicElement) {
          beneficiaries.add(dynamicElement.toString());
        });
        ((snapshot.data() as Map<String, dynamic>)['items'] as Map<String, dynamic>).forEach((name, dynamicItem) {
          items[name] = Item.fromMap(dynamicItem as Map<String, dynamic>);
          items[name].isExpanded = false;
            //add each item to the panel (for expandable items presented to user)
          //frontend_list[name] = new Item_front_end(name, items[name]);
        });

        setState(() {
          context.read<ShoppingTrip>().initializeTripFromDB(snapshot['uuid'],
              (snapshot.data() as Map<String, dynamic>)['title'], date,
              (snapshot.data() as Map<String, dynamic>)['description'],
              (snapshot.data() as Map<String, dynamic>)['host'],
              beneficiaries, items);

        });
      }
    });
  }

  Future<DocumentSnapshot> _queryCurrentTrip() async {
    if(tripUUID != '') {
      DocumentSnapshot tempShot;
      await shoppingTripCollection.doc(tripUUID).get().then((docSnapshot) => tempShot=docSnapshot);
      print(tempShot.data());
      return tempShot;
    } else {
      return null;
    }
  }


  void auto_collapse(Item ignore){
    context.read<ShoppingTrip>().items.values.forEach((item) {
      setState(() {
        if(item != ignore)
          item.isExpanded = false;
      });
    });
  }



  Widget simple_item(Item item){
    String name = item.name;
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
            color: Theme.of(context).primaryColorDark,
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
      background: Container(color: Colors.red),
    );
  }



  Widget indie_item(String name, int number,StringVoidFunc callback){
    return Container(
      color: Theme.of(context).primaryColorLight,
      child: Row(
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
              child:
              NumberInputWithIncrementDecrement(
                initialValue: number,
                controller: TextEditingController(),
                onIncrement: (num newlyIncrementedValue) {
                  callback(name,newlyIncrementedValue);
                },
                onDecrement: (num newlyDecrementedValue) {
                  callback(name,newlyDecrementedValue);
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
        context.read<ShoppingTrip>().editItem(item.name,item.subitems.values.reduce((sum, element) => sum + element),item.subitems);
        // TODO update database here for quant
      });
    };
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Theme.of(context).primaryColorDark,
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
          context.read<ShoppingTrip>().items[context.read<ShoppingTrip>().items.keys.toList()[index]].isExpanded = !isExpanded;
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
          color: Colors.amberAccent
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
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
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
    }
  }

  @override
  Widget build(BuildContext context) {

    //full_list.add(host_uuid);
    return Masterlist(context);
  }

  Widget Masterlist(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Edit grocery items'),
        backgroundColor: const Color(0xFFbc5100),
        actions: <Widget>[
          PopupMenuButton<int>(
            onSelected: (item) => handleClick(item),
            itemBuilder: (context) => [
              PopupMenuItem<int>(value: 1, child: Text('Trip Settings')),
            ],
          ),
        ],
      ),

      body: SafeArea(
        child: Scrollbar(
          child: ListView(
            padding: const EdgeInsets.all(25),
            children: [
              SizedBox(
                height: 10,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Host',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  // TODO how to call watch
                  // Container(child: Text(context.watch<Cowboy>().first_name),),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      (context.watch<Cowboy>().firstName == null)?
                      CircularProgressIndicator():

                      Text(
                        // may show an old name if name has been updated extremely recently
                        '$hostFirstName',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Beneficiaries',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      for(String name in context.watch<ShoppingTrip>().beneficiaries)
                        Container(
                          child: Text(
                            '$name ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                        ),

                      //TODO: Add users to list of beneficiaries when + button is pressed
                      Container(
                          child: IconButton(icon: const Icon(Icons.add_circle))),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 60,
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
              //for(var key in cur_trip.items.keys.toList().reversed)
              //  single_item(cur_trip.items[key]),
              /*
              for(var key in frontend_list.keys.toList().reversed)
                single_item(frontend_list[key]),

               */
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 70,
                    width: 150,
                    child: RoundedButton(
                      onPressed: () {

                      },
                      title: "Master List",
                    ),
                  ),
                  Container(
                    height: 70,
                    width: 150,
                    child: RoundedButton(
                      onPressed: () {
                        //go master list page
                      },
                      title: "Personal List",
                    ),
                  )
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}