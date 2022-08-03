import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_mule/components/rounded_ button.dart';
import 'package:grocery_mule/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_mule/screens/confirm_email.dart';
import 'package:grocery_mule/screens/lists.dart';
import 'package:grocery_mule/theme/text_styles.dart';

import '../components/text_fields.dart';
import '../theme/colors.dart';

class ReauthScreen extends StatefulWidget {
  static String id = 'reauth_screen';

  @override
  _ReauthScreenState createState() => _ReauthScreenState();
}

class _ReauthScreenState extends State<ReauthScreen> {
  late String email;
  late String password;
  final _auth = FirebaseAuth.instance;
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Please Reauthenticate',
              style: appFontStyle.copyWith(
                  color: Colors.black,
                  fontSize: 25.sp,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 48.0,
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r)),
              color: appColorLight,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                child: TextField(
                  style: appFontStyle,

                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.alternate_email_outlined,
                        color: appOrange,
                      ),
                      hintText: 'Enter your email',
                      hintStyle: appFontStyle),

                ),
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
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                child: TextField(
                  style: appFontStyle,
                  textAlign: TextAlign.center,
                  obscureText: true,
                  onChanged: (value) {
                    password = value;
                  },
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.password,
                        color: appOrange,
                      ),
                      hintText: 'Enter your password',
                      hintStyle: appFontStyle),
                ),
              ),
            ),

            SizedBox(
              height: 24.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
              child: RoundedButton(
                title: 'Reauthenticate',
                color: appOrange,
                onPressed: () async {
                  Navigator.pop(context, [email, password]);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
