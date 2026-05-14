import 'package:cached_network_image/cached_network_image.dart';
import 'package:editvideo/generated/assets.dart';
import 'package:editvideo/widget/button/common_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    this.placeholderName = Assets.commonIconVideoError,
    this.onPress,
    this.placeholder,
    this.errorWidget,
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
    this.onPress,
    this.placeholder,
    String? placeholderName,
    this.errorWidget,
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

  final void Function(String? imageUrl)? onPress;

  @override
  Widget build(BuildContext context) {
    final errorWidget = Center(
      child: Image.asset(
        placeholderName,
        width: 80.w,
        height: 80.w,
        fit: BoxFit.cover,
      ),
    );
    final isValidUrl = imageUrl != null && imageUrl!.isNotEmpty;
    final Widget content = CachedNetworkImage(
      cacheKey: cacheKey,
      imageUrl: imageUrl ?? '',
      fadeInDuration: needFadeIn ? const Duration(milliseconds: 500) : Duration.zero,
      fadeOutDuration: needFadeIn ? const Duration(milliseconds: 500) : Duration.zero,
      alignment: alignment ?? Alignment.center,
      width: width,
      height: height,
      fit: fit,
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
