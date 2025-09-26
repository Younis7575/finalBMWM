// import 'package:bmw_passes/constants/custom_color.dart';
// import 'package:bmw_passes/constants/custom_style.dart';
// import 'package:flutter/material.dart';

// class CustomTextField extends StatelessWidget {
//   final String hintText;
//   final bool isPassword;
//   final TextEditingController? controller;
//   final String? Function(String?)? validator; // ✅ validator function

//   const CustomTextField({
//     super.key,
//     required this.hintText,
//     this.isPassword = false,
//     this.controller,
//     this.validator, // ✅ take validator
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       obscureText: isPassword,
//       validator: validator, // ✅ apply validator
//       decoration: InputDecoration(
//         hintText: hintText,
//         hintStyle: CustomStyle.formfield,
//         filled: true,
//         fillColor: CustomColor.fieldbackgroun,
//         contentPadding: const EdgeInsets.symmetric(
//           vertical: 16,
//           horizontal: 12,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderSide: const BorderSide(
//             color: CustomColor.fieldbackgroun,
//             width: 1.2,
//           ),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderSide: const BorderSide(color: CustomColor.mainText, width: 2),
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }
// }
import 'package:bmw_passes/constants/custom_color.dart';
import 'package:bmw_passes/constants/custom_style.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator; // ✅ validator function
  final Color? borderColor; // ✅ NEW

  const CustomTextField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.borderColor, // ✅ take border color
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

        // ✅ Normal state
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: borderColor ?? CustomColor.fieldbackgroun,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),

        // ✅ Focused state
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: borderColor ?? CustomColor.mainText,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),

        // ✅ Error state
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: borderColor ?? Colors.red,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: borderColor ?? Colors.red,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
