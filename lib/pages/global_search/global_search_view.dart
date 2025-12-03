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
import '../../widgets/base_page.dart';

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

    // Đăng ký callback để logic có thể điều khiển TabController
    logic.onTabChanged = (index) {
      if (_tabController.index != index) {
        _tabController.animateTo(index);
      }
    };

    // Listen to tab changes and update logic index
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        logic.index.value = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    logic.onTabChanged = null; // Cleanup callback
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: BasePage(
        showAppBar: true,
        centerTitle: false,
        showLeading: false,
        customAppBar: WechatStyleSearchBox(
          controller: logic.searchCtrl,
          focusNode: logic.focusNode,
          hintText: StrRes.search,
          enabled: true,
          autofocus: true,
          onSubmitted: (_) => logic.search(),
          onCleared: () =>
              logic.clearSearch(), // Clear search and reset to initial state
          margin: EdgeInsets.zero,
          backgroundColor: const Color(0xFFF8FAFC),
          searchIconColor: const Color(0xFF6B7280),
        ),
        body: _buildContentContainer(),
      ),
    );
  }

  Widget _buildContentContainer() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          // Search Box

          // Tab Bar
          TabBar(
            controller: _tabController,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(
                color: Color(0xFF9E9E9E),
                width: 2.0,
              ),
              insets: EdgeInsets.symmetric(horizontal: 16.0),
            ),
            indicatorPadding: EdgeInsets.all(2.w),
            dividerColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            labelColor: const Color(0xFF374151),
            unselectedLabelColor: const Color(0xFF9CA3AF),
            labelStyle: TextStyle(
              fontFamily: 'FilsonPro',
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'FilsonPro',
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
            isScrollable: false,
            labelPadding: EdgeInsets.symmetric(horizontal: 0.w),
            padding: EdgeInsets.zero,
            tabs: [
              Tab(text: StrRes.globalSearchAll),
              Tab(text: StrRes.globalSearchContacts),
              Tab(text: StrRes.globalSearchGroup),
              Tab(text: StrRes.messages),
              Tab(text: StrRes.globalSearchChatFile),
            ],
          ),
          // Tab Bar View
          Expanded(
            child: Obx(() {
              // Show initial empty state when user hasn't searched yet
              if (!logic.hasSearched.value) {
                return _initialEmptyState;
              }
              // Show "no results" empty state when search returned no results
              if (logic.isSearchNotResult) {
                return _emptyListView;
              }
              // Show normal search results
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
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              offset: const Offset(-1, -1),
              blurRadius: 4,
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 1.5,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.9),
              const Color(0xFFF8FAFC),
            ],
            stops: const [0.05, 0.3],
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
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 0.5),
                      blurRadius: 1,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ],
                ),
              ),
            ),
            ...children,
            if (null != seeMoreStr)
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onSeeMore,
                child: Container(
                  height: 48.h,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: const BoxDecoration(
                    border: BorderDirectional(
                      top: BorderSide(
                        color: Color(0xFFF3F4F6),
                        width: 1,
                      ),
                    ),
                  ),
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
        ),
      );

  Widget _buildFriendItemView({
    String? showName,
    String? faceURL,
    String? content,
    bool showDivider = false,
    Function()? onTap,
  }) =>
      Container(
        color: Colors.white,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  AvatarView(
                    width: 50.w,
                    height: 50.h,
                    text: showName,
                    url: faceURL,
                    textStyle: TextStyle(
                      fontFamily: 'FilsonPro',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    isCircle: false,
                    borderRadius: BorderRadius.circular(50.r),
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
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF424242),
                          ),
                          keyStyle: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF424242),
                          ),
                        ),
                        if (content != null) ...[
                          8.verticalSpace,
                          SearchKeywordText(
                            text: content,
                            keyText: RegExp.escape(logic.searchKey),
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF9E9E9E),
                            ),
                            keyStyle: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF9E9E9E),
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
      Container(
        color: Colors.white,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  fileIcon ??
                      AvatarView(
                        width: 50.w,
                        height: 50.h,
                        text: showName,
                        url: faceURL,
                        isGroup: isGroup,
                        textStyle: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        isCircle: false,
                        borderRadius: BorderRadius.circular(50.r),
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
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF424242),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (time != null) ...[
                              20.horizontalSpace,
                              Text(
                                time,
                                style: TextStyle(
                                  fontFamily: 'FilsonPro',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF9E9E9E),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (content != null) ...[
                          8.verticalSpace,
                          SearchKeywordText(
                            text: content,
                            keyText: RegExp.escape(logic.searchKey),
                            style: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF9E9E9E),
                            ),
                            keyStyle: TextStyle(
                              fontFamily: 'FilsonPro',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF9E9E9E),
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
        ),
      );

  Widget _buildGroupItemView({
    required GroupInfo info,
    bool showDivider = false,
    Function()? onTap,
  }) {
    final shouldShowCount = logic.shouldShowMemberCount(info.groupID);

    return Container(
      color: Colors.white,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                AvatarView(
                  width: 50.w,
                  height: 50.h,
                  text: info.groupName,
                  url: info.faceURL,
                  isGroup: true,
                  textStyle: TextStyle(
                    fontFamily: 'FilsonPro',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  isCircle: false,
                  borderRadius: BorderRadius.circular(50.r),
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
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF424242),
                        ),
                        keyStyle: TextStyle(
                          fontFamily: 'FilsonPro',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF424242),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (shouldShowCount) ...[
                        8.verticalSpace,
                        Text(
                          '${info.memberCount ?? 0} ${StrRes.members}',
                          style: TextStyle(
                            fontFamily: 'FilsonPro',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF9E9E9E),
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
