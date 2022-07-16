// @dart=2.9
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grocery_mule/constants.dart';
import 'package:grocery_mule/dev/migration.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:grocery_mule/providers/shopping_trip_provider.dart';
import 'package:grocery_mule/screens/checkout_screen.dart';
import 'package:grocery_mule/screens/confirm_email.dart';
import 'package:grocery_mule/screens/createlist.dart';
import 'package:grocery_mule/screens/editlist.dart';
import 'package:grocery_mule/screens/friend_screen.dart';
import 'package:grocery_mule/screens/intro_screen.dart';
import 'package:grocery_mule/screens/lists.dart';
import 'package:grocery_mule/screens/login_screen.dart';
import 'package:grocery_mule/screens/paypal_link.dart';
import 'package:grocery_mule/screens/personal_list.dart';
import 'package:grocery_mule/screens/receipt_scanning.dart';
import 'package:grocery_mule/screens/registration_screen.dart';
import 'package:grocery_mule/screens/user_info.dart';
import 'package:grocery_mule/screens/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options.dart';

bool seen_intro; // global that updates with show_home's value upon startup

// check if user has been shown the intro screen
Future<Null> checkFirstSeen() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool cur_state = prefs.getBool('show_home') ??
      false; // get value of cur_state, false if null
  if (cur_state == false) {
    await prefs.setBool('show_home', true);
    seen_intro = false;
  } else if (cur_state == true) {
    seen_intro = true;
  } else {
    print('something wrong with show_home');
  }
}

void main() async {
  // Ensure that Firebase is initialized
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize Firebase
  //

  Widget _defaultHome;
  await checkFirstSeen(); // update seen_intro bool

  if (!seen_intro) {
    // if user hasn't seen intro, show it
    _defaultHome = new IntroScreen();
  } else {
    final User curUser = FirebaseAuth.instance.currentUser;
    if (curUser == null) {
      _defaultHome = new WelcomeScreen();
    } else {
      _defaultHome = new ListsScreen();
    }
  }

  // pass entire MaterialApp as child of MultiProvider
  runApp(
    ScreenUtilInit(
      // Iphone 13 Screen Size
      designSize: const Size(390, 844),
      // minTextAdapt: true,
      splitScreenMode: true,
      child: WelcomeScreen(),

      builder: (context, child) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => Cowboy()),
            ChangeNotifierProvider(create: (_) => ShoppingTrip()),
          ],
          builder: (context, child) {
            // print(MediaQuery.of(context).size);
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                  primaryColor: dark_beige,
                  scaffoldBackgroundColor: cream,
                  cardColor: dark_beige,
                  canvasColor: cream,
                  colorScheme: ColorScheme.fromSwatch()
                      .copyWith(secondary: light_orange)),
              home: _defaultHome,
              routes: {
                WelcomeScreen.id: (context) => WelcomeScreen(),
                LoginScreen.id: (context) => LoginScreen(),
                RegistrationScreen.id: (context) => RegistrationScreen(),
                ListsScreen.id: (context) => ListsScreen(),
                CreateListScreen.id: (context) =>
                    CreateListScreen(true, "dummy"),
                EditListScreen.id: (context) => EditListScreen(null),
                UserInfoScreen.id: (context) => UserInfoScreen(),
                ConfirmEmailScreen.id: (context) => ConfirmEmailScreen(),
                FriendScreen.id: (context) => FriendScreen(),
                PersonalListScreen.id: (context) => PersonalListScreen(),
                CheckoutScreen.id: (context) => CheckoutScreen(),
                IntroScreen.id: (context) => IntroScreen(),
                Migration.id: (context) => Migration(),
                PayPalPage.id: (context) => PayPalPage(),
                ReceiptScanning.id: (context) => ReceiptScanning(),
              },
            );
          }),
    ),
  );
}
