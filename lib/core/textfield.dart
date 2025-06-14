import 'package:flutter/material.dart';
import 'package:foodapp/core/colors/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class TextField1 extends StatelessWidget {
  final Color? backgroundColor;
  final Widget? child;

  const TextField1({
    super.key,
    this.backgroundColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors1.lightGreyBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: child,
      ),
    );
  }
}