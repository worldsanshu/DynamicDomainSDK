// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/core/controller/client_config_controller.dart';
import 'package:openim_common/openim_common.dart';
import 'package:synchronized/synchronized.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:openim/pages/auth/widget/app_text_form_field.dart';
import 'package:openim/widgets/qr_code_bottom_sheet.dart';

import '../../../core/controller/im_controller.dart';
import '../../../routes/app_navigator.dart';
import '../../contacts/select_contacts/select_contacts_logic.dart';
import '../../conversation/conversation_logic.dart';
import '../chat_logic.dart';
import '../chat_setup/search_chat_history/multimedia/multimedia_logic.dart';
import 'group_member_list/group_member_list_logic.dart';

class GroupSetupLogic extends GetxController {
  final imLogic = Get.find<IMController>();

  // final chatLogic = Get.find<ChatLogic>();
  ChatLogic? get chatLogic {
    try {
      return Get.find<ChatLogic>(tag: GetTags.chat);
    } catch (e) {
      return null;
    }
  }

  final clientConfigLogic = Get.find<ClientConfigController>();
  final conversationLogic = Get.find<ConversationLogic>();
  final memberList = <GroupMembersInfo>[].obs;
  final memberAllList = <GroupMembersInfo>[].obs;

  // Store online status for group members
  final Map<String, bool> memberOnlineStatusMap = <String, bool>{};
  late Rx<ConversationInfo> conversationInfo;
  late Rx<GroupInfo> groupInfo;
  late Rx<GroupMembersInfo> myGroupMembersInfo;
  StreamSubscription? _guSub;
  StreamSubscription? _mASub;
  StreamSubscription? _mISub;
  StreamSubscription? _mDSub;
  StreamSubscription? _ccSub;
  StreamSubscription? _jasSub;
  StreamSubscription? _jdsSub;
  final lock = Lock();
  final isJoinedGroup = false.obs;
  final avatar = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  Future<void> _initData() async {
    // Initialize with default values first to prevent late initialization errors
    conversationInfo = Rx(ConversationInfo(conversationID: ''));
    groupInfo = Rx(GroupInfo(groupID: '', groupName: '', memberCount: 0));
    myGroupMembersInfo = Rx(GroupMembersInfo(
      userID: OpenIM.iMManager.userID,
      nickname: OpenIM.iMManager.userInfo.nickname,
    ));

    _initMemberStatusListener();

    if (Get.arguments != null && Get.arguments['conversationInfo'] != null) {
      conversationInfo.value = Get.arguments['conversationInfo'];
    } else if (chatLogic != null) {
      final temp = await OpenIM.iMManager.conversationManager
          .getOneConversation(
              sourceID: chatLogic!.conversationInfo.isGroupChat
                  ? chatLogic!.conversationInfo.groupID!
                  : chatLogic!.conversationInfo.userID!,
              sessionType: chatLogic!.conversationInfo.conversationType!);
      conversationInfo.value = temp;
    } else {
      return;
    }

    groupInfo.value = _defaultGroupInfo;
    myGroupMembersInfo.value = _defaultMemberInfo;

    _ccSub = imLogic.conversationChangedSubject.listen((newList) {
      final newValue = newList.firstWhereOrNull((element) =>
          element.conversationID == conversationInfo.value.conversationID);
      if (newValue != null) {
        conversationInfo.update((val) {
          val?.isPinned = newValue.isPinned;
          // 免打扰 0：正常；1：不接受消息；2：接受在线消息不接受离线消息；
          val?.recvMsgOpt = newValue.recvMsgOpt;
          val?.isMsgDestruct = newValue.isMsgDestruct;
          val?.msgDestructTime = newValue.msgDestructTime;
        });
      }
    });

    _guSub = imLogic.groupInfoUpdatedSubject.listen((value) {
      if (value.groupID == groupInfo.value.groupID) {
        _updateGroupInfo(value);
      }
    });

    _jasSub = imLogic.joinedGroupAddedSubject.listen((value) {
      if (value.groupID == groupInfo.value.groupID) {
        isJoinedGroup.value = true;
        _queryAllInfo();
      }
    });

    _jdsSub = imLogic.joinedGroupDeletedSubject.listen((value) {
      if (value.groupID == groupInfo.value.groupID) {
        isJoinedGroup.value = false;
      }
    });

    _mISub = imLogic.memberInfoChangedSubject.listen((e) {
      if (e.groupID == groupInfo.value.groupID &&
          e.userID == myGroupMembersInfo.value.userID) {
        myGroupMembersInfo.update((val) {
          val?.nickname = e.nickname;
          val?.roleLevel = e.roleLevel;
        });
      }
      if (e.groupID == groupInfo.value.groupID &&
          e.userID == groupInfo.value.ownerUserID) {
        var index = memberList.indexWhere(
            (element) => element.userID == groupInfo.value.ownerUserID);
        if (index == -1) {
          memberList.insert(0, e);
        } else if (index != 0) {
          memberList.insert(0, memberList.removeAt(index));
        }
      }
      memberList.sort((a, b) {
        if (b.roleLevel != a.roleLevel) {
          return b.roleLevel!.compareTo(a.roleLevel!);
        } else {
          return b.joinTime!.compareTo(a.joinTime!);
        }
      });
    });
    _mASub = imLogic.memberAddedSubject.listen((e) async {
      if (e.groupID == groupInfo.value.groupID) {
        if (e.userID == OpenIM.iMManager.userID) {
          isJoinedGroup.value = true;
          _queryAllInfo();
        } else {
          memberList.add(e);
          memberAllList.add(e); // Also add to memberAllList
          // Subscribe to online status for new member
          if (e.userID != null) {
            try {
              await OpenIM.iMManager.userManager
                  .subscribeUsersStatus([e.userID!]);
            } catch (e) {
              // Ignore errors for subscription
            }
          }
        }
      }
    });
    _mDSub = imLogic.memberDeletedSubject.listen((e) {
      if (e.groupID == groupInfo.value.groupID) {
        if (e.userID == OpenIM.iMManager.userID) {
          isJoinedGroup.value = false;
        } else {
          memberList.removeWhere((element) => element.userID == e.userID);
          memberAllList.removeWhere((element) =>
              element.userID == e.userID); // Also remove from memberAllList
          // Unsubscribe from online status for removed member
          if (e.userID != null) {
            try {
              OpenIM.iMManager.userManager.unsubscribeUsersStatus([e.userID!]);
              memberOnlineStatusMap.remove(e.userID);
            } catch (e) {
              // Ignore errors for unsubscription
            }
          }
          // memberList.refresh();
        }
      }
    });

    _checkIsJoinedGroup();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    _guSub?.cancel();
    _mASub?.cancel();
    _mDSub?.cancel();
    _ccSub?.cancel();
    _mISub?.cancel();
    _jdsSub?.cancel();
    _jasSub?.cancel();

    // Unsubscribe from online status for all members
    for (var member in memberList) {
      if (member.userID != null) {
        try {
          OpenIM.iMManager.userManager.unsubscribeUsersStatus([member.userID!]);
        } catch (e) {
          // Ignore errors for unsubscription
        }
      }
    }

    super.onClose();
  }

  get _defaultGroupInfo => GroupInfo(
        groupID: conversationInfo.value.groupID ?? '',
        groupName: conversationInfo.value.showName,
        faceURL: conversationInfo.value.faceURL,
        memberCount: 0,
      );

  get _defaultMemberInfo => GroupMembersInfo(
        userID: OpenIM.iMManager.userID,
        nickname: OpenIM.iMManager.userInfo.nickname,
      );

  bool get isOwnerOrAdmin => isOwner || isAdmin;

  bool get isAdmin =>
      myGroupMembersInfo.value.roleLevel == GroupRoleLevel.admin;

  bool get isOwner => groupInfo.value.ownerUserID == OpenIM.iMManager.userID;

  bool get isPinned => conversationInfo.value.isPinned == true;

  bool get isNotDisturb => conversationInfo.value.recvMsgOpt != 0;

  String get conversationID => conversationInfo.value.conversationID;

  bool get isMsgDestruct => conversationInfo.value.isMsgDestruct == true;

  int get destructDuration =>
      conversationInfo.value.msgDestructTime ?? 7 * 24 * 60 * 60;

  bool get showMemberCount => clientConfigLogic.shouldShowMemberCount(
      roleLevel: myGroupMembersInfo.value.roleLevel ?? 1);

  bool get showGroupManagement =>
      clientConfigLogic.adminHasManagementAccess ? isOwnerOrAdmin : isOwner;

