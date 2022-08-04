import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:grocery_mule/constants.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:grocery_mule/screens/lists.dart';
import 'package:grocery_mule/screens/login_screen.dart';
import 'package:grocery_mule/screens/user_info.dart';
import 'package:grocery_mule/screens/paypal_link.dart';
import 'package:grocery_mule/screens/registration_screen.dart';
import 'package:grocery_mule/theme/colors.dart';
import 'package:grocery_mule/theme/text_styles.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );
    // Sign in to Firebase with the Apple [UserCredential].
    final UserCredential credential =
        await FirebaseAuth.instance.signInWithCredential(oauthCredential);

    if (credential.additionalUserInfo!.isNewUser) {
      print("detected Apple New User!!!!");
      print("apple UUID: " + credential.user!.uid);
      print("apple email: " + credential.user!.email!);
      if(appleCredential.givenName == null) {
        print("given Name is NULL!!");
      }
      // print("apple givenName: " + appleCredential.givenName!);
      // print("apple familyName: " + appleCredential.familyName!);
      // print("apple email: " + appleCredential.email!);


      context.read<Cowboy>().initializeCowboy(
          credential.user!.uid,
          "",
          "",
          credential.user!.email!);
      Navigator.pop(context);
      await Navigator.pushNamed(context, UserInfoScreen.id);
      Navigator.pushNamed(context, PayPalPage.id);
    } else {
      Navigator.pop(context);
      Navigator.pushNamed(context, ListsScreen.id);
    }
    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    return;
  }

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
              "Welcome!",
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
                  print('error: ' + e.toString());
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: RectangularTextIconButton(
                  onPressed: () async {
                    try {
                      await signInWithGoogle();
                    } catch (e) {
                      print('error: ' + e.toString());
                    }
                  },
                  text: "Continue With Google",
                  icon: Icon(
                    FontAwesomeIcons.google,
                    color: Colors.blueAccent,
                  ),
                  buttonColor: Colors.white,
                  textColor: Colors.blue,
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                try {
                  await signInWithApple();
                } catch (e) {
                  print('error: ' + e.toString());
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: RectangularTextIconButton(
                  onPressed: () async {
                    try {
                      await signInWithApple();
                    } catch (e) {
                      print('error: ' + e.toString());
                    }
                  },
                  text: "Continue With Apple",
                  icon: Icon(
                    FontAwesomeIcons.apple,
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
