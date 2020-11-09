import 'package:flutter/material.dart';

import '../../constants.dart';

Widget TextForm({
  String labelText,
  Color fillColor: Colors.white,
  double borderRadius: 8,
  Widget suffixIcon,
  String hintText,
  Function onEditingComplete,
  Function validator,
  bool autovalidate: true,
  String initialValue,
  TextEditingController controller,
  TextInputType keyboardType,
  bool enabled: true,
  int maxline,
  TextStyle style,
}) {
  return TextFormField(
    decoration: InputDecoration(
        labelText: labelText,
        fillColor: fillColor,
        // border: OutlineInputBorder(
        //   borderRadius: BorderRadius.circular(borderRadius),
        // ),
        // enabledBorder: OutlineInputBorder(
        //   borderRadius: BorderRadius.circular(borderRadius),
        //   borderSide: BorderSide(
        //     color: priText,
        //     width: 2.0,
        //   ),
        // ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: priText,
            width: 2,
          ),
        ),
        suffixIcon: suffixIcon,
        errorMaxLines: 3,
        hintText: hintText),
    controller: controller,
    initialValue: initialValue,
    onEditingComplete: onEditingComplete,
    validator: validator,
    autovalidate: autovalidate,
    keyboardType: keyboardType,
    enabled: enabled,
    maxLines: maxline ?? 1,
    style: style,
  );
}
