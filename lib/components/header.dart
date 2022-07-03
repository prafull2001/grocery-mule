import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_mule/theme/text_styles.dart';

import '../theme/colors.dart';

class HomeHeader extends StatelessWidget {
  final String title;
  final Color color;
  final Color textColor;

  const HomeHeader({
    required this.title,
    required this.color,
    required this.textColor,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: ClipPath(
          clipper: OvalBottomBorderClipper(),
          child: Container(
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadiusDirectional.circular(10)),
            height: 50.h,
            width: 400.w,
            child: Center(
              child: Text(title,
                  style: titleBlack.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  )),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeHeader2 extends StatelessWidget {
  final String title;

  const HomeHeader2({
    required this.title,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
      child: Center(
        child: ClipPath(
          clipper: OvalBottomBorderClipper(),
          child: Container(
            decoration: BoxDecoration(
                color: appOrange,
                borderRadius: BorderRadiusDirectional.circular(5)),
            height: 65.h,
            width: ScreenUtil().screenWidth,
            child: Center(
              child: Text(
                title,
                style: titleBlack.copyWith(
                    color: appColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
