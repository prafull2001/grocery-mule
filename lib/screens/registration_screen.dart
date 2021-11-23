import 'package:flutter/material.dart';
import 'package:smart_shopper/components/rounded_ button.dart';
import 'package:smart_shopper/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_shopper/database/updateListData.dart';
import 'package:smart_shopper/screens/lists.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smart_shopper/database/google_signin.dart';


class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}


class _RegistrationScreenState extends State<RegistrationScreen> {
  String email="";
  String password="";
  String firstName="";
  String lastName="";

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
                  'Log In',
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
            TextField(
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
              onChanged: (value) {
                email = value;
              },
              decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your email')
            ),
            SizedBox(
              height: 8.0,
            ),
            TextField(
              textAlign: TextAlign.center,
              obscureText: true,
              onChanged: (value) {
                password = value;
              },
              style: TextStyle(color: Colors.black),
              decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your password')
            ),
            SizedBox(
              height: 8.0,
            ),
            TextField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  firstName = value;
                },
                style: TextStyle(color: Colors.black),
                decoration: kTextFieldDecoration.copyWith(hintText: 'First Name')
            ),
            SizedBox(
              height: 8.0,
            ),
            TextField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  lastName = value;
                },
                style: TextStyle(color: Colors.black),
                decoration: kTextFieldDecoration.copyWith(hintText: 'Last Name')
            ),
            SizedBox(
              height: 24.0,
            ),
            RoundedButton(
              title: 'Register',
              color: Colors.blueAccent,
              onPressed: ()
                async {
                  try {
                    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                    );
                    if (userCredential != null){
                      //app always hangs at this spot, could be something to do with the asynchrony?
                      print(email + ' ' + firstName + ' ' + lastName);
                      await DatabaseService(userID: email).initializeUserData(firstName, lastName, email);
                      print('moving to lists screen');
                      Navigator.pop(context);
                      Navigator.pushNamed(context, ListsScreen.id);
                    }
                  }  catch (e) {
                    print(e);
                  }
                }
            ),
            GoogleSignIn(),
          ],
        ),
      ),
    );
  }
}
class GoogleSignIn extends StatefulWidget {
  @override
  _GoogleSignInState createState() => _GoogleSignInState();
}

class _GoogleSignInState extends State<GoogleSignIn> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return !isLoading ? SizedBox(
      width: size.width * 0.8,
      child: RoundedButton(
        title: "testing",
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          FirebaseService service = new FirebaseService();
          try {
            await service.signInwithGoogle();
            print('doing stuff');
          } catch (e) {
            if (e is FirebaseAuthException) {
              showMessage(e.message);
            }
          }
          setState(() {
            isLoading = false;
          });
        },

      ),
    ) : CircularProgressIndicator();
  }

  void showMessage(String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(message),
            actions: [
              TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
