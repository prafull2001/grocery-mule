import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_mule/components/rounded_ button.dart';
import 'package:grocery_mule/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:grocery_mule/screens/paypal_link.dart';
import 'package:provider/provider.dart';
import 'package:grocery_mule/screens/confirm_email.dart';
import 'package:grocery_mule/screens/lists.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late String email;
  late String password;
  late String firstName;
  late String lastName;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text(
                  'Nice to meet you!',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30.0,
            ),
            Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r)),
                color: appColorLight,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                    onChanged: (value) {
                      email = value;
                    },
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.alternate_email_sharp,
                          color: appOrange,
                        ),
                        hintText: 'Email Address',
                        hintStyle: appFontStyle),
                  ),
                )),
            SizedBox(
              height: 8.0,
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r)),
              color: appColorLight,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                child: TextField(
                    textAlign: TextAlign.center,
                    obscureText: true,
                    onChanged: (value) {
                      password = value;
                    },
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.password,
                          color: appOrange,
                        ),
                        hintText: 'Account Password',
                        hintStyle: appFontStyle)),
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r)),
                color: appColorLight,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                  child: TextField(
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      firstName = value;
                    },
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.supervised_user_circle,
                          color: appOrange,
                        ),
                        hintText: 'First Name',
                        hintStyle: appFontStyle),
                  ),
                )),
            SizedBox(
              height: 8.0,
            ),
            Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r)),
                color: appColorLight,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                  child: TextField(
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      lastName = value;
                    },
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.supervised_user_circle_outlined,
                          color: appOrange,
                        ),
                        hintText: 'Last Name',
                        hintStyle: appFontStyle),
                  ),
                )),
            SizedBox(
              height: 24.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
              child: RoundedButton(
                  title: 'Register',
                  color: appOrange,
                  onPressed: () async {
                    try {
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      userCredential.user!.updateDisplayName(firstName);
                      if (userCredential != null) {
                        print(email + ' ' + firstName + ' ' + lastName);
                        context.read<Cowboy>().initializeCowboy(
                            userCredential.user?.uid,
                            firstName,
                            lastName,
                            email);
                        await Navigator.pushNamed(
                            context, ConfirmEmailScreen.id);
                        // await DatabaseService(uuid: new_cowboy.uuid).initializeUserData(new_cowboy);

                        Navigator.pop(context);
                        //Navigator.pushNamed(context, ListsScreen.id);
                        Navigator.pushNamed(context, PayPalPage.id);
                      }
                    } on FirebaseAuthException catch (e) {
                      print(e);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(e.message!),
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
                      print(e);
                    }
                  }),
            ),
            SizedBox(
              height: 24.0,
            ),
          ],
        ),
      ),
    );
  }
}
