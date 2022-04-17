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
  Map<String, Item> list_items;
  Map<String, int> item_list;
  Map<String, int> cleaned_list;

  @override
  void initState() {
    hostFirstName = context.read<Cowboy>().firstName;
    list_items = context.read<ShoppingTrip>().items;
    cleaned_list = <String, int>{};

    list_items.forEach((key, item) {
      Item curItem = item;
      if(item.subitems[context.read<Cowboy>().uuid] > 0) {
        cleaned_list[key] = item.subitems[context.read<Cowboy>().uuid];
      }
    });
  }

  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Personal List'),
        backgroundColor: light_orange,
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
              SizedBox(
                height: 30.0,
              ),
              if(!(cleaned_list.isEmpty))...[
                for (var entry in cleaned_list.entries)
                  simple_item(entry.key, entry.value)
              ] else ...[
                SizedBox(
                  height: 70.0,
                ),

                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        'Your personal list will appear once you\'ve added items to your list!',
                        style: TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ]
          ]
        ),
      ),
    );
  }

  Widget simple_item(String item_name, int item_quantity){
    String name = item_name;
    int quantity = item_quantity;


    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: dark_beige,
      ),
      child: Column(
        children: [
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
            ),
          Container(
            height: 2.5,
            width: 400,
            color: Colors.white,
          ),
      ]
      ),
    );
  }
}

