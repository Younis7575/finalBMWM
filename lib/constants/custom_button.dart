import 'package:bmw_passes/constants/custom_color.dart';
import 'package:bmw_passes/constants/custom_style.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  // final Color textColor;
  final double borderRadius;
  final double elevation;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = CustomColor.mainText, // Default: Dark Blue
    // this.textColor = CustomColor.screenBackground,
    this.borderRadius = 12,
    this.elevation = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Full width
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          // foregroundColor: textColor,
          elevation: elevation,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Text(
          text,
          style: CustomStyle.buttonText.copyWith(
            color: CustomColor.screenBackground,
          ),
        ),
      ),
    );
  }
}
