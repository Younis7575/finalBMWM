//update code

import 'dart:convert';
import 'dart:developer';
import 'package:bmw_passes/screens/auth/login_model.dart';
import 'package:bmw_passes/screens/auth/login_screen.dart';
import 'package:bmw_passes/screens/home/qe_code_scanning_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var isLoading = false.obs;

  /// ✅ Save login token + timestamp
  Future<void> saveLoginSession(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", token);
    await prefs.setString("login_time", DateTime.now().toIso8601String());
  }

  /// ✅ Check if session is still valid (5 minutes)
  Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTimeString = prefs.getString("login_time");
    final token = prefs.getString("access_token");

    if (token == null || loginTimeString == null) return false;

    final loginTime = DateTime.parse(loginTimeString);
    final now = DateTime.now();
    final difference = now.difference(loginTime).inMinutes;

    if (difference >= 5) {
      // Session expired
      await prefs.remove("access_token");
      await prefs.remove("login_time");
      return false;
    }

    return true;
  }

  /// ✅ Username Validation
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return "Username cannot be empty";
    return null;
  }

  /// ✅ Password Validation
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password cannot be empty";
    return null;
  }

  /// ✅ Login function with API
  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      var url = Uri.parse("https://spmetesting.com/api/auth/login.php");
      var response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "X-APP-KEY": "73706d652d6170706c69636174696f6e2d373836",
        },
        body: {
          "user_name": usernameController.text.trim(),
          "password": passwordController.text.trim(),
        },
      );

      log("Login response => ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = jsonDecode(response.body);
        var loginModel = LoginModel.fromJson(data);

        // ✅ Save token + timestamp
        await saveLoginSession(loginModel.token ?? "");

        Get.snackbar(
          "Success",
          loginModel.message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // ✅ Navigate to QR Screen
        Get.offAll(() => const QrScanScreen());
      } else {
        Get.snackbar(
          "Error",
          "User Not Found",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Logout function
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("access_token");

    if (token != null && token.isNotEmpty) {
      var url = Uri.parse("https://spmetesting.com/api/auth/logout.php");
      try {
        var response = await http.post(
          url,
          headers: {
            "Accept": "application/json",
            "X-API-ACCESS-TOKEN": token,
            "X-APP-KEY": "73706d652d6170706c69636174696f6e2d373836",
          },
        );
        log("Logout response => ${response.body}");
      } catch (e) {
        log("Logout API error => $e");
      }
    }

    await prefs.remove("access_token");
    await prefs.remove("login_time");

    Get.offAll(() => const LoginScreen());
    Get.snackbar(
      "Logged Out",
      "You have been logged out successfully",
      snackPosition: SnackPosition.TOP,
    );
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