  void _initMemberStatusListener() {
    // Listen to user status changes for group members
    imLogic.userStatusChangedSubject.listen((userStatus) {
      if (userStatus.userID != null) {
        // Check if this user is a member of current group
        if (memberList.any((member) => member.userID == userStatus.userID)) {
          memberOnlineStatusMap[userStatus.userID!] = userStatus.status == 1;
          // Refresh the member list to update online indicators
          memberList.refresh();
        }
      }
    });
  }

  void _checkIsJoinedGroup() async {
    isJoinedGroup.value = await OpenIM.iMManager.groupManager.isJoinedGroup(
      groupID: groupInfo.value.groupID,
    );
    _queryAllInfo();
  }

  void _queryAllInfo() {
    if (isJoinedGroup.value) {
      getGroupInfo();
      getGroupMembers();
      getMyGroupMemberInfo();
      getAllGroupMembers();
    }
  }

  getGroupMembers() async {
    var list = await OpenIM.iMManager.groupManager.getGroupMemberList(
      groupID: groupInfo.value.groupID,
      count: 10,
    );
    memberList.assignAll(list);

    // Subscribe to online status for all members
    for (var member in list) {
      if (member.userID != null) {
        try {
          await OpenIM.iMManager.userManager
              .subscribeUsersStatus([member.userID!]);
        } catch (e) {
          // Ignore errors for subscription
        }
      }
    }
  }

  /// Get all group members (not just first 10)
  Future<void> getAllGroupMembers() async {
    try {
      final allMembers = <GroupMembersInfo>[];
      int offset = 0;
      const int pageSize = 100;

      while (true) {
        final list = await OpenIM.iMManager.groupManager.getGroupMemberList(
          groupID: groupInfo.value.groupID,
          offset: offset,
          count: pageSize,
        );

        if (list.isEmpty) break;

        allMembers.addAll(list);

        // If we got less than pageSize, we've reached the end
        if (list.length < pageSize) break;

        offset += pageSize;
      }

      memberAllList.assignAll(allMembers);

      Logger.print('Loaded ${memberAllList.length} total group members');
    } catch (e) {
      Logger.print('Error loading all group members: $e');
    }
  }

  /// Refresh member list - useful when returning from add/remove member screens
  void refreshMemberList() {
    if (isJoinedGroup.value) {
      getGroupMembers();
      getAllGroupMembers();
    }
  }

  getGroupInfo() async {
    var list = await OpenIM.iMManager.groupManager.getGroupsInfo(
      groupIDList: [groupInfo.value.groupID],
    );
    var value = list.firstOrNull;
    if (null != value) {
      _updateGroupInfo(value);
    }
  }

  getMyGroupMemberInfo() async {
    final list = await OpenIM.iMManager.groupManager.getGroupMembersInfo(
      groupID: groupInfo.value.groupID,
      userIDList: [OpenIM.iMManager.userID],
    );
    final info = list.firstOrNull;
    if (null != info) {
      myGroupMembersInfo.update((val) {
        val?.nickname = info.nickname;
        val?.roleLevel = info.roleLevel;
      });
    }
  }

  void _updateGroupInfo(GroupInfo value) {
    groupInfo.update((val) {
      val?.groupName = value.groupName;
      val?.faceURL = value.faceURL;
      val?.notification = value.notification;
      val?.introduction = value.introduction;
      val?.memberCount = value.memberCount;
      val?.ownerUserID = value.ownerUserID;
      val?.status = value.status;
      val?.needVerification = value.needVerification;
      val?.groupType = value.groupType;
      val?.lookMemberInfo = value.lookMemberInfo;
      val?.applyMemberFriend = value.applyMemberFriend;
      val?.notificationUserID = value.notificationUserID;
      val?.notificationUpdateTime = value.notificationUpdateTime;
      val?.ex = value.ex;
    });
  }

