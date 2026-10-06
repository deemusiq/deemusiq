// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsBrandingGen {
  const $AssetsBrandingGen();

  /// File path: assets/branding/deemusiq-logo.ico
  String get deemusiqLogoIco => 'assets/branding/deemusiq-logo.ico';

  /// File path: assets/branding/deemusiq-logo.png
  AssetGenImage get deemusiqLogoPng =>
      const AssetGenImage('assets/branding/deemusiq-logo.png');

  /// List of all assets
  List<dynamic> get values => [deemusiqLogoIco, deemusiqLogoPng];
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/app_icon.png
  AssetGenImage get appIcon => const AssetGenImage('assets/icons/app_icon.png');

  /// File path: assets/icons/app_icon_fg.png
  AssetGenImage get appIconFg =>
      const AssetGenImage('assets/icons/app_icon_fg.png');

  /// List of all assets
  List<AssetGenImage> get values => [appIcon, appIconFg];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/album-placeholder.png
  AssetGenImage get albumPlaceholder =>
      const AssetGenImage('assets/images/album-placeholder.png');

  /// File path: assets/images/bengali-patterns-bg.jpg
  AssetGenImage get bengaliPatternsBg =>
      const AssetGenImage('assets/images/bengali-patterns-bg.jpg');

  /// File path: assets/images/liked-tracks.jpg
  AssetGenImage get likedTracks =>
      const AssetGenImage('assets/images/liked-tracks.jpg');

  /// Directory path: assets/images/logos
  $AssetsImagesLogosGen get logos => const $AssetsImagesLogosGen();

  /// File path: assets/images/onboard_1.jpg
  AssetGenImage get onboard1 =>
      const AssetGenImage('assets/images/onboard_1.jpg');

  /// File path: assets/images/onboard_2.jpg
  AssetGenImage get onboard2 =>
      const AssetGenImage('assets/images/onboard_2.jpg');

  /// File path: assets/images/onboard_3.jpg
  AssetGenImage get onboard3 =>
      const AssetGenImage('assets/images/onboard_3.jpg');

  /// File path: assets/images/onboard_4.jpg
  AssetGenImage get onboard4 =>
      const AssetGenImage('assets/images/onboard_4.jpg');

  /// File path: assets/images/onboard_5.jpg
  AssetGenImage get onboard5 =>
      const AssetGenImage('assets/images/onboard_5.jpg');

  /// File path: assets/images/placeholder.png
  AssetGenImage get placeholder =>
      const AssetGenImage('assets/images/placeholder.png');

  /// File path: assets/images/splash_1.jpg
  AssetGenImage get splash1 =>
      const AssetGenImage('assets/images/splash_1.jpg');

  /// File path: assets/images/splash_2.jpg
  AssetGenImage get splash2 =>
      const AssetGenImage('assets/images/splash_2.jpg');

  /// File path: assets/images/splash_3.jpg
  AssetGenImage get splash3 =>
      const AssetGenImage('assets/images/splash_3.jpg');

  /// File path: assets/images/splash_4.jpg
  AssetGenImage get splash4 =>
      const AssetGenImage('assets/images/splash_4.jpg');

  /// File path: assets/images/user-placeholder.png
  AssetGenImage get userPlaceholder =>
      const AssetGenImage('assets/images/user-placeholder.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        albumPlaceholder,
        bengaliPatternsBg,
        likedTracks,
        onboard1,
        onboard2,
        onboard3,
        onboard4,
        onboard5,
        placeholder,
        splash1,
        splash2,
        splash3,
        splash4,
        userPlaceholder
      ];
}

class $AssetsImagesLogosGen {
  const $AssetsImagesLogosGen();

  /// File path: assets/images/logos/dab-music.png
  AssetGenImage get dabMusic =>
      const AssetGenImage('assets/images/logos/dab-music.png');

  /// File path: assets/images/logos/invidious.jpg
  AssetGenImage get invidious =>
      const AssetGenImage('assets/images/logos/invidious.jpg');

  /// File path: assets/images/logos/jiosaavn.png
  AssetGenImage get jiosaavn =>
      const AssetGenImage('assets/images/logos/jiosaavn.png');

  /// List of all assets
  List<AssetGenImage> get values => [dabMusic, invidious, jiosaavn];
}

class Assets {
  const Assets._();

  static const String license = 'LICENSE';
  static const $AssetsBrandingGen branding = $AssetsBrandingGen();
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();

  /// List of all assets
  static List<String> get values => [license];
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
