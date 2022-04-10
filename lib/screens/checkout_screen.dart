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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Checkout Screen'),
        backgroundColor: const Color(0xFFbc5100),
      ),

    );
  }

}