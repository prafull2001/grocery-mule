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

class _CreateListsScreenState extends State<CreateListScreen> {
  String tripTitle;
  String tripDescription;
  DateTime tripDate;
  String trip_id;
  var _tripTitleController;
  var _tripDescriptionController;
  final String userID = FirebaseAuth.instance.currentUser.uid;


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

  Widget simple_item(){
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
              'Apple',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            padding: EdgeInsets.all(20),
          ),
          Container(
            child: Text(
              'x7',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ),
          Container(
              child: IconButton(
                  icon: const Icon(Icons.expand_more_sharp)
              )
          ),
        ],
      )),
    );
  }
  Widget quant(){
    return NumberInputWithIncrementDecrement(
      controller: TextEditingController(),
    );
  }
  Widget indie_item(){
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            child: Text(
            'Harry',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              ),
            ),
            padding: EdgeInsets.all(20),
          ),
          Container(
            child: quant(),
            padding: EdgeInsets.all(20),
          ),
        ]
      ),
    );
  }
  Widget expanded_item(){
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
                    'Apple',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                  padding: EdgeInsets.all(20),
                ),
                Container(
                  child: Text(
                    'x7',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ),
                Container(
                    child: IconButton(
                        icon: const Icon(Icons.expand_less_sharp)
                    )
                ),
              ],
            ),
         // indie_item(),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
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
                          'PS',
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
                        Container(
                          child: Text(
                            'DJ AT VP',
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
                            icon: const Icon(Icons.add_circle)
                        )
                    ),
                  ],
                ),
                simple_item(),
                expanded_item(),
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
                    onPressed: () {
                      delete(trip_id);
                      Navigator.pop(context);
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
}