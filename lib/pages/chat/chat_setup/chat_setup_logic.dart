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
import 'package:openim/widgets/custom_bottom_sheet.dart';
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
  late StreamSubscription _blacklistAddedSub;
  late StreamSubscription _blacklistDeletedSub;

  final isBlacklist = false.obs;

  String get conversationID => conversationInfo.value.conversationID;

  bool get isPinned => conversationInfo.value.isPinned == true;

  bool get isMsgDestruct => conversationInfo.value.isMsgDestruct == true;

  bool get isNotDisturb => conversationInfo.value.recvMsgOpt != 0;

  @override
  void onClose() {
    ccSub.cancel();
    fcSub.cancel();
    _blacklistAddedSub.cancel();
    _blacklistDeletedSub.cancel();
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

    if (conversationInfo.value.isSingleChat &&
        conversationInfo.value.userID != null) {
      final list = await OpenIM.iMManager.friendshipManager.getBlacklist();
      final isBlack = list.firstWhereOrNull(
              (e) => e.userID == conversationInfo.value.userID) !=
          null;
      isBlacklist.value = isBlack;
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

    _blacklistAddedSub = imLogic.blacklistAddedSubject.listen((user) {
      if (user.userID == conversationInfo.value.userID) {
        isBlacklist.value = true;
      }
    });
    _blacklistDeletedSub = imLogic.blacklistDeletedSubject.listen((user) {
      if (user.userID == conversationInfo.value.userID) {
        isBlacklist.value = false;
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

  void toggleBlacklist() async {
    if (isBlacklist.value) {
      await _removeBlacklist();
    } else {
      await _addBlacklist();
    }
  }

  Future<void> _addBlacklist() async {
    var confirm = await Get.dialog(
        barrierColor: Colors.transparent,
        CustomDialog(title: StrRes.areYouSureAddBlacklist));
    if (confirm == true) {
      await OpenIM.iMManager.friendshipManager.addBlacklist(
        userID: conversationInfo.value.userID!,
      );
      IMViews.showToast(StrRes.addedBlacklistSuccessfully, type: 1);
    }
  }

  Future<void> _removeBlacklist() async {
    var confirm = await Get.dialog(
        barrierColor: Colors.transparent,
        CustomDialog(title: StrRes.areYouSureRemoveBlacklist));
    if (confirm == true) {
      await OpenIM.iMManager.friendshipManager.removeBlacklist(
        userID: conversationInfo.value.userID!,
      );
      IMViews.showToast(StrRes.removedBlacklistSuccessfully, type: 1);
    }
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
        userID: OpenIM.iMManager.userInfo.userID,
        faceURL: OpenIM.iMManager.userInfo.faceURL,
        nickname: OpenIM.iMManager.userInfo.nickname,
      ),
      UserInfo(
        userID: conversationInfo.value.userID,
        faceURL: conversationInfo.value.faceURL,
        nickname: conversationInfo.value.showName,
      ),
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
    CustomBottomSheet.show(
      title: StrRes.setChatBackground,
      icon: CupertinoIcons.photo_fill,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
      isDismissible: true,
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
        pickerConfig: AssetPickerConfig(
          maxAssets: 1,
          requestType: RequestType.image,
          limitedPermissionOverlayPredicate: (state) => false,
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
          Get.back();
          IMViews.showToast(StrRes.setSuccessfully, type: 1);
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
