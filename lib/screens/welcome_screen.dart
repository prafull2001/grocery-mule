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
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
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
    if(credential.additionalUserInfo!.isNewUser){
      //create new document for the new user
      context.read<Cowboy>().initializeCowboy(credential.user!.uid, firstName, lastName, email!);
    }
    return;
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
              },
              color: Colors.amber,
            ),
            RoundedButton(
              title: 'Register',
              onPressed: (){
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
              color: Colors.amber,
            ),
            RoundedButton(
                title: 'Sign in with Google',
                color: Colors.blueAccent,
                onPressed: ()
                async {
                  try {
                    await signInWithGoogle();
                    Navigator.pop(context);
                    Navigator.pushNamed(context, ListsScreen.id);
                    /*if (userCredential != null){
                      //context.read<Cowboy>().initializeCowboy(userCredential.user.uid, firstName, lastName, email);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, ListsScreen.id);
                    }
                     */
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


