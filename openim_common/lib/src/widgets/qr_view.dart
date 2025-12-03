import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:openim_common/openim_common.dart'
    hide Config; // hide exported Config to use explicit alias only
import 'package:openim_common/src/config.dart'
    as appcfg; // use appcfg.Config everywhere
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';

import 'qr_scan_box.dart';

class QrcodeView extends StatefulWidget {
  const QrcodeView({super.key});

  @override
  State<QrcodeView> createState() => _QrcodeViewState();
}

class _QrcodeViewState extends State<QrcodeView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Removed unused ImagePicker instance (_picker)
  MobileScannerController controller = MobileScannerController();

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  AnimationController? _animationController;
  Timer? _timer;
  var scanArea = 280.w;
  var cutOutBottomOffset = 40.h;
  bool _isProcessing = false; // Flag to prevent multiple scans

  void _upState() {
    setState(() {});
  }

  @override
  void initState() {
    _initAnimation();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    _clearAnimation();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app comes back to foreground, resume scanning
    if (state == AppLifecycleState.resumed) {
      // Reset processing flag and resume camera
      _isProcessing = false;
      controller.start();
    } else if (state == AppLifecycleState.paused) {
      // When app goes to background, pause scanning
      controller.stop();
    }
  }

  void _initAnimation() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _animationController!
      ..addListener(_upState)
      ..addStatusListener((state) {
        if (state == AnimationStatus.completed) {
          _timer = Timer(const Duration(seconds: 1), () {
            _animationController?.reverse(from: 1.0);
          });
        } else if (state == AnimationStatus.dismissed) {
          _timer = Timer(const Duration(seconds: 1), () {
            _animationController?.forward(from: 0.0);
          });
        }
      });
    _animationController!.forward(from: 0.0);
  }

  void _clearAnimation() {
    _timer?.cancel();
    if (_animationController != null) {
      _animationController?.dispose();
      _animationController = null;
    }
  }

  void _pickAndScanImage() async {
    final List<AssetEntity>? assets = await AssetPicker.pickAssets(
      Get.context!,
      pickerConfig: AssetPickerConfig(
        maxAssets: 1,
        requestType: RequestType.image,
        selectPredicate: (_, entity, isSelected) async {
          if (entity.type == AssetType.image) {
            return true;
          }
          return false;
        },
      ),
    );

    if (null != assets && assets.isNotEmpty) {
      final asset = assets.first;
      final file = await asset.file;
      if (file != null) {
        final barcode = await MobileScannerController().analyzeImage(file.path);
        if (barcode != null && barcode.barcodes.isNotEmpty) {
          final result = barcode.barcodes.first.rawValue;
          if (result != null) {
            _parse(result);
          }
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimationLimiter(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF8FAFC),
                Color(0xFFF1F5F9),
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: <Widget>[
                _buildQrView(),
                _scanOverlay(),
                _buildBackButton(),
                _buildToolsPanel(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolsPanel() => Positioned(
        bottom: 60.h,
        left: 0,
        right: 0,
        child: AnimationConfiguration.staggeredList(
          position: 0,
          duration: const Duration(milliseconds: 400),
          child: SlideAnimation(
            verticalOffset: 40.0,
            curve: Curves.easeOutCubic,
            child: FadeInAnimation(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 24.w),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9CA3AF).withOpacity(0.08),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFF3F4F6),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildToolButton(
                      onTap: () => Permissions.photos(_pickAndScanImage),
                      icon: CupertinoIcons.photo,
                      iconColor: const Color(0xFF757575), // AppColor.iconColor,
                      label: StrRes.gallery,
                    ),
                    Container(
                      width: 1.w,
                      height: 40.h,
                      color: const Color(0xFFF3F4F6),
                    ),
                    ValueListenableBuilder<MobileScannerState>(
                      valueListenable: controller,
                      builder: (context, state, child) {
                        final TorchState torchState = state.torchState;

                        if (torchState == TorchState.unavailable) {
                          return _buildToolButton(
                            onTap: () => controller.toggleTorch(),
                            icon: CupertinoIcons.lightbulb_slash,
                            iconColor:
                                const Color(0xFF757575), // AppColor.iconColor,
                            label: StrRes.flashUnavailable,
                          );
                        }

                        return _buildToolButton(
                          onTap: () => controller.toggleTorch(),
                          icon: torchState == TorchState.on
                              ? CupertinoIcons.lightbulb_fill
                              : CupertinoIcons.lightbulb,
                          iconColor: torchState == TorchState.on
                              ? const Color(0xFFFBBF24)
                              : const Color(0xFF757575), // AppColor.iconColor,
                          label: torchState == TorchState.on
                              ? StrRes.flashlightOff
                              : StrRes.flashlightOn,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildToolButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color iconColor,
    required String label,
  }) =>
      Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42.w,
                  height: 42.h,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFFF3F4F6),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 20.w,
                    color: iconColor,
                  ),
                ),
                8.verticalSpace,
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _scanOverlay() => Positioned(
        top: 200.h,
        left: 0,
        right: 0,
        child: AnimationConfiguration.staggeredList(
          position: 1,
          duration: const Duration(milliseconds: 400),
          child: FadeInAnimation(
            curve: Curves.easeOutCubic,
            child: Center(
              child: Container(
                padding: EdgeInsets.only(bottom: cutOutBottomOffset),
                child: CustomPaint(
                  size: Size(scanArea, scanArea),
                  painter: QrScanBoxPainter(
                    boxLineColor: const Color(0xFF4F42FF),
                    animationValue: _animationController?.value ?? 0,
                    isForward:
                        _animationController?.status == AnimationStatus.forward,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
  Widget _buildBackButton() => Positioned(
        top: 20.h,
        left: 20.w,
        child: AnimationConfiguration.staggeredList(
          position: 2,
          duration: const Duration(milliseconds: 400),
          child: SlideAnimation(
            horizontalOffset: -20.0,
            curve: Curves.easeOutCubic,
            child: FadeInAnimation(
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 42.w,
                  height: 42.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9CA3AF).withOpacity(0.08),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowLeft01,
                    size: 20.w,
                    color: const Color(0xFF757575), // AppColor.iconColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildQrView() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1F2937),
              Color(0xFF111827),
            ],
          ),
        ),
        child: MobileScanner(
          controller: controller,
          onDetect: (capture) {
            // Prevent multiple scans while processing
            if (_isProcessing) return;

            final barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              _isProcessing = true;
              controller.stop();
              _parse(barcodes.first.displayValue);
            }
          },
        ),
      ),
    );
  }

  void _parse(String? result) async {
    if (null != result) {
      if (result.startsWith(appcfg.Config.friendScheme)) {
        // Friend QR code - navigate to user profile
        var userID = result.substring(appcfg.Config.friendScheme.length);
        PackageBridge.scanBridge!.scanOutUserID(userID);
      } else if (result.startsWith(appcfg.Config.groupScheme)) {
        // Group QR code - navigate to group
        var groupID = result.substring(appcfg.Config.groupScheme.length);
        PackageBridge.scanBridge!.scanOutGroupID(groupID);
      } else if (IMUtils.isUrlValid(result)) {
        // Valid URL - launch in browser
        final uri = Uri.parse(Uri.encodeFull(result));
        try {
          final launched =
              await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!launched) {
            // Failed to launch URL
            IMViews.showToast(StrRes.cannotRecognize);
            _isProcessing = false;
            controller.start();
          }
          // If launched successfully, the app will go to background
          // and didChangeAppLifecycleState will handle resuming when user comes back
        } catch (e) {
          // Error launching URL
          IMViews.showToast(StrRes.cannotRecognize);
          _isProcessing = false;
          controller.start();
        }
      } else {
        // Other QR code - return result and close
        Get.back(result: result);
        IMViews.showToast(StrRes.scanResult.trArgs([result]));
      }
    } else {
      // Invalid QR code
      Get.back();
      IMViews.showToast(StrRes.cannotRecognize);
    }
  }
}
