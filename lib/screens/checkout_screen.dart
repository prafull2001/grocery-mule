import 'package:flutter/material.dart';
import 'package:grocery_mule/components/rounded_ button.dart';
import 'package:grocery_mule/constants.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:grocery_mule/providers/shopping_trip_provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
  CollectionReference userCollection = FirebaseFirestore.instance.collection('paypal_users');
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
                  color: Colors.black
              ),
            );
        }
    );
  }
}

class PayPalButton extends StatefulWidget {
  late final String userUUID;
  PayPalButton(String userUUID){
    this.userUUID = userUUID;
  }

  @override
  _PayPalButtonState createState() => _PayPalButtonState();
}

class _PayPalButtonState extends State<PayPalButton>{
  late String userUUID;
  CollectionReference userCollection = FirebaseFirestore.instance.collection('paypal_users');
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //comment
                Container(
                  height: 70,
                  width: 150,
                  child: RoundedButton(
                    onPressed: () async {
                      String paypalStr = snapshot.data!['paypal'];
                      Uri paypal_link = Uri.parse(paypalStr);
                      if(await canLaunchUrl(paypal_link)){
                        launchUrl(paypal_link);
                      }
                    },
                    title: "PayPal",
                    color: Colors.amber,
                  ),
                ),

              ],
            );
        }
    );
  }
  }





class CheckoutScreen extends StatefulWidget {
  static String id = 'checkout_screen';

  @override
  _CheckoutScreen createState() => _CheckoutScreen();
}

class _CheckoutScreen extends State<CheckoutScreen> {
  Map<String, Map<String,int>> aggre_raw_list = {};
  Map<String, Map<String,int>> aggre_clean_list = {};
  Map<String, String> paypalLinks = {};
  CollectionReference tripCollection = FirebaseFirestore.instance.collection('paypal_shopping_trips');
  CollectionReference userCollection = FirebaseFirestore.instance.collection('paypal_users');
  late CollectionReference itemSubCollection;
  //map each bene uuid to their own map
  //@override
  void initState() {
    String tripUUID = context.read<ShoppingTrip>().uuid;
    itemSubCollection = tripCollection.doc(tripUUID).collection('items');

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
    // String name = uuid;//context.read<ShoppingTrip>().beneficiaries[uuid]!.split('|~|')[1].split(' ')[0];

    return Column(
        children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
            children: [
             UserName(uuid)
            ],
          ),
          if(aggre_raw_list[uuid]!.isNotEmpty)...[
          for (var entry in aggre_raw_list[uuid]!.entries)
            simple_item(entry.key, entry.value),
             if(context.read<Cowboy>().uuid != uuid)...[
               PayPalButton(uuid)
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     //comment
              //     Container(
              //       height: 70,
              //       width: 150,
              //       child: RoundedButton(
              //         onPressed: () {
              //         },
              //         title: "PayPal",
              //         color: Colors.amber,
              //       ),
              //     ),
              //
              //   ],
              // )
             ]

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
      body: StreamBuilder<QuerySnapshot>(
        stream: tripCollection.doc(context.read<ShoppingTrip>().uuid).collection('items').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> itemColQuery) {
          if (itemColQuery.hasError) {
            return const Text('Something went wrong');
          }
          if (itemColQuery.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          List<String> bene_uuid_list = context.read<ShoppingTrip>().beneficiaries;

          bene_uuid_list.forEach((bene_uuid) { // initialize empty bene mapping to aggre_cleaned_list
            aggre_raw_list[bene_uuid] = {};
          });
          itemColQuery.data!.docs.forEach((doc) {
            if(doc['uuid'] != 'dummy'){
              Map<String, dynamic> curSubitems = doc.get(FieldPath(['subitems'])); // get map of subitems for cur item
              curSubitems.forEach((key, value) { // add item name & quantity if user UUIDs match & quantity > 0
                if(curSubitems[key] > 0) {
                  dynamic curItemName = doc.get(FieldPath(['name']));
                  aggre_raw_list[key]![curItemName] = curSubitems[key];
                }
              });
            }
          });


          return ListView(
            padding: const EdgeInsets.all(25),
            children: [
              for (var entry in aggre_raw_list.entries)
                personalList(entry.key),
            ],
          );
        }
      ),
    );
  }

}