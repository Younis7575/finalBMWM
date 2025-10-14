import 'package:bmw_passes/constants/custom_color.dart';
import 'package:bmw_passes/constants/custom_style.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;  

  const CustomTextField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.controller,
    this.validator,  
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,  
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: CustomStyle.formfield,
        filled: true,
        fillColor: CustomColor.fieldbackgroun,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: CustomColor.fieldbackgroun,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: CustomColor.mainText, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
