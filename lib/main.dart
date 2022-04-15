import 'package:flutter/material.dart';
import 'package:grocery_mule/constants.dart';
import 'package:grocery_mule/screens/checkout_screen.dart';
import 'package:grocery_mule/screens/confirm_email.dart';
import 'package:grocery_mule/screens/editlist.dart';
import 'package:grocery_mule/screens/user_info.dart';
import 'package:grocery_mule/screens/welcome_screen.dart';
import 'package:grocery_mule/screens/login_screen.dart';
import 'package:grocery_mule/screens/personal_list.dart';
import 'package:grocery_mule/screens/registration_screen.dart';
import 'package:grocery_mule/screens/lists.dart';
import 'package:grocery_mule/screens/createlist.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:grocery_mule/providers/shopping_trip_provider.dart';
import 'package:grocery_mule/screens/friend_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:after_layout/after_layout.dart';

void main() async {
  // Ensure that Firebase is initialized
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Initialize Firebase
  //
  final prefs = await SharedPreferences.getInstance();
  final bool showHome = prefs.getBool('showHome') ?? false;
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Cowboy()),
          ChangeNotifierProvider(create: (_) => ShoppingTrip()),
        ],
        child: GroceryMule(showHome: showHome),
      ),

  );
}

class GroceryMule extends StatefulWidget {
  final bool show_home;
  const GroceryMule({Key key, bool showHome, this.show_home}); // might need to swap orders


  @override
  _GroceryMuleState createState() => _GroceryMuleState();
}

class _GroceryMuleState extends State<GroceryMule>{
/*
  Future checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool first_launch = prefs.getBool('first_launch') ?? false;

    if(first_launch) {
      //Navigator.pushNamed(context, WelcomeScreen.id); // switch to intro screen
      return true;
    } else {
      prefs.setBool('first_launch', true);
      return false;
      //might need to push home screen, but may need await ^^ for that
    }
  }

  // @override
  // void afterFirstLayout(BuildContext context) => checkFirstLaunch();
*/

  @override
  Widget build(BuildContext context) {
    Widget home;
    final User curUser = FirebaseAuth.instance.currentUser;

    // put this all in the 'else' statement of the introduction screen
    if(widget.show_home == true){
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
    } else {
      // stuff for intro page
    }

    return MaterialApp(
      theme: ThemeData(
        primaryColor: dark_beige,
        scaffoldBackgroundColor: cream,
        cardColor: dark_beige,
        canvasColor: cream, colorScheme: ColorScheme.fromSwatch().copyWith(secondary: light_orange)
      ),
      home: home,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        ListsScreen.id: (context) => ListsScreen(),
        CreateListScreen.id: (context) => CreateListScreen(true),
        EditListScreen.id: (context) => EditListScreen(null),
        UserInfoScreen.id: (context) => UserInfoScreen(),
        ConfirmEmailScreen.id: (context) => ConfirmEmailScreen(),
        FriendScreen.id: (context) => FriendScreen(),
        PersonalListScreen.id: (context) => PersonalListScreen(),
        CheckoutScreen.id: (context) => CheckoutScreen(),
      },
    );
  }
}
