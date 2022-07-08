import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grocery_mule/constants.dart';
import 'package:grocery_mule/dev/collection_references.dart';
import 'package:grocery_mule/providers/shopping_trip_provider.dart';
import 'package:grocery_mule/screens/receipt_scanning.dart';
import 'package:grocery_mule/theme/colors.dart';
import 'package:grocery_mule/theme/text_styles.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/text_buttons.dart';

class UserName extends StatefulWidget {
  late final String userUUID;
  late final Color color;
  UserName(String userUUID, Color color) {
    this.userUUID = userUUID;
    this.color = color;
  }

  @override
  _UserNameState createState() => _UserNameState();
}

class _UserNameState extends State<UserName> {
  late String userUUID;
  @override
  void initState() {
    userUUID = widget.userUUID;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: userCollection.doc(userUUID).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          return Text(
            '${snapshot.data!['first_name']} ',
            style: TextStyle(fontSize: 20, color: widget.color),
          );
        });
  }
}

class PayPalButton extends StatefulWidget {
  late final String userUUID;
  PayPalButton(String userUUID) {
    this.userUUID = userUUID;
  }

  @override
  _PayPalButtonState createState() => _PayPalButtonState();
}

class _PayPalButtonState extends State<PayPalButton> {
  late String userUUID;
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('paypal_users');
  @override
  void initState() {
    userUUID = widget.userUUID;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: userCollection.doc(userUUID).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 10.h),
            child: RectangularTextIconButton(
                text: "PayPal",
                buttonColor: Colors.blueGrey,
                icon: Icon(FontAwesomeIcons.paypal),
                textColor: Colors.white,
                onPressed: () async {
                  String paypalStr = snapshot.data!['paypal'];
                  Uri paypal_link = Uri.parse(paypalStr);
                  if (await canLaunchUrl(paypal_link)) {
                    launchUrl(paypal_link);
                  }
                }),
          );
        });
  }
}

class ItemsPerPerson extends StatefulWidget {
  late final Map<String, double> itemPrices;
  late final String userUUID;
  late Map<String, int> itemMapping;
  late Map<String, int> itemUUIDMapping;
  int num_bene = 1;

  ItemsPerPerson(this.itemPrices, this.userUUID, this.itemMapping, this.itemUUIDMapping, this.num_bene, {required Key key})
      : super(key: key);
  @override
  _ItemsPerPersonState createState() => _ItemsPerPersonState();
}

class _ItemsPerPersonState extends State<ItemsPerPerson> {
  bool expand = false;
  double beneficiary_subtotal = 0;
  //@override
  void initState() {
    super.initState();

    // beneficiary_subtotal = calculate_total();
    // print(userUUID + ' total: ' + beneficiary_subtotal.toString());
  }

  double calculate_total() {

    double dp(double val, int places){
      num mod = pow(10.0, places);
      return ((val * mod).round().toDouble() / mod);
    }

    double total = 0;
    // print(userUUID + ' | ' + itemPrices.toString() + ' | '  + itemUUIDMapping.toString());
    // print(itemUUIDMapping.toString());
    if (widget.itemUUIDMapping.isNotEmpty) {
      widget.itemUUIDMapping.forEach((itemUUID, quantity) {
        double unitPrice = widget.itemPrices[itemUUID]!;
        double subTotal = unitPrice * quantity;
        total += subTotal;
      });
    } else {
      print('item map empty');
    }
    total += double.parse(widget.itemPrices['tax']!.toString()) / widget.num_bene;
    total += double.parse(widget.itemPrices['add. fees']!.toString()) / widget.num_bene;
    total = dp(total, 2);

    return total;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return personalList();
  }

