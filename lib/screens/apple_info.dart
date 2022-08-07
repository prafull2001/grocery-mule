import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grocery_mule/components/header.dart';
import 'package:grocery_mule/components/rounded_ button.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:grocery_mule/screens/paypal_link.dart';
import 'package:grocery_mule/theme/colors.dart';
import 'package:grocery_mule/theme/text_styles.dart';
import 'package:provider/provider.dart';

class AppleInfoScreen extends StatefulWidget {
  static String id = 'apple_info_screen';

  @override
  _AppleInfoScreenState createState() => _AppleInfoScreenState();
}

class _AppleInfoScreenState extends State<AppleInfoScreen> {
  late String email;
  late String firstName;
  late String lastName;
  String payPal = "";

  FirebaseAuth auth = FirebaseAuth.instance;
  final User? curUser = FirebaseAuth.instance.currentUser;

  bool checkField(String firstname, String lastname, String email) {
    bool flag = true;
    if (firstname == '') {
      Fluttertoast.showToast(msg: 'Name cannot be empty');
      flag = false;
    } else if (firstname.length < 3) {
      Fluttertoast.showToast(
          msg: 'First name must be at least 3 characters long');
      flag = false;
    } else if (email == '') {
      Fluttertoast.showToast(msg: 'Email cannot be empty');
      flag = false;
    } else if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email)) {
      Fluttertoast.showToast(msg: 'Email is not valid');
      flag = false;
    }
    if (lastName == '') {
      Fluttertoast.showToast(msg: 'Warning: last name is empty');
    }
    return flag;
  }

  @override
  Widget build(BuildContext context) {
    email = '';
    firstName = '';
    lastName = '';

    return Scaffold(
      body: Padding(
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
              initialValue: '',
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
                ),
                hintText: 'First Last',
              ),
              textAlign: TextAlign.center,
              initialValue: '',
              onChanged: (value) {
                List<String> names = value.trim().split(' ');
                if (value.isEmpty) {
                  firstName = '';
                } else if (names.length == 1) {
                  firstName = names[0].trim();
                  lastName = '';
                } else {
                  firstName = names[0].trim();
                  lastName = names[1].trim();
                }
              },
              style: appFontStyle,
            ),
            SizedBox(
              height: 8.0,
            ),
            RoundedButton(
                title: 'Set User Info',
                color: appOrange,
                onPressed: () async {
                  if ((checkField(firstName, lastName, email))) {
                    try {
                      context
                          .read<Cowboy>()
                          .fillUpdatedInfo(firstName, lastName, email, payPal);
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, PayPalPage.id);
                    } catch (e) {
                      print(e);
                    }
                  }
                })
          ],
        ),
      ),
    );
  }
}
