import 'package:flutter/material.dart';
import 'package:grocery_mule/constants.dart';
import 'package:grocery_mule/screens/checkout_screen.dart';
import 'package:grocery_mule/screens/confirm_email.dart';
import 'package:grocery_mule/screens/editlist.dart';
import 'package:grocery_mule/screens/intro_screen.dart';
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
import 'dart:io';

bool seen_intro;

Future<Null> checkFirstSeen() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool cur_state = prefs.getBool('show_home') ?? false;
  print('cur_state: ' + cur_state.toString());
  if (cur_state == false) {
    print('FIRST TIME LAUNCH');
    await prefs.setBool('show_home', true);
    seen_intro = false;
  } else if (cur_state == true ){
    seen_intro = true;
  } else {
    print('something wrong with sharedpreference');
  }
}

void main() async {
  // Ensure that Firebase is initialized
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Initialize Firebase
  //

  Widget _defaultHome;
  await checkFirstSeen(); // update seen_intro bool

  if (!seen_intro) {
    _defaultHome = new IntroScreen();
  } else {
    final User curUser = FirebaseAuth.instance.currentUser;
    if(curUser == null) {
      print('USER IS NULL');
      //welcome screen
      _defaultHome = new WelcomeScreen();
    } else {
      print('USER IS NOT NULL');
      //listsscreen
      _defaultHome = new ListsScreen();
    }
  }


  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Cowboy()),
          ChangeNotifierProvider(create: (_) => ShoppingTrip()),
        ],
        child: new MaterialApp(
          theme: ThemeData(
            primaryColor: dark_beige,
            scaffoldBackgroundColor: cream,
            cardColor: dark_beige,
            canvasColor: cream, colorScheme: ColorScheme.fromSwatch().copyWith(secondary: light_orange)
          ),
          home: _defaultHome,
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
            IntroScreen.id: (context) => IntroScreen(),
          },
        ),
      ),
  );
}


/*
class GroceryMule extends StatefulWidget {
  @override
  _GroceryMuleState createState() => _GroceryMuleState();
}
//with AfterLayoutMixin<GroceryMule>
class _GroceryMuleState extends State<GroceryMule> {

  @override
  void initState() {
    super.initState();
    checkFirstSeen();
  }

  @override
  Widget build(BuildContext context) {
    //Widget home;
    final User curUser = FirebaseAuth.instance.currentUser;

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
        IntroScreen.id: (context) => IntroScreen(),
      },
    );
  }

  // @override
  // void afterFirstLayout(BuildContext context) {
  //   checkFirstSeen();
  // }
}
*/