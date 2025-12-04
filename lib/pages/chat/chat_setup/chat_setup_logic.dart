// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:openim/constants/app_color.dart';
import 'package:openim/core/controller/client_config_controller.dart';
import 'package:openim/pages/chat/chat_setup/search_chat_history/multimedia/multimedia_logic.dart';
import 'package:openim_common/openim_common.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import '../../../core/controller/app_controller.dart';
import '../../../core/controller/im_controller.dart';
import '../../../routes/app_navigator.dart';
import '../../conversation/conversation_logic.dart';
import '../chat_logic.dart';

class ChatSetupLogic extends GetxController {
  // final chatLogic = Get.find<ChatLogic>();
  ChatLogic? get chatLogic {
    try {
      return Get.find<ChatLogic>(tag: GetTags.chat);
    } catch (e) {
      return null;
    }
  }

  final appLogic = Get.find<AppController>();
  final clientConfigLogic = Get.find<ClientConfigController>();
  final imLogic = Get.find<IMController>();
  late Rx<ConversationInfo> conversationInfo;
  late StreamSubscription ccSub;
  late StreamSubscription fcSub;

  String get conversationID => conversationInfo.value.conversationID;

  bool get isPinned => conversationInfo.value.isPinned == true;

  bool get isMsgDestruct => conversationInfo.value.isMsgDestruct == true;

  bool get isNotDisturb => conversationInfo.value.recvMsgOpt != 0;

  @override
  void onClose() {
    ccSub.cancel();
    fcSub.cancel();
    super.onClose();
  }

  @override
  Future<void> onInit() async {
    if (Get.arguments['conversationInfo'] != null) {
      conversationInfo = Rx(Get.arguments['conversationInfo']);
    } else if (chatLogic != null) {
      final temp = await OpenIM.iMManager.conversationManager
          .getOneConversation(
              sourceID: chatLogic!.conversationInfo.isGroupChat
                  ? chatLogic!.conversationInfo.groupID!
                  : chatLogic!.conversationInfo.userID!,
              sessionType: chatLogic!.conversationInfo.conversationType!);
      conversationInfo = Rx(temp);
    } else {
      print('GroupSetupLogic: No conversationInfo provided');
      return;
    }

    ccSub = imLogic.conversationChangedSubject.listen((newList) {
      for (var newValue in newList) {
        if (newValue.conversationID == conversationID) {
          conversationInfo.update((val) {
            val?.burnDuration = newValue.burnDuration ?? 30;
            val?.isPrivateChat = newValue.isPrivateChat;
            val?.isPinned = newValue.isPinned;
            // 免打扰 0：正常；1：不接受消息；2：接受在线消息不接受离线消息；
            val?.recvMsgOpt = newValue.recvMsgOpt;
            val?.isMsgDestruct = newValue.isMsgDestruct;
            val?.msgDestructTime = newValue.msgDestructTime;
          });
          break;
        }
      }
    });
    // 好友信息变化
    fcSub = imLogic.friendInfoChangedSubject.listen((value) {
      if (conversationInfo.value.userID == value.userID) {
        conversationInfo.update((val) {
          val?.showName = value.getShowName();
          val?.faceURL = value.faceURL;
        });
      }
    });
    super.onInit();
  }

  void toggleTopContacts() async {
    await LoadingView.singleton.wrap(
      asyncFunction: () => OpenIM.iMManager.conversationManager.pinConversation(
        conversationID: conversationID,
        isPinned: !isPinned,
      ),
    );
  }

  /// 消息免打扰 0：正常；1：不接受消息；2：接受在线消息不接受离线消息；
  void toggleNotDisturb() {
    LoadingView.singleton.wrap(
        asyncFunction: () =>
            OpenIM.iMManager.conversationManager.setConversationRecvMessageOpt(
              conversationID: conversationID,
              status: !isNotDisturb ? 2 : 0,
            ));
  }

  void setConversationBurnDuration(int duration) {
    LoadingView.singleton.wrap(
        asyncFunction: () => OpenIM.iMManager.conversationManager
            .setConversationBurnDuration(
                conversationID: conversationID, burnDuration: duration));
  }

