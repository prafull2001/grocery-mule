// @dart=2.9
import 'package:flutter/material.dart';
import 'package:grocery_mule/components/rounded_ button.dart';
import 'package:grocery_mule/constants.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:grocery_mule/providers/shopping_trip_provider.dart';

class CheckoutScreen extends StatefulWidget {
  static String id = 'checkout_screen';

  @override
  _CheckoutScreen createState() => _CheckoutScreen();
}

class _CheckoutScreen extends State<CheckoutScreen> {
  Map<String, Item> list_items;
  Map<String, int> item_list;
  Map<String, Map<String,int>> aggre_cleaned_list;
  //map each bene uuid to their own map
  @override
  void initState() {
    list_items = context.read<ShoppingTrip>().items;
    aggre_cleaned_list = {};
    context.read<ShoppingTrip>().beneficiaries.keys.forEach((uuid){
      aggre_cleaned_list[uuid] = {};
    });
    list_items.forEach((key, item) {
      //iterate through each subitem in the item
      context.read<ShoppingTrip>().beneficiaries.keys.forEach((uuid) {
        if(item.subitems[uuid] > 0) {
          aggre_cleaned_list[uuid][key] = item.subitems[uuid];
        }
      });
    });
    print('aggregate list');
    print(aggre_cleaned_list);
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
  Widget personalList(String uuid){
    String name =  context.read<ShoppingTrip>().beneficiaries[uuid];
    return Column(
        children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('$name',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400,
              )
              ),
            ],
          ),
          if(aggre_cleaned_list[uuid].isNotEmpty)...[
          for (var entry in aggre_cleaned_list[uuid].entries)
            simple_item(entry.key, entry.value),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //comment
                Container(
                  height: 70,
                  width: 150,
                  child: RoundedButton(
                    onPressed: () {
                    },
                    title: "Paypal",
                  ),
                ),

              ],
            )
          ]else...[
            Container(
              height: 40,
              width: 400,

              child: Column(
                  children: [
                  Text('No items found',
                    style: TextStyle(
                      color: Colors.red,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
                    )
                    ),
                  ]
              ),
            )
          ]
        ]
    );

  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Checkout Screen'),
        backgroundColor: light_orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(25),
        children: [
          for (var entry in aggre_cleaned_list.entries)
            personalList(entry.key),
        ],
      ),
    );
  }

}