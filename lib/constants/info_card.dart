import 'package:flutter/material.dart';
import 'package:bmw_passes/constants/custom_color.dart';
import 'package:bmw_passes/constants/custom_style.dart';

class InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Widget? leading;

  const   InfoCard({
    super.key,
    required this.label,
    required this.value,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: CustomColor.contentText),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: CustomStyle.infoLabel.copyWith(
                    color: CustomColor.mainText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: CustomStyle.infoValue.copyWith(
                    color: CustomColor.contentText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
