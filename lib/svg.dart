import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_graphics/vector_graphics_compat.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

import 'src/loaders.dart';
import 'src/utilities/file.dart';

/// A widget that will parse SVG data for rendering on screen.
class SvgPicture extends StatelessWidget {
  /// Instantiates a widget that renders an SVG picture using the `pictureProvider`.
  ///
  /// Either the [width] and [height] arguments should be specified, or the
  /// widget should be placed in a context that sets tight layout constraints.
  /// Otherwise, the image dimensions will change as the image is loaded, which
  /// will result in ugly layout changes.
  ///
  /// If `matchTextDirection` is set to true, the picture will be flipped
  /// horizontally in [TextDirection.rtl] contexts.
  ///
  /// The `allowDrawingOutsideOfViewBox` parameter should be used with caution -
  /// if set to true, it will not clip the canvas used internally to the view box,
  /// meaning the picture may draw beyond the intended area and lead to undefined
  /// behavior or additional memory overhead.
  ///
  /// A custom `placeholderBuilder` can be specified for cases where decoding or
  /// acquiring data may take a noticeably long time, e.g. for a network picture.
  ///
  /// The `semanticsLabel` can be used to identify the purpose of this picture for
  /// screen reading software.
  ///
  /// If [excludeFromSemantics] is true, then [semanticLabel] will be ignored.
  const SvgPicture(
    this.bytesLoader, {
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.matchTextDirection = false,
    this.allowDrawingOutsideViewBox = false,
    this.placeholderBuilder,
    this.colorFilter,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.theme,
  }) : super(key: key);

  /// Instantiates a widget that renders an SVG picture from an [AssetBundle].
  ///
  /// The key will be derived from the `assetName`, `package`, and `bundle`
  /// arguments. The `package` argument must be non-null when displaying an SVG
  /// from a package and null otherwise. See the `Assets in packages` section for
  /// details.
  ///
  /// Either the [width] and [height] arguments should be specified, or the
  /// widget should be placed in a context that sets tight layout constraints.
  /// Otherwise, the image dimensions will change as the image is loaded, which
  /// will result in ugly layout changes.
  ///
  /// If `matchTextDirection` is set to true, the picture will be flipped
  /// horizontally in [TextDirection.rtl] contexts.
  ///
  /// The `allowDrawingOutsideOfViewBox` parameter should be used with caution -
  /// if set to true, it will not clip the canvas used internally to the view box,
  /// meaning the picture may draw beyond the intended area and lead to undefined
  /// behavior or additional memory overhead.
  ///
  /// A custom `placeholderBuilder` can be specified for cases where decoding or
  /// acquiring data may take a noticeably long time.
  ///
  /// The `color` and `colorBlendMode` arguments, if specified, will be used to set a
  /// [ColorFilter] on any [Paint]s created for this drawing.
  ///
  /// The `theme` argument, if provided, will override the default theme
  /// used when parsing SVG elements.
  ///
  /// ## Assets in packages
  ///
  /// To create the widget with an asset from a package, the [package] argument
  /// must be provided. For instance, suppose a package called `my_icons` has
  /// `icons/heart.svg` .
  ///
  /// Then to display the image, use:
  ///
  /// ```dart
  /// SvgPicture.asset('icons/heart.svg', package: 'my_icons')
  /// ```
  ///
  /// Assets used by the package itself should also be displayed using the
  /// [package] argument as above.
  ///
  /// If the desired asset is specified in the `pubspec.yaml` of the package, it
  /// is bundled automatically with the app. In particular, assets used by the
  /// package itself must be specified in its `pubspec.yaml`.
  ///
  /// A package can also choose to have assets in its 'lib/' folder that are not
  /// specified in its `pubspec.yaml`. In this case for those images to be
  /// bundled, the app has to specify which ones to include. For instance a
  /// package named `fancy_backgrounds` could have:
  ///
  /// ```
  /// lib/backgrounds/background1.svg
  /// lib/backgrounds/background2.svg
  /// lib/backgrounds/background3.svg
  ///```
  ///
  /// To include, say the first image, the `pubspec.yaml` of the app should
  /// specify it in the assets section:
  ///
  /// ```yaml
  ///  assets:
  ///    - packages/fancy_backgrounds/backgrounds/background1.svg
  /// ```
  ///
  /// The `lib/` is implied, so it should not be included in the asset path.
  ///
  ///
  /// See also:
  ///
  ///  * [AssetPicture], which is used to implement the behavior when the scale is
  ///    omitted.
  ///  * [ExactAssetPicture], which is used to implement the behavior when the
  ///    scale is present.
  ///  * <https://flutter.io/assets-and-images/>, an introduction to assets in
  ///    Flutter.
  ///
  /// If [excludeFromSemantics] is true, then [semanticLabel] will be ignored.
  SvgPicture.asset(
    String assetName, {
    Key? key,
    this.matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.allowDrawingOutsideViewBox = false,
    this.placeholderBuilder,
    this.colorFilter,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.theme,
  })  : bytesLoader = SvgAssetLoader(
          assetName,
          packageName: package,
          assetBundle: bundle,
        ),
        super(key: key);

