import 'package:flutter/material.dart';
import 'package:grocery_mule/components/rounded_ button.dart';
import 'package:grocery_mule/constants.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:grocery_mule/providers/shopping_trip_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'lists.dart';

class PayPalPage extends StatefulWidget{
  static String id = 'paypal_page';


  @override
  _PayPalPageSate createState() => _PayPalPageSate();
}

// TODO: make link button visitable and add image with example PayPal.me screen

class _PayPalPageSate extends State<PayPalPage>{
  String paypal_link = '';
  bool link_valid = false;

  void checkStringValidity(String input){
    String paypal_prefix = "https://www.paypal.com/paypalme/";

    if (input.startsWith(paypal_prefix) && input.length > 32) {
      link_valid = true;
      setState(() {});
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Link is valid!'),
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
    } else {
      link_valid = false;
      setState(() {});
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Please enter a valid PayPal.me link.'),
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
      // display alert dialog here
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Add PayPal.me Link'),
        backgroundColor: light_orange,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 30.0,
            ),
            Image(
              image: AssetImage('images/paypal_example.png'),
            ),
            SizedBox(
              height: 30.0,
            ),
            Flexible(
              child: Text(
                'Please add your full \'https\' PayPal.me link to your profile!',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
              onChanged: (value) {
                paypal_link = value;
              },
            ),
            SizedBox(
              height: 24.0,
            ),
            RoundedButton(
                title: 'Add Paypal Link',
                color: Colors.blueAccent,
                onPressed: () {
                  if(paypal_link != ''){
                    checkStringValidity(paypal_link);
                  } else {
                    setState(() {});
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('This field cannot be empty!'),
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
                }
            ),
            if(link_valid)...[
              RoundedButton(
                  title: 'Finish Login',
                  color: Colors.blueAccent,
                  onPressed: () async{
                    Uri link = Uri.parse(paypal_link);
                    print(link);
                    // if(await canLaunchUrl(link)){
                    //   print('About to launch $link');
                    //   await launchUrl(link);
                    // }
                    context.read<Cowboy>().updateCowboyPaypal(paypal_link);
                    Navigator.pushNamed(context, ListsScreen.id);
                  }
              )
            ]
          ],
        ),
      ),
    );
  }

}
