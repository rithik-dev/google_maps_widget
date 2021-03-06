import 'package:flutter/material.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:google_maps_widget/src/services/maps_service.dart';

/// Defines all the constants used by [GoogleMapsWidget] & [MapsService].
class Constants {
  Constants._();

  static const kDefaultCameraZoom = 15.0;
  static const kDefaultSourceName = "Source";
  static const kDefaultDestinationName = "Destination";
  static const kDefaultDriverName = "Driver";
  static const kRouteWidth = 5;
  static const kRouteColor = Colors.indigo;
  static const kDefaultMarkerSize = Size.square(150);
}
