import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum IconImgType { generic, svg }

enum IconBtnSize { small, normal, big }

const _iconBtnSizes = {
  IconBtnSize.small: 34.0,
  IconBtnSize.normal: 40.0,
  IconBtnSize.big: 46.0,
};
const _iconBtnSvgIconSizes = {
  IconBtnSize.small: 22.0,
  IconBtnSize.normal: 28.0,
  IconBtnSize.big: 34.0,
};
const _iconBtnIconSizes = {
  IconBtnSize.small: 20.0,
  IconBtnSize.normal: 24.0,
  IconBtnSize.big: 28.0,
};

class _IconAssetWrapper extends StatelessWidget {
  final IconImgType imgType;
  final IconBtnSize size;
  final String assetPath;
  final ColorFilter? colorFilter;

  const _IconAssetWrapper({
    required this.imgType,
    required this.size,
    required this.assetPath,
    this.colorFilter,
  });

  @override
  Widget build(BuildContext context) {
    switch (imgType) {
      case IconImgType.generic:
        return Image.asset(assetPath, height: _iconBtnSvgIconSizes[size]!);
      case IconImgType.svg:
        return SvgPicture.asset(
          assetPath,
          height: _iconBtnSvgIconSizes[size]!,
          colorFilter: colorFilter,
        );
    }
  }
}

class _IconNetworkWrapper extends StatelessWidget {
  final IconImgType imgType;
  final IconBtnSize size;
  final String url;
  final ColorFilter? colorFilter;

  const _IconNetworkWrapper({
    required this.imgType,
    required this.size,
    required this.url,
    this.colorFilter,
  });

  @override
  Widget build(BuildContext context) {
    switch (imgType) {
      case IconImgType.generic:
        return Image.network(url, height: _iconBtnSvgIconSizes[size]!);
      case IconImgType.svg:
        return SvgPicture.network(
          url,
          height: _iconBtnSvgIconSizes[size]!,
          colorFilter: colorFilter,
        );
    }
  }
}

class IconBtn extends StatelessWidget {
  /// Icon to be displayed.
  final IconData? icon;

  /// Icon asset path to be displayed.
  final String? iconAssetPath;

  /// Icon asset path to be displayed.
  final String? iconUrl;

  /// Icon asset type.
  final IconImgType iconImgType;

  /// Color filter to be applied if svg icon is used.
  final ColorFilter? svgIconColorFilter;

  /// Icon color when using normal icons.
  final Color? iconColor;

  /// Button size.
  final IconBtnSize size;

  /// Button on press callback.
  final VoidCallback onPressed;

  /// Button background color.
  final Color backgroundColor;

  const IconBtn({
    super.key,
    this.icon,
    this.iconAssetPath,
    this.iconUrl,
    this.iconImgType = IconImgType.generic,
    this.svgIconColorFilter,
    this.iconColor,
    this.backgroundColor = Colors.transparent,
    this.size = IconBtnSize.normal,
    required this.onPressed,
  }) : assert(icon != null || iconAssetPath != null || iconUrl != null);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _iconBtnSizes[size]!,
      height: _iconBtnSizes[size]!,
      child: CupertinoButton(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(128),
        padding: const EdgeInsets.all(0),
        onPressed: onPressed,
        child: icon != null
            ? Icon(icon, size: _iconBtnIconSizes[size]!, color: iconColor)
            : iconAssetPath != null
                ? _IconAssetWrapper(
                    imgType: iconImgType,
                    size: size,
                    assetPath: iconAssetPath!,
                    colorFilter: svgIconColorFilter,
                  )
                : _IconNetworkWrapper(
                    imgType: iconImgType,
                    size: size,
                    url: iconUrl!,
                    colorFilter: svgIconColorFilter,
                  ),
      ),
    );
  }
}