  void modifyGroupAvatar() async {
    IMViews.openPhotoSheet(
      onlyImage: true,
      isGroup: true,
      onData: (path, url) async {
        if (url != null) {
          try {
            avatar.value = File(path);
            await _modifyGroupInfo(faceUrl: url);
            groupInfo.update((val) {
              val?.faceURL = url;
            });
            IMViews.showToast(StrRes.groupAvatarUpdatedSuccessfully, type: 1);
          } catch (e) {
            IMViews.showToast(StrRes.groupAvatarUpdateFailed);
          }
        }
      },
      quality: 15,
    );
  }

  void modifyGroupName(String? faceUrl) => _showEditGroupNameBottomSheet();

  void _showEditGroupNameBottomSheet() {
    final nameController = TextEditingController();
    nameController.text = groupInfo.value.groupName ?? '';
    final canSubmit = false.obs; // Reactive variable for button state

    // Listen to text changes
    nameController.addListener(() {
      final newName = nameController.text.trim();
      canSubmit.value =
          newName.isNotEmpty && newName != groupInfo.value.groupName;
    });

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
                      Icon(
                        CupertinoIcons.pencil,
                        size: 24.w,
                        color: const Color(0xFF374151),
                      ),
                      12.horizontalSpace,
                      Text(
                        StrRes.groupName,
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
                          StrRes.enterNewGroupName,
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
                          maxLength: 30,
                          decoration: InputDecoration(
                            hintText: StrRes.enterGroupName,
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
                        child: Obx(
                          () => Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: canSubmit.value
                                  ? () {
                                      final newName =
                                          nameController.text.trim();
                                      Get.back();
                                      _updateGroupName(newName);
                                    }
                                  : null,
                              borderRadius: BorderRadius.circular(12.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: canSubmit.value
                                      ? const Color(0xFF3B82F6)
                                      : const Color(0xFF9CA3AF),
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

  void _updateGroupName(String groupName) async {
    try {
      await LoadingView.singleton.wrap(
        asyncFunction: () => _modifyGroupInfo(groupName: groupName),
      );

      // Update local state
      groupInfo.update((val) {
        val?.groupName = groupName;
      });

      IMViews.showToast(StrRes.groupNameUpdatedSuccessfully, type: 1);
    } catch (e) {
      IMViews.showToast(StrRes.failedToUpdateGroupName);
    }
  }

  _modifyGroupInfo({
    String? groupName,
    String? notification,
    String? introduction,
    String? faceUrl,
  }) =>
      OpenIM.iMManager.groupManager.setGroupInfo(GroupInfo(
        groupID: groupInfo.value.groupID,
        groupName: groupName,
        notification: notification,
        introduction: introduction,
        faceURL: faceUrl,
      ));

  void modifyMyGroupNickname() => _showEditGroupNicknameBottomSheet();

  void _showEditGroupNicknameBottomSheet() {
    final nameController = TextEditingController();
    nameController.text = myGroupMembersInfo.value.nickname ?? '';
    final canSubmit = false.obs; // Reactive variable for button state

    // Listen to text changes
    nameController.addListener(() {
      final newName = nameController.text.trim();
      canSubmit.value =
          newName.isNotEmpty && newName != myGroupMembersInfo.value.nickname;
    });

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
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Get.theme.primaryColor.withOpacity(0.1),
                              Get.theme.primaryColor.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          CupertinoIcons.person_crop_circle,
                          size: 24.w,
                          color: Get.theme.primaryColor,
                        ),
                      ),
                      12.horizontalSpace,
                      Text(
                        StrRes.groupNickname,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: Get.theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Input Container
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  child: AppTextFormField(
                    focusNode: FocusNode()..requestFocus(),
                    controller: nameController,
                    label: StrRes.enterYourNicknameInGroup,
                    hint: StrRes.enterYourGroupNickname,
                    keyboardType: TextInputType.text,
                    maxLength: 20,
                    onChanged: (value) {
                      // Listener already set up above
                    },
                    validator: (value) => null,
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
                        child: Obx(
                          () => Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: canSubmit.value
                                  ? () {
                                      final newName =
                                          nameController.text.trim();
                                      Get.back();
                                      _updateMyGroupNickname(newName);
                                    }
                                  : null,
                              borderRadius: BorderRadius.circular(12.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                decoration: BoxDecoration(
                                  gradient: canSubmit.value
                                      ? LinearGradient(
                                          colors: [
                                            Get.theme.primaryColor,
                                            Get.theme.primaryColor
                                                .withOpacity(0.8),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: canSubmit.value
                                      ? null
                                      : const Color(0xFF9CA3AF),
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: canSubmit.value
                                      ? [
                                          BoxShadow(
                                            color: Get.theme.primaryColor
                                                .withOpacity(0.3),
                                            offset: const Offset(0, 2),
                                            blurRadius: 6,
                                          ),
                                        ]
                                      : null,
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

  void _updateMyGroupNickname(String nickname) async {
    try {
      await LoadingView.singleton.wrap(
        asyncFunction: () => OpenIM.iMManager.groupManager.setGroupMemberInfo(
          groupMembersInfo: SetGroupMemberInfo(
            groupID: groupInfo.value.groupID,
            userID: OpenIM.iMManager.userID,
            nickname: nickname,
          ),
        ),
      );

      // Update local state
      myGroupMembersInfo.update((val) {
        val?.nickname = nickname;
      });

      IMViews.showToast(StrRes.groupNicknameUpdatedSuccessfully, type: 1);
    } catch (e) {
      IMViews.showToast(StrRes.failedToUpdateGroupNickname);
    }
  }

  void viewGroupQrcode() => _showGroupQRCodeBottomSheet();

  void _showGroupQRCodeBottomSheet() {
    Get.bottomSheet(
      QRCodeBottomSheet(
        title: StrRes.qrcode,
        name: groupInfo.value.groupName ?? '',
        avatarUrl: groupInfo.value.faceURL,
        qrData: _buildGroupQRContent(),
        isGroup: true,
        memberCount: showMemberCount ? groupInfo.value.memberCount : null,
        description: StrRes.scanToJoinGroup,
        hintText: StrRes.shareQRCodeToJoinGroup,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  String _buildGroupQRContent() {
    return '${Config.groupScheme}${groupInfo.value.groupID}';
  }

  void startReport() => AppNavigator.startReportReasonList(
      chatType: 'groupChat', groupID: groupInfo.value.groupID);

  void viewGroupMembers({bool isShowEveryone = true}) async {
    await AppNavigator.startGroupMemberList(
      groupInfo: groupInfo.value,
      opType: GroupMemberOpType.view,
      isShowEveryone: isShowEveryone,
    );
    // Refresh member list after returning from member management screen
    refreshMemberList();
  }

  void viewGroupOnlineInfo() {
    AppNavigator.startGroupOnlineInfo(
      groupInfo: groupInfo.value,
      isOwnerOrAdmin: isOwnerOrAdmin,
    );
  }

  void editGroupAnnouncement() => AppNavigator.startEditGroupAnnouncement(
        groupID: groupInfo.value.groupID,
      );

  void groupManage() => AppNavigator.startGroupManage(
        groupInfo: groupInfo.value,
      );

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

  void _removeConversation() async {
    // 删除群会话
    await OpenIM.iMManager.conversationManager
        .deleteConversationAndDeleteAllMsg(
      conversationID: conversationInfo.value.conversationID,
    );

    conversationLogic.removeConversation(conversationInfo.value.conversationID);
  }

  void quitGroup() async {
    if (isJoinedGroup.value) {
      if (isOwner) {
        var confirm = await Get.dialog(CustomDialog(
          title: StrRes.dismissGroupHint,
        ));
        if (confirm == true) {
          imLogic.markGroupAsDismissing(groupInfo.value.groupID);

          // transferGroup();
          await OpenIM.iMManager.groupManager.dismissGroup(
            groupID: groupInfo.value.groupID,
          );

          // 删除群会话
          // _removeConversation();
        } else {
          return;
        }
      } else {
        var confirm = await Get.dialog(CustomDialog(
          title: StrRes.quitGroupHint,
        ));
        if (confirm == true) {
          imLogic.markGroupAsQuitting(groupInfo.value.groupID);

          // 退群
          await OpenIM.iMManager.groupManager.quitGroup(
            groupID: groupInfo.value.groupID,
          );
          // 删除群会话
          _removeConversation();
        } else {
          return;
        }
      }
    } else {
      if (!isOwner) {
        // 删除群会话
        _removeConversation();
      }
    }

    AppNavigator.startBackMain();
  }

  void copyGroupID() {
    IMUtils.copy(text: groupInfo.value.groupID);
  }

  int length() {
    int buttons = isOwnerOrAdmin ? 2 : 1;
    return (memberList.length + buttons) > 10
        ? 10
        : (memberList.length + buttons);
  }

  Widget itemBuilder({
    required int index,
    required Widget Function(GroupMembersInfo info) builder,
    required Widget Function() addButton,
    required Widget Function() delButton,
  }) {
    var length = isOwnerOrAdmin ? 8 : 9;
    if (memberList.length > length) {
      if (index < length) {
        var info = memberList.elementAt(index);
        return builder(info);
      } else if (index == length) {
        return addButton();
      } else {
        return delButton();
      }
    } else {
      if (index < memberList.length) {
        var info = memberList.elementAt(index);
        return builder(info);
      } else if (index == memberList.length) {
        return addButton();
      } else {
        return delButton();
      }
    }
  }

  void toggleTopChat() async {
    await LoadingView.singleton.wrap(
      asyncFunction: () => OpenIM.iMManager.conversationManager.pinConversation(
        conversationID: conversationID,
        isPinned: !isPinned,
      ),
    );
  }

  void toggleNotDisturb() {
    LoadingView.singleton.wrap(
        asyncFunction: () =>
            OpenIM.iMManager.conversationManager.setConversationRecvMessageOpt(
              conversationID: conversationID,
              status: !isNotDisturb ? 2 : 0,
            ));
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

  addMember() async {
    final result = await AppNavigator.startSelectContacts(
      action: SelAction.addMember,
      groupID: groupInfo.value.groupID,
      excludeIDList: memberAllList.map((e) => e.userID!).toList(),
    );

    final list = IMUtils.convertSelectContactsResultToUserID(result);
    if (list is List<String>) {
      LoadingView.singleton.show();
      try {
        await OpenIM.iMManager.groupManager.inviteUserToGroup(
          groupID: groupInfo.value.groupID,
          userIDList: list,
          reason: 'Come on baby',
        );
        LoadingView.singleton.dismiss();
        if (isOwnerOrAdmin) {
          IMViews.showToast(StrRes.addSuccessfully, type: 1);
        } else {
          IMViews.showToast(StrRes.inviteSuccessfully, type: 1);
        }
      } catch (e) {
        LoadingView.singleton.dismiss();
        IMViews.showToast(StrRes.inviteFailed, type: 1);
      }

      refreshMemberList();
    }
  }

  removeMember() async {
    final list = await AppNavigator.startGroupMemberList(
      groupInfo: groupInfo.value,
      opType: GroupMemberOpType.del,
    );
    if (list is List<GroupMembersInfo> && list.isNotEmpty) {
      var removeUidList = list.map((e) => e.userID!).toList();
      try {
        await LoadingView.singleton.wrap(
          asyncFunction: () => OpenIM.iMManager.groupManager.kickGroupMember(
            groupID: groupInfo.value.groupID,
            userIDList: removeUidList,
            reason: 'Get out baby',
          ),
        );
      } catch (_) {}
      refreshMemberList();
    }
  }

  /// Check if group member is online
  bool isMemberOnline(GroupMembersInfo member) {
    return memberOnlineStatusMap[member.userID] ?? false;
  }

  /// Check if group has online members
  bool hasGroupOnlineMembers() {
    return memberOnlineStatusMap.values.any((isOnline) => isOnline);
  }

  /// Check if member should show online indicator
  bool shouldShowOnlineIndicator(GroupMembersInfo member) {
    return isMemberOnline(member);
  }

  void viewMemberInfo(GroupMembersInfo membersInfo) {
    final isSelf = membersInfo.userID == OpenIM.iMManager.userID;
    final isFriend = imLogic.friendIDMap.containsKey(membersInfo.userID);
    if (!isSelf &&
        groupInfo.value.lookMemberInfo == 1 &&
        !isOwnerOrAdmin &&
        !isFriend) {
      return;
    }
    AppNavigator.startUserProfilePane(
      userID: membersInfo.userID!,
      nickname: membersInfo.nickname,
      faceURL: membersInfo.faceURL,
      groupID: membersInfo.groupID,
    );
  }
}
