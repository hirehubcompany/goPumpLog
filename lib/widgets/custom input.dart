import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'constant.dart';


class CustomInput extends StatelessWidget {
  final String hintText;
  final Function(String) onChanged;
  final Function(String) onSubmitted;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final bool isPasswordField;
  CustomInput({required this.hintText, required this.isPasswordField, required this.textInputAction, required this.focusNode, required this.onChanged, required this.onSubmitted});


  @override
  Widget build(BuildContext context) {
    bool _isPasswordField = isPasswordField;

    return Sizer(builder: (context, orientation, deviceType){
      return Container(
        margin: EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 24.0,
        ),
        decoration: BoxDecoration(
            color: Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(12.0)

        ),
        child: TextField(
          obscureText: _isPasswordField,
          focusNode: focusNode,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: textInputAction,

          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 18.0,
              )
          ),
          style: Constants.regularDarkText,
        ),
      );
    });
  }
}


