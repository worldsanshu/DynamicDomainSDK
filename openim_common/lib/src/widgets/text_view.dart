import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:openim_common/openim_common.dart';

/// message content: @uid1 @uid2 xxxxxxx
///

enum TextModel { match, normal }

class MatchTextView extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final TextStyle? matchTextStyle;
  final InlineSpan? prefixSpan;

  /// isReceived ? TextAlign.left : TextAlign.right
  final TextAlign textAlign;
  final TextOverflow overflow;
  final int? maxLines;
  final double textScaleFactor;

  /// all user info
  /// key:userid
  /// value:username
  final Map<String, String> allAtMap;
  final List<MatchPattern> patterns;
  final TextModel model;
  final Function(String? text)? onVisibleTrulyText;
  final bool isSupportCopy;
  final FocusNode? copyFocusNode;

  // final TextAlign textAlign;
  const MatchTextView(
      {super.key,
      required this.text,
      this.allAtMap = const <String, String>{},
      this.prefixSpan,
      this.patterns = const <MatchPattern>[],
      this.textAlign = TextAlign.left,
      this.overflow = TextOverflow.clip,
      this.textStyle,
      this.matchTextStyle,
      this.maxLines,
      this.textScaleFactor = 1.0,
      this.model = TextModel.match,
      this.onVisibleTrulyText,
      this.isSupportCopy = false,
      this.copyFocusNode});

  @override
  Widget build(BuildContext context) {
    final List<InlineSpan> children = <InlineSpan>[];

    if (prefixSpan != null) children.add(prefixSpan!);

    if (model == TextModel.normal) {
      _normalModel(children);
    } else {
      _matchModel(children);
    }

    // 复制@消息直接使用不在重复解析
    final textSpan = TextSpan(children: children);
    onVisibleTrulyText?.call(textSpan.toPlainText());

    var text = Text.rich(
      textSpan,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      textScaler: TextScaler.linear(textScaleFactor),
    );
    return Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: isSupportCopy
            ? SelectionArea(focusNode: copyFocusNode, child: text)
            : text);
  }

  _normalModel(List<InlineSpan> children) {
    children.add(TextSpan(text: text, style: textStyle));
  }

  _matchModel(List<InlineSpan> children) {
    // Debug: Log the input text being processed
    final mappingMap = <String, MatchPattern>{};

    for (var e in patterns) {
      if (e.type == PatternType.at) {
        mappingMap[regexAt] = e;
        mappingMap[regexAtAll] = MatchPattern(type: PatternType.atAll);
      } else if (e.type == PatternType.atAll) {
        // Handle atAll pattern explicitly
        mappingMap[regexAtAll] = e;
      } else if (e.type == PatternType.email) {
        mappingMap[regexEmail] = e;
      } else if (e.type == PatternType.mobile) {
        mappingMap[regexMobile] = e;
      } else if (e.type == PatternType.tel) {
        mappingMap[regexTel] = e;
      } else if (e.type == PatternType.url) {
        mappingMap[regexUrl] = e;
      } else {
        mappingMap[e.pattern!] = e;
      }
    }
    var regexEmoji = emojiFaces.keys
        .toList()
        .join('|')
        .replaceAll('[', '\\[')
        .replaceAll(']', '\\]');

    mappingMap[regexEmoji] = MatchPattern(type: PatternType.email);

    String pattern;

    if (mappingMap.length > 1) {
      pattern = '(${mappingMap.keys.toList().join('|')})';
    } else {
      pattern = regexEmoji;
    }
    // RegExp pattern2 = RegExp(r"(@\d+\s)");
    // pattern2.hasMatch(text.replaceAll("", ''));
    // match  text
      text.splitMapJoin(
      RegExp(pattern),
      onMatch: (Match match) {
        var matchText = match[0]!;
        InlineSpan inlineSpan;
        final mapping = mappingMap[matchText] ??
            mappingMap[mappingMap.keys.firstWhere((element) {
              final reg = RegExp(element);
              return reg.hasMatch(matchText);
            }, orElse: () {
              return '';
            })];
        if (mapping != null) {
          if (mapping.type == PatternType.at) {
            String userID = matchText.replaceFirst("@", "").trim();
            // Handle AtAllTag with special highlighting
            if (userID == 'AtAllTag') {
              matchText = '@${StrRes.everyone} ';
              // Use amber color and bold font only, no background
              inlineSpan = TextSpan(
                text: matchText,
                style: (mapping.style ??
                        matchTextStyle ??
                        textStyle ??
                        const TextStyle())
                    .copyWith(
                  color: const Color(0xFFD97706), // Amber text color
                  fontWeight: FontWeight.w700, // Bold
                ),
              );
            } else if (allAtMap.containsKey(userID)) {
              matchText = '@${allAtMap[userID]} ';
              inlineSpan = TextSpan(
                text: matchText,
                style: mapping.style ?? matchTextStyle ?? textStyle,
                recognizer: mapping.onTap == null
                    ? null
                    : (TapGestureRecognizer()
                      ..onTap = () => mapping.onTap!(
                          _getUrl(userID, mapping.type), mapping.type)),
              );
            } else {
              inlineSpan = TextSpan(text: matchText, style: textStyle);
            }
          } else if (mapping.type == PatternType.atAll) {
            matchText = '@${StrRes.everyone} ';
            // Use amber color and bold font only, no background
            inlineSpan = TextSpan(
              text: matchText,
              style: (mapping.style ??
                      matchTextStyle ??
                      textStyle ??
                      const TextStyle())
                  .copyWith(
                color: const Color(0xFFD97706), // Amber text color
                fontWeight: FontWeight.w700, // Bold
              ),
            );
          }
          /* else if (mapping.type == PatternType.EMOJI) {
            inlineSpan = ImageSpan();
          } */
          else {
            // For URLs, prevent line breaking at slashes by using zero-width no-break space
            final displayText = mapping.type == PatternType.url
                ? matchText.replaceAllMapped(
                    RegExp(r'[/.]'),
                    (match) =>
                        '${match[0]}\u200B', // Add zero-width space after / and .
                  )
                : matchText;

            inlineSpan = TextSpan(
              text: displayText,
              style: mapping.style ?? matchTextStyle ?? textStyle,
              recognizer: mapping.onTap == null
                  ? null
                  : (TapGestureRecognizer()
                    ..onTap = () => mapping.onTap!(
                        _getUrl(matchText, mapping.type), mapping.type)),
            );
          }
        } else {
          inlineSpan = TextSpan(text: matchText, style: textStyle);
        }
        children.add(inlineSpan);
        return '';
      },
      onNonMatch: (text) {
        children.add(TextSpan(text: text, style: textStyle));
        return '';
      },
    );
  }

  _getUrl(String text, PatternType type) {
    switch (type) {
      case PatternType.url:
        return text.substring(0, 4) == 'http' ? text : 'http://$text';
      case PatternType.email:
        return text.substring(0, 7) == 'mailto:' ? text : 'mailto:$text';
      case PatternType.tel:
      case PatternType.mobile:
        return text.substring(0, 4) == 'tel:' ? text : 'tel:$text';
      default:
        return text;
    }
  }

 static String stripHtmlIfNeeded(String text) {
    if (text.isEmpty) return text;
 
    return text.replaceAll(RegExp(
      r'<\s*\/?\s*[a-zA-Z0-9_-]+\s*[^>]*\/?\s*>',
      caseSensitive: false,
      multiLine: true,
    ), ' ');
  }
}

