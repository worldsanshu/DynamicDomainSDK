// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:openim/pages/mine/edit_my_info/edit_my_info_logic.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/controller/im_controller.dart';
import '../../../core/controller/trtc_controller.dart';

class MyInfoLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  final trtcLogic = Get.find<TRTCController>();

  final userInfo =
      UserFullInfo.fromJson(OpenIM.iMManager.userInfo.toJson()).obs;

  void editMyName() => editNameBottomSheet();

  void editNameBottomSheet() {
    final nameController = TextEditingController();
    nameController.text = imLogic.userInfo.value.nickname ?? '';

    Get.bottomSheet(
      barrierColor: Colors.transparent,
      Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32.r),
                topRight: Radius.circular(32.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9CA3AF).withOpacity(0.08),
                  offset: const Offset(0, -3),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.only(top: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),

                // Title Section
                Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedUser,
                        size: 24.w,
                        color: const Color(0xFF374151),
                      ),
                      12.horizontalSpace,
                      Text(
                        StrRes.nickname,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),

                // Input Container
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9CA3AF).withOpacity(0.06),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFF3F4F6),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          StrRes.enterYourNickname,
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        12.verticalSpace,
                        TextField(
                          controller: nameController,
                          autofocus: true,
                          maxLength: 20,
                          decoration: InputDecoration(
                            hintText: StrRes.plsEnterYourNickname,
                            hintStyle: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF9CA3AF),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E7EB),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                color: Color(0xFF4F42FF),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E7EB),
                                width: 1,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            counterText: '',
                          ),
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Action Buttons
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Get.back(),
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                StrRes.cancel,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      12.horizontalSpace,
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              final newName = nameController.text.trim();
                              if (newName.isNotEmpty &&
                                  newName != imLogic.userInfo.value.nickname) {
                                Get.back();
                                _updateNickname(newName);
                              } else {
                                Get.back();
                              }
                            },
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                StrRes.confirm,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),
              ],
            ),
          ),
        ],
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void viewMyQrcode() => _showQRCodeBottomSheet();

  void _showQRCodeBottomSheet() {
    Get.bottomSheet(
      barrierColor: Colors.transparent,
      Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32.r),
                topRight: Radius.circular(32.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9CA3AF).withOpacity(0.08),
                  offset: const Offset(0, -3),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.only(top: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),

                // Title Section
                Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedQrCode01,
                        size: 24.w,
                        color: const Color(0xFF374151),
                      ),
                      12.horizontalSpace,
                      Text(
                        StrRes.qrcode,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),

                // QR Code Section
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9CA3AF).withOpacity(0.06),
                        offset: const Offset(0, 2),
                        blurRadius: 6.r,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFF3F4F6),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      children: [
                        // QR Title
                        Text(
                          StrRes.scanToAddMe,
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF374151),
                          ),
                        ),
                        16.verticalSpace,
                        // QR Code
                        Center(
                          child: Container(
                            width: 180.w,
                            height: 180.w,
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  offset: const Offset(1, 1),
                                  blurRadius: 3,
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.9),
                                  offset: const Offset(-0.5, -0.5),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: QrImageView(
                              data: _buildQRContent(),
                              size: 150.w,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        16.verticalSpace,
                        // Hint Text
                        Text(
                          StrRes.qrcodeHint,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 30.h),
              ],
            ),
          ),
        ],
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  String _buildQRContent() {
    return '${Config.friendScheme}${imLogic.userInfo.value.userID}';
  }

  void editEnglishName() => AppNavigator.startEditMyInfo(
        attr: EditAttr.englishName,
      );

  void editTel() => AppNavigator.startEditMyInfo(
        attr: EditAttr.telephone,
      );

  void editMobile() => AppNavigator.startEditMyInfo(
        attr: EditAttr.mobile,
      );

  void editEmail() =>
      AppNavigator.startEditMyInfo(attr: EditAttr.email, maxLength: 30);

  void openUpdateAvatarSheet() {
    IMViews.openPhotoSheet(
      onlyImage: true,
      onData: (path, url) async {
        if (url != null) {
          try {
            await LoadingView.singleton.wrap(
              asyncFunction: () => ChatApis.updateUserInfo(
                      userID: OpenIM.iMManager.userID, faceURL: url)
                  .then((value) {
                imLogic.userInfo.update((val) {
                  val?.faceURL = url;
                  trtcLogic.setNicknameAvatar(userInfo.value.nickname ?? "",
                      imLogic.userInfo.value.faceURL ?? "");
                });

                IMViews.showToast(StrRes.avatarUpdatedSuccessfully);
              }),
            );
          } catch (e) {
            IMViews.showToast(StrRes.avatarUpdateFailed);
          }
        }
      },
      quality: 15,
    );
  }

  void openDatePicker() {
    final currentBirth = imLogic.userInfo.value.birth;
    final initialDate = currentBirth != null && currentBirth > 0
        ? DateTime.fromMillisecondsSinceEpoch(currentBirth)
        : DateTime(1990, 1, 1);

    DateTime selectedDate = initialDate;

    Get.bottomSheet(
      barrierColor: Colors.transparent,
      Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32.r),
                topRight: Radius.circular(32.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9CA3AF).withOpacity(0.08),
                  offset: const Offset(0, -3),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.only(top: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),

                // Title Section
                Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedCalendar03,
                        size: 24.w,
                        color: const Color(0xFF374151),
                      ),
                      12.horizontalSpace,
                      Text(
                        StrRes.birthDay,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),

                // Date Picker Container
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9CA3AF).withOpacity(0.06),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFF3F4F6),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200.h,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: initialDate,
                          maximumDate: DateTime.now(),
                          minimumDate: DateTime(1900, 1, 1),
                          onDateTimeChanged: (DateTime dateTime) {
                            selectedDate = dateTime;
                          },
                        ),
                      ),

                      // Action Buttons
                      Container(
                        padding: EdgeInsets.all(16.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => Get.back(),
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 12.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Text(
                                      StrRes.cancel,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'FilsonPro',
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            12.horizontalSpace,
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Get.back();
                                    _updateBirthday(
                                        selectedDate.millisecondsSinceEpoch ~/
                                            1000);
                                  },
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 12.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Text(
                                      StrRes.confirm,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'FilsonPro',
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // SizedBox(height: 30.h),
              ],
            ),
          ),
        ],
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void selectGender() {
    Get.bottomSheet(
      barrierColor: Colors.transparent,
      Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32.r),
                topRight: Radius.circular(32.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9CA3AF).withOpacity(0.08),
                  offset: const Offset(0, -3),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.only(top: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),

                // Title Section
                Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedUserMultiple,
                        size: 24.w,
                        color: const Color(0xFF374151),
                      ),
                      12.horizontalSpace,
                      Text(
                        StrRes.gender,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),

                // Gender Options Container
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9CA3AF).withOpacity(0.06),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFF3F4F6),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildGenderActionItem(
                        icon: HugeIcons.strokeRoundedUser,
                        title: StrRes.man,
                        iconColor: const Color(0xFF4F42FF),
                        onTap: () {
                          Get.back();
                          _updateGender(1);
                        },
                        index: 0,
                      ),
                      _buildGenderDivider(),
                      _buildGenderActionItem(
                        icon: HugeIcons.strokeRoundedUser,
                        title: StrRes.woman,
                        iconColor: const Color(0xFFF9A8D4),
                        onTap: () {
                          Get.back();
                          _updateGender(2);
                        },
                        index: 1,
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),

                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    width: Get.width / 3 + 4,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(50),
                        left: Radius.circular(50),
                      ),
                    ),
                    child: Text(StrRes.cancel,
                        style: const TextStyle(
                            fontFamily: 'FilsonPro',
                            fontWeight: FontWeight.w500)),
                  ),
                ),
                SizedBox(height: 15.h),
              ],
            ),
          ),
        ],
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildGenderDivider() {
    return Padding(
      padding: EdgeInsets.only(left: 70.w),
      child: const Divider(
        height: 1,
        thickness: 1,
        color: Color(0xFFF3F4F6),
      ),
    );
  }

  Widget _buildGenderActionItem({
    required List<List<dynamic>> icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
    required int index,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: isLast
              ? BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r),
                  ),
                )
              : null,
          child: Row(
            children: [
              HugeIcon(
                icon: icon,
                size: 20.w,
                color: iconColor,
              ),
              16.horizontalSpace,
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateNickname(String nickname) {
    LoadingView.singleton.wrap(
      asyncFunction: () => ChatApis.updateUserInfo(
              userID: OpenIM.iMManager.userID, nickname: nickname)
          .then((value) {
        imLogic.userInfo.update((val) {
          val?.nickname = nickname;
        });
        IMViews.showToast(StrRes.nicknameUpdatedSuccessfully);
      }).catchError((error) {
        IMViews.showToast(StrRes.nicknameUpdateFailed);
        throw error;
      }),
    );
  }

  void _updateGender(int gender) {
    LoadingView.singleton.wrap(
      asyncFunction: () => ChatApis.updateUserInfo(
              userID: OpenIM.iMManager.userID, gender: gender)
          .then((value) {
        imLogic.userInfo.update((val) {
          val?.gender = gender;
        });
        IMViews.showToast(StrRes.genderUpdatedSuccessfully);
      }).catchError((error) {
        IMViews.showToast(StrRes.genderUpdateFailed);
        throw error;
      }),
    );
  }

  void _updateBirthday(int birthday) {
    LoadingView.singleton.wrap(
      asyncFunction: () => ChatApis.updateUserInfo(
        userID: OpenIM.iMManager.userID,
        birth: birthday * 1000,
      ).then((value) {
        imLogic.userInfo.update((val) {
          val?.birth = birthday * 1000;
        });
        IMViews.showToast(StrRes.birthdayUpdatedSuccessfully);
      }).catchError((error) {
        IMViews.showToast(StrRes.birthdayUpdateFailed);
        throw error;
      }),
    );
  }

  @override
  void onReady() {
    _queryMyFullIno();
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void _queryMyFullIno() async {
    final info = await LoadingView.singleton.wrap(
      asyncFunction: () => ChatApis.queryMyFullInfo(),
    );
    if (null != info) {
      imLogic.userInfo.update((val) {
        val?.nickname = info.nickname;
        val?.faceURL = info.faceURL;
        val?.gender = info.gender;
        val?.phoneNumber = info.phoneNumber;
        val?.birth = info.birth;
        val?.email = info.email;
      });
    }
  }

  updateLinkExpiry(int i) {}
}
