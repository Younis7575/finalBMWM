import 'package:bmw_passes/constants/Text_Field_Widget.dart';
import 'package:bmw_passes/constants/custom_button.dart';
import 'package:bmw_passes/constants/custom_color.dart';
import 'package:bmw_passes/constants/custom_style.dart'; 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: CustomColor.screenBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/login-icon.png",
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 15),
                  Text("Login", style: CustomStyle.loginText),
                  const SizedBox(height: 15),  

                  // ✅ Custom Text Fields
                  Column(
                    children: [
                      CustomTextField(
                        hintText: "Username",
                        controller: controller.usernameController,
                        validator: controller.validateUsername,
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        hintText: "Password",
                        isPassword: true,
                        controller: controller.passwordController,
                        validator: controller.validatePassword,
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),
                  Obx(
                    () => CustomButton(
                      text: controller.isLoading.value
                          ? "Loading..."
                          : "Sign in",
                      onPressed: () {
                        if (!controller.isLoading.value) {
                          controller.login();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
