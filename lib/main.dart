 
// // import 'dart:io';
// // import 'package:bmw_passes/screens/splash/splash_screen.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:permission_handler/permission_handler.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

 
// // Future<void> requestCameraPermission() async {
// //   final status = await Permission.camera.request();

// //   if (status.isGranted) {
// //     debugPrint("✅ Camera permission granted");
// //   } else if (status.isDenied) {
// //     debugPrint("❌ Camera permission denied (user can allow again)");
 
// //     if (Platform.isIOS) {
// //       Get.defaultDialog(
// //         title: "Permission Needed",
// //         middleText:
// //             "Camera access is required to scan QR codes. "
// //             "Please allow it from Settings if you denied it.",
// //         textConfirm: "OK",
// //         onConfirm: () => Get.back(),
// //       );
// //     }
// //   } else if (status.isPermanentlyDenied) {
// //     debugPrint("⚠️ Camera permission permanently denied");
// //     Get.defaultDialog(
// //       title: "Permission Required",
// //       middleText:
// //           "Camera access is needed to scan QR codes. Please enable it in Settings.",
// //       textConfirm: "Go to Settings",
// //       textCancel: "Cancel",
// //       onConfirm: () {
// //         openAppSettings();
// //       },
// //     );
// //   }
// // }
 
// // Future<bool> isSessionValid() async {
// //   final prefs = await SharedPreferences.getInstance();
// //   final loginTime = prefs.getString("login_time");
// //   final token = prefs.getString("access_token");

// //   if (token == null || loginTime == null) return false;

// //   final loginDate = DateTime.parse(loginTime);
// //   final now = DateTime.now();
// //   final diff = now.difference(loginDate).inMinutes;

// //   if (diff > 5) {
// //     await prefs.clear();
// //     return false;
// //   }
// //   return true;
// // }

// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
 
// //   bool loggedIn = await isSessionValid();

// //   runApp(MyApp(loggedIn: loggedIn));
// // }

// // class MyApp extends StatelessWidget {
// //   final bool loggedIn;
// //   const MyApp({super.key, required this.loggedIn});

// //   @override
// //   Widget build(BuildContext context) {
// //     return GetMaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       title: 'M Passes',
// //       theme: ThemeData(
// //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
// //       ), 
// //       home: const SplashScreen(),
// //     );
// //   }
// // }


// import 'dart:async';
// import 'dart:convert';
// import 'dart:ui';
// import 'package:bmw_passes/constants/custom_button.dart';
// import 'package:bmw_passes/constants/custom_color.dart';
// import 'package:bmw_passes/screens/auth/login_screen.dart';
// import 'package:bmw_passes/screens/home/user_detail_screen.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../constants/custom_style.dart';

// class QrScanScreen extends StatefulWidget {
//   const QrScanScreen({super.key});

//   @override
//   State<QrScanScreen> createState() => _QrScanScreenState();
// }

// class _QrScanScreenState extends State<QrScanScreen>
//     with SingleTickerProviderStateMixin, WidgetsBindingObserver {
//   final MobileScannerController controller = MobileScannerController();
//   String? qrResult;
//   double zoomValue = 0.0;
//   bool isFetching = false;
//   bool showErrorOverlay = false;
//   String errorTitle = "";
//   String errorSubtitle = "";

//   late AnimationController _animController;
//   late Animation<double> _positionAnimation;

//   late StreamSubscription<ConnectivityResult> _connectivitySub;
//   bool _wasOffline = false;
//   bool _isOnline = true;

//   bool _showConnectionBar = false;
//   String _connectionBarText = "";
//   Color _connectionBarColor = Colors.transparent;
//   Timer? _connectionBarTimer;

//   bool _isProcessingLogout = false;
//   bool _isHandlingConnection = false;
//   bool _isScreenActive = true;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _isScreenActive = true;

//     qrResult = null;

//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat(reverse: true);

//     _positionAnimation = Tween<double>(
//       begin: -1,
//       end: 1,
//     ).animate(_animController);

//     _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
//       if (!_isScreenActive || _isProcessingLogout) return;

//       if (result == ConnectivityResult.none) {
//         if (mounted && _isScreenActive) {
//           setState(() {
//             _isOnline = false;
//             _wasOffline = true;
//             _isHandlingConnection = false;
//           });
//           _showConnectionStatusBar("Connection is off", Colors.red);
//         }
//       } else {
//         if (_wasOffline && mounted && _isScreenActive) {
//           setState(() {
//             _isOnline = true;
//             _wasOffline = false;
//             _isHandlingConnection = false;
//           });
//           _showConnectionStatusBar("Connection is restore", Colors.green);
//         } else {
//           setState(() {
//             _isOnline = true;
//           });
//         }
//       }
//     });

//     _checkInitialConnection();
//   }

//   void _showConnectionStatusBar(String message, Color color) {
//     _connectionBarTimer?.cancel();

//     if (mounted) {
//       setState(() {
//         _showConnectionBar = true;
//         _connectionBarText = message;
//         _connectionBarColor = color;
//       });
//     }

