import 'package:bmw_passes/constants/custom_color.dart';
import 'package:bmw_passes/constants/custom_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class PassTypeRow extends StatelessWidget {
  final String passType; // <-- new parameter

  const PassTypeRow({
    super.key,
    required this.passType, // <-- required
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width * 0.92,
      height: Get.height * 0.07,
      padding: EdgeInsets.symmetric(
        horizontal: Get.width * 0.04,
        vertical: Get.height * 0.015,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: CustomColor.contentText),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            "Pass Type:",
            style: CustomStyle.infoLabel.copyWith(
              color: CustomColor.mainText,
              fontSize: Get.width * 0.04,
            ),
          ),
          SizedBox(width: Get.width * 0.02),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              "assets/images/passType.png",
              height: Get.height * 0.035,
              width: Get.height * 0.035,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: Get.width * 0.02),
          Flexible(
            child: Text(
              passType, // ✅ yahan ab jo bhi text bhejoge wahi show hoga
              overflow: TextOverflow.ellipsis,
              style: CustomStyle.infoLabel.copyWith(
                color: CustomColor.mainText,
                fontSize: Get.width * 0.04,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
