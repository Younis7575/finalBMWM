import 'package:flutter/material.dart';
import 'package:bmw_passes/constants/custom_style.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(title, style: CustomStyle.sectionTitle),
      ),
    );
  }
}
