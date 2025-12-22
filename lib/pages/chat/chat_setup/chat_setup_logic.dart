// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:openim/core/controller/client_config_controller.dart';
import 'package:openim/pages/chat/chat_setup/search_chat_history/multimedia/multimedia_logic.dart';
import 'package:openim/widgets/font_size_bottom_sheet.dart';
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

  // Flag to prevent spam clicking on create group button
  bool _isCreatingGroup = false;

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
      IMViews.showToast(StrRes.clearSuccessfully, type: 1);

      AppNavigator.startBackMain();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (Get.isRegistered<ConversationLogic>()) {
          Get.find<ConversationLogic>().onRefresh();
        }
      });
    }
  }

  Future<void> createGroup() async {
    // Prevent spam clicking - if already showing dialog, return early
    if (_isCreatingGroup) return;
    _isCreatingGroup = true;

    try {
      final result = await GatewayApi.getRealNameAuthInfo();
      final status = result['status'] ?? 0;
      if (status != 2) {
        var confirm = await Get.dialog(CustomDialog(
          title: StrRes.realNameAuthRequiredForGroup,
          rightText: StrRes.goToRealNameAuth,
        ));
        _isCreatingGroup = false; // Reset flag after dialog closes
        if (confirm == true) AppNavigator.startRealNameAuth();
        return;
      }
    } catch (e) {
      var confirm = await Get.dialog(CustomDialog(
        title: StrRes.realNameAuthRequiredForGroup,
        rightText: StrRes.goToRealNameAuth,
      ));
      _isCreatingGroup = false; // Reset flag after dialog closes
      if (confirm == true) AppNavigator.startRealNameAuth();
      return;
    }

    _isCreatingGroup = false; // Reset flag before navigating

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

  void setFontSize() {
    FontSizeBottomSheet.show(
      onSave: (factor) async {
        await chatLogic?.changeFontSize(factor);
      },
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
              color: Colors.white,
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
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          CupertinoIcons.photo_fill,
                          size: 24.w,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      16.horizontalSpace,
                      Text(
                        StrRes.setChatBackground,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),

                // Options
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      _buildOptionItem(
                        icon: CupertinoIcons.photo,
                        title: StrRes.selectAssetsFromAlbum,
                        color: const Color(0xFF34D399),
                        onTap: () {
                          Get.back();
                          _onTapAlbum();
                        },
                      ),
                      16.verticalSpace,
                      _buildOptionItem(
                        icon: CupertinoIcons.camera,
                        title: StrRes.selectAssetsFromCamera,
                        color: const Color(0xFF4F42FF),
                        onTap: () {
                          Get.back();
                          _onTapCamera();
                        },
                      ),
                      16.verticalSpace,
                      _buildOptionItem(
                        icon: CupertinoIcons.refresh,
                        title: StrRes.setDefaultBackground,
                        color: const Color(0xFFFBBF24),
                        onTap: () {
                          Get.back();
                          _recoverBackground();
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ],
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9CA3AF).withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                icon,
                size: 24.w,
                color: color,
              ),
            ),
            16.horizontalSpace,
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 20.w,
              color: const Color(0xFFD1D5DB),
            ),
          ],
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
