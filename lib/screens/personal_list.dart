import 'package:flutter/material.dart';
import 'package:grocery_mule/components/rounded_ button.dart';
import 'package:grocery_mule/constants.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:grocery_mule/providers/shopping_trip_provider.dart';

class PersonalListScreen extends StatefulWidget {
  static String id = 'personallist_screen';

  @override
  _PersonalListScreen createState() => _PersonalListScreen();
}

class _PersonalListScreen extends State<PersonalListScreen> {
  String hostFirstName;

  @override
  void initState() {
    hostFirstName = context.read<Cowboy>().firstName;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Personal List'),
        backgroundColor: const Color(0xFFbc5100),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
            children: <Widget>[
              SizedBox(
                height: 30.0,
              ),
              Text(
                  '$hostFirstName\'s List',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                  ),
              ),
            ]
        ),
      ),
    );
  }
}

