import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_widget/src/models/marker_info.dart';
import 'package:google_maps_widget/src/services/maps_service.dart';
import 'package:google_maps_widget/src/utils/constants.dart';

class GoogleMapsWidget extends StatefulWidget {
  final String apiKey;
  final LatLng sourceLatLng;
  final LatLng destinationLatLng;
  final void Function(LatLng)? onTapSourceInfoWindow;
  final void Function(LatLng)? onTapDestinationInfoWindow;
  final void Function(LatLng)? onTapDriverInfoWindow;
  final void Function(LatLng)? onTapSourceMarker;
  final void Function(LatLng)? onTapDestinationMarker;
  final void Function(LatLng)? onTapDriverMarker;
  final Stream<LatLng>? driverCoordinatesStream;
  final LatLng? defaultCameraLocation;
  final double defaultCameraZoom;
  final String sourceName;
  final String destinationName;
  final String driverName;
  final Color routeColor;
  final int routeWidth;
  final MarkerIconInfo? sourceMarkerIconInfo;
  final MarkerIconInfo? destinationMarkerIconInfo;
  final MarkerIconInfo? driverMarkerIconInfo;
  final void Function(GoogleMapController)? onMapCreated;

  // other google maps params
  final bool rotateGesturesEnabled;
  final bool scrollGesturesEnabled;
  final bool zoomControlsEnabled;
  final bool zoomGesturesEnabled;
  final bool liteModeEnabled;
  final bool tiltGesturesEnabled;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool indoorViewEnabled;
  final bool trafficEnabled;
  final bool buildingsEnabled;
  final bool compassEnabled;
  final bool mapToolbarEnabled;
  final ArgumentCallback<LatLng>? onTap;
  final VoidCallback? onCameraIdle;
  final CameraPositionCallback? onCameraMove;
  final VoidCallback? onCameraMoveStarted;
  final ArgumentCallback<LatLng>? onLongPress;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;
  final Set<Polygon> polygons;
  final Set<Circle> circles;
  final Set<TileOverlay> tileOverlays;
  final MapType mapType;
  final EdgeInsets padding;
  final MinMaxZoomPreference minMaxZoomPreference;
  final CameraTargetBounds cameraTargetBounds;

  const GoogleMapsWidget({
    required this.apiKey,
    required this.sourceLatLng,
    required this.destinationLatLng,
    this.onMapCreated,
    this.sourceMarkerIconInfo,
    this.destinationMarkerIconInfo,
    this.driverMarkerIconInfo,
    this.onTapSourceMarker,
    this.onTapDestinationMarker,
    this.onTapDriverMarker,
    this.onTapSourceInfoWindow,
    this.onTapDestinationInfoWindow,
    this.onTapDriverInfoWindow,
    this.driverCoordinatesStream,
    this.defaultCameraLocation,
    this.defaultCameraZoom = Constants.DEFAULT_CAMERA_ZOOM,
    this.sourceName = Constants.DEFAULT_SOURCE_NAME,
    this.destinationName = Constants.DEFAULT_DESTINATION_NAME,
    this.driverName = Constants.DEFAULT_DRIVER_NAME,
    this.routeColor = Constants.ROUTE_COLOR,
    this.routeWidth = Constants.ROUTE_WIDTH,

    // other google maps params
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
    this.compassEnabled = true,
    this.mapToolbarEnabled = true,
    this.cameraTargetBounds = CameraTargetBounds.unbounded,
    this.mapType = MapType.normal,
    this.minMaxZoomPreference = MinMaxZoomPreference.unbounded,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.zoomControlsEnabled = true,
    this.zoomGesturesEnabled = true,
    this.liteModeEnabled = false,
    this.tiltGesturesEnabled = true,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = true,
    this.padding = const EdgeInsets.all(0),
    this.indoorViewEnabled = false,
    this.trafficEnabled = false,
    this.buildingsEnabled = true,
    this.polygons = const <Polygon>{},
    this.circles = const <Circle>{},
    this.onCameraMoveStarted,
    this.tileOverlays = const <TileOverlay>{},
    this.onCameraMove,
    this.onCameraIdle,
    this.onTap,
    this.onLongPress,
  });

