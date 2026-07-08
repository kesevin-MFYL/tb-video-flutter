import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:flutter/cupertino.dart';

class CommonImageView extends StatelessWidget {

  CommonImageView({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.cacheKey,
    this.fit = BoxFit.cover,
    this.alignment,
    this.needFadeIn = true,
    this.needCache = true,
    this.placeholderName = Assets.commonIconVideoError,
    this.onPress,
    this.placeholder,
    this.errorWidget,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  CommonImageView.normal({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.cacheKey,
    this.fit = BoxFit.cover,
    this.alignment,
    this.needFadeIn = true,
    this.needCache = true,
    this.onPress,
    this.placeholder,
    String? placeholderName,
    this.errorWidget,
    this.memCacheWidth,
    this.memCacheHeight,
  }) {
    this.placeholderName = placeholderName ?? Assets.commonIconVideoError;
  }

  final String? imageUrl;
  final double? width;
  final double? height;
  final String? cacheKey;
  final BoxFit fit;
  final Alignment? alignment;
  late  String placeholderName;
  final PlaceholderWidgetBuilder? placeholder;
  final LoadingErrorWidgetBuilder? errorWidget;

  final bool needFadeIn;
  final bool needCache;

  final void Function(String? imageUrl)? onPress;

  // 避免加载过大尺寸的图片导致内存爆炸，通过memCache设置上限
  final int? memCacheWidth;
  final int? memCacheHeight;

  @override
  Widget build(BuildContext context) {
    final errorWidget = Center(
      child: Image.asset(
        placeholderName,
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
    final isValidUrl = imageUrl != null && imageUrl!.isNotEmpty;
    
    // 如果没有指定 memCache 并且指定了宽度或高度，自动计算合适的 memCache (假设设备像素比为3)
    int? cacheWidth = memCacheWidth;
    int? cacheHeight = memCacheHeight;
    if (needCache) {
      if (cacheWidth == null && cacheHeight == null) {
        if (width != null && width! > 0 && width != double.infinity) {
          cacheWidth = (width! * 3).toInt();
        }
        if (height != null && height! > 0 && height != double.infinity) {
          cacheHeight = (height! * 3).toInt();
        }
      }
    }

    final Widget content = CachedNetworkImage(
      cacheKey: cacheKey,
      imageUrl: imageUrl ?? '',
      fadeInDuration: needFadeIn ? const Duration(milliseconds: 500) : Duration.zero,
      fadeOutDuration: needFadeIn ? const Duration(milliseconds: 500) : Duration.zero,
      alignment: alignment ?? Alignment.center,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      placeholder: placeholder,
      errorWidget: this.errorWidget ?? (context,url,error)=> errorWidget,
      errorListener: (error) {},
    );

    if (onPress != null) {
      final button = CommonButton(
        borderRadius: BorderRadius.zero,
        padding: EdgeInsets.zero,
        minSize: 0,
        child: content,
        onPressed: () => onPress!(imageUrl),
      );

      if (isValidUrl) {
        return Hero(
          tag: imageUrl!,
          child: button,
        );
      } else {
        return button;
      }
    } else {
      return content;
    }
  }
}
