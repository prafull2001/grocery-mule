import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_mule/components/rounded_ button.dart';
import 'package:grocery_mule/constants.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:grocery_mule/theme/colors.dart';
import 'package:grocery_mule/theme/text_styles.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'lists.dart';

class PayPalPage extends StatefulWidget {
  static String id = 'paypal_page';

  @override
  _PayPalPageSate createState() => _PayPalPageSate();
}

class _PayPalPageSate extends State<PayPalPage> {
  String paypal_link = '';
  bool link_valid = false;

  void checkStringValidity(String input) async {
    String paypal_prefix = "https://www.paypal.com/paypalme/";
    String test_link = paypal_prefix + input;
    Uri paypal_link = Uri.parse(test_link);
    if (await canLaunchUrl(paypal_link) &&
        RegExp(r"(^(\d|[a-zA-Z])+$)").hasMatch(input)) {
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
                  context.read<Cowboy>().updateCowboyPaypal(input);
                  Navigator.pushNamed(context, ListsScreen.id);
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
            title: Text('Please enter a valid PayPal.me Username.'),
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
        title: Text(
          'Link PayPal Account',
          style: appFontStyle.copyWith(color: Colors.black),
        ),
        backgroundColor: light_orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 30.0,
              ),
              Text(
                'Add your Paypal username to your profile!',
                style: appFontStyle,
              ),
              SizedBox(
                height: 30.0,
              ),
              Card(
                color: appColorLight,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  // side: const BorderSide(
                  //     color: Color.fromARGB(255, 0, 0, 0), width: 2.0),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    textColor: Colors.black,
                    backgroundColor: appColorLight,
                    collapsedTextColor: Colors.black,
                    title: Text(
                      "Finding your PayPal.me link",
                      style: appFontStyle,
                    ),
                    children: [
                      RoundedButton(
                        onPressed: () async {
                          String paypalStr = "https://www.paypal.com/paypalme/";
                          Uri paypal_link = Uri.parse(paypalStr);
                          if (await canLaunchUrl(paypal_link)) {
                            launchUrl(paypal_link);
                          }
                        },
                        title: "Visit \'paypal.me\'",
                        color: Colors.blueAccent,
                      ),
                      Image.asset(
                        "images/infoPaypal.gif",
                      ),
                      ListTile(title: Text("Paste your username below")),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 30.0,
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
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                        text: 'Skip for now',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).pop();
                            context.read<Cowboy>().updateCowboyPaypal("");
                            Navigator.pushNamed(context, ListsScreen.id);
                          }),
                  ),
                  SizedBox(
                    width: 24.0,
                  ),
                  RoundedButton(
                      title: 'Add Paypal username',
                      color: Colors.blueAccent,
                      onPressed: () {
                        if (paypal_link != '') {
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
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
