import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_mule/components/rounded_ button.dart';
import 'package:grocery_mule/constants.dart';
import 'dart:async';
import 'package:grocery_mule/screens/lists.dart';
import 'package:grocery_mule/classes/ListData.dart';
import 'package:grocery_mule/classes/data_structures.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
typedef StringVoidFunc = void Function(String,int);

class CreateListScreen extends StatefulWidget {
  static String id = 'create_list_screen';
  String uuid;
  String initTitle;
  String initDescription;
  DateTime initDate;

  //createList has the ids
  //when createList has a list that's already filled
  //keep a field of the original id, but generate a new id
  //in the return variable
  CreateListScreen(ShoppingTrip trip) {
    initTitle = trip.title;
    initDescription = trip.description;
    initDate = trip.date;
    uuid = trip.uuid;
    print("createlist.dart constructor (uuid): "+uuid);
  }

  @override
  _CreateListsScreenState createState() => _CreateListsScreenState();
}
class Item_front_end {
  int expand;
  Map<String,int> quantity;
  String food;
  int id;
  Item_front_end(int id,String name,List<String> users){  //pass in list of beneficiaries, food
    expand = 0;
    quantity = {};
    users.forEach((element) {quantity[element] = 0;});
    //quantity = {'Harry':0,'Praf':0,'Dhruv':0};
    food = name;
    this.id = id;
  }
}
class _CreateListsScreenState extends State<CreateListScreen> {
  String tripTitle;
  String tripDescription;
  DateTime tripDate;
  String trip_id;
  var _tripTitleController;
  var _tripDescriptionController;
  final String userID = FirebaseAuth.instance.currentUser.uid;
  Map<int,Item_front_end> grocery_list = {};
  List<String> users = [];
  static int item_id = 1;
  bool isAdd = false;
  bool delete_list = false;
  Future<void> delete(String tripID) async{
    await FirebaseFirestore.instance
        .collection('shopping_trips_test')
        .doc(tripID)
        .delete()
        .then((value) => print('deleted'))
        .catchError((error)=>print("failed"))
    ;

  }
  @override
  void initState() {
    // TODO: implement initState
    _tripTitleController = TextEditingController()..text = widget.initTitle;
    _tripDescriptionController = TextEditingController()..text = widget.initDescription;
    trip_id = widget.uuid;
    tripTitle =  widget.initTitle;
    tripDescription = widget.initDescription;
    tripDate = widget.initDate;
    users.add(FirebaseAuth.instance.currentUser.displayName);
    //test code
    users.add("Praf");
    users.add("Dhruv");
    grocery_list = {0:new Item_front_end(0,"apple",users)};

    //end test code
    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: tripDate,
        firstDate: DateTime(2021),
        lastDate: DateTime(2050),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light().copyWith(
                primary: const Color(0xFFbc5100),
              ),
            ),
            child: child,
          );
        }
    );
    if (picked != null && picked != tripDate)
      setState(() {
        tripDate = picked;
      });
  }
  void add_beneficiary(String name){
    if(!users.contains(name))
      setState(() {
        users.add(name);
        //update backend here
      });
    else
      print("beneficary already exists");
  }
  void delete_beneficiary(String name){
    if(!users.contains(name))
      setState(() {
        users.remove(name);
        //update backend here
      });
  }
  void add_item(String food){
    Item_front_end new_item = new Item_front_end(item_id,food,users);
    if(grocery_list[item_id] == null) {
      setState(() {
        grocery_list[item_id] = new_item;
        item_id++;
        //update backend here
      });
    }
    else
      print("item already exists");
  }

  void delete_item(int id){

    if(grocery_list[id] != null) {
      setState(() {
        grocery_list.remove(id);
        //update backend here
      });
    }

  }
  Widget simple_item(Item_front_end item){
    String food = item.food;
    int quantity = 0;
    item.quantity.forEach((key, value) {
      quantity = quantity + value;
    });

    return Dismissible(
      key: Key(item.food),
      onDismissed: (direction) {
        // Remove the item from the data source.
        setState(() {
          delete_item(item.id);
        });
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
          color: Colors.amberAccent
        ),

        child: (
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              child: Text(
                '$food',
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
            Container(
                child: IconButton(
                    icon: const Icon(Icons.expand_more_sharp),
                    onPressed:
                        () =>(
                        setState(() { item.expand = 1;}))
                )
            ),
          ],
        )),
      ),
      background: Container(color: Colors.red),
    );
  }

  Widget indie_item(String name, int number,StringVoidFunc callback){
    return Container(
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

  Widget expanded_item(Item_front_end item){
    String food = item.food;
    int quantity = 0;
    item.quantity.forEach((key, value) {
      quantity = quantity + value;
    });
    void updateUsrQuantity(String name, int number){
      setState(() {
        item.quantity[name] = number;
      });
    };
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.amberAccent
      ),

      child: Column(
        children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  child: Text(
                    '$food',
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
                Container(
                    child: IconButton(
                        icon: const Icon(Icons.expand_less_sharp),
                      onPressed:
                        () =>(
                        setState(() {item.expand = 0;}))
                    )
                ),
              ],
            ),
          for(var entry in item.quantity.entries)
            indie_item(entry.key,entry.value,updateUsrQuantity)
        ],
      ),
    );
  }
  Widget single_item(Item_front_end test){

    return (
        (test.expand == 1)?expanded_item(test)
        : simple_item(test)
    );
  }

  Widget create_item(){
     String food = '';
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
                                add_item(food);
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
  @override
  Widget build(BuildContext context) {
    String host = users[0];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Create List'),
        backgroundColor: const Color(0xFFbc5100),
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
                          'List Name',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          child: TextField(
                              keyboardType: TextInputType.text,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black),
                              controller: _tripTitleController,
                              onChanged: (value){
                                tripTitle = value;
                              }

                          ),
                        )
                      ],
                    )
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
                        'Date of Trip',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("${tripDate.toLocal()}".split(' ')[0]),
                      SizedBox(
                        height: 20.0,
                      ),
                      RoundedButton(
                        onPressed: () => _selectDate(context),
                        title: 'Select Date',
                      ),
                    ],
                  ),
                ]),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          child: TextField(
                              keyboardType: TextInputType.emailAddress,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black),
                              controller: _tripDescriptionController,
                              onChanged: (value){
                                tripDescription = value;
                              }
                          ),
                        )
                      ],
                    )
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
                          'Host',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '$host',
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
                        for(String name in users)
                          if(name != users[0])
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
                for(var key in grocery_list.keys)
                  single_item(grocery_list[key]),
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
                Container(
                  height: 70,
                  width: 5,
                  child: RoundedButton(
                    onPressed: () {
                      if(tripTitle != '') {
                        var shopping_trip = new ShoppingTrip(tripTitle, tripDate, tripDescription, userID, []);
                        shopping_trip.uuid = trip_id;
                        // print("createlist.dart method (uuid): "+shopping_trip.uuid);
                        // final listData = ListData(tripTitle, tripDescription, tripDate, trip_id);
                        Navigator.pop(context, shopping_trip);
                      }else{
                        print("triggered");
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("List name cannot be empty"),
                              actions: [
                                TextButton(
                                  child: Text("OK"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    title: "Create/Update List",
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 70,
                  width: 150,
                  child: RoundedButton(
                    onPressed: () async {
                      await check_delete(context);
                      if(delete_list) {
                        delete(trip_id);
                        Navigator.pop(context);
                      }
                    },
                    title: "Delete List",
                  ),
                )
              ],
            ),
        ),
      ),
    );
  }

  check_delete(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure you wish to delete this item?"),
          actions: <Widget>[
            FlatButton(
                onPressed: () => {
                  delete_list = true,
                  Navigator.of(context).pop(),
                  },
                child: const Text("DELETE")
            ),
            FlatButton(
              onPressed: () => {
                delete_list = false,
                Navigator.of(context).pop(),

              },
              child: const Text("CANCEL"),
            ),
          ],
        );
      },
    );
  }
}