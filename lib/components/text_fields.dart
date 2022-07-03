import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grocery_mule/theme/colors.dart';
import 'package:grocery_mule/theme/text_styles.dart';

class TextFields extends StatelessWidget {
  const TextFields(
      {required this.controller,
      required this.icon,
      required this.hintText,
      required this.context,
      required this.helpText,
      required this.secureText,
      required this.input,
      required this.show,
      required this.borderColor,
      required this.focusColor,
      required this.onTap1,
      required this.enabled,
      required this.onChanged,
      required this.inSquare,
      required this.suffix})
      : super();

  final Tab icon;
  final TextEditingController controller;
  final String hintText;
  final BuildContext context;
  final String helpText;
  final bool secureText;
  final TextInputType input;
  final IconButton show;
  final Color borderColor;
  final Color focusColor;
  final Function onTap1;
  final bool enabled;
  final Function(String)? onChanged;
  final Widget suffix;
  final bool inSquare;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: 10, start: 10),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                color: appColorLight,
                borderRadius: inSquare
                    ? BorderRadius.circular(10)
                    : BorderRadius.all(Radius.circular(38)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 8,
                    offset: Offset(4, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: TextFormField(
                  // inputFormatters: [maskTextInputFormatter],
                  // controller: textControl,

                  onChanged: onChanged,
                  keyboardType: input,

                  enabled: true,

                  style: appFontStyle.copyWith(color: Colors.black),

                  controller: controller,
                  obscureText: secureText,
                  decoration: InputDecoration(
                      prefixIcon: icon,
                      suffixIcon: show,
                      // suffix: suffix,
                      focusColor: focusColor,
                      hintText: hintText,
                      hintStyle: appFontStyle.copyWith(color: Colors.black),
                      labelText: helpText,
                      border: InputBorder.none),
                ),
              ),
            ),
          )),
    );
  }
}

class TextFields2 extends StatelessWidget {
  const TextFields2(
      {required this.textControl,
      required this.icon,
      required this.hintText,
      required this.context,
      required this.helpText,
      required this.secureText,
      required this.input,
      required this.show,
      required this.borderColor,
      required this.focusColor,
      required this.onTap1,
      required this.enabled,
      required this.onChanged})
      : super();

  final Tab icon;
  final String hintText;
  final BuildContext context;
  final String helpText;
  final bool secureText;
  final TextInputType input;
  final IconButton show;
  final Color borderColor;
  final Color focusColor;
  final Function onTap1;
  final bool enabled;
  final Function(String)? onChanged;
  final TextEditingController textControl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: 8, start: 8),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(width: 4, color: borderColor),
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: TextFormField(
                  controller: textControl,
                  onChanged: onChanged,
                  keyboardType: input,
                  enabled: enabled,
                  onTap: () {
                    onTap1;
                  },
                  style: TextStyle(
                    color: focusColor,
                  ),
                  obscureText: secureText,
                  decoration: InputDecoration(
                      suffixIcon: show,
                      focusColor: focusColor,
                      icon: icon,
                      hintText: hintText,
                      hintStyle: TextStyle(fontSize: 17, color: focusColor),
                      labelText: helpText,
                      border: InputBorder.none),
                ),
              ),
            ),
          )),
    );
  }
}
