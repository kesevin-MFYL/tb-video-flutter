import 'package:editvideo/config/color/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget loadingIndicator({Color? color, double? size, double strokeWidth = 5.5}) {
  return SizedBox(
    height: size ?? 50.w,
    width: size ?? 50.w,
    child: CircularProgressIndicator(
      backgroundColor: Colors.transparent,
      strokeWidth: strokeWidth,
      valueColor: AlwaysStoppedAnimation<Color>(color ?? CommonColors.primaryColor),
    ),
  );
}

/// 构建一个能够自动对齐 Emoji 与文字的 Widget。
/// 如果文本中不包含任何 Emoji，直接返回普通的 Text 组件（性能最优）；
/// 如果包含 Emoji，则使用 RichText 对每个 Emoji 单独进行垂直微调，解决对齐问题。
///
/// [text] 要显示的文本
/// [style] 文本样式，会应用到整个文本（包括 Emoji 和普通文字）
/// [emojiVerticalOffset] Emoji 垂直偏移量（像素），正值向下，负值向上，默认 -2.0 可根据实际字体微调
Widget buildEmojiAlignedText(String text, {TextStyle? style, double emojiVerticalOffset = -1.0}) {
  // 正则：匹配真正的 Emoji（不会匹配普通数字、字母、符号）
  final emojiRegex = RegExp(r'\p{Extended_Pictographic}', unicode: true);

  // 检查是否包含任何 Emoji
  if (!emojiRegex.hasMatch(text)) {
    // 无 Emoji，直接返回普通 Text
    return Text(text, style: style);
  }

  // 有 Emoji，构建 RichText
  final List<InlineSpan> spans = [];
  int lastIndex = 0;
  bool isFirstSpan = true;

  for (final match in emojiRegex.allMatches(text)) {
    // 添加 Emoji 之前的普通文本
    if (match.start > lastIndex) {
      if (!isFirstSpan) {
        // 前面有 Emoji，添加普通文本前需要间距
        spans.add(const WidgetSpan(child: SizedBox(width: 4)));
      }
      spans.add(TextSpan(text: text.substring(lastIndex, match.start), style: style));
      isFirstSpan = false;

      // 紧接着要添加当前 Emoji，也需要间距
      spans.add(const WidgetSpan(child: SizedBox(width: 4)));
    }

    // 添加当前 Emoji，单独微调垂直位置
    final String emoji = match.group(0)!;
    spans.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Transform.translate(
          offset: Offset(0, emojiVerticalOffset),
          child: Text(emoji, style: style),
        ),
      ),
    );

    isFirstSpan = false;
    lastIndex = match.end;
  }

  // 添加剩余的普通文本
  if (lastIndex < text.length) {
    if (!isFirstSpan) {
      // 前面有 Emoji，添加剩余普通文本前需要间距
      spans.add(const WidgetSpan(child: SizedBox(width: 4)));
    }
    spans.add(TextSpan(text: text.substring(lastIndex), style: style));
  }

  return RichText(
    text: TextSpan(style: style ?? const TextStyle(), children: spans),
  );
}