  @override
  _GoogleMapsWidgetState createState() => _GoogleMapsWidgetState();
}

class _GoogleMapsWidgetState extends State<GoogleMapsWidget> {
  final _mapsService = MapsService();

  @override
  void initState() {
    _mapsService.initialize(
      setState: setState,
      apiKey: this.widget.apiKey,
      sourceLatLng: this.widget.sourceLatLng,
      destinationLatLng: this.widget.destinationLatLng,
      onTapSourceMarker: this.widget.onTapSourceMarker,
      onTapDestinationMarker: this.widget.onTapDestinationMarker,
      onTapDriverMarker: this.widget.onTapDriverMarker,
      onTapSourceInfoWindow: this.widget.onTapSourceInfoWindow,
      onTapDestinationInfoWindow: this.widget.onTapDestinationInfoWindow,
      onTapDriverInfoWindow: this.widget.onTapDriverInfoWindow,
      driverCoordinatesStream: this.widget.driverCoordinatesStream,
      sourceName: this.widget.sourceName,
      destinationName: this.widget.destinationName,
      driverName: this.widget.driverName,
      routeColor: this.widget.routeColor,
      routeWidth: this.widget.routeWidth,
      defaultCameraLocation: this.widget.defaultCameraLocation,
      defaultCameraZoom: this.widget.defaultCameraZoom,
      sourceMarkerIconInfo: this.widget.sourceMarkerIconInfo,
      destinationMarkerIconInfo: this.widget.destinationMarkerIconInfo,
      driverMarkerIconInfo: this.widget.driverMarkerIconInfo,
    );

    super.initState();
  }

  @override
  void dispose() {
    _mapsService.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _mapsService.defaultCameraLocation,
        zoom: _mapsService.defaultCameraZoom,
      ),
      markers: _mapsService.markers,
      polylines: _mapsService.polyLines,
      onMapCreated: (controller) {
        _mapsService.setController(controller);
        if (this.widget.onMapCreated != null)
          return this.widget.onMapCreated!(controller);
      },

      // other google maps params
      gestureRecognizers: this.widget.gestureRecognizers,
      compassEnabled: this.widget.compassEnabled,
      mapToolbarEnabled: this.widget.mapToolbarEnabled,
      cameraTargetBounds: this.widget.cameraTargetBounds,
      mapType: this.widget.mapType,
      minMaxZoomPreference: this.widget.minMaxZoomPreference,
      rotateGesturesEnabled: this.widget.rotateGesturesEnabled,
      scrollGesturesEnabled: this.widget.scrollGesturesEnabled,
      zoomControlsEnabled: this.widget.zoomControlsEnabled,
      zoomGesturesEnabled: this.widget.zoomGesturesEnabled,
      liteModeEnabled: this.widget.liteModeEnabled,
      tiltGesturesEnabled: this.widget.tiltGesturesEnabled,
      myLocationEnabled: this.widget.myLocationEnabled,
      myLocationButtonEnabled: this.widget.myLocationButtonEnabled,
      padding: this.widget.padding,
      indoorViewEnabled: this.widget.indoorViewEnabled,
      trafficEnabled: this.widget.trafficEnabled,
      buildingsEnabled: this.widget.buildingsEnabled,
      polygons: this.widget.polygons,
      circles: this.widget.circles,
      onCameraMoveStarted: this.widget.onCameraMoveStarted,
      tileOverlays: this.widget.tileOverlays,
      onCameraMove: this.widget.onCameraMove,
      onCameraIdle: this.widget.onCameraIdle,
      onTap: this.widget.onTap,
      onLongPress: this.widget.onLongPress,
    );
  }
}