  /// Creates a widget that displays a [PictureStream] obtained from the network.
  ///
  /// The [url] argument must not be null.
  ///
  /// Either the [width] and [height] arguments should be specified, or the
  /// widget should be placed in a context that sets tight layout constraints.
  /// Otherwise, the image dimensions will change as the image is loaded, which
  /// will result in ugly layout changes.
  ///
  /// If `matchTextDirection` is set to true, the picture will be flipped
  /// horizontally in [TextDirection.rtl] contexts.
  ///
  /// The `allowDrawingOutsideOfViewBox` parameter should be used with caution -
  /// if set to true, it will not clip the canvas used internally to the view box,
  /// meaning the picture may draw beyond the intended area and lead to undefined
  /// behavior or additional memory overhead.
  ///
  /// A custom `placeholderBuilder` can be specified for cases where decoding or
  /// acquiring data may take a noticeably long time, such as high latency scenarios.
  ///
  /// The `color` and `colorBlendMode` arguments, if specified, will be used to set a
  /// [ColorFilter] on any [Paint]s created for this drawing.
  ///
  /// The `theme` argument, if provided, will override the default theme
  /// used when parsing SVG elements.
  ///
  /// All network images are cached regardless of HTTP headers.
  ///
  /// An optional `headers` argument can be used to send custom HTTP headers
  /// with the image request.
  ///
  /// If [excludeFromSemantics] is true, then [semanticLabel] will be ignored.
  SvgPicture.network(
    String url, {
    Key? key,
    Map<String, String>? headers,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.matchTextDirection = false,
    this.allowDrawingOutsideViewBox = false,
    this.placeholderBuilder,
    this.colorFilter,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.theme,
  })  : bytesLoader = SvgNetworkLoader(url, headers: headers),
        super(key: key);

  /// Creates a widget that displays a [PictureStream] obtained from a [File].
  ///
  /// The [file] argument must not be null.
  ///
  /// Either the [width] and [height] arguments should be specified, or the
  /// widget should be placed in a context that sets tight layout constraints.
  /// Otherwise, the image dimensions will change as the image is loaded, which
  /// will result in ugly layout changes.
  ///
  /// If `matchTextDirection` is set to true, the picture will be flipped
  /// horizontally in [TextDirection.rtl] contexts.
  ///
  /// The `allowDrawingOutsideOfViewBox` parameter should be used with caution -
  /// if set to true, it will not clip the canvas used internally to the view box,
  /// meaning the picture may draw beyond the intended area and lead to undefined
  /// behavior or additional memory overhead.
  ///
  /// A custom `placeholderBuilder` can be specified for cases where decoding or
  /// acquiring data may take a noticeably long time.
  ///
  /// The `color` and `colorBlendMode` arguments, if specified, will be used to set a
  /// [ColorFilter] on any [Paint]s created for this drawing.
  ///
  /// The `theme` argument, if provided, will override the default theme
  /// used when parsing SVG elements.
  ///
  /// On Android, this may require the
  /// `android.permission.READ_EXTERNAL_STORAGE` permission.
  ///
  /// If [excludeFromSemantics] is true, then [semanticLabel] will be ignored.
  SvgPicture.file(
    File file, {
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.matchTextDirection = false,
    this.allowDrawingOutsideViewBox = false,
    this.placeholderBuilder,
    this.colorFilter,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.theme,
  })  : bytesLoader = SvgFileLoader(file),
        super(key: key);

  /// Creates a widget that displays a [PictureStream] obtained from a [Uint8List].
  ///
  /// The [bytes] argument must not be null.
  ///
  /// Either the [width] and [height] arguments should be specified, or the
  /// widget should be placed in a context that sets tight layout constraints.
  /// Otherwise, the image dimensions will change as the image is loaded, which
  /// will result in ugly layout changes.
  ///
  /// If `matchTextDirection` is set to true, the picture will be flipped
  /// horizontally in [TextDirection.rtl] contexts.
  ///
  /// The `allowDrawingOutsideOfViewBox` parameter should be used with caution -
  /// if set to true, it will not clip the canvas used internally to the view box,
  /// meaning the picture may draw beyond the intended area and lead to undefined
  /// behavior or additional memory overhead.
  ///
  /// A custom `placeholderBuilder` can be specified for cases where decoding or
  /// acquiring data may take a noticeably long time.
  ///
  /// The `color` and `colorBlendMode` arguments, if specified, will be used to set a
  /// [ColorFilter] on any [Paint]s created for this drawing.
  ///
  /// The `theme` argument, if provided, will override the default theme
  /// used when parsing SVG elements.
  ///
  /// If [excludeFromSemantics] is true, then [semanticLabel] will be ignored.
  SvgPicture.memory(
    Uint8List bytes, {
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.matchTextDirection = false,
    this.allowDrawingOutsideViewBox = false,
    this.placeholderBuilder,
    this.colorFilter,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.theme,
  })  : bytesLoader = SvgBytesLoader(bytes),
        super(key: key);

