import 'package:flutter/material.dart';
import 'package:grocery_mule/screens/confirm_email.dart';
import 'package:grocery_mule/screens/user_info.dart';
import 'package:grocery_mule/screens/welcome_screen.dart';
import 'package:grocery_mule/screens/login_screen.dart';
import 'package:grocery_mule/screens/registration_screen.dart';
import 'package:grocery_mule/screens/lists.dart';
import 'package:grocery_mule/screens/createlist.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  // Ensure that Firebase is initialized
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Initialize Firebase
  //
  runApp(GroceryMule());
}

class GroceryMule extends StatefulWidget {
  @override
  _GroceryMuleState createState() => _GroceryMuleState();
}

class _GroceryMuleState extends State<GroceryMule>{
  @override
  Widget build(BuildContext context) {
    Widget home;
    final User curUser = FirebaseAuth.instance.currentUser;
    if(curUser == null) {
      print('USER IS NULL');
      setState((){
        home = WelcomeScreen();
      });
    } else {
      print('USER IS NOT NULL');
      setState((){
        home = ListsScreen();
      });
    };

    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xFFf57f17),
        primaryColorDark: const Color(0xFFbc5100),
        primaryColorLight: const Color(0xFFffb04c),
        accentColor: const Color(0xFFbf360c),
        scaffoldBackgroundColor: const Color(0xFFffe0b2),
        canvasColor: const Color(0xFFffe0b2)
      ),
      home: home,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        ListsScreen.id: (context) => ListsScreen(),
        CreateListScreen.id: (context) => CreateListScreen(null),
        UserInfoScreen.id: (context) => UserInfoScreen(),
        ConfirmEmailScreen.id: (context) => ConfirmEmailScreen(),
      },
    );
  }
}
