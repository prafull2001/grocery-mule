import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/text_styles.dart';

class RectangularTextButton extends StatelessWidget {
  final String text;
  final Color buttonColor;
  final Color textColor;
  final VoidCallback onPressed;

  const RectangularTextButton(
      {Key? key,
      required this.text,
      this.buttonColor = Colors.white,
      this.textColor = Colors.black,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: buttonColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: Container(
          child: TextButton(
              onPressed: onPressed,
              child: Text(
                text,
                style: appFontStyle.copyWith(color: textColor, fontSize: 15.sp),
              ))),
    );
  }
}

class RectangularTextIconButton extends StatelessWidget {
  final String text;
  final Color buttonColor;
  final Color textColor;
  final VoidCallback onPressed;
  final Icon icon;
  const RectangularTextIconButton(
      {Key? key,
      required this.text,
      this.icon = const Icon(Icons.abc),
      this.buttonColor = Colors.white,
      this.textColor = Colors.black,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: buttonColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: Container(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: TextButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: appFontStyle.copyWith(
                        color: textColor, fontSize: 15.sp),
                  )),
            ),
          ),
          icon
        ],
      )),
    );
  }
}
