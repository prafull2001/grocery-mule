import 'package:flutter/material.dart';

const cream = Color(0xffFFE9D0);
const light_orange = Color(0xFFFF8A65);
const orange = Color(0xffFF6E40);
const red = Color(0xFFEF5350);
const beige = Color(0xFFb6a8a0);
const dark_beige = Color(0xff97877E);
const darker_beige = Color(0xff49413D);

const kSendButtonTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: darker_beige, width: 2.0),
  ),
);

const kTextFieldDecoration = InputDecoration(
  hintText: 'Placeholder Text',
  hintStyle: TextStyle(fontSize: 20.0, color: dark_beige),
  contentPadding:
  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: dark_beige, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: dark_beige, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);