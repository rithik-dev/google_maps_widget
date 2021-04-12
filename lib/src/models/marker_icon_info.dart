import 'dart:typed_data';
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
  /// If null, defaults to [Constants.DEFAULT_MARKER_SIZE].
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
    if (assetPath != null)
      return await _getMarkerFromAsset(
        path: assetPath!,
        size: assetMarkerSize ?? Constants.DEFAULT_MARKER_SIZE,
      );

    if (icon != null) return await _getMarkerFromMaterialIcon(icon: icon!);

    return BitmapDescriptor.defaultMarker;
  }

  /// Creates a [BitmapDescriptor] from an asset image.
  ///
  /// [path] is the path of the image.
  /// [size] can be provided to resize the image.
  /// Defaults to [Constants.DEFAULT_MARKER_SIZE]
  static Future<BitmapDescriptor> _getMarkerFromAsset({
    required String path,
    Size size = Constants.DEFAULT_MARKER_SIZE,
  }) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: size.width.toInt(),
      targetHeight: size.height.toInt(),
    );
    FrameInfo fi = await codec.getNextFrame();
    final _bytes = (await fi.image.toByteData(format: ImageByteFormat.png))!
        .buffer
        .asUint8List();

    return BitmapDescriptor.fromBytes(_bytes);
  }

  /// Creates a [BitmapDescriptor] from a material [Icon].
  static Future<BitmapDescriptor> _getMarkerFromMaterialIcon({
    required Icon icon,
  }) async {
    final iconData = icon.icon!;
    final _pictureRecorder = PictureRecorder();
    final _canvas = Canvas(_pictureRecorder);
    final _textPainter = TextPainter(textDirection: TextDirection.ltr);
    final _iconStr = String.fromCharCode(iconData.codePoint);

    _textPainter.text = TextSpan(
      text: _iconStr,
      style: TextStyle(
        letterSpacing: 0.0,
        fontSize: 48.0,
        fontFamily: iconData.fontFamily,
        color: icon.color,
      ),
    );
    _textPainter.layout();
    _textPainter.paint(_canvas, Offset(0.0, 0.0));

    final _picture = _pictureRecorder.endRecording();
    final _image = await _picture.toImage(48, 48);
    final _bytes = await _image.toByteData(format: ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(_bytes!.buffer.asUint8List());
  }
}
