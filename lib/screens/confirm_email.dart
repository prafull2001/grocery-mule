import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grocery_mule/theme/text_styles.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../providers/cowboy_provider.dart';

class ConfirmEmailScreen extends StatefulWidget {
  static String id = 'confirm-email';

  @override
  _ConfirmEmailScreenState createState() => _ConfirmEmailScreenState();
}

class _ConfirmEmailScreenState extends State<ConfirmEmailScreen> {
  final auth = FirebaseAuth.instance;
  late User user;
  late Timer timer;

  void initState() {
    user = auth.currentUser!;
    user.sendEmailVerification();
    timer = Timer.periodic(Duration(seconds: 2), (timer) {
      checkEmailVerified();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: const Text('Email Confirmation'),
          backgroundColor: const Color(0xFFf57f17),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon(
              //   Icons.mark_email_read,
              //   color: Colors.green,
              //   size: 100.h,
              // ),
              Row(
                children: <Widget>[
                  Flexible(
                    child: Text('You\'re in!\nJust one more step...',
                        style: appFontStyle.copyWith(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: 50.h,
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                        'Please check your inbox and verify your email account before you continue!',
                        style: appFontStyle.copyWith(
                          fontSize: 20.0,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w900,
                        )),
                  ),
                ],
              ),
              Image.network("https://i.gifer.com/QHTn.gif")
            ],
          ),
        ),
      ),
    );
  }

  Future<void> checkEmailVerified() async {
    user = auth.currentUser!;
    await user.reload();
    if (user.emailVerified) {
      timer.cancel();
      print('email was successfully verified!');
      Navigator.pop(context);
    }
  }
}
