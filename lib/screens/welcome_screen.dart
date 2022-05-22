import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grocery_mule/screens/login_screen.dart';
import 'package:grocery_mule/constants.dart';
import 'package:grocery_mule/screens/registration_screen.dart';
import 'package:grocery_mule/components/rounded_ button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:provider/provider.dart';
import 'package:grocery_mule/screens/lists.dart';
import 'package:google_sign_in/google_sign_in.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  String? email;
  String? password;
  late String firstName;
  late String lastName;
  FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();


  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await (_googleSignIn.signIn() as Future<GoogleSignInAccount?>);
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential res = await auth.signInWithCredential(credential);

      String full_name = res.user!.displayName!;
      List<String> name_array = full_name.split(" ");
      firstName = name_array[0];
      lastName = name_array[1];
      email = res.user!.email;
      if (res.additionalUserInfo!.isNewUser) {
        print("new user");
        //final new_res = await signInWithGoogle();

        context.read<Cowboy>().initializeCowboy(res.user!.uid, firstName, lastName, email!);
        //User logging in for the first time
        // Redirect user to tutorial
      }
      return res;
    } catch (e) {
      //return await signInWithGoogle();
      throw Exception("Sign In Error: " + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'GroceryMule',
                  style: TextStyle(
                    fontSize: 35.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Container(
                  child: Image.asset('images/logo.png'),
                  height: 100.0,
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              title: 'Log In',
              onPressed: (){
                Navigator.pushNamed(context, LoginScreen.id);
              }, color: Colors.lightBlue,
            ),
            RoundedButton(
              title: 'Register',
              onPressed: (){
                Navigator.pushNamed(context, RegistrationScreen.id);
              }, color: Colors.lightBlue,
            ),
            RoundedButton(
                title: 'Sign in with Google',
                color: Colors.blueAccent,
                onPressed: ()
                async {
                  try {
                    UserCredential userCredential = await signInWithGoogle();
                    if (userCredential != null){
                      //context.read<Cowboy>().initializeCowboy(userCredential.user.uid, firstName, lastName, email);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, ListsScreen.id);
                    }
                  }  catch (e) {
                    print(e);
                  }
                }
            ),
          ],
        ),
      ),
    );
  }
}