  void clearChatHistory() async {
    var confirm = await Get.dialog(
        barrierColor: Colors.transparent,
        CustomDialog(
          title: StrRes.confirmClearChatHistory,
          rightText: StrRes.clearAll,
        ));
    if (confirm == true) {
      await LoadingView.singleton.wrap(asyncFunction: () {
        OpenIM.iMManager.conversationManager
            .hideConversation(conversationID: conversationID);
        return OpenIM.iMManager.conversationManager
            .deleteConversationAndDeleteAllMsg(
          conversationID: conversationID,
        );
      });
      chatLogic?.clearAllMessage();
      IMViews.showToast(StrRes.clearSuccessfully);

      AppNavigator.startBackMain();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (Get.isRegistered<ConversationLogic>()) {
          Get.find<ConversationLogic>().onRefresh();
        }
      });
    }
  }

  Future<void> createGroup() async {
    try {
      final result = await GatewayApi.getRealNameAuthInfo();
      final status = result['status'] ?? 0;
      if (status != 2) {
        var confirm = await Get.dialog(CustomDialog(
          title: StrRes.realNameAuthRequiredForGroup,
          rightText: StrRes.goToRealNameAuth,
        ));
        if (confirm == true) AppNavigator.startRealNameAuth();
        return;
      }
    } catch (e) {
      var confirm = await Get.dialog(CustomDialog(
        title: StrRes.realNameAuthRequiredForGroup,
        rightText: StrRes.goToRealNameAuth,
      ));
      if (confirm == true) AppNavigator.startRealNameAuth();
      return;
    }

    AppNavigator.startCreateGroup(defaultCheckedList: [
      UserInfo(
        userID: conversationInfo.value.userID,
        faceURL: conversationInfo.value.faceURL,
        nickname: conversationInfo.value.showName,
      ),
      OpenIM.iMManager.userInfo,
    ]);
  }

  void startReport() => AppNavigator.startReportReasonList(
      chatType: 'singleChat', userID: conversationInfo.value.userID);

  void setFontSize() => _showFontSizeBottomSheet();

  void _showFontSizeBottomSheet() {
    final factor = DataSp.getChatFontSizeFactor().obs;

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
                        icon: HugeIcons.strokeRoundedTextFont,
                        size: 24.w,
                        color: const Color(0xFF374151),
                      ),
                      12.horizontalSpace,
                      Text(
                        StrRes.fontSize,
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

                // Preview Container
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF9FAFB), Color(0xFFF3F4F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9CA3AF).withOpacity(0.07),
                        offset: const Offset(0, 3),
                        blurRadius: 8,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '昨天 16:09',
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          8.verticalSpace,
                          ChatBubble(
                            bubbleType: BubbleType.send,
                            alignment: null,
                            constraints: BoxConstraints(maxWidth: 200.w),
                            child: Obx(() => Text(
                                  '预览字体大小',
                                  style: TextStyle(
                                    fontFamily: 'FilsonPro',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                  textScaleFactor: factor.value,
                                )),
                          ),
                        ],
                      ),
                      10.horizontalSpace,
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22.r),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9CA3AF).withOpacity(0.1),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: AvatarView(
                          width: 44.w,
                          height: 44.h,
                          text: OpenIM.iMManager.userInfo.nickname,
                          url: OpenIM.iMManager.userInfo.faceURL,
                          isCircle: true,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Font Size Slider
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 36.w,
                            height: 36.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F42FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedTextFont,
                              size: 18.w,
                              color: const Color(0xFF4F42FF),
                            ),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 6.h,
                                activeTrackColor: const Color(0xFF4F42FF),
                                inactiveTrackColor: const Color(0xFFF3F4F6),
                                thumbColor: const Color(0xFF4F42FF),
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 8.r),
                                overlayShape: RoundSliderOverlayShape(
                                    overlayRadius: 16.r),
                              ),
                              child: Obx(
                                () => Slider(
                                  value: factor.value,
                                  min: 0.8,
                                  max: 1.4,
                                  onChanged: (value) => factor.value = value,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 36.w,
                            height: 36.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F42FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedTextFont,
                              size: 18.w,
                              color: const Color(0xFF4F42FF),
                            ),
                          ),
                        ],
                      ),
                      10.verticalSpace,
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'A',
                              style: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            Text(
                              'A',
                              style: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                            onTap: () async {
                              Get.back();
                              await chatLogic?.changeFontSize(factor.value);
                            },
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                StrRes.save,
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

  void setBackgroundImage() => _showBackgroundImageBottomSheet();

  void _showBackgroundImageBottomSheet() {
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
                        icon: HugeIcons.strokeRoundedImage02,
                        size: 24.w,
                        color: const Color(0xFF374151),
                      ),
                      12.horizontalSpace,
                      Text(
                        StrRes.setChatBackground,
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

                // Background Options Container
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
                      _buildBackgroundActionItem(
                        icon: HugeIcons.strokeRoundedImage01,
                        title: StrRes.selectAssetsFromAlbum,
                        iconColor: const Color(0xFF34D399),
                        onTap: () {
                          Get.back();
                          _onTapAlbum();
                        },
                        index: 0,
                      ),
                      _buildBackgroundDivider(),
                      _buildBackgroundActionItem(
                        icon: HugeIcons.strokeRoundedCamera01,
                        title: StrRes.selectAssetsFromCamera,
                        iconColor: const Color(0xFF4F42FF),
                        onTap: () {
                          Get.back();
                          _onTapCamera();
                        },
                        index: 1,
                      ),
                      _buildBackgroundDivider(),
                      _buildBackgroundActionItem(
                        icon: HugeIcons.strokeRoundedRefresh,
                        title: StrRes.setDefaultBackground,
                        iconColor: const Color(0xFFFBBF24),
                        onTap: () {
                          Get.back();
                          _recoverBackground();
                        },
                        index: 2,
                        isLast: true,
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

  Widget _buildBackgroundDivider() {
    return Padding(
      padding: EdgeInsets.only(left: 52.w),
      child: const Divider(
        height: 1,
        thickness: 1,
        color: Color(0xFFF3F4F6),
      ),
    );
  }

  Widget _buildBackgroundActionItem({
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
                  color: AppColor.iconColor // iconColor,
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

  void _onTapAlbum() async {
    Permissions.photos(() async {
      final List<AssetEntity>? assets = await AssetPicker.pickAssets(
        Get.context!,
        pickerConfig: const AssetPickerConfig(
          maxAssets: 1,
          requestType: RequestType.image,
        ),
      );
      if (null != assets) {
        for (var asset in assets) {
          _handleAssets(asset);
        }
      }
    });
  }

  void _onTapCamera() async {
    final AssetEntity? entity = await CameraPicker.pickFromCamera(
      Get.context!,
      locale: Get.locale,
      pickerConfig: const CameraPickerConfig(
        enableAudio: false,
        enableRecording: false,
        enableScaledPreview: true,
        resolutionPreset: ResolutionPreset.medium,
      ),
    );
    _handleAssets(entity);
  }

  void _handleAssets(AssetEntity? asset) async {
    if (null != asset) {
      Logger.print('--------assets type-----${asset.type}');
      var result = (await asset.file)!.path;
      Logger.print('--------assets path-----$result');
      switch (asset.type) {
        case AssetType.image:
          chatLogic?.changeBackground(result);
          break;
        default:
          break;
      }
    }
  }

  void _recoverBackground() {
    chatLogic?.clearBackground();
  }

  void searchChatHistory() => AppNavigator.startSearchChatHistory(
        conversationInfo: conversationInfo.value,
      );

  void searchChatHistoryPicture() =>
      AppNavigator.startSearchChatHistoryMultimedia(
        conversationInfo: conversationInfo.value,
      );

  void searchChatHistoryVideo() =>
      AppNavigator.startSearchChatHistoryMultimedia(
        conversationInfo: conversationInfo.value,
        multimediaType: MultimediaType.video,
      );

  void searchChatHistoryFile() => AppNavigator.startSearchChatHistoryFile(
        conversationInfo: conversationInfo.value,
      );

  void viewUserInfo() => AppNavigator.startUserProfilePane(
        userID: conversationInfo.value.userID!,
        nickname: conversationInfo.value.showName,
        faceURL: conversationInfo.value.faceURL,
      );
}
