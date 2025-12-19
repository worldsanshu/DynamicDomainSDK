// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/pages/mine/edit_my_info/edit_my_info_logic.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim/widgets/qr_code_bottom_sheet.dart';
import 'package:openim_common/openim_common.dart';

import '../../../core/controller/im_controller.dart';
import '../../../core/controller/trtc_controller.dart';

class MyInfoLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  final trtcLogic = Get.find<TRTCController>();

  final userInfo =
      UserFullInfo.fromJson(OpenIM.iMManager.userInfo.toJson()).obs;

  bool isUpdatingGender = false; // Prevent race condition

  void editMyName() => editNameBottomSheet();

  void editNameBottomSheet() {
    final nameController = TextEditingController();
    nameController.text = imLogic.userInfo.value.nickname ?? '';

    Get.bottomSheet(
      barrierColor: Colors.black.withOpacity(0.25),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      StrRes.nickname,
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20.w,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              Padding(
                padding: EdgeInsets.all(20.w),
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
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(
                              color: Color(0xFF3B82F6), width: 2),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 14.h),
                        counterText: '',
                      ),
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    24.verticalSpace,
                    GestureDetector(
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
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.2),
                              offset: const Offset(0, 4),
                              blurRadius: 12,
                            ),
                          ],
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void viewMyQrcode() => _showQRCodeBottomSheet();

  void _showQRCodeBottomSheet() {
    Get.bottomSheet(
      QRCodeBottomSheet(
        title: StrRes.qrcode,
        name: imLogic.userInfo.value.nickname ?? '',
        avatarUrl: imLogic.userInfo.value.faceURL,
        qrData: '${Config.friendScheme}${imLogic.userInfo.value.userID}',
        isGroup: false,
        description: StrRes.scanToAddMe,
        hintText: StrRes.qrcodeHint,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
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
      allowGif: true,
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
                IMViews.showToast(StrRes.avatarUpdatedSuccessfully, type: 1);
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
      barrierColor: Colors.black.withOpacity(0.25),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      StrRes.birthDay,
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20.w,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
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
              Padding(
                padding: EdgeInsets.all(20.w),
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                    _updateBirthday(
                        selectedDate.millisecondsSinceEpoch ~/ 1000);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.2),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
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
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void selectGender() {
    final currentGender = imLogic.userInfo.value.gender ?? 0;

    Get.bottomSheet(
      barrierColor: Colors.black.withOpacity(0.25),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      StrRes.gender,
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20.w,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Column(
                  children: [
                    _buildGenderActionItem(
                      icon: CupertinoIcons.person,
                      title: StrRes.man,
                      iconColor: const Color(0xFF4F42FF),
                      onTap: () {
                        Get.until((route) =>
                            !Get.isBottomSheetOpen!); // Đóng chỉ bottom sheet
                        if (currentGender != 1) {
                          _updateGender(1);
                        } else {
                          IMViews.showToast(StrRes.genderUpdatedSuccessfully,
                              type: 1);
                        }
                      },
                      index: 0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 52.w),
                      child: const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    ),
                    _buildGenderActionItem(
                      icon: CupertinoIcons.person,
                      title: StrRes.woman,
                      iconColor: const Color(0xFFF9A8D4),
                      onTap: () {
                        Get.until((route) =>
                            !Get.isBottomSheetOpen!); // Đóng chỉ bottom sheet
                        if (currentGender != 2) {
                          _updateGender(2);
                        } else {
                          IMViews.showToast(StrRes.genderUpdatedSuccessfully,
                              type: 1);
                        }
                      },
                      index: 1,
                      isLast: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildGenderActionItem({
    required IconData icon,
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
              Icon(
                icon,
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
        IMViews.showToast(StrRes.nicknameUpdatedSuccessfully, type: 1);
      }).catchError((error) {
        IMViews.showToast(StrRes.nicknameUpdateFailed);
        throw error;
      }),
    );
  }

  void _updateGender(int gender) {
    if (isUpdatingGender) return; // Prevent concurrent updates

    isUpdatingGender = true;
    LoadingView.singleton.wrap(
      asyncFunction: () => ChatApis.updateUserInfo(
              userID: OpenIM.iMManager.userID, gender: gender)
          .then((value) {
        imLogic.userInfo.update((val) {
          val?.gender = gender;
        });
        IMViews.showToast(StrRes.genderUpdatedSuccessfully, type: 1);
      }).catchError((error) {
        IMViews.showToast(StrRes.genderUpdateFailed);
        throw error;
      }).whenComplete(() {
        isUpdatingGender = false; // Release lock
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
        IMViews.showToast(StrRes.birthdayUpdatedSuccessfully, type: 1);
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