class MatchPattern {
  PatternType type;

  String? pattern;

  TextStyle? style;

  Function(String link, PatternType? type)? onTap;

  MatchPattern({required this.type, this.pattern, this.style, this.onTap});
}

enum PatternType { at, atAll, email, mobile, tel, url, emoji, custom }

/// 空格@uid空格
// const regexAt = r"(@\d+\s)";
const regexAt = r"(@\d+\s)|(@\d+)";
// const regexAt = r"(\s@\S+\s)";

const regexAtAll = r'@Everyone\s?';

/// Email Regex - A predefined type for handling email matching
const regexEmail = r"\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b";

/// URL Regex - A predefined type for handling URL matching
const regexUrl =
    r"[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:._\+-~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:_\+.~#?&\/\/=]*)";

/// Phone Regex - A predefined type for handling phone matching
// const regexMobile =
//     r"(\+?( |-|\.)?\d{1,2}( |-|\.)?)?(\(?\d{3}\)?|\d{3})( |-|\.)?(\d{3}( |-|\.)?\d{4})";

/// Regex of exact mobile.
const String regexMobile =
    '^(\\+?86)?((13[0-9])|(14[57])|(15[0-35-9])|(16[2567])|(17[01235-8])|(18[0-9])|(19[1589]))\\d{8}\$';

/// Regex of telephone number.
const String regexTel = '^0\\d{2,3}[-]?\\d{7,8}';

const emojiFaces = <String, String>{'[]': '[]'};
