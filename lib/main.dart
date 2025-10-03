 
import 'dart:io';
import 'package:bmw_passes/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

 
Future<void> requestCameraPermission() async {
  final status = await Permission.camera.request();

  if (status.isGranted) {
    debugPrint("✅ Camera permission granted");
  } else if (status.isDenied) {
    debugPrint("❌ Camera permission denied (user can allow again)");
 
    if (Platform.isIOS) {
      Get.defaultDialog(
        title: "Permission Needed",
        middleText:
            "Camera access is required to scan QR codes. "
            "Please allow it from Settings if you denied it.",
        textConfirm: "OK",
        onConfirm: () => Get.back(),
      );
    }
  } else if (status.isPermanentlyDenied) {
    debugPrint("⚠️ Camera permission permanently denied");
    Get.defaultDialog(
      title: "Permission Required",
      middleText:
          "Camera access is needed to scan QR codes. Please enable it in Settings.",
      textConfirm: "Go to Settings",
      textCancel: "Cancel",
      onConfirm: () {
        openAppSettings();
      },
    );
  }
}
 
Future<bool> isSessionValid() async {
  final prefs = await SharedPreferences.getInstance();
  final loginTime = prefs.getString("login_time");
  final token = prefs.getString("access_token");

  if (token == null || loginTime == null) return false;

  final loginDate = DateTime.parse(loginTime);
  final now = DateTime.now();
  final diff = now.difference(loginDate).inMinutes;

  if (diff > 5) {
    await prefs.clear();
    return false;
  }
  return true;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
  bool loggedIn = await isSessionValid();

  runApp(MyApp(loggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool loggedIn;
  const MyApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BMW Passes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ), 
      home: const SplashScreen(),
    );
  }
}