  Widget simple_item(String item_name, int item_quantity) {
    String name = item_name;
    int quantity = item_quantity;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
      ),
      child: Column(children: [
        Card(
          elevation: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                child: Text('$name',
                    style: appFontStyle.copyWith(
                        fontSize: 16.sp, color: Colors.white)),
                padding: EdgeInsets.all(20),
              ),
              Container(
                child: Text('x$quantity',
                    style: appFontStyle.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget personalList() {
    return Card(
      key: Key(widget.userUUID),
      shape: RoundedRectangleBorder(
        // side: const BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 2.0),
        borderRadius: BorderRadius.circular(10.r),
      ),
      color: darkBrown,
      child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
              title: Container(
                child: UserName(widget.userUUID, Colors.white),
              ),
              children: <Widget>[
                if (widget.itemMapping.isNotEmpty) ...[
                  for (var entry in widget.itemMapping.entries)
                    simple_item(entry.key, entry.value),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RectangularTextButton(
                      text: 'Total Cost:  \$${calculate_total().toStringAsFixed(2)}',
                      onPressed: () {
                        beneficiary_subtotal = calculate_total();
                        Clipboard.setData(ClipboardData(text: beneficiary_subtotal.toString()));
                        Fluttertoast.showToast(msg: 'Price copied to clipboard!');
                      },
                    ),
                  ),
                  // TextButton(
                  //   style: ButtonStyle(
                  //       foregroundColor:
                  //           MaterialStateProperty.all<Color>(Colors.black),
                  //       backgroundColor:
                  //           MaterialStateProperty.all<Color>(orange)),
                  //   onPressed: () {
                  //     beneficiary_subtotal = calculate_total();
                  //     Clipboard.setData(
                  //         ClipboardData(text: beneficiary_subtotal.toString()));
                  //     Fluttertoast.showToast(msg: 'Price copied to clipboard!');
                  //   },
                  //   child: Text('\$' + '${calculate_total()}'),
                  // ),
                  if (widget.userUUID != context.read<ShoppingTrip>().host) ...[
                    PayPalButton(widget.userUUID)
                  ]
                ] else ...[
                  Container(
                    height: 40,
                    width: 400,
                    child: Column(children: [
                      Text('No items found',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400,
                          )),
                    ]),
                  )
                ],
              ])),
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  static String id = 'checkout_screen';

  @override
  _CheckoutScreen createState() => _CheckoutScreen();
}

class _CheckoutScreen extends State<CheckoutScreen> {
  Map<String, Map<String, int>> aggre_raw_list = {};
  Map<String, Map<String, int>> aggre_item_list = {};
  Map<String, Map<String, int>> aggre_clean_list = {};
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
        title: const Text(
          'Checkout Screen',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        backgroundColor: light_orange,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: tripCollection
              .doc(context.read<ShoppingTrip>().uuid)
              .collection('items')
              .snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> itemColQuery) {
            if (itemColQuery.hasError) {
              return const Text('Something went wrong');
            }
            if (itemColQuery.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            List<String> bene_uuid_list = context.read<ShoppingTrip>().beneficiaries;

            bene_uuid_list.forEach((bene_uuid) {
              // initialize empty bene mapping to aggre_cleaned_list
              aggre_raw_list[bene_uuid] = {};
              aggre_item_list[bene_uuid] = {};
            });
            itemColQuery.data!.docs.forEach((doc) {
              if (doc['uuid'] != 'tax' && doc['uuid'] != 'add. fees') {
                Map<String, dynamic> curSubitems = doc.get(FieldPath(['subitems'])); // get map of subitems for cur item
                //print('curSubitems: ' + curSubitems.toString());
                curSubitems.forEach((key, value) {
                  // add item name & quantity if user UUIDs match & quantity > 0
                  if (curSubitems[key] > 0) {
                    dynamic curItemName = doc.get(FieldPath(['name']));
                    dynamic curItemID = doc.get(FieldPath(['uuid']));
                    aggre_raw_list[key]![curItemName] = curSubitems[key];
                    aggre_item_list[key]![curItemID] =
                        curSubitems[key] = curSubitems[key];
                  }
                });
                itemPrices[doc['uuid']] = doc['price'] / doc['quantity'];
              } else {
                // print('price: ${double.parse(doc['price'].toString())} length: ${bene_uuid_list.length}');
                itemPrices[doc['uuid']] = double.parse(doc['price'].toString());
              }
            });

            // print('aggrelist: ' + aggre_raw_list.toString());
            // print('aggre_item_list: ' + aggre_item_list.toString());

            return Column(
              children: [
                SizedBox(
                  height: 10.0,
                ),
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: aggre_raw_list.length,
                  itemBuilder: (context, int index) {
                    return ItemsPerPerson(
                        itemPrices,
                        aggre_raw_list.keys.toList()[index],
                        aggre_raw_list[aggre_raw_list.keys.toList()[index]]!,
                        aggre_item_list[aggre_item_list.keys.toList()[index]]!,
                        bene_uuid_list.length,
                        key: Key(aggre_raw_list.keys.toList()[index]));
                  },
                ),
                GestureDetector(
                  onTap: () {Navigator.pushNamed(context, ReceiptScanning.id);},
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35.w),
                    child: RectangularTextIconButton(
                      text: "Receipt Scanning",
                      buttonColor: Colors.lightGreen,
                      icon: Icon(Icons.search_rounded),
                      textColor: Colors.white,
                      onPressed: () {},
                    ),
                  ),
                ),
                // Container(
                //   height: 70,
                //   width: 150,
                //   child: RoundedButton(
                //     onPressed: () {
                //       Navigator.pushNamed(context, ReceiptScanning.id);
                //     },
                //     title: "Receipt Scanning",
                //     color: Colors.blueAccent,
                //   ),
                // ),
              ],
            );
          }),
    );
  }
//,
}
