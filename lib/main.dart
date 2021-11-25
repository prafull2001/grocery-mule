import 'package:flutter/material.dart';
import 'package:smart_shopper/screens/confirm_email.dart';
import 'package:smart_shopper/screens/user_info.dart';
import 'package:smart_shopper/screens/welcome_screen.dart';
import 'package:smart_shopper/screens/login_screen.dart';
import 'package:smart_shopper/screens/registration_screen.dart';
import 'package:smart_shopper/screens/lists.dart';
import 'package:smart_shopper/screens/createlist.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // Ensure that Firebase is initialized
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Initialize Firebase
  //
  runApp(SmartShopper());
}

class SmartShopper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xFFf57f17),
        primaryColorDark: const Color(0xFFbc5100),
        primaryColorLight: const Color(0xFFffb04c),
        accentColor: const Color(0xFFbf360c),
        scaffoldBackgroundColor: const Color(0xFFffe0b2),
      ),
      initialRoute: WelcomeScreen.id,
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
