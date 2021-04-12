import 'package:flutter/material.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:google_maps_widget/src/services/maps_service.dart';

/// Defines all the constants used by [GoogleMapsWidget] & [MapsService].
class Constants {
  Constants._();

  static const DEFAULT_CAMERA_ZOOM = 15.0;
  static const DEFAULT_SOURCE_NAME = "Source";
  static const DEFAULT_DESTINATION_NAME = "Destination";
  static const DEFAULT_DRIVER_NAME = "Driver";
  static const ROUTE_WIDTH = 5;
  static const ROUTE_COLOR = Colors.indigo;
  static const DEFAULT_MARKER_SIZE = const Size.square(150);
}
