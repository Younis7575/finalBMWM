import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:bmw_passes/constants/custom_button.dart';
import 'package:bmw_passes/constants/custom_color.dart';
import 'package:bmw_passes/screens/auth/login_screen.dart';
import 'package:bmw_passes/screens/home/user_detail_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController();
  String? qrResult;
  double zoomValue = 0.0;
  bool isFetching = false;
  bool showErrorOverlay = false;
  String errorTitle = "";
  String errorSubtitle = "";

  late AnimationController _animController;
  late Animation<double> _positionAnimation;

  late StreamSubscription<ConnectivityResult> _connectivitySub;
  bool _wasOffline = false;
  bool _isOnline = true;

  // ✅ NEW: Connection status bar variables
  bool _showConnectionBar = false;
  String _connectionBarText = "";
  Color _connectionBarColor = Colors.transparent;
  Timer? _connectionBarTimer;

  // Flags
  bool _isProcessingLogout = false;
  bool _isHandlingConnection = false;
  bool _isScreenActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isScreenActive = true;

    qrResult = null;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _positionAnimation = Tween<double>(
      begin: -1,
      end: 1,
    ).animate(_animController);

    // ✅ FIXED: Connection listener with status bar
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      if (!_isScreenActive || _isProcessingLogout) return;

      if (result == ConnectivityResult.none) {
        // 🔴 Internet off - Red line dikhao
        if (mounted && _isScreenActive) {
          setState(() {
            _isOnline = false;
            _wasOffline = true;
            _isHandlingConnection = false;
          });
          _showConnectionStatusBar("Connection is off", Colors.red);
        }
      } else {
        // 🟢 Internet on - Green line dikhao (only if was offline)
        if (_wasOffline && mounted && _isScreenActive) {
          setState(() {
            _isOnline = true;
            _wasOffline = false;
            _isHandlingConnection = false;
          });
          _showConnectionStatusBar("Connection is restore", Colors.green);
        } else {
          // First time online - no status bar
          setState(() {
            _isOnline = true;
          });
        }
      }
    });

    _checkInitialConnection();
  }

  // ✅ NEW: Connection status bar method
  void _showConnectionStatusBar(String message, Color color) {
    // Pehle existing timer cancel karo
    _connectionBarTimer?.cancel();

    if (mounted) {
      setState(() {
        _showConnectionBar = true;
        _connectionBarText = message;
        _connectionBarColor = color;
      });
    }

    // 5 seconds baad auto-hide
    _connectionBarTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _isScreenActive) {
        setState(() {
          _showConnectionBar = false;
          _connectionBarText = "";
          _connectionBarColor = Colors.transparent;
        });
      }
    });
  }

  // ✅ NEW: Initial connection status check
  Future<void> _checkInitialConnection() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        if (mounted) {
          setState(() {
            _isOnline = false;
            _wasOffline = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isOnline = true;
            _wasOffline = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isOnline = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _isScreenActive = false;
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySub.cancel();
    _connectionBarTimer?.cancel();
    _animController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isScreenActive) return;

    if (state == AppLifecycleState.resumed && !_isProcessingLogout) {
      _checkTokenOnResume();
    }
  }

  void _resetScreenState() {
    if (mounted) {
      setState(() {
        showErrorOverlay = false;
        errorTitle = "";
        errorSubtitle = "";
        isFetching = false;
        qrResult = null;
        _wasOffline = false;
        _isHandlingConnection = false;
        _isOnline = true;
        _showConnectionBar = false;
        _connectionBarText = "";
        _connectionBarColor = Colors.transparent;
      });
    }
    _connectionBarTimer?.cancel();
  }

  Future<void> _checkTokenOnResume() async {
    if (mounted && !_isProcessingLogout && _isScreenActive) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      if (token == null || token.isEmpty) {
        await _handleTokenExpired();
      } else {
        _resetScreenState();
      }
    }
  }

  /// ✅ FIXED: Verify customer with connection check
  Future<void> verifyCustomer(String customerId) async {
    // 🔴 NEW: Agar internet off hai toh scan block karo
    if (!_isOnline) {
      _showConnectionStatusBar("Connection is off", Colors.red);
      return;
    }

    if (isFetching ||
        _isProcessingLogout ||
        _isHandlingConnection ||
        !_isScreenActive)
      return;

    setState(() => isFetching = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("access_token");

    if (token == null || token.isEmpty) {
      if (mounted && _isScreenActive) {
        setState(() => isFetching = false);
        await _handleTokenExpired();
      }
      return;
    }

    try {
      var url = Uri.parse(
        "https://spmetesting.com/api/auth/verify-scanned-customer.php",
      );

      var response = await http
          .post(
            url,
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/x-www-form-urlencoded",
              "X-API-ACCESS-TOKEN": token,
              "X-APP-KEY": "73706d652d6170706c69636174696f6e2d373836",
            },
            body: {"customer_id": customerId.trim()},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = jsonDecode(response.body);
        if (data["status"] == "success") {
          if (mounted &&
              !_isProcessingLogout &&
              !_isHandlingConnection &&
              _isScreenActive) {
            Get.to(() => UserDetailScreen(userData: data["data"]));
          }
        } else if (data["message"].toString().toLowerCase().contains("token")) {
          await _handleTokenExpired();
        } else {
          _showErrorDialog("User not found");
        }
      } else if (response.statusCode == 401) {
        await _handleTokenExpired();
      } else {
        _showErrorDialog("Oops! User not found");
      }
    } catch (e) {
      if (e is TimeoutException) {
        _showErrorDialog("Request timeout. Please try again.");
      } else {
        _showErrorDialog("Check Internet Connection");
      }
    } finally {
      if (mounted &&
          !_isProcessingLogout &&
          !_isHandlingConnection &&
          _isScreenActive) {
        setState(() {
          isFetching = false;
          qrResult = null;
        });
      }
    }
  }

  Future<void> _handleTokenExpired() async {
    if (_isProcessingLogout || _isHandlingConnection || !_isScreenActive)
      return;

    _connectionBarTimer?.cancel();

    if (mounted) {
      setState(() {
        isFetching = false;
        showErrorOverlay = false;
      });
    }

    await Future.delayed(const Duration(milliseconds: 150));

    if (mounted &&
        !_isProcessingLogout &&
        !_isHandlingConnection &&
        _isScreenActive) {
      setState(() {
        showErrorOverlay = true;
        errorTitle = "Session Expired";
        errorSubtitle = "Your token has expired. Please login again.";
      });
    }
  }

  /// ✅ FIXED: Error dialog
  void _showErrorDialog(String message, {bool showLoginButton = false}) {
    if (_isProcessingLogout || _isHandlingConnection || !_isScreenActive)
      return;

    _connectionBarTimer?.cancel();

    if (mounted) {
      setState(() {
        showErrorOverlay = false;
      });
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted &&
          !_isProcessingLogout &&
          !_isHandlingConnection &&
          _isScreenActive) {
        setState(() {
          showErrorOverlay = true;
          errorTitle = "Verification Failed";
          errorSubtitle = message;
          qrResult = null;
        });

        if (!showLoginButton) {
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted &&
                !_isProcessingLogout &&
                !_isHandlingConnection &&
                _isScreenActive) {
              setState(() {
                showErrorOverlay = false;
              });
            }
          });
        }
      }
    });
  }

  /// ✅ FIXED: Logout method
  Future<void> _performLogout() async {
    if (_isProcessingLogout) return;

    _isProcessingLogout = true;
    _isHandlingConnection = false;
    _isScreenActive = false;
    _connectionBarTimer?.cancel();

    try {
      if (mounted) {
        setState(() {
          isFetching = false;
          showErrorOverlay = false;
          errorTitle = "";
          errorSubtitle = "";
          qrResult = null;
          _wasOffline = false;
          _showConnectionBar = false;
          _connectionBarText = "";
          _connectionBarColor = Colors.transparent;
        });
      }

      await Future.delayed(const Duration(milliseconds: 200));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } finally {
      _isProcessingLogout = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      _isScreenActive = true;
      _resetScreenState();
    }
  }

  /// ✅ FIXED: Logout dialog
  void _showLogoutDialog(BuildContext context) {
    if (_isProcessingLogout) return;

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
                        await _performLogout();
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

  @override
  void reassemble() {
    super.reassemble();
    if (!_isScreenActive) return;

    if (defaultTargetPlatform == TargetPlatform.android) controller.stop();
    if (defaultTargetPlatform == TargetPlatform.iOS) controller.start();
  }

  // ✅ FIXED: UI without WiFi icon, with connection status bar
  @override
  Widget build(BuildContext context) {
    final double boxWidth = MediaQuery.of(context).size.width * 0.80;
    final double boxHeight = MediaQuery.of(context).size.height * 0.35;
    const double topOffset = 170;

    return Scaffold(
      backgroundColor: CustomColor.screenBackground,
      body: SafeArea(
        child: Stack(
          children: [
            MobileScanner(
              controller: controller,
              onDetect: (capture) {
                // 🔴 NEW: Internet check before scanning
                if (!_isOnline) {
                  _showConnectionStatusBar("Connection is off", Colors.red);
                  return;
                }

                if (_isProcessingLogout ||
                    _isHandlingConnection ||
                    !_isScreenActive)
                  return;

                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null &&
                      !isFetching &&
                      !_isProcessingLogout &&
                      !_isHandlingConnection &&
                      _isScreenActive) {
                    qrResult = barcode.rawValue;
                    verifyCustomer(qrResult!);
                  }
                }
              },
            ),

            // ✅ CONNECTION STATUS BAR (Top par)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: _showConnectionBar ? 0 : -50, // Animate from top
              left: 0,
              right: 0,
              child: Container(
                height: 40,
                color: _connectionBarColor,
                child: Center(
                  child: Text(
                    _connectionBarText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Overlay
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

            // Blue corners
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

            // Animated Red Line
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

            // ✅ FIXED: Only Logout Button (WiFi icon removed)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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

            // Zoom + Manual Scan
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Zoom Slider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove,
                              color: CustomColor.slider,
                            ),
                            onPressed: () async {
                              setState(() {
                                zoomValue = (zoomValue - 0.1).clamp(0.0, 1.0);
                              });
                              await controller.setZoomScale(zoomValue);
                            },
                          ),
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
                          IconButton(
                            icon: const Icon(
                              Icons.add,
                              color: CustomColor.slider,
                            ),
                            onPressed: () async {
                              setState(() {
                                zoomValue = (zoomValue + 0.1).clamp(0.0, 1.0);
                              });
                              await controller.setZoomScale(zoomValue);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Manual Scan Button
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: GestureDetector(
                        onTap: () {
                          if (!_isOnline) {
                            _showConnectionStatusBar(
                              "Connection is off",
                              Colors.red,
                            );
                            return;
                          }

                          if (qrResult != null &&
                              qrResult!.isNotEmpty &&
                              !_isProcessingLogout) {
                            verifyCustomer(qrResult!);
                          } else {
                            Get.snackbar("Error", "No QR code scanned yet!");
                          }
                        },
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final screenWidth = MediaQuery.of(
                              context,
                            ).size.width;
                            return SizedBox(
                              width: screenWidth * 0.9,
                              height: 60,
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
                                    left: screenWidth * 0.35,
                                    top: -30,
                                    child: Image.asset(
                                      "assets/images/QR.1.png",
                                      width: screenWidth * 0.2,
                                      height: screenWidth * 0.2,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Error Overlay (for token expired etc.) - SAME AS BEFORE
            if (showErrorOverlay &&
                !_isProcessingLogout &&
                _isScreenActive) ...[
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(color: Colors.black.withOpacity(0.3)),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.19,
                left: 0,
                right: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 300,
                  padding: const EdgeInsets.all(26),
                  margin: const EdgeInsets.symmetric(horizontal: 49),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/images/error_info.png",
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        errorSubtitle.isNotEmpty
                            ? errorSubtitle
                            : "Oops! User not found",
                        style: CustomStyle.mainText.copyWith(
                          color: CustomColor.contentText,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: 200,
                        child: CustomButton(
                          text:
                              errorSubtitle.contains("expired") ||
                                  errorSubtitle.contains(
                                    "Connection restored",
                                  ) ||
                                  errorSubtitle.contains(
                                    "Connection Restored",
                                  ) ||
                                  errorSubtitle.contains("Internet")
                              ? "OK"
                              : "Scan More",
                          onPressed: () async {
                            if (mounted &&
                                !_isProcessingLogout &&
                                !_isHandlingConnection &&
                                _isScreenActive) {
                              setState(() => showErrorOverlay = false);
                            }
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

  Widget _buildCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          border: Border(
            top:
                alignment == Alignment.topLeft ||
                    alignment == Alignment.topRight
                ? const BorderSide(color: CustomColor.mainText, width: 15)
                : BorderSide.none,
            left:
                alignment == Alignment.topLeft ||
                    alignment == Alignment.bottomLeft
                ? const BorderSide(color: CustomColor.mainText, width: 15)
                : BorderSide.none,
            right:
                alignment == Alignment.topRight ||
                    alignment == Alignment.bottomRight
                ? const BorderSide(color: CustomColor.mainText, width: 15)
                : BorderSide.none,
            bottom:
                alignment == Alignment.bottomLeft ||
                    alignment == Alignment.bottomRight
                ? const BorderSide(color: CustomColor.mainText, width: 15)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

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
