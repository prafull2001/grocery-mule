import 'package:flutter/material.dart';
import 'package:grocery_mule/components/rounded_ button.dart';
import 'package:grocery_mule/constants.dart';

class PersonalListScreen extends StatefulWidget {
  static String id = 'personallist_screen';

  @override
  _PersonalListScreen createState() => _PersonalListScreen();
}

class _PersonalListScreen extends State<PersonalListScreen> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Personal List'),
        backgroundColor: const Color(0xFFbc5100),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
      ),
    );
  }
}

