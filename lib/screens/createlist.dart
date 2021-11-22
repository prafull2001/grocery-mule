import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_shopper/components/rounded_ button.dart';
import 'package:smart_shopper/constants.dart';
import 'dart:async';
import 'package:smart_shopper/screens/lists.dart';
import 'package:smart_shopper/classes/ListData.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateListScreen extends StatefulWidget {
  static String id = 'create_list_screen';
  String initTitle;
  String initDescription;
  DateTime initDate;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  String unique_id;

  //creatList has the ids
  //when creatlist has a list that's aleady filled
  //keep a field of the original id, but generate a new id
  //in the return variable
  CreateListScreen(ListData data){
    if(data == null){
      initTitle = "";
      initDescription = "";
      initDate = DateTime.now();
      String dateID = dateFormat.format(DateTime.now());
      unique_id = "LISTID:" + dateID.replaceAll(' ', '');
      //we are creating new list
    } else {
      initTitle = data.name;
      initDescription = data.description;
      initDate = data.date;
      unique_id = data.unique_id;
      //if the data already exits, then we are just updating it
    }
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
  final String userID = FirebaseAuth.instance.currentUser.email;

  Future<void> delete(String listId) async{
    print(listId);
    await FirebaseFirestore.instance
        .collection('users_test')
        .doc(userID)
        .collection('shopping_trips')
        .doc(listId)
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
    tripTitle =  widget.initTitle;
    tripDescription = widget.initDescription;
    tripDate = widget.initDate;
    trip_id = widget.unique_id;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Create List'),
      ),
      body: SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
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
              Container(
                height: 70,
                width: 150,
                child: RoundedButton(
                  onPressed: () {
                    final listData = ListData(tripTitle, tripDescription, tripDate, trip_id);
                    Navigator.pop(context, listData);
                  },
                  title: "Create List",
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
    );
  }
}