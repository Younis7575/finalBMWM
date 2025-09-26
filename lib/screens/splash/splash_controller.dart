import 'package:bmw_passes/screens/auth/login_screen.dart';
import 'package:bmw_passes/screens/home/qe_code_scanning_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_controller.dart'; // import controller

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;

  @override
  void onInit() {
    super.onInit();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOutBack),
    );

    fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    animationController.forward();

    /// After splash, check login status
    Future.delayed(const Duration(seconds: 3), () async {
      final loginController = Get.put(LoginController());
      bool valid = await loginController.isSessionValid();

      if (valid) {
        /// ✅ Logged in & session not expired
        Get.offAll(() => const QrScanScreen());
      } else {
        /// ❌ No token or expired session
        Get.offAll(() => const LoginScreen());
      }
    });
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
