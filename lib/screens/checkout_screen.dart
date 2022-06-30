import 'package:flutter/material.dart';
import 'package:grocery_mule/components/rounded_ button.dart';
import 'package:grocery_mule/constants.dart';
import 'package:grocery_mule/screens/receipt_scanning.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:grocery_mule/providers/shopping_trip_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:grocery_mule/dev/collection_references.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';



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

class ItemsPerPerson extends StatefulWidget{
  late final Map<String, double> itemPrices;
  late final String userUUID;
  late Map<String,int> itemMapping;
  late Map<String,int> itemUUIDMapping;

  ItemsPerPerson(this.itemPrices, this.userUUID, this.itemMapping,this.itemUUIDMapping, { required Key key}): super(key: key);
  @override
  _ItemsPerPersonState createState() => _ItemsPerPersonState();
}

class _ItemsPerPersonState extends State<ItemsPerPerson>{
  late Map<String, double> itemPrices;
  late final String userUUID;
  late Map<String,int> itemMapping;
  late Map<String,int> itemUUIDMapping;
  bool expand = false;
  double beneficiary_subtotal = 0;
  //@override
  void initState() {
    itemPrices = widget.itemPrices;
    userUUID = widget.userUUID;
    itemMapping = widget.itemMapping;
    itemUUIDMapping = widget.itemUUIDMapping;
    super.initState();

    // beneficiary_subtotal = calculate_total();
    // print(userUUID + ' total: ' + beneficiary_subtotal.toString());
  }

  double calculate_total(){
    double total = 0;
    //print(userUUID + ' | ' + itemPrices.toString() + ' | '  + itemUUIDMapping.toString());
    // print(itemUUIDMapping.toString());
    if(itemUUIDMapping.isNotEmpty){
      print('item map not empty: ' + itemUUIDMapping.toString());
      itemUUIDMapping.forEach((itemUUID, quantity) {
        double unitPrice = itemPrices[itemUUID]!;
        double subTotal = unitPrice * quantity;
        total += subTotal;
      });
    } else {
      print('item map empty');
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return personalList();
  }

  Widget simple_item(String item_name, int item_quantity){
    String name = item_name;
    int quantity = item_quantity;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,

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
          ]
      ),
    );
  }

  Widget personalList() {
    return Card(
      key: Key(userUUID),
      shape: RoundedRectangleBorder(
        side: const BorderSide(
            color: Color.fromARGB(255, 0, 0, 0), width: 2.0),
        borderRadius: BorderRadius.circular(30.0),
      ),
      color: Colors.blueGrey[400],
      child: Theme(
        data: Theme.of(context)
            .copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Container(
            child: UserName(userUUID),
          ),
          children: <Widget>[
            if(itemMapping.isNotEmpty)...[
              for (var entry in itemMapping.entries)
                simple_item(entry.key, entry.value),
              TextButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                  backgroundColor: MaterialStateProperty.all<Color>(orange)
                ),
                onPressed: () {
                  beneficiary_subtotal = calculate_total();
                  print(beneficiary_subtotal);
                  Clipboard.setData(ClipboardData(text: beneficiary_subtotal.toString()));
                  Fluttertoast.showToast(msg: 'Price copied to clipboard!');
                },
                child: Text('\$' + '${calculate_total()}'),
              ),
              if(userUUID!= context.read<ShoppingTrip>().host)...[
                PayPalButton(userUUID)
              ]
            ]else...[
              Container(
                height: 40,
                width: 400,

                child: Column(
                    children: [
                    Text('No items found',
                      style: TextStyle(
                        color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w400,
                      )
                      ),
                    ]
                ),
              )
            ],

          ])
        ),
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
  Map<String, Map<String,int>> aggre_item_list = {};
  Map<String, Map<String,int>> aggre_clean_list = {};
  Map<String, String> paypalLinks = {};
  Map<String, double> itemPrices = {};
  Map<String, dynamic> beneItems = {};

  late CollectionReference itemSubCollection;
  //map each bene uuid to their own map
  //@override
  void initState() {
    String tripUUID = context.read<ShoppingTrip>().uuid;
    itemSubCollection = tripCollection.doc(tripUUID).collection('items');
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Checkout Screen',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
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
            aggre_item_list[bene_uuid] = {};
          });
          itemColQuery.data!.docs.forEach((doc) {
            if(doc['uuid'] != 'dummy'){
              Map<String, dynamic> curSubitems = doc.get(FieldPath(['subitems'])); // get map of subitems for cur item
              //print('curSubitems: ' + curSubitems.toString());
              curSubitems.forEach((key, value) { // add item name & quantity if user UUIDs match & quantity > 0
                if(curSubitems[key] > 0) {
                  dynamic curItemName = doc.get(FieldPath(['name']));
                  dynamic curItemID = doc.get(FieldPath(['uuid']));
                  aggre_raw_list[key]![curItemName] = curSubitems[key];
                  aggre_item_list[key]![curItemID] = curSubitems[key] = curSubitems[key];
                }
              });
              itemPrices[doc['uuid']] = doc['price']/doc['quantity'];
            }
          });

          // print('aggrelist: ' + aggre_raw_list.toString());
          // print('aggre_item_list: ' + aggre_item_list.toString());

          return
            Column(
              children: [
                SizedBox(
                  height: 10.0,
                ),
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: aggre_raw_list.length,
                  itemBuilder: (context, int index){
                    return ItemsPerPerson(itemPrices, aggre_raw_list.keys.toList()[index],aggre_raw_list[aggre_raw_list.keys.toList()[index]]!,
                        aggre_item_list[aggre_item_list.keys.toList()[index]]!, key: Key(aggre_raw_list.keys.toList()[index]));
                  },
                ),
                Container(
                  height: 70,
                  width: 150,
                  child: RoundedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, ReceiptScanning.id);
                    },
                    title: "Receipt Scanning",
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            );
        }
      ),
    );
  }
//,
}