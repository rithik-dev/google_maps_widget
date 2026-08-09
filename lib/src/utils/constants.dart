import 'package:flutter/material.dart';
import 'package:google_maps_widget/google_maps_widget.dart';

/// Defines all the constants used by [GoogleMapsWidget].
class Constants {
  Constants._();

  static const kDefaultCameraZoom = 15.0;
  static const kRouteWidth = 5;
  static const kRouteColor = Colors.indigo;
  static const kDefaultMarkerSize = Size.square(150);

  /// How long to wait to establish a connection to the Routes API.
  static const kRoutesConnectTimeout = Duration(seconds: 15);

  /// How long to wait for the Routes API response once connected.
  static const kRoutesReceiveTimeout = Duration(seconds: 15);
}
