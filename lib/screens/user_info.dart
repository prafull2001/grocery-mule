import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grocery_mule/components/header.dart';
import 'package:grocery_mule/components/rounded_ button.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:grocery_mule/theme/colors.dart';
import 'package:grocery_mule/theme/text_styles.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:grocery_mule/dev/collection_references.dart';

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

  bool checkPaypalValidity(String input) {
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
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
          future: userCollection.doc(curUser?.uid).get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            String prevEmail;
            String prevFirst;
            String prevLast;
            String prevPaypal;
            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> data =
                  snapshot.data?.data() as Map<String, dynamic>;
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
                    HomeHeader2(title: "Edit Information"),
                    SizedBox(
                      height: 50.h,
                    ),
                    Center(
                      child: Icon(
                        FontAwesomeIcons.userGroup,
                        color: appOrange,
                        size: 80.h,
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.email,
                          color: Colors.blueGrey,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: appOrange,
                            width: 1.0,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.center,
                      style: appFontStyle,
                      initialValue: prevEmail,
                      onChanged: (value) {
                        email = value;
                      },
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: appOrange,
                              width: 1.0,
                            ),
                          ),
                          icon: Icon(
                            FontAwesomeIcons.userLarge,
                            color: appOrange,
                          )),
                      textAlign: TextAlign.center,
                      initialValue: prevFirst,
                      onChanged: (value) {
                        firstName = value;
                      },
                      style: appFontStyle,
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    // TextFormField(
                    //      decoration: InputDecoration(
                    //       icon: Icon(
                    //     Icons.email,
                    //     color: appOrange,
                    //   )),
                    //   textAlign: TextAlign.center,
                    //   initialValue: prevLast,
                    //   onChanged: (value) {
                    //     lastName = value;
                    //   },
                    //   style: TextStyle(color: Colors.black),
                    // ),
                    // SizedBox(
                    //   height: 24.0,
                    // ),
                    TextFormField(
                      decoration: InputDecoration(
                        icon: Icon(
                          FontAwesomeIcons.paypal,
                          color: Color(0xff002069),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: appOrange,
                            width: 1.0,
                          ),
                        ),
                      ),
                      textAlign: TextAlign.center,
                      initialValue: prevPaypal,
                      onChanged: (value) {
                        payPal = value;
                      },
                      style: appFontStyle,
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    RoundedButton(
                        title: 'Update User Info',
                        color: appOrange,
                        onPressed: () async {
                          if (checkPaypalValidity(payPal)) {
                            try {
                              context.read<Cowboy>().fillUpdatedInfo(
                                  firstName, lastName, email, payPal);
                              print('moving to lists screen');
                              Navigator.pop(context);
                            } catch (e) {
                              print(e);
                            }
                          }
                        })
                  ],
                ),
              );
            }
            return CircularProgressIndicator();
          }),
    );
  }
}
