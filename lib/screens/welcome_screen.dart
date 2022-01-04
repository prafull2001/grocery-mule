import 'package:flutter/material.dart';
import 'package:grocery_mule/classes/data_structures.dart';
import 'package:grocery_mule/screens/login_screen.dart';
import 'package:grocery_mule/screens/registration_screen.dart';
import 'package:grocery_mule/components/rounded_ button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_mule/database/updateListData.dart';
import 'package:grocery_mule/screens/confirm_email.dart';
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
  String email;
  String password;
  String firstName;
  String lastName;
  FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential res = await auth.signInWithCredential(credential);
      String fullname = res.user.displayName;
      List<String> namearray = fullname.split(" ");
      firstName = namearray[0];
      lastName = namearray[1];
      email = res.user.email;
      print("signed in " + firstName + " " + lastName);
      if (res.user == null)
        return await signInWithGoogle();
      else
        return res;
    } catch (e) {
      print("Sign In Error:" + e.toString());
      //return await signInWithGoogle();
    }
  }
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
                  'GroceryMule',
                  style: TextStyle(
                    fontSize: 35.0,
                    fontWeight: FontWeight.w900,
                  ),
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
              },
            ),
            RoundedButton(
              title: 'Register',
              onPressed: (){
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
            ),
            RoundedButton(
                title: 'Sign in with Google',
                color: Colors.blueAccent,
                onPressed: ()
                async {
                  try {
                    UserCredential userCredential = await signInWithGoogle();
                    if (userCredential != null){
                      var new_cowboy = new Cowboy(userCredential.user.uid, firstName, lastName, email);
                      await DatabaseService(uuid: new_cowboy.uuid).initializeUserData(new_cowboy);
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


