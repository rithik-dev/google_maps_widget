import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_widget/src/utils/constants.dart';

/// Class used to provide information about the marker on the [GoogleMap] widget.
/// Pass either an asset image [assetPath] or a material [icon].
/// [assetMarkerSize] can be provided to resize image at [assetPath].
///
/// See also:
///   * [bitmapDescriptor] parameter.
class MarkerIconInfo {
  const MarkerIconInfo({
    this.icon,
    this.assetPath,
    this.assetMarkerSize,
  });

  /// Material icon that can be passed which can be used
  /// in place of a default [Marker].
  final Icon? icon;

  /// Asset image path that can be passed which can be used
  /// in place of a default [Marker].
  final String? assetPath;

  /// Asset marker size which can be used to
  /// resize image at [assetPath].
  /// If null, defaults to [Constants.kDefaultMarkerSize].
  final Size? assetMarkerSize;

  /// This getter is used to get the [BitmapDescriptor] required
  /// by the [Marker].
  ///
  /// If both [assetPath] and [icon] are passed,
  /// [BitmapDescriptor] created from [assetPath] is returned.
  ///
  /// If both [assetPath] and [icon] are not passed,
  /// then [BitmapDescriptor.defaultMarker] is returned.
  Future<BitmapDescriptor> get bitmapDescriptor async {
    if (assetPath != null) {
      return await _getMarkerFromAsset(
        path: assetPath!,
        size: assetMarkerSize ?? Constants.kDefaultMarkerSize,
      );
    }

    if (icon != null) return await _getMarkerFromMaterialIcon(icon: icon!);

    return BitmapDescriptor.defaultMarker;
  }

  /// Creates a [BitmapDescriptor] from an asset image.
  ///
  /// [path] is the path of the image.
  /// [size] can be provided to resize the image.
  /// Defaults to [Constants.kDefaultMarkerSize]
  static Future<BitmapDescriptor> _getMarkerFromAsset({
    required String path,
    Size size = Constants.kDefaultMarkerSize,
  }) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: size.width.toInt(),
      targetHeight: size.height.toInt(),
    );
    FrameInfo fi = await codec.getNextFrame();
    final bytes = (await fi.image.toByteData(format: ImageByteFormat.png))!
        .buffer
        .asUint8List();

    return BitmapDescriptor.fromBytes(bytes);
  }

  /// Creates a [BitmapDescriptor] from a material [Icon].
  static Future<BitmapDescriptor> _getMarkerFromMaterialIcon({
    required Icon icon,
  }) async {
    final iconData = icon.icon!;
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final iconStr = String.fromCharCode(iconData.codePoint);

    textPainter.text = TextSpan(
      text: iconStr,
      style: TextStyle(
        letterSpacing: 0.0,
        fontSize: 48.0,
        fontFamily: iconData.fontFamily,
        color: icon.color,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(0.0, 0.0));

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(48, 48);
    final bytes = await image.toByteData(format: ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }
}
