// ignore_for_file: deprecated_member_use

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:search_keyword_text/search_keyword_text.dart';
import 'package:sprintf/sprintf.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../widgets/file_download_progress.dart';
import 'global_search_logic.dart';

class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage>
    with TickerProviderStateMixin {
  final logic = Get.find<GlobalSearchLogic>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    logic.onTabChanged = (index) {
      if (_tabController.index != index) {
        _tabController.animateTo(index);
      }
    };

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        logic.index.value = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    logic.onTabChanged = null;
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return TouchCloseSoftKeyboard(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            // 1. Header Background
            Container(
              height: 150.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor.withOpacity(0.7),
                    primaryColor,
                    primaryColor.withOpacity(0.9),
                  ],
                ),
              ),
            ),

            // 2. Main Content Card
            Container(
              margin: EdgeInsets.only(top: 90.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: 40.h), // Space for Search Box overlap

                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: primaryColor,
                        width: 3.0,
                      ),
                      insets: EdgeInsets.symmetric(horizontal: 16.0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    indicatorPadding: EdgeInsets.zero,
                    dividerColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    labelColor: primaryColor,
                    unselectedLabelColor: const Color(0xFF9CA3AF),
                    labelStyle: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    tabs: [
                      Tab(text: StrRes.globalSearchAll),
                      Tab(text: StrRes.globalSearchContacts),
                      Tab(text: StrRes.globalSearchGroup),
                      Tab(text: StrRes.messages),
                      Tab(text: StrRes.globalSearchChatFile),
                    ],
                  ),
                  
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),

                  // Tab Bar View
                  Expanded(
                    child: Obx(() {
                      if (!logic.hasSearched.value) {
                        return _initialEmptyState;
                      }
                      if (logic.isSearchNotResult) {
                        return _emptyListView;
                      }
                      return TabBarView(
                        controller: _tabController,
                        children: [
                          _buildAllListView(),
                          _buildContactsListView(),
                          _buildGroupListView(),
                          _buildChatHistoryListView(),
                          _buildFileListView(),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),

            // 3. Search Box (Overlapping)
            Positioned(
              top: 50.h,
              left: 20.w,
              right: 20.w,
              child: Container(
                height: 56.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    16.horizontalSpace,
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedSearch01,
                      size: 24.w,
                      color: const Color(0xFF9CA3AF),
                    ),
                    12.horizontalSpace,
                    Expanded(
                      child: TextField(
                        controller: logic.searchCtrl,
                        focusNode: logic.focusNode,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF374151),
                        ),
                        decoration: InputDecoration(
                          hintText: StrRes.search,
                          hintStyle: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF9CA3AF),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => logic.search(),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    logic.searchCtrl.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              logic.clearSearch();
                              setState(() {});
                            },
                            child: Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Icon(
                                CupertinoIcons.clear_circled_solid,
                                size: 20.w,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          )
                        : SizedBox(width: 16.w),
                  ],
                ),
              ),
            ),      
          ],
        ),
      ),
    );
  }

  Widget _buildAllListView() => Container(
        color: Colors.white,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(top: 16.h, bottom: 20.h),
          child: AnimationLimiter(
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 450),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  curve: Curves.easeOutQuart,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  if (logic.contactsList.isNotEmpty)
                    _buildCommonContainer(
                      title: StrRes.globalSearchContacts,
                      children: logic
                          .subList(logic.contactsList)
                          .asMap()
                          .entries
                          .map((entry) => _buildFriendItemView(
                                showName: logic.getNickname(entry.value),
                                faceURL: entry.value.faceURL,
                                content: logic.getItemContent(entry.value),
                                onTap: () => logic.viewUserProfile(entry.value),
                                showDivider:
                                    entry.key != logic.contactsList.length - 1,
                              ))
                          .toList(),
                      seeMoreStr: logic.contactsList.length > 2
                          ? StrRes.seeMoreRelatedContacts
                          : null,
                      onSeeMore: () => logic.switchTab(1),
                    ),
                  if (logic.groupList.isNotEmpty) 16.verticalSpace,
                  if (logic.groupList.isNotEmpty)
                    _buildCommonContainer(
                      title: StrRes.globalSearchGroup,
                      children: logic
                          .subList(logic.groupList)
                          .asMap()
                          .entries
                          .map((entry) => _buildGroupItemView(
                                info: entry.value,
                                onTap: () => logic.viewGroup(entry.value),
                                showDivider:
                                    entry.key != logic.groupList.length - 1,
                              ))
                          .toList(),
                      seeMoreStr: logic.groupList.length > 2
                          ? StrRes.seeMoreRelatedGroup
                          : null,
                      onSeeMore: () => logic.switchTab(2),
                    ),
                  if (logic.textSearchResultItems.isNotEmpty) 16.verticalSpace,
                  if (logic.textSearchResultItems.isNotEmpty)
                    _buildCommonContainer(
                      title: StrRes.messages,
                      children: logic
                          .subList(logic.textSearchResultItems)
                          .asMap()
                          .entries
                          .map((entry) {
                        final e = entry.value;
                        final key = entry.key;
                        final message = e.messageList?.firstOrNull;
                        final showName = e.showName;
                        final faceURL = e.faceURL;
                        final sendTime = message?.sendTime;
                        final count = e.messageCount ?? 0;
                        final content = count > 1
                            ? sprintf(StrRes.relatedChatHistory, [count])
                            : logic.calContent(message!);
                        final time = null == sendTime
                            ? null
                            : IMUtils.getChatTimeline(sendTime);
                        return _buildMessageItemView(
                            showName: showName,
                            faceURL: faceURL,
                            time: time,
                            content: content,
                            isGroup: message?.isSingleChat == false,
                            onTap: () => logic.viewMessage(e),
                            showDivider: key != logic.contactsList.length - 1);
                      }).toList(),
                      seeMoreStr: logic.textSearchResultItems.length > 2
                          ? StrRes.seeMoreRelatedChatHistory
                          : null,
                      onSeeMore: () => logic.switchTab(3),
                    ),
                  if (logic.fileMessageList.isNotEmpty) 16.verticalSpace,
                  if (logic.fileMessageList.isNotEmpty)
                    _buildCommonContainer(
                      title: StrRes.globalSearchChatFile,
                      children: logic
                          .subList(logic.fileMessageList)
                          .asMap()
                          .entries
                          .map((entry) => _buildMessageItemView(
                              showName: IMUtils.calContent(
                                content: entry.value.fileElem?.fileName ?? '',
                                key: logic.searchKey,
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF374151),
                                ),
                                usedWidth: 44.w + 80.w + 26.w,
                              ),
                              fileIcon: ChatFileIconView(
                                message: entry.value,
                                downloadProgressView:
                                    FileDownloadProgressView(entry.value),
                              ),
                              content: entry.value.senderNickname,
                              onTap: () => logic.viewFile(entry.value),
                              showDivider:
                                  entry.key != logic.contactsList.length - 1))
                          .toList(),
                      seeMoreStr: logic.fileMessageList.length > 2
                          ? StrRes.seeMoreRelatedFile
                          : null,
                      onSeeMore: () => logic.switchTab(4),
                    ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildContactsListView() =>
      logic.searchKey.isNotEmpty && logic.contactsList.isEmpty
          ? _emptyListView
          : Container(
              color: Colors.white,
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(0.w, 16.h, 0.w, 16.h),
                itemCount: logic.contactsList.length,
                itemBuilder: (_, index) => _buildFriendItemView(
                  showName: logic.getNickname(logic.contactsList[index]),
                  faceURL: logic.contactsList[index].faceURL,
                  content: logic.getItemContent(logic.contactsList[index]),
                  onTap: () => logic.viewUserProfile(logic.contactsList[index]),
                  showDivider: index != logic.contactsList.length - 1,
                ),
              ),
            );

  Widget _buildGroupListView() =>
      logic.searchKey.isNotEmpty && logic.groupList.isEmpty
          ? _emptyListView
          : Container(
              color: Colors.white,
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(0.w, 16.h, 0.w, 16.h),
                itemCount: logic.groupList.length,
                itemBuilder: (_, index) => _buildGroupItemView(
                  info: logic.groupList[index],
                  onTap: () => logic.viewGroup(logic.groupList[index]),
                ),
              ),
            );

  Widget _buildChatHistoryListView() => logic.searchKey.isNotEmpty &&
          logic.textSearchResultItems.isEmpty
      ? _emptyListView
      : SmartRefresher(
          key: const ValueKey(0),
          controller: logic.textMessageRefreshCtrl,
          enablePullDown: false,
          enablePullUp: true,
          footer: IMViews.buildFooter(),
          onLoading: logic.loadTextMessage,
          child: Container(
            color: Colors.white,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(0.w, 16.h, 0.w, 16.h),
              itemCount: logic.textSearchResultItems.length,
              itemBuilder: (_, index) {
                final e = logic.textSearchResultItems.elementAt(index);
                final message = e.messageList?.firstOrNull;
                final showName = e.showName;
                final faceURL = e.faceURL;
                final sendTime = message?.sendTime;
                final count = e.messageCount ?? 0;
                final content = count > 1
                    ? sprintf(StrRes.relatedChatHistory, [count])
                    : logic.calContent(message!);
                final time =
                    null == sendTime ? null : IMUtils.getChatTimeline(sendTime);
                return _buildMessageItemView(
                  showName: showName,
                  faceURL: faceURL,
                  time: time,
                  content: content,
                  isGroup: message?.isSingleChat == false,
                  onTap: () => logic.viewMessage(e),
                  showDivider: index != logic.textSearchResultItems.length - 1,
                );
              },
            ),
          ),
        );

  Widget _buildFileListView() =>
      logic.searchKey.isNotEmpty && logic.fileMessageList.isEmpty
          ? _emptyListView
          : SmartRefresher(
              key: const ValueKey(1),
              controller: logic.fileMessageRefreshCtrl,
              enablePullDown: false,
              enablePullUp: true,
              footer: IMViews.buildFooter(),
              onLoading: logic.loadFileMessage,
              child: Container(
                color: Colors.white,
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(0.w, 16.h, 0.w, 16.h),
                  itemCount: logic.fileMessageList.length,
                  itemBuilder: (_, index) {
                    final e = logic.fileMessageList.elementAt(index);
                    return _buildMessageItemView(
                      showName: IMUtils.calContent(
                        content: e.fileElem?.fileName ?? '',
                        key: logic.searchKey,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                        usedWidth: 44.w + 80.w + 26.w,
                      ),
                      fileIcon: ChatFileIconView(
                        message: e,
                        downloadProgressView: FileDownloadProgressView(e),
                      ),
                      content: e.senderNickname,
                      onTap: () => logic.viewFile(e),
                      showDivider: index != logic.fileMessageList.length - 1,
                    );
                  },
                ),
              ),
            );

  Widget _buildCommonContainer({
    required String title,
    List<Widget> children = const [],
    String? seeMoreStr,
    Function()? onSeeMore,
  }) =>
      Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF374151),
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            ...children,
            if (null != seeMoreStr) ...[
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onSeeMore,
                child: Container(
                  height: 48.h,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Text(
                        seeMoreStr,
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4F42FF),
                        ),
                      ),
                      const Spacer(),
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight02,
                        color: const Color(0xFF4F42FF),
                        size: 18.w,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      );

  Widget _buildFriendItemView({
    String? showName,
    String? faceURL,
    String? content,
    bool showDivider = false,
    Function()? onTap,
  }) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                AvatarView(
                  width: 48.w,
                  height: 48.h,
                  text: showName,
                  url: faceURL,
                  textStyle: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  isCircle: true,
                ),
                16.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SearchKeywordText(
                        text: showName ?? '',
                        keyText: RegExp.escape(logic.searchKey),
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                        keyStyle: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF4F42FF),
                        ),
                      ),
                      if (content != null) ...[
                        4.verticalSpace,
                        SearchKeywordText(
                          text: content,
                          keyText: RegExp.escape(logic.searchKey),
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF9CA3AF),
                          ),
                          keyStyle: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4F42FF),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildMessageItemView({
    String? showName,
    String? faceURL,
    String? time,
    String? content,
    Widget? fileIcon,
    bool showDivider = false,
    bool isGroup = false,
    Function()? onTap,
  }) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                fileIcon ??
                    AvatarView(
                      width: 48.w,
                      height: 48.h,
                      text: showName,
                      url: faceURL,
                      isGroup: isGroup,
                      textStyle: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      isCircle: true,
                    ),
                16.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              showName ?? '',
                              style: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF374151),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (time != null) ...[
                            12.horizontalSpace,
                            Text(
                              time,
                              style: TextStyle(
                                fontFamily: 'FilsonPro',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (content != null) ...[
                        4.verticalSpace,
                        SearchKeywordText(
                          text: content,
                          keyText: RegExp.escape(logic.searchKey),
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B7280),
                          ),
                          keyStyle: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4F42FF),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildGroupItemView({
    required GroupInfo info,
    bool showDivider = false,
    Function()? onTap,
  }) {
    final shouldShowCount = logic.shouldShowMemberCount(info.groupID);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              AvatarView(
                width: 48.w,
                height: 48.h,
                text: info.groupName,
                url: info.faceURL,
                isGroup: true,
                textStyle: TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                isCircle: true,
              ),
              16.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchKeywordText(
                      text: info.groupName ?? '',
                      keyText: RegExp.escape(logic.searchKey),
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                      keyStyle: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF4F42FF),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (shouldShowCount) ...[
                      4.verticalSpace,
                      Text(
                        '${info.memberCount ?? 0} ${StrRes.members}',
                        style: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _emptyListView => Center(
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              40.verticalSpace,
              Container(
                padding: EdgeInsets.all(20.w),
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
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedSearch01,
                      size: 48.w,
                      color: const Color(0xFF6B7280),
                    ),
                    16.verticalSpace,
                    Text(
                      StrRes.searchNotFound,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  // Initial empty state - shown when user hasn't searched yet
  Widget get _initialEmptyState => Center(
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              40.verticalSpace,
              Container(
                padding: EdgeInsets.all(32.w),
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
                    // Search icon
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedSearch01,
                      size: 64.w,
                      color: const Color(0xFF9CA3AF),
                    ),
                    24.verticalSpace,
                    // Text message
                    Text(
                      StrRes.pleaseEnterToSearch,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'FilsonPro',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