  /// Creates a widget that displays a [PictureStream] obtained from a [String].
  ///
  /// The [bytes] argument must not be null.
  ///
  /// Either the [width] and [height] arguments should be specified, or the
  /// widget should be placed in a context that sets tight layout constraints.
  /// Otherwise, the image dimensions will change as the image is loaded, which
  /// will result in ugly layout changes.
  ///
  /// If `matchTextDirection` is set to true, the picture will be flipped
  /// horizontally in [TextDirection.rtl] contexts.
  ///
  /// The `allowDrawingOutsideOfViewBox` parameter should be used with caution -
  /// if set to true, it will not clip the canvas used internally to the view box,
  /// meaning the picture may draw beyond the intended area and lead to undefined
  /// behavior or additional memory overhead.
  ///
  /// A custom `placeholderBuilder` can be specified for cases where decoding or
  /// acquiring data may take a noticeably long time.
  ///
  /// The `color` and `colorBlendMode` arguments, if specified, will be used to set a
  /// [ColorFilter] on any [Paint]s created for this drawing.
  ///
  /// The `theme` argument, if provided, will override the default theme
  /// used when parsing SVG elements.
  ///
  /// If [excludeFromSemantics] is true, then [semanticLabel] will be ignored.
  SvgPicture.string(
    String string, {
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.matchTextDirection = false,
    this.allowDrawingOutsideViewBox = false,
    this.placeholderBuilder,
    this.colorFilter,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
    this.theme,
  })  : bytesLoader = SvgStringLoader(string),
        super(key: key);

  /// The default placeholder for a SVG that may take time to parse or
  /// retrieve, e.g. from a network location.
  static WidgetBuilder defaultPlaceholderBuilder =
      (BuildContext ctx) => const LimitedBox();

  /// If specified, the width to use for the SVG.  If unspecified, the SVG
  /// will take the width of its parent.
  final double? width;

  /// If specified, the height to use for the SVG.  If unspecified, the SVG
  /// will take the height of its parent.
  final double? height;

  /// How to inscribe the picture into the space allocated during layout.
  /// The default is [BoxFit.contain].
  final BoxFit fit;

  /// How to align the picture within its parent widget.
  ///
  /// The alignment aligns the given position in the picture to the given position
  /// in the layout bounds. For example, an [Alignment] alignment of (-1.0,
  /// -1.0) aligns the image to the top-left corner of its layout bounds, while a
  /// [Alignment] alignment of (1.0, 1.0) aligns the bottom right of the
  /// picture with the bottom right corner of its layout bounds. Similarly, an
  /// alignment of (0.0, 1.0) aligns the bottom middle of the image with the
  /// middle of the bottom edge of its layout bounds.
  ///
  /// If the [alignment] is [TextDirection]-dependent (i.e. if it is a
  /// [AlignmentDirectional]), then a [TextDirection] must be available
  /// when the picture is painted.
  ///
  /// Defaults to [Alignment.center].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry alignment;

  /// The [BytesLoader] used to resolve the SVG.
  final BytesLoader bytesLoader;

  /// The placeholder to use while fetching, decoding, and parsing the SVG data.
  final WidgetBuilder? placeholderBuilder;

  /// If true, will horizontally flip the picture in [TextDirection.rtl] contexts.
  final bool matchTextDirection;

  /// If true, will allow the SVG to be drawn outside of the clip boundary of its
  /// viewBox.
  final bool allowDrawingOutsideViewBox;

  /// The [Semantics.label] for this picture.
  ///
  /// The value indicates the purpose of the picture, and will be
  /// read out by screen readers.
  final String? semanticsLabel;

  /// Whether to exclude this picture from semantics.
  ///
  /// Useful for pictures which do not contribute meaningful information to an
  /// application.
  final bool excludeFromSemantics;

  /// The color filter, if any, to apply to this widget.
  final ColorFilter? colorFilter;

  /// The theme used when parsing SVG elements.
  final SvgTheme? theme;

  @override
  Widget build(BuildContext context) {
    return createCompatVectorGraphic(
      loader: bytesLoader,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter: colorFilter,
      placeholderBuilder: placeholderBuilder,
    );
  }
}
