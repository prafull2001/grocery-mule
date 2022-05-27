// @dart=2.9
import 'package:flutter/material.dart';
import 'package:grocery_mule/components/rounded_ button.dart';
import 'package:grocery_mule/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_mule/screens/confirm_email.dart';
import 'package:grocery_mule/screens/lists.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  String email;
  String password;
  final _auth = FirebaseAuth.instance;
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
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            TextField(
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
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
              decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your password')
            ),
            SizedBox(
              height: 24.0,
            ),
            RoundedButton(
              title: 'Log In',
              color: Colors.lightBlue,
              onPressed: () async{
                try {
                  final user = await _auth.signInWithEmailAndPassword(email: email, password: password);
                  if (user != null && user.user.emailVerified){
                    debugPrint('User signed in');
                    Navigator.pushNamed(context, ListsScreen.id);
                  } else if (!(user.user.emailVerified)){
                    await Navigator.pushNamed(context, ConfirmEmailScreen.id);
                    Navigator.pushNamed(context, ListsScreen.id);
                  }
                } on FirebaseAuthException catch (e){
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
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
