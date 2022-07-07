import 'package:flutter/material.dart';
import 'package:grocery_mule/theme/text_styles.dart';
import '../constants.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton(
      {required this.title, required this.color, required this.onPressed});

  final Color color;
  final String title;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 0.25,
        color: color,
        borderRadius: BorderRadius.circular(10.0),
        child: MaterialButton(
          onPressed: onPressed as void Function()?,
          minWidth: 200.0,
          height: 42.0,
          child: Text(title, style: appFontStyle.copyWith(color: Colors.white)),
        ),
      ),
    );
  }
}
