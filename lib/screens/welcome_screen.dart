import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grocery_mule/screens/login_screen.dart';
import 'package:grocery_mule/constants.dart';
import 'package:grocery_mule/screens/paypal_link.dart';
import 'package:grocery_mule/screens/registration_screen.dart';
import 'package:grocery_mule/components/rounded_ button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:grocery_mule/theme/colors.dart';
import 'package:grocery_mule/theme/text_styles.dart';
import 'package:provider/provider.dart';
import 'package:grocery_mule/screens/lists.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../components/text_buttons.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  late String email;
  late String password;
  late String firstName;
  late String lastName;
  FirebaseAuth auth = FirebaseAuth.instance;
  //final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle() async {
    // Trigger the Google Authentication flow.
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    // Obtain the auth details from the request.
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    // Create a new credential.
    final OAuthCredential googleCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // Sign in to Firebase with the Google [UserCredential].
    final UserCredential credential =
        await FirebaseAuth.instance.signInWithCredential(googleCredential);
    //check if it is a new user
    String full_name = credential.user!.displayName!;
    List<String> name_array = full_name.split(" ");
    firstName = name_array[0];
    lastName = name_array[1];
    email = credential.user!.email!;
    // if new user, create doc and push PayPal Screen, else continue to Lists
    if (credential.additionalUserInfo!.isNewUser) {
      context
          .read<Cowboy>()
          .initializeCowboy(credential.user!.uid, firstName, lastName, email);
      Navigator.pop(context);
      Navigator.pushNamed(context, PayPalPage.id);
    } else {
      Navigator.pop(context);
      Navigator.pushNamed(context, ListsScreen.id);
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('GroceryMule', style: titleBlackBold),
                Container(
                  child: Image.asset('images/logo.png'),
                  height: 100.0,
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            Center(
                child: Text(
              "Let's Connect",
              style: titleBlack,
            )),
            Center(
                child: Text(
              "Together",
              style: titleBlack,
            )),
            SizedBox(
              height: 20.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.h),
              child: RectangularTextButton(
                onPressed: () {
                  Navigator.pushNamed(context, LoginScreen.id);
                },
                text: "Login",
                buttonColor: Colors.white,
                textColor: Colors.black,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.h),
              child: RectangularTextButton(
                onPressed: () {
                  Navigator.pushNamed(context, RegistrationScreen.id);
                },
                text: "Register",
                buttonColor: appOrange,
                textColor: Colors.white,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Divider(
                color: Colors.blueGrey,
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
            ),
            GestureDetector(
              onTap: () async {
                try {
                  await signInWithGoogle();
                } catch (e) {
                  print('error: '+e.toString());
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: RectangularTextIconButton(
                  onPressed: () async {
                    try {
                      await signInWithGoogle();
                    } catch (e) {
                      print('error: '+e.toString());
                    }
                  },
                  text: "Continue With Google",
                  icon: Icon(
                    FontAwesomeIcons.google,
                    // color: Colors.redAccent,
                  ),
                  buttonColor: Colors.white,
                  textColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