//     _connectionBarTimer = Timer(const Duration(seconds: 5), () {
//       if (mounted && _isScreenActive) {
//         setState(() {
//           _showConnectionBar = false;
//           _connectionBarText = "";
//           _connectionBarColor = Colors.transparent;
//         });
//       }
//     });
//   }

//   Future<void> _checkInitialConnection() async {
//     try {
//       var connectivityResult = await Connectivity().checkConnectivity();
//       if (connectivityResult == ConnectivityResult.none) {
//         if (mounted) {
//           setState(() {
//             _isOnline = false;
//             _wasOffline = true;
//           });
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             _isOnline = true;
//             _wasOffline = false;
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isOnline = true;
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _isScreenActive = false;
//     WidgetsBinding.instance.removeObserver(this);
//     _connectivitySub.cancel();
//     _connectionBarTimer?.cancel();
//     _animController.dispose();
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (!_isScreenActive) return;

//     if (state == AppLifecycleState.resumed && !_isProcessingLogout) {
//       _checkTokenOnResume();
//     }
//   }

//   void _resetScreenState() {
//     if (mounted) {
//       setState(() {
//         showErrorOverlay = false;
//         errorTitle = "";
//         errorSubtitle = "";
//         isFetching = false;
//         qrResult = null;
//         _wasOffline = false;
//         _isHandlingConnection = false;
//         _isOnline = true;
//         _showConnectionBar = false;
//         _connectionBarText = "";
//         _connectionBarColor = Colors.transparent;
//       });
//     }
//     _connectionBarTimer?.cancel();
//   }

//   Future<void> _checkTokenOnResume() async {
//     if (mounted && !_isProcessingLogout && _isScreenActive) {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString("access_token");
//       if (token == null || token.isEmpty) {
//         await _handleTokenExpired();
//       } else {
//         _resetScreenState();
//       }
//     }
//   }

//   Future<void> verifyCustomer(String customerId) async {
//     if (!_isOnline) {
//       _showConnectionStatusBar("Connection is off", Colors.red);
//       return;
//     }

//     if (isFetching ||
//         _isProcessingLogout ||
//         _isHandlingConnection ||
//         !_isScreenActive) return;

//     setState(() => isFetching = true);

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString("access_token");

//     if (token == null || token.isEmpty) {
//       if (mounted && _isScreenActive) {
//         setState(() => isFetching = false);
//         await _handleTokenExpired();
//       }
//       return;
//     }

//     try {
//       var url = Uri.parse(
//         "https://spmetesting.com/api/auth/verify-scanned-customer.php",
//       );

//       var response = await http
//           .post(
//             url,
//             headers: {
//               "Accept": "application/json",
//               "Content-Type": "application/x-www-form-urlencoded",
//               "X-API-ACCESS-TOKEN": token,
//               "X-APP-KEY": "73706d652d6170706c69636174696f6e2d373836",
//             },
//             body: {"customer_id": customerId.trim()},
//           )
//           .timeout(const Duration(seconds: 30));

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         var data = jsonDecode(response.body);
//         if (data["status"] == "success") {
//           if (mounted &&
//               !_isProcessingLogout &&
//               !_isHandlingConnection &&
//               _isScreenActive) {
//             Get.to(() => UserDetailScreen(userData: data["data"]));
//           }
//         } else if (data["message"].toString().toLowerCase().contains("token")) {
//           await _handleTokenExpired();
//         } else {
//           _showErrorDialog("User not found");
//         }
//       } else if (response.statusCode == 401) {
//         await _handleTokenExpired();
//       } else {
//         _showErrorDialog("Oops! User not found");
//       }
//     } catch (e) {
//       if (e is TimeoutException) {
//         _showErrorDialog("Request timeout. Please try again.");
//       } else {
//         _showErrorDialog("Check Internet Connection");
//       }
//     } finally {
//       if (mounted &&
//           !_isProcessingLogout &&
//           !_isHandlingConnection &&
//           _isScreenActive) {
//         setState(() {
//           isFetching = false;
//           qrResult = null;
//         });
//       }
//     }
//   }

//   Future<void> _handleTokenExpired() async {
//     if (_isProcessingLogout || _isHandlingConnection || !_isScreenActive) return;

//     _connectionBarTimer?.cancel();

//     if (mounted) {
//       setState(() {
//         isFetching = false;
//         showErrorOverlay = false;
//       });
//     }

//     await Future.delayed(const Duration(milliseconds: 150));

//     if (mounted &&
//         !_isProcessingLogout &&
//         !_isHandlingConnection &&
//         _isScreenActive) {
//       setState(() {
//         showErrorOverlay = true;
//         errorTitle = "Session Expired";
//         errorSubtitle = "Your token has expired. Please login again.";
//       });
//     }
//   }

//   /// ✅ FIXED — Popup stays until button pressed
//   void _showErrorDialog(String message, {bool showLoginButton = false}) {
//     if (_isProcessingLogout || _isHandlingConnection || !_isScreenActive) return;

