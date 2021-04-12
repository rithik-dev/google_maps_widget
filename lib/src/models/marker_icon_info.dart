import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_widget/src/utils/constants.dart';

class MarkerIconInfo {
  final IconData? iconData;
  final String? assetPath;
  final Size? assetMarkerSize;

  MarkerIconInfo({
    this.iconData,
    this.assetPath,
    this.assetMarkerSize,
  });

  Future<BitmapDescriptor?> get bitmapDescriptor async {
    if (assetPath != null)
      return await _getMarkerFromAsset(
        path: assetPath!,
        size: assetMarkerSize ?? Constants.DEFAULT_MARKER_SIZE,
      );

    if (iconData != null)
      return await _getMarkerFromMaterialIcon(iconData: this.iconData!);

    return BitmapDescriptor.defaultMarker;
  }

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

  static Future<BitmapDescriptor> _getMarkerFromMaterialIcon({
    required IconData iconData,
  }) async {
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
        color: Colors.red,
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
