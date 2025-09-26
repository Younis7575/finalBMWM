import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/custom_color.dart';
import '../constants/custom_style.dart';

class PassTypeRow extends StatelessWidget {
  const PassTypeRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width * 0.92, // 90% of screen width
      height: Get.height * 0.07, // 7% of screen height
      padding: EdgeInsets.symmetric(
        horizontal: Get.width * 0.04, // responsive horizontal padding
        vertical: Get.height * 0.015, // responsive vertical padding
      ),
      decoration: BoxDecoration(
        border: Border.all(color: CustomColor.contentText),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Pass Type:",
            style: CustomStyle.infoLabel.copyWith(
              color: CustomColor.mainText,
              fontSize: Get.width * 0.04, // responsive font size
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
              "BMW M Accessorized",
              overflow: TextOverflow.ellipsis, // handle text overflow
              style: CustomStyle.infoLabel.copyWith(
                color: CustomColor.mainText,
                fontSize: Get.width * 0.04, // responsive font size
              ),
            ),
          ),
        ],
      ),
    );
  }
}
