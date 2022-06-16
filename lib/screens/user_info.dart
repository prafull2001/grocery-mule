import 'package:flutter/material.dart';
import 'package:grocery_mule/components/rounded_ button.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class UserInfoScreen extends StatefulWidget {
  static String id = 'userinfo_screen';

  @override
  _UserInfoScreenScreenState createState() => _UserInfoScreenScreenState();
}

class _UserInfoScreenScreenState extends State<UserInfoScreen> {
  late String email;
  late String firstName;
  late String lastName;
  late String payPal;

  FirebaseAuth auth = FirebaseAuth.instance;
  final User? curUser = FirebaseAuth.instance.currentUser;

  bool checkPaypalValidity(String input){
    String paypal_prefix = "https://www.paypal.com/paypalme/";

    if (input.startsWith(paypal_prefix) && input.length > 32) {
      return true;
    } else {
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
    }
    return false;
  }


  @override
  Widget build(BuildContext context) {
    final CollectionReference userCollection = FirebaseFirestore.instance.collection('paypal_users');

    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
          future: userCollection.doc(curUser?.uid).get(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
            String prevEmail;
            String prevFirst;
            String prevLast;
            String prevPaypal;
            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> data = snapshot.data?.data() as Map<String, dynamic>;
              prevEmail = data['email'];
              prevFirst = data['first_name'];
              prevLast = data['last_name'];
              prevPaypal = data['paypal'];
              email = prevEmail;
              firstName = prevFirst;
              lastName = prevLast;
              payPal = prevPaypal;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(
                      height: 30.0,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                      initialValue: prevEmail,
                      onChanged: (value) {
                        email = value;
                      },
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    TextFormField(
                      textAlign: TextAlign.center,
                      initialValue: prevFirst,
                      onChanged: (value) {
                        firstName = value;
                      },
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    TextFormField(
                      textAlign: TextAlign.center,
                      initialValue: prevLast,
                      onChanged: (value) {
                        lastName = value;
                      },
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                    TextFormField(
                      textAlign: TextAlign.center,
                      initialValue: prevPaypal,
                      onChanged: (value) {
                        payPal = value;
                      },
                      style: TextStyle(color: Colors.black),
                    ),
                    RoundedButton(
                        title: 'Update User Info',
                        color: Colors.blueAccent,
                        onPressed: ()
                        async {
                          if(checkPaypalValidity(payPal)){
                            try {
                              context.read<Cowboy>().fillUpdatedInfo(firstName, lastName, email, payPal);
                              print('moving to lists screen');
                              Navigator.pop(context);
                            }  catch (e) {
                              print(e);
                            }
                          }
                        }
                    )
                  ],
                ),
              );

            }
            return CircularProgressIndicator();

          }
      ),
    );
  }
}
