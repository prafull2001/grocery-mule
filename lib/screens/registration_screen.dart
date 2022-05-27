// @dart=2.9
import 'package:flutter/material.dart';
import 'package:grocery_mule/components/rounded_ button.dart';
import 'package:grocery_mule/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:provider/provider.dart';
import 'package:grocery_mule/screens/confirm_email.dart';
import 'package:grocery_mule/screens/lists.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String email;
  String password;
  String firstName;
  String lastName;
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
                  'Register',
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
                      print(email + ' ' + firstName + ' ' + lastName);
                      context.read<Cowboy>().initializeCowboy(userCredential.user.uid, firstName, lastName, email);
                      await Navigator.pushNamed(context, ConfirmEmailScreen.id);
                      // await DatabaseService(uuid: new_cowboy.uuid).initializeUserData(new_cowboy);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, ListsScreen.id);
                    }
                  } on FirebaseAuthException catch (e) {
                    print(e);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(e.message),
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
                    print(e);
                  }
                }
            ),
            SizedBox(
              height: 24.0,
            ),

          ],
        ),
      ),
    );
  }
}
