import 'package:bmw_passes/screens/auth/login_screen.dart';
import 'package:bmw_passes/screens/home/qe_code_scanning_screen.dart';
import 'package:bmw_passes/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ✅ Check if session is still valid
Future<bool> isSessionValid() async {
  final prefs = await SharedPreferences.getInstance();
  final loginTime = prefs.getInt('loginTime');  

  if (loginTime == null) return false;

  final now = DateTime.now().millisecondsSinceEpoch;
  final diff = now - loginTime;

  // 30 days in milliseconds
  const thirtyDays = 30 * 24 * 60 * 60 * 1000;

  if (diff >= thirtyDays) {
    // Session expired → clear storage
    await prefs.clear();
    return false;
  }
  return true;
}

/// ✅ Request all required permissions
Future<void> requestAllPermissions() async {
  final statuses = await [
    Permission.camera,
    Permission.microphone,
    Permission.location,
    Permission.storage,      // works until API 32
    Permission.photos,       // iOS only
    Permission.videos,       // iOS only
    Permission.audio,        // iOS only
  ].request();

  statuses.forEach((perm, status) {
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  });
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request all permissions at app startup
  await requestAllPermissions();

  // Check if user is logged in & session is valid
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
      home: SplashScreen(),
    );
  }
}
