import 'dart:convert';
import 'dart:math';

import 'package:emoji_selector/emoji_selector.dart';
import 'package:emoji_selector/src/category.dart';
import 'package:emoji_selector/src/category_icon.dart';
import 'package:emoji_selector/src/category_selector.dart';
import 'package:emoji_selector/src/emoji_internal_data.dart';
import 'package:emoji_selector/src/emoji_page.dart';
import 'package:emoji_selector/src/group.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class EmojiSelector extends StatefulWidget {
  final int columns;
  final int rows;
  final EdgeInsets padding;
  final bool withTitle;
  final Function(EmojiData) onSelected;
  final Color? primaryColor;
  final Color? backgroundColor;

  // Localization strings
  final String? loadingEmojisText;
  final String? searchForEmojisText;
  final String? smileysAndPeopleText;
  final String? animalsAndNatureText;
  final String? foodAndDrinkText;
  final String? activityText;
  final String? travelAndPlacesText;
  final String? objectsText;
  final String? symbolsText;
  final String? flagsText;

  const EmojiSelector({
    Key? key,
    this.columns = 10,
    this.rows = 5,
    this.padding = const EdgeInsets.all(2.0),
    this.withTitle = true,
    this.primaryColor,
    this.backgroundColor,
    required this.onSelected,
    this.loadingEmojisText,
    this.searchForEmojisText,
    this.smileysAndPeopleText,
    this.animalsAndNatureText,
    this.foodAndDrinkText,
    this.activityText,
    this.travelAndPlacesText,
    this.objectsText,
    this.symbolsText,
    this.flagsText,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EmojiSelectorState();
}

class _EmojiSelectorState extends State<EmojiSelector>
    with TickerProviderStateMixin {
  TextEditingController _controller = TextEditingController();
  Category selectedCategory = Category.smileys;
  List<EmojiInternalData> _emojiSearch = [];
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;

  // Updated color scheme according to Cute Minimalist guide
  Color get primaryColor => widget.primaryColor ?? const Color(0xFF4F42FF);
  Color get backgroundColor =>
      widget.backgroundColor ?? const Color(0xFFF9FAFB);
  Color get surfaceColor => const Color(0xFFFFFFFF);
  Color get onSurfaceColor => const Color(0xFF374151);
  Color get secondaryColor => const Color(0xFF6B7280);

  final List<EmojiInternalData> _emojis = [];
  late Map<Category, Group> _groups;
  List<Category> order = [
    Category.smileys,
    Category.animals,
    Category.foods,
    Category.activities,
    Category.travel,
    Category.objects,
    Category.symbols,
    Category.flags,
  ];

  bool _loaded = false;

  final bool _showEmojiSearch = false;

  @override
  void initState() {
    super.initState();
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _searchAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Initialize groups with localized strings
    _groups = {
      Category.smileys: Group(
        Category.smileys,
        CategoryIcons.smileyIcon,
        widget.smileysAndPeopleText ?? 'Smileys & People',
        ['Smileys & Emotion', 'People & Body'],
      ),
      Category.animals: Group(
        Category.animals,
        CategoryIcons.animalIcon,
        widget.animalsAndNatureText ?? 'Animals & Nature',
        ['Animals & Nature'],
      ),
      Category.foods: Group(
        Category.foods,
        CategoryIcons.foodIcon,
        widget.foodAndDrinkText ?? 'Food & Drink',
        ['Food & Drink'],
      ),
      Category.activities: Group(
        Category.activities,
        CategoryIcons.activityIcon,
        widget.activityText ?? 'Activity',
        ['Activities'],
      ),
      Category.travel: Group(
        Category.travel,
        CategoryIcons.travelIcon,
        widget.travelAndPlacesText ?? 'Travel & Places',
        ['Travel & Places'],
      ),
      Category.objects: Group(
        Category.objects,
        CategoryIcons.objectIcon,
        widget.objectsText ?? 'Objects',
        ['Objects'],
      ),
      Category.symbols: Group(
        Category.symbols,
        CategoryIcons.symbolIcon,
        widget.symbolsText ?? 'Symbols',
        ['Symbols'],
      ),
      Category.flags: Group(
        Category.flags,
        CategoryIcons.flagIcon,
        widget.flagsText ?? 'Flags',
        ['Flags'],
      ),
    };

    loadEmoji(context);
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9CA3AF).withValues(alpha: 0.08),
              offset: const Offset(0, 2),
              blurRadius: 12,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.loadingEmojisText ?? 'Loading emojis...',
                style: const TextStyle(
                  fontFamily: 'FilsonPro',
                  color: Color(
                    0xFF6B7280,
                  ),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      );
    }

    int smileysNum = _groups[Category.smileys]!.pages.length;
    int animalsNum = _groups[Category.animals]!.pages.length;
    int foodsNum = _groups[Category.foods]!.pages.length;
    int activitiesNum = _groups[Category.activities]!.pages.length;
    int travelNum = _groups[Category.travel]!.pages.length;
    int objectsNum = _groups[Category.objects]!.pages.length;
    int symbolsNum = _groups[Category.symbols]!.pages.length;
    int flagsNum = _groups[Category.flags]!.pages.length;

    PageController pageController;
    switch (selectedCategory) {
      case Category.smileys:
        pageController = PageController(initialPage: 0);
        break;
      case Category.animals:
        pageController = PageController(initialPage: smileysNum);
        break;
      case Category.foods:
        pageController = PageController(initialPage: smileysNum + animalsNum);
        break;
      case Category.activities:
        pageController =
            PageController(initialPage: smileysNum + animalsNum + foodsNum);
        break;
      case Category.travel:
        pageController = PageController(
            initialPage: smileysNum + animalsNum + foodsNum + activitiesNum);
        break;
      case Category.objects:
        pageController = PageController(
            initialPage:
                smileysNum + animalsNum + foodsNum + activitiesNum + travelNum);
        break;
      case Category.symbols:
        pageController = PageController(
            initialPage: smileysNum +
                animalsNum +
                foodsNum +
                activitiesNum +
                travelNum +
                objectsNum);
        break;
      case Category.flags:
        pageController = PageController(
            initialPage: smileysNum +
                animalsNum +
                foodsNum +
                activitiesNum +
                travelNum +
                objectsNum +
                symbolsNum);
        break;
      default:
        pageController = PageController(initialPage: 0);
        break;
    }
    pageController.addListener(() {
      setState(() {});
    });

    List<Widget> pages = [];
    List<Widget> selectors = [];
    Group selectedGroup = _groups[selectedCategory]!;
    int index = 0;
    for (Category category in _groups.keys) {
      Group group = _groups[category]!;
      pages.addAll(group.pages.map((e) => EmojiPage(
            rows: widget.rows,
            columns: widget.columns,
            emojis: e,
            primaryColor: primaryColor,
            onSelected: (internalData) {
              EmojiData emoji = EmojiData(
                id: internalData.id,
                name: internalData.name,
                unified: internalData.unified,
                char: internalData.char,
                category: internalData.category,
              );
              widget.onSelected(emoji);
            },
          )));
      int current = index;
      selectors.add(
        CategorySelector(
          icon: group.icon,
          selected: selectedCategory == group.category,
          primaryColor: primaryColor,
          onSelected: () {
            pageController.jumpToPage(current);
          },
        ),
      );
      index += group.pages.length;
    }

    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: Colors.white, //surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9CA3AF).withValues(alpha: 0.08),
            offset: const Offset(0, 2),
            blurRadius: 12,
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
          // Search Bar
          if (_showEmojiSearch)
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFF3F4F6),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _controller,
                onChanged: (text) {
                  searchEmoji(text);
                  if (text.isNotEmpty) {
                    _searchAnimationController.forward();
                  } else {
                    _searchAnimationController.reverse();
                  }
                },
                style: const TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                  hintText:
                      widget.searchForEmojisText ?? 'Search for emojis...',
                  hintStyle: const TextStyle(
                    fontFamily: 'FilsonPro',
                    color: Color(
                      0xFF6B7280,
                    ),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.only(left: 8, right: 8),
                    child: AnimatedBuilder(
                      animation: _searchAnimation,
                      builder: (context, child) {
                        return Icon(
                          Icons.search_rounded,
                          color: Color.lerp(
                            const Color(0xFF6B7280),
                            primaryColor,
                            _searchAnimation.value,
                          ),
                          size: 20,
                        );
                      },
                    ),
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: IconButton(
                            icon: const Icon(
                              Icons.clear_rounded,
                              color: Color(0xFF6B7280),
                              size: 20,
                            ),
                            onPressed: () {
                              _controller.clear();
                              searchEmoji('');
                              _searchAnimationController.reverse();
                            },
                          ),
                        )
                      : null,
                ),
              ),
            ),

          // Category Title
          if (widget.withTitle && _controller.text.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Text(
                selectedGroup.title,
                style: const TextStyle(
                  fontFamily: 'FilsonPro',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.3,
                ),
              ),
            ),

          // Emoji Grid
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: (_emojiSearch.isNotEmpty && _controller.text.isNotEmpty)
                  ? EmojiPage(
                      rows: widget.rows,
                      columns: widget.columns,
                      emojis: _emojiSearch,
                      primaryColor: primaryColor,
                      onSelected: (internalData) {
                        EmojiData emoji = EmojiData(
                          id: internalData.id,
                          name: internalData.name,
                          unified: internalData.unified,
                          char: internalData.char,
                          category: internalData.category,
                        );
                        widget.onSelected(emoji);
                      },
                    )
                  : PageView(
                      pageSnapping: true,
                      controller: pageController,
                      onPageChanged: (index) {
                        if (index < smileysNum) {
                          selectedCategory = Category.smileys;
                        } else if (index < smileysNum + animalsNum) {
                          selectedCategory = Category.animals;
                        } else if (index < smileysNum + animalsNum + foodsNum) {
                          selectedCategory = Category.foods;
                        } else if (index <
                            smileysNum +
                                animalsNum +
                                foodsNum +
                                activitiesNum) {
                          selectedCategory = Category.activities;
                        } else if (index <
                            smileysNum +
                                animalsNum +
                                foodsNum +
                                activitiesNum +
                                travelNum) {
                          selectedCategory = Category.travel;
                        } else if (index <
                            smileysNum +
                                animalsNum +
                                foodsNum +
                                activitiesNum +
                                travelNum +
                                objectsNum) {
                          selectedCategory = Category.objects;
                        } else if (index <
                            smileysNum +
                                animalsNum +
                                foodsNum +
                                activitiesNum +
                                travelNum +
                                objectsNum +
                                symbolsNum) {
                          selectedCategory = Category.symbols;
                        } else if (index <
                            smileysNum +
                                animalsNum +
                                foodsNum +
                                activitiesNum +
                                travelNum +
                                objectsNum +
                                symbolsNum +
                                flagsNum) {
                          selectedCategory = Category.flags;
                        }
                      },
                      children: pages,
                    ),
            ),
          ),

          // Category Selector
          if (_controller.text.isEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFF3F4F6),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9CA3AF).withValues(alpha: 0.06),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate available width
                  double availableWidth = constraints.maxWidth - 16;
                  double buttonWidth = 42;
                  double totalButtonsWidth = selectors.length * buttonWidth;

                  // If buttons fit, use Row with spaceEvenly
                  if (totalButtonsWidth <= availableWidth) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: selectors,
                    );
                  } else {
                    // If buttons don't fit, use scrollable SingleChildScrollView
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: selectors.asMap().entries.map((entry) {
                          int index = entry.key;
                          Widget selector = entry.value;

                          return Container(
                            margin: EdgeInsets.only(
                              right: index < selectors.length - 1 ? 10 : 0,
                            ),
                            child: selector,
                          );
                        }).toList(),
                      ),
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  loadEmoji(BuildContext context) async {
    const path = 'packages/emoji_selector/data/emoji_new.json';
    String data = await rootBundle.loadString(path);
    final emojiList = json.decode(data);

    // Filter out skin tone variants and keep only base emojis
    Set<String> processedEmojis = {};

    for (var emojiJson in emojiList) {
      String codes = emojiJson['codes'].toString();

      // Check if this emoji has skin tone
      bool hasSkinTone = codes.contains('1F3FB') ||
          codes.contains('1F3FC') ||
          codes.contains('1F3FD') ||
          codes.contains('1F3FE') ||
          codes.contains('1F3FF');

      String baseCode;
      if (hasSkinTone) {
        // Extract base emoji code by removing skin tone
        // Remove skin tone codes and clean up spaces
        baseCode = codes
            .replaceAll(RegExp(r'\s*1F3F[B-F]\s*'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
      } else {
        baseCode = codes;
      }

      // Only add if we haven't processed this base emoji yet
      if (!processedEmojis.contains(baseCode)) {
        processedEmojis.add(baseCode);

        // Create emoji data with base code (no skin tone)
        Map<String, dynamic> baseEmojiJson = Map.from(emojiJson);
        baseEmojiJson['codes'] = baseCode;

        EmojiInternalData data = EmojiInternalData.fromJson(baseEmojiJson);
        _emojis.add(data);
      }
    }

    // Per Category, create pages
    for (Category category in order) {
      Group group = _groups[category]!;
      List<EmojiInternalData> categoryEmojis = [];
      for (String name in group.names) {
        List<EmojiInternalData> subName =
            _emojis.where((element) => element.category == name).toList();
        // Since new format doesn't have sort_order, we maintain original order
        categoryEmojis.addAll(subName);
      }

      // Create pages for that Category
      int num = (categoryEmojis.length / (widget.rows * widget.columns)).ceil();
      for (var i = 0; i < num; i++) {
        int start = widget.columns * widget.rows * i;
        int end =
            min(widget.columns * widget.rows * (i + 1), categoryEmojis.length);
        List<EmojiInternalData> pageEmojis = categoryEmojis.sublist(start, end);
        group.pages.add(pageEmojis);
      }
    }
    setState(() {
      _loaded = true;
    });
  }

  void searchEmoji(String text) {
    List<EmojiInternalData> newEmojis = _emojis.where((element) {
      return element.name!.toLowerCase().contains(text.toLowerCase()) ||
          (element.shortName != null &&
              element.shortName!.toLowerCase().contains(text.toLowerCase()));
    }).toList();
    setState(() {
      _emojiSearch = newEmojis;
    });
  }
}