//     _connectionBarTimer?.cancel();

//     if (mounted) {
//       setState(() {
//         showErrorOverlay = false;
//       });
//     }

//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (mounted &&
//           !_isProcessingLogout &&
//           !_isHandlingConnection &&
//           _isScreenActive) {
//         setState(() {
//           showErrorOverlay = true;
//           errorTitle = "Verification Failed";
//           errorSubtitle = message;
//           qrResult = null;
//         });
//       }
//     });
//   }

//   Future<void> _performLogout() async {
//     if (_isProcessingLogout) return;

//     _isProcessingLogout = true;
//     _isHandlingConnection = false;
//     _isScreenActive = false;
//     _connectionBarTimer?.cancel();

//     try {
//       if (mounted) {
//         setState(() {
//           isFetching = false;
//           showErrorOverlay = false;
//           errorTitle = "";
//           errorSubtitle = "";
//           qrResult = null;
//           _wasOffline = false;
//           _showConnectionBar = false;
//           _connectionBarText = "";
//           _connectionBarColor = Colors.transparent;
//         });
//       }

//       await Future.delayed(const Duration(milliseconds: 200));

//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.clear();

//       if (defaultTargetPlatform == TargetPlatform.iOS) {
//         await Future.delayed(const Duration(milliseconds: 300));
//       }

//       if (mounted) {
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (context) => const LoginScreen()),
//           (Route<dynamic> route) => false,
//         );
//       }
//     } finally {
//       _isProcessingLogout = false;
//     }
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (ModalRoute.of(context)?.isCurrent ?? false) {
//       _isScreenActive = true;
//       _resetScreenState();
//     }
//   }

//   void _showLogoutDialog(BuildContext context) {
//     if (_isProcessingLogout) return;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Container(
//             width: MediaQuery.of(context).size.width * 0.8,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   "Logout",
//                   style: CustomStyle.infoLabel.copyWith(
//                     color: CustomColor.dot,
//                     fontSize: 22,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   "Are you sure you want to logout?",
//                   textAlign: TextAlign.center,
//                   style: CustomStyle.infoValue.copyWith(
//                     color: CustomColor.contentText,
//                   ),
//                 ),
//                 const SizedBox(height: 25),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.grey[100],
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 25,
//                           vertical: 12,
//                         ),
//                       ),
//                       onPressed: () => Navigator.of(context).pop(),
//                       child: Text(
//                         "Cancel",
//                         style: CustomStyle.infoValue.copyWith(
//                           color: CustomColor.contentText,
//                         ),
//                       ),
//                     ),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 30,
//                           vertical: 12,
//                         ),
//                       ),
//                       onPressed: () async {
//                         Navigator.of(context).pop();
//                         await _performLogout();
//                       },
//                       child: const Text("OK", style: TextStyle(fontSize: 16)),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   void reassemble() {
//     super.reassemble();
//     if (!_isScreenActive) return;
//     if (defaultTargetPlatform == TargetPlatform.android) controller.stop();
//     if (defaultTargetPlatform == TargetPlatform.iOS) controller.start();
//   }

//   // 🖼️ BUILD METHOD SAME DESIGN
//   @override
//   Widget build(BuildContext context) {
//     // 👇 same UI code as before (no design changes)
//     // (omitted here for brevity, since only _showErrorDialog changed)
//     // Paste your build() and helper widgets as-is.
//     // ...
//     return Scaffold(
//       backgroundColor: CustomColor.screenBackground,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             // 👇 keep your scanner + UI here (unchanged)
//             // ...
//           ],
//         ),
//       ),
//     );
//   }
// }

// class ShadowSliderThumbShape extends SliderComponentShape {
//   final double thumbRadius;
//   const ShadowSliderThumbShape({this.thumbRadius = 8});

//   @override
//   Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
//       Size.fromRadius(thumbRadius);

//   @override
//   void paint(
//     PaintingContext context,
//     Offset center, {
//     required Animation<double> activationAnimation,
//     required Animation<double> enableAnimation,
//     required bool isDiscrete,
//     required TextPainter labelPainter,
//     required RenderBox parentBox,
//     required SliderThemeData sliderTheme,
//     required TextDirection textDirection,
//     required double value,
//     required double textScaleFactor,
//     required Size sizeWithOverflow,
//   }) {
//     final Canvas canvas = context.canvas;
//     final shadowPaint = Paint()
//       ..color = Colors.black.withOpacity(0.3)
//       ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
//     canvas.drawCircle(center, thumbRadius + 2, shadowPaint);

//     final thumbPaint = Paint()..color = sliderTheme.thumbColor ?? Colors.red;
//     canvas.drawCircle(center, thumbRadius, thumbPaint);
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/splash/splash_screen.dart';

Future<void> requestCameraPermission() async {
  final status = await Permission.camera.request();
  if (status.isGranted) {
    debugPrint("✅ Camera permission granted");
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
  WidgetsFlutterBinding.ensureInitialized(); // ✅ important line

  await requestCameraPermission();
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
      title: 'M Passes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
    );
  }
}
