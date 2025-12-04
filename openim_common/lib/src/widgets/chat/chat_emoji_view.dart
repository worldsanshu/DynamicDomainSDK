// ignore_for_file: deprecated_member_use

import 'package:emoji_selector/emoji_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart' hide Config;
import 'package:should_rebuild/should_rebuild.dart';

class ChatEmojiView extends StatefulWidget {
  const ChatEmojiView({
    super.key,
    this.favoriteList = const [],
    this.onAddFavorite,
    this.onSelectedFavorite,
    required this.textEditingController,
    required this.height,
    this.customEmojiLayout,
  });
  final List<String> favoriteList;
  final Function()? onAddFavorite;
  final Function(int index, String url)? onSelectedFavorite;
  final TextEditingController textEditingController;
  final double height;
  final Widget? customEmojiLayout;

  @override
  State<ChatEmojiView> createState() => _ChatEmojiViewState();
}

class _ChatEmojiViewState extends State<ChatEmojiView> {
  static var _currentTabIndex = 0; // Static variable to preserve tab state
  var _index = _currentTabIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFFFF), // iOS white background
      height: widget.height,
      child: Column(
        children: [
          // iOS-style tab bar
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF), // iOS white
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFC7C7CC), // iOS border
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                _buildTabButton(
                  icon: CupertinoIcons.chat_bubble_2,
                  label: 'Emoji',
                  isSelected: _index == 0,
                  onTap: () {
                    setState(() {
                      _index = 0;
                      _currentTabIndex = 0;
                    });
                  },
                ),
                _buildTabButton(
                  icon: CupertinoIcons.heart_fill,
                  label: 'Favorites',
                  isSelected: _index == 1,
                  onTap: () {
                    setState(() {
                      _index = 1;
                      _currentTabIndex = 1;
                    });
                  },
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: IndexedStack(
              index: _index,
              children: [
                widget.customEmojiLayout ??
                    ShouldRebuild<EmojiLayout>(
                      shouldRebuild: (oldWidget, newWidget) => false,
                      child: EmojiLayout(
                        height: widget.height - 56.h,
                        controller: widget.textEditingController,
                      ),
                    ),
                _buildFavoriteLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 0.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF007AFF).withOpacity(0.1)
                  : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color:
                      isSelected ? const Color(0xFF007AFF) : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20.w,
                  color: isSelected
                      ? const Color(0xFF007AFF) // iOS blue
                      : const Color(0xFF8E8E93), // iOS gray
                ),
                2.verticalSpace,
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF007AFF) // iOS blue
                        : const Color(0xFF8E8E93), // iOS gray
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildFavoriteLayout() => Container(
        color: Colors.white, // iOS system background
        child: GridView.builder(
          padding: EdgeInsets.all(8.w),
          itemCount: widget.favoriteList.length + 1,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            childAspectRatio: 1.0,
            mainAxisSpacing: 8.h,
            crossAxisSpacing: 8.w,
          ),
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return _AddFavoriteButton(
                onTap: widget.onAddFavorite,
              );
            }
            var emoji = widget.favoriteList.elementAt(index - 1);
            return _FavoriteEmojiButton(
              emoji: emoji,
              onSelected: () =>
                  widget.onSelectedFavorite?.call(index - 1, emoji),
            );
          },
        ),
      );
}

/// Add favorite button widget with hover animation
class _AddFavoriteButton extends StatefulWidget {
  final VoidCallback? onTap;

  const _AddFavoriteButton({
    this.onTap,
  });

  @override
  State<_AddFavoriteButton> createState() => _AddFavoriteButtonState();
}

class _AddFavoriteButtonState extends State<_AddFavoriteButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: _isHovered
                    ? const Color(0x0D007AFF)
                    : const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered
                        ? const Color(0x14007AFF)
                        : const Color(0x0F9CA3AF),
                    offset: const Offset(0, 2),
                    blurRadius: _isHovered ? 6 : 4,
                  ),
                ],
                border: Border.all(
                  color: _isHovered
                      ? const Color(0xFF007AFF)
                      : const Color(0xFFC7C7CC),
                  width: _isHovered ? 1.5 : 0.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: widget.onTap,
                  child: Center(
                    child: Icon(
                      CupertinoIcons.plus,
                      size: 20.w,
                      color: const Color(0xFF007AFF),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Favorite emoji button widget with hover animation
class _FavoriteEmojiButton extends StatefulWidget {
  final String emoji;
  final VoidCallback onSelected;

  const _FavoriteEmojiButton({
    required this.emoji,
    required this.onSelected,
  });

  @override
  State<_FavoriteEmojiButton> createState() => _FavoriteEmojiButtonState();
}

class _FavoriteEmojiButtonState extends State<_FavoriteEmojiButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: _isHovered
                    ? const Color(0xFFF3F4F6)
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered
                        ? const Color(0x149CA3AF)
                        : const Color(0x0F9CA3AF),
                    offset: const Offset(0, 2),
                    blurRadius: _isHovered ? 6 : 4,
                  ),
                ],
                border: Border.all(
                  color: _isHovered
                      ? const Color(0xFFD1D5DB)
                      : const Color(0xFFF3F4F6),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: widget.onSelected,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        widget.emoji,
                        style: const TextStyle(
                          fontSize: 24,
                          fontFamily: 'Apple Color Emoji',
                          fontFamilyFallback: ["Noto Emoji"],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class EmojiLayout extends StatelessWidget {
  const EmojiLayout({
    super.key,
    required this.controller,
    this.height,
  });
  final TextEditingController controller;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 288.h,
      color: const Color(0xFFF2F2F7), // iOS system background
      child: EmojiSelector(
        columns: 8,
        rows: 4,
        onSelected: (emojiData) {
          // Add emoji to text controller
          controller
            ..text += emojiData.char
            ..selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length),
            );
        },
        loadingEmojisText: StrRes.loadingEmojis,
        searchForEmojisText: StrRes.searchForEmojis,
        smileysAndPeopleText: StrRes.smileysAndPeople,
        animalsAndNatureText: StrRes.animalsAndNature,
        foodAndDrinkText: StrRes.foodAndDrink,
        activityText: StrRes.activity,
        travelAndPlacesText: StrRes.travelAndPlaces,
        objectsText: StrRes.objects,
        symbolsText: StrRes.symbols,
        flagsText: StrRes.flags,
      ),
    );
  }
}
