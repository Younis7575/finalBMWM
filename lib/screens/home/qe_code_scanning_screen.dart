import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:bmw_passes/constants/custom_button.dart';
import 'package:bmw_passes/constants/custom_color.dart';
import 'package:bmw_passes/screens/auth/login_screen.dart';
import 'package:bmw_passes/screens/home/user_detail_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/custom_style.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController();
  String? qrResult;
  double zoomValue = 0.0;
  bool isFetching = false;
  bool showErrorOverlay = false;
  String errorTitle = "";
  String errorSubtitle = "";

  /// ✅ Verify customer by QR result
  /// ✅ Verify customer by QR result
  Future<void> verifyCustomer(String customerId) async {
    if (isFetching) return;
    setState(() => isFetching = true);

    log("📌 Scanned Customer ID => $customerId"); // ✅ Print customer_id

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("access_token"); // ✅ fixed key
    log("Access Token => $token");

    if (token == null || token.isEmpty) {
      Get.snackbar("Error", "No access token found. Please login again.");
      Get.offAll(() => const LoginScreen());
      return;
    }

    var url = Uri.parse(
      "https://spmetesting.com/api/auth/verify-scanned-customer.php",
    );

    var response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        "X-API-ACCESS-TOKEN": token,
        "X-APP-KEY": "73706d652d6170706c69636174696f6e2d373836",
      },
      body: {
        "customer_id": customerId.trim(), // ✅ clean up QR string
      },
    );

    log("Verify API Response => ${response.body}");
    log("Verify API Token => $token");

    if (response.statusCode == 200 || response.statusCode == 201) {
      log("Verify API Status => ${response.statusCode}");
      var data = jsonDecode(response.body);
      if (data["status"] == "success") {
  /// ✅ Navigate with verified user data
  await Get.to(() => UserDetailScreen(userData: data["data"]));

  // 🔄 Reset after returning back
  setState(() {
    qrResult = null;
    isFetching = false;
  });
}


      // if (data["status"] == "success") {
      //   /// ✅ Navigate with verified user data
      //   Get.to(() => UserDetailScreen(userData: data["data"]));
      // } 
      else {
        /// ❌ Show Alert Box if customer not found
        _showErrorDialog(context, data["message"] ?? "Customer not found");
      }
    } else {
      _showErrorDialog(context, "Verification failed. Try again.");
    }
    setState(() => isFetching = false);
  }

  /// ❌ Show error dialog when user not found
  void _showErrorDialog(BuildContext context, String message) {
    setState(() {
      showErrorOverlay = true;
      errorTitle = "Verification Failed";
      errorSubtitle = message;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => showErrorOverlay = false);
      }
    });
  }

  /// ✅ Logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Logout",
                  style: CustomStyle.infoLabel.copyWith(
                    color: CustomColor.dot,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Are you sure you want to logout?",
                  textAlign: TextAlign.center,
                  style: CustomStyle.infoValue.copyWith(
                    color: CustomColor.contentText,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        "Cancel",
                        style: CustomStyle.infoValue.copyWith(
                          color: CustomColor.contentText,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();

                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.remove("access_token");

                        Get.offAll(() => const LoginScreen());
                      },
                      child: const Text("OK", style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  late AnimationController _animController;
  late Animation<double> _positionAnimation;

  @override
  void initState() {
    super.initState();

 
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _positionAnimation = Tween<double>(
      begin: -1,
      end: 1,
    ).animate(_animController);
  }

  @override
  void dispose() {
    controller.dispose();  
    _animController.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (defaultTargetPlatform == TargetPlatform.android) {
      controller.stop();
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double boxWidth = MediaQuery.of(context).size.width * 0.80;
    final double boxHeight = MediaQuery.of(context).size.height * 0.35;
    const double topOffset = 170;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            /// 📷 Camera Scanner
            MobileScanner(
              controller: controller,
              onDetect: (capture) {
  final List<Barcode> barcodes = capture.barcodes;
  for (final barcode in barcodes) {
    if (barcode.rawValue != null) {
      if (!isFetching) {
        qrResult = barcode.rawValue;
        verifyCustomer(qrResult!); // ✅ call API
      }
    }
  }
},

              // onDetect: (capture) {
              //   final List<Barcode> barcodes = capture.barcodes;
              //   for (final barcode in barcodes) {
              //     if (barcode.rawValue != null && !isFetching) {
              //       qrResult = barcode.rawValue;
              //       verifyCustomer(qrResult!); // ✅ call API
              //     }
              //   }
              // },
            ),

            /// 🌓 Overlay with transparent box
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                CustomColor.screenBackground,
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: topOffset),
                      child: Container(
                        width: boxWidth,
                        height: boxHeight,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 🔵 Blue corners
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: topOffset),
                child: SizedBox(
                  width: boxWidth,
                  height: boxHeight,
                  child: Stack(
                    children: [
                      _buildCorner(Alignment.topLeft),
                      _buildCorner(Alignment.topRight),
                      _buildCorner(Alignment.bottomLeft),
                      _buildCorner(Alignment.bottomRight),
                    ],
                  ),
                ),
              ),
            ),

            /// 🔴 Animated Red Line
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: topOffset),
                child: SizedBox(
                  width: boxWidth,
                  height: boxHeight,
                  child: AnimatedBuilder(
                    animation: _positionAnimation,
                    builder: (context, child) {
                      return Align(
                        alignment: Alignment(0, _positionAnimation.value),
                        child: Container(
                          width: boxWidth,
                          height: 3,
                          color: Colors.red,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            /// 🔙 Back & Logout
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                   
                    onPressed: () {
                      Get.back();
                    }, child: Text(""),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.logout_outlined,
                      color: CustomColor.mainText,
                      size: 25,
                    ),
                    onPressed: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),

            /// 📏 Zoom + Scan Button
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// 📏 Zoom Slider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.remove, color: CustomColor.slider),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                thumbShape: const ShadowSliderThumbShape(
                                  thumbRadius: 6,
                                ),
                              ),
                              child: Slider(
                                value: zoomValue,
                                min: 0.0,
                                max: 1.0,
                                activeColor: Colors.red,
                                onChanged: (val) async {
                                  setState(() => zoomValue = val);
                                  await controller.setZoomScale(val);
                                },
                              ),
                            ),
                          ),
                          const Icon(Icons.add, color: CustomColor.slider),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🔘 Manual Scan Button
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: 364,
                        height: 67,
                        child: GestureDetector(
                          onTap: () {
                            if (qrResult != null && qrResult!.isNotEmpty) {
                              verifyCustomer(qrResult!);
                            } else {
                              Get.snackbar("Error", "No QR code scanned yet!");
                            }
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: CustomColor.mainText,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              Positioned(
                                left: 120,
                                top: -40,
                                child: Image.asset(
                                  "assets/images/QR.1.png",
                                  width: 90,
                                  height: 90,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (showErrorOverlay) ...[
              /// Blur Background
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(color: Colors.black.withOpacity(0.3)),
                ),
              ),

              /// Styled Error Box
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// 🔴 Red Circle Icon
                      Image.asset(
                        "assets/images/error_info.png",
                        width: 60,
                        height: 60,
                      ),

                      const SizedBox(height: 20),

                      /// 📝 Error Message
                      Text(
                        "Oops! User not found",
                        style: CustomStyle.mainText.copyWith(
                          color: CustomColor.contentText,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 25),

                      /// 🔘 Scan More Button
                      Container(
                        width: 200,
                        child: CustomButton(
                          text: "Scan More",
                          onPressed: () {
                            setState(() => showErrorOverlay = false);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 🔵 Build corner edges
  Widget _buildCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          border: Border(
            top:
                alignment == Alignment.topLeft ||
                    alignment == Alignment.topRight
                ? const BorderSide(color: CustomColor.darkBlue, width: 20)
                : BorderSide.none,
            left:
                alignment == Alignment.topLeft ||
                    alignment == Alignment.bottomLeft
                ? const BorderSide(color: CustomColor.darkBlue, width: 20)
                : BorderSide.none,
            right:
                alignment == Alignment.topRight ||
                    alignment == Alignment.bottomRight
                ? const BorderSide(color: CustomColor.darkBlue, width: 20)
                : BorderSide.none,
            bottom:
                alignment == Alignment.bottomLeft ||
                    alignment == Alignment.bottomRight
                ? const BorderSide(color: CustomColor.darkBlue, width: 20)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }





}

/// ✅ Custom slider thumb
class ShadowSliderThumbShape extends SliderComponentShape {
  final double thumbRadius;

  const ShadowSliderThumbShape({this.thumbRadius = 8});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(center, thumbRadius + 2, shadowPaint);

    final thumbPaint = Paint()..color = sliderTheme.thumbColor ?? Colors.red;
    canvas.drawCircle(center, thumbRadius, thumbPaint);
  }
}
