import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_widget/src/models/direction.dart';
import 'package:google_maps_widget/src/models/marker_icon_info.dart';
import 'package:google_maps_widget/src/utils/constants.dart';

/// A [GoogleMapsWidget] which can be used to make polylines(route)
/// from a source to a destination,
/// and also handle a driver's realtime location (if any) on the map.
class GoogleMapsWidget extends StatefulWidget {
  const GoogleMapsWidget({
    Key? key,
    required this.apiKey,
    required this.sourceLatLng,
    required this.destinationLatLng,
    this.totalDistanceCallback,
    this.totalTimeCallback,
    this.onMapCreated,
    this.sourceMarkerIconInfo = const MarkerIconInfo(),
    this.destinationMarkerIconInfo = const MarkerIconInfo(),
    this.driverMarkerIconInfo = const MarkerIconInfo(),
    this.onTapSourceMarker,
    this.onTapDestinationMarker,
    this.onTapDriverMarker,
    this.onTapSourceInfoWindow,
    this.onTapDestinationInfoWindow,
    this.onTapDriverInfoWindow,
    this.driverCoordinatesStream,
    this.defaultCameraLocation,
    this.markers = const <Marker>{},
    this.polylines = const <Polyline>{},
    this.showPolyline = true,
    this.showSourceMarker = true,
    this.showDestinationMarker = true,
    this.showDriverMarker = true,
    this.defaultCameraZoom = Constants.kDefaultCameraZoom,
    this.sourceName = Constants.kDefaultSourceName,
    this.destinationName = Constants.kDefaultDestinationName,
    this.driverName = Constants.kDefaultDriverName,
    this.routeColor = Constants.kRouteColor,
    this.routeWidth = Constants.kRouteWidth,
    this.updatePolylinesOnDriverLocUpdate = true,

    // other google maps params
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
    this.layoutDirection,
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
  }) : super(key: key);

  /// Google Maps API Key.
  final String apiKey;

  /// The source [LatLng].
  final LatLng sourceLatLng;

  /// The destination [LatLng].
  final LatLng destinationLatLng;

  /// Called every time source [Marker]'s [InfoWindow] is tapped.
  final void Function(LatLng)? onTapSourceInfoWindow;

  /// Called every time destination [Marker]'s [InfoWindow] is tapped.
  final void Function(LatLng)? onTapDestinationInfoWindow;

  /// Called every time driver [Marker]'s [InfoWindow] is tapped.
  final void Function(LatLng)? onTapDriverInfoWindow;

  /// Called every time source [Marker] is tapped.
  final void Function(LatLng)? onTapSourceMarker;

  /// Called every time destination [Marker] is tapped.
  final void Function(LatLng)? onTapDestinationMarker;

  /// Called every time driver [Marker] is tapped.
  final void Function(LatLng)? onTapDriverMarker;

  /// If true, Updates the polylines everytime a new event is pushed to
  /// the driver stream, i.e. the driver location changes..
  ///
  /// Valid only if [GoogleMapsWidget.driverCoordinatesStream] is not null.
  final bool updatePolylinesOnDriverLocUpdate;

  /// Called after polylines are created for the given
  /// [sourceLatLng] and [destinationLatLng] and
  /// totalTime is initialized.
  final void Function(String?)? totalTimeCallback;

  /// Called after polylines are created for the given
  /// [sourceLatLng] and [destinationLatLng] and
  /// totalDistance is initialized.
  final void Function(String?)? totalDistanceCallback;

  /// A [Stream] of [LatLng] objects for the driver
  /// used to render [driverMarkerIconInfo] on the map
  /// with the provided [LatLng] objects.
  ///
  /// See also:
  ///   * [onTapDriverInfoWindow] parameter.
  ///   * [onTapDriverMarker] parameter.
  ///   * [driverName] parameter.
  ///
  /// If null, the [driverMarkerIconInfo] is not rendered.
  final Stream<LatLng>? driverCoordinatesStream;

  /// The initial location of the map's camera.
  /// If null, initial location is [sourceLatLng].
  final LatLng? defaultCameraLocation;

  /// The initial zoom of the map's camera.
  /// Defaults to [Constants.kDefaultCameraZoom].
  final double defaultCameraZoom;

  /// Displays source [Marker]'s [InfoWindow] displaying [sourceName]
  /// when tapped on [sourceMarkerIconInfo].
  /// Defaults to [Constants.kDefaultSourceName].
  final String sourceName;

  /// Displays destination [Marker]'s [InfoWindow] displaying [destinationName]
  /// when tapped on [destinationMarkerIconInfo].
  /// Defaults to [Constants.kDefaultDestinationName].
  final String destinationName;

  /// Displays driver's [Marker]'s [InfoWindow] displaying [driverName]
  /// when tapped on [driverMarkerIconInfo].
  /// Defaults to [Constants.kDefaultDriverName].
  final String driverName;

  /// Color of the route made between [sourceLatLng] and [destinationLatLng].
  /// Defaults to [Constants.kRouteColor].
  final Color routeColor;

  /// Width of the route made between [sourceLatLng] and [destinationLatLng].
  /// Defaults to [Constants.kRouteWidth].
  final int routeWidth;

  /// The marker which is rendered on the location [sourceLatLng].
  final MarkerIconInfo sourceMarkerIconInfo;

  /// The marker which is rendered on the location [destinationLatLng].
  final MarkerIconInfo destinationMarkerIconInfo;

  /// The marker which is rendered on the driver's current location
  /// provided by [driverCoordinatesStream].
  ///
  /// See also:
  ///   * [driverCoordinatesStream] parameter.
  final MarkerIconInfo driverMarkerIconInfo;

  /// Whether to show the source marker at [sourceLatLng].
  ///
  /// Defaults to true.
  final bool showSourceMarker;

  /// Whether to show the destination marker at [destinationLatLng].
  ///
  /// Defaults to true.
  final bool showDestinationMarker;

  /// Whether to show the driver marker.
  ///
  /// Defaults to true.
  final bool showDriverMarker;

  /// Whether to show the generated polyline from [sourceLatLng]
  /// to [destinationLatLng].
  ///
  /// Defaults to true.
  final bool showPolyline;

  /// Callback method for when the map is ready to be used.
  ///
  /// Used to receive a [GoogleMapController] for this [GoogleMap].
  final void Function(GoogleMapController)? onMapCreated;

  /////////////////////////////////////////////////
  // OTHER GOOGLE MAPS PARAMS
  /////////////////////////////////////////////////

  /// True if the map view should respond to rotate gestures.
  final bool rotateGesturesEnabled;

  /// True if the map view should respond to scroll gestures.
  final bool scrollGesturesEnabled;

  /// True if the map view should show zoom controls. This includes two buttons
  /// to zoom in and zoom out. The default value is to show zoom controls.
  ///
  /// This is only supported on Android. And this field is silently ignored on iOS.
  final bool zoomControlsEnabled;

  /// True if the map view should respond to zoom gestures.
  final bool zoomGesturesEnabled;

  /// True if the map view should be in lite mode. Android only.
  ///
  /// See https://developers.google.com/maps/documentation/android-sdk/lite#overview_of_lite_mode for more details.
  final bool liteModeEnabled;

  /// True if the map view should respond to tilt gestures.
  final bool tiltGesturesEnabled;

  /// True if a "My Location" layer should be shown on the map.
  ///
  /// This layer includes a location indicator at the current device location,
  /// as well as a My Location button.
  /// * The indicator is a small blue dot if the device is stationary, or a
  /// chevron if the device is moving.
  /// * The My Location button animates to focus on the user's current location
  /// if the user's location is currently known.
  ///
  /// Enabling this feature requires adding location permissions to both native
  /// platforms of your app.
  /// * On Android add either
  /// `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />`
  /// or `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />`
  /// to your `AndroidManifest.xml` file. `ACCESS_COARSE_LOCATION` returns a
  /// location with an accuracy approximately equivalent to a city block, while
  /// `ACCESS_FINE_LOCATION` returns as precise a location as possible, although
  /// it consumes more battery power. You will also need to request these
  /// permissions during run-time. If they are not granted, the My Location
  /// feature will fail silently.
  /// * On iOS add a `NSLocationWhenInUseUsageDescription` key to your
  /// `Info.plist` file. This will automatically prompt the user for permissions
  /// when the map tries to turn on the My Location layer.
  final bool myLocationEnabled;

  /// Enables or disables the my-location button.
  ///
  /// The my-location button causes the camera to move such that the user's
  /// location is in the center of the map. If the button is enabled, it is
  /// only shown when the my-location layer is enabled.
  ///
  /// By default, the my-location button is enabled (and hence shown when the
  /// my-location layer is enabled).
  ///
  /// See also:
  ///   * [myLocationEnabled] parameter.
  final bool myLocationButtonEnabled;

  /// Enables or disables the indoor view from the map
  final bool indoorViewEnabled;

  /// Enables or disables the traffic layer of the map
  final bool trafficEnabled;

  /// Enables or disables showing 3D buildings where available
  final bool buildingsEnabled;

  /// The layout direction to use for the embedded view.
  ///
  /// If this is null, the ambient [Directionality] is used instead. If there is
  /// no ambient [Directionality], [TextDirection.ltr] is used.
  final TextDirection? layoutDirection;

  /// True if the map should show a compass when rotated.
  final bool compassEnabled;

  /// True if the map should show a toolbar when you interact with the map. Android only.
  final bool mapToolbarEnabled;

  /// Called every time a [GoogleMap] is tapped.
  final ArgumentCallback<LatLng>? onTap;

  /// Called when camera movement has ended, there are no pending
  /// animations and the user has stopped interacting with the map.
  final VoidCallback? onCameraIdle;

  /// Called repeatedly as the camera continues to move after an
  /// onCameraMoveStarted call.
  ///
  /// This may be called as often as once every frame and should
  /// not perform expensive operations.
  final CameraPositionCallback? onCameraMove;

  /// Called when the camera starts moving.
  ///
  /// This can be initiated by the following:
  /// 1. Non-gesture animation initiated in response to user actions.
  ///    For example: zoom buttons, my location button, or marker clicks.
  /// 2. Programmatically initiated animation.
  /// 3. Camera motion initiated in response to user gestures on the map.
  ///    For example: pan, tilt, pinch to zoom, or rotate.
  final VoidCallback? onCameraMoveStarted;

  /// Called every time a [GoogleMap] is long pressed.
  final ArgumentCallback<LatLng>? onLongPress;

  /// Which gestures should be consumed by the map.
  ///
  /// It is possible for other gesture recognizers to be competing with the map on pointer
  /// events, e.g if the map is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The map will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty, the map will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  /// Polygons to be placed on the map.
  final Set<Polygon> polygons;

  /// Circles to be placed on the map.
  final Set<Circle> circles;

  /// Markers to be placed on the map. (apart from the source and destination markers).
  final Set<Marker> markers;

  /// Polylines to be placed on the map. (apart from the one generated
  /// between the [sourceLatLng] and the [destinationLatLng].
  ///
  /// You can disable the generated polyline by setting the [showPolyline] to false.
  final Set<Polyline> polylines;

  /// Tile overlays to be placed on the map.
  final Set<TileOverlay> tileOverlays;

  /// Type of map tiles to be rendered.
  final MapType mapType;

  /// Padding to be set on map. See https://developers.google.com/maps/documentation/android-sdk/map#map_padding for more details.
  final EdgeInsets padding;

  /// Preferred bounds for the camera zoom level.
  ///
  /// Actual bounds depend on map data and device.
  final MinMaxZoomPreference minMaxZoomPreference;

  /// Geographical bounding box for the camera target.
  final CameraTargetBounds cameraTargetBounds;

  @override
  GoogleMapsWidgetState createState() => GoogleMapsWidgetState();
}

class GoogleMapsWidgetState extends State<GoogleMapsWidget> {
  /// Markers to be placed on the map.
  final _markersMap = <MarkerId, Marker>{};

  /// Polylines to be placed on the map.
  final _polylines = <Polyline>{};

  final _mapsControllerCompleter = Completer<GoogleMapController>();

  Future<GoogleMapController> getGoogleMapsController() =>
      _mapsControllerCompleter.future;

  void setSourceLatLng(LatLng sourceLatLng) async {
    if (_sourceLatLng == sourceLatLng) return;

    _sourceLatLng = sourceLatLng;
    await _buildPolyLines();
    _setSourceDestinationMarkers();
    setState(() {});
  }

  void setDestinationLatLng(LatLng destinationLatLng) async {
    if (_destinationLatLng == destinationLatLng) return;

    _destinationLatLng = destinationLatLng;
    await _buildPolyLines();
    _setSourceDestinationMarkers();
    setState(() {});
  }

  StreamSubscription<LatLng>? _driverCoordinatesStreamSubscription;

  late LatLng _sourceLatLng;
  late LatLng _destinationLatLng;

  /// setting source and destination markers
  void _setSourceDestinationMarkers() async {
    _markersMap.remove(MarkerIconInfo.sourceMarkerId);

    if (widget.showSourceMarker) {
      _markersMap[MarkerIconInfo.sourceMarkerId] = Marker(
        markerId: MarkerIconInfo.sourceMarkerId,
        position: _sourceLatLng,
        anchor: widget.sourceMarkerIconInfo.anchor,
        rotation: widget.sourceMarkerIconInfo.rotation,
        icon: await widget.sourceMarkerIconInfo.bitmapDescriptor,
        onTap: widget.onTapSourceMarker == null
            ? null
            : () => widget.onTapSourceMarker!(_sourceLatLng),
        infoWindow: InfoWindow(
          onTap: widget.onTapSourceInfoWindow == null
              ? null
              : () => widget.onTapSourceInfoWindow!(_sourceLatLng),
          title: widget.sourceName,
        ),
      );
    }

    _markersMap.remove(MarkerIconInfo.destinationMarkerId);

    if (widget.showDestinationMarker) {
      _markersMap[MarkerIconInfo.destinationMarkerId] = Marker(
        markerId: MarkerIconInfo.destinationMarkerId,
        position: _destinationLatLng,
        anchor: widget.destinationMarkerIconInfo.anchor,
        rotation: widget.destinationMarkerIconInfo.rotation,
        icon: await widget.destinationMarkerIconInfo.bitmapDescriptor,
        onTap: widget.onTapDestinationMarker == null
            ? null
            : () => widget.onTapDestinationMarker!(_destinationLatLng),
        infoWindow: InfoWindow(
          onTap: widget.onTapDestinationInfoWindow == null
              ? null
              : () => widget.onTapDestinationInfoWindow!(_destinationLatLng),
          title: widget.destinationName,
        ),
      );
    }

    setState(() {});
  }

  /// Build polylines from [_sourceLatLng] to [_destinationLatLng].
  Future<void> _buildPolyLines({LatLng? driverLoc}) async {
    if (!widget.showPolyline) return;

    final result = await Direction.getDirections(
      googleMapsApiKey: widget.apiKey,
      origin: driverLoc ?? _sourceLatLng,
      destination: _destinationLatLng,
    );

    final polylineCoordinates = <LatLng>[];

    if (result != null && result.polylinePoints.isNotEmpty) {
      polylineCoordinates.addAll(result.polylinePoints);
    }

    final polyline = Polyline(
      polylineId: const PolylineId("poly_line"),
      color: widget.routeColor,
      width: widget.routeWidth,
      points: polylineCoordinates,
    );

    if (driverLoc != null) _polylines.clear();
    _polylines.add(polyline);

    // setting map such as both source and
    // destinations markers can be seen
    if (result != null) {
      final controller = await getGoogleMapsController();

      controller.animateCamera(
        CameraUpdate.newLatLngBounds(result.bounds, 32),
      );

      widget.totalTimeCallback?.call(result.totalDuration);
      widget.totalDistanceCallback?.call(result.totalDistance);
    }

    setState(() {});
  }

  /// This function uses [GoogleMapsWidget.driverCoordinatesStream] which
  /// is a [Stream] of [LatLng]-[coordinates] and renders
  /// [GoogleMapsWidget.driverMarkerIconInfo] marker to show
  /// driver's location in realtime.
  Future<void> _listenToDriverCoordinates() async {
    final driverStream = widget.driverCoordinatesStream;
    if (driverStream == null) return;

    final driverMarker = await widget.driverMarkerIconInfo.bitmapDescriptor;

    _driverCoordinatesStreamSubscription = driverStream.listen((coordinate) {
      if (widget.updatePolylinesOnDriverLocUpdate) {
        _buildPolyLines(driverLoc: coordinate);
      }

      if (!widget.showDriverMarker) return;

      _markersMap.remove(MarkerIconInfo.driverMarkerId);

      _markersMap[MarkerIconInfo.driverMarkerId] = Marker(
        markerId: MarkerIconInfo.driverMarkerId,
        position: coordinate,
        anchor: widget.driverMarkerIconInfo.anchor,
        rotation: widget.driverMarkerIconInfo.rotation,
        icon: driverMarker,
        onTap: widget.onTapDriverMarker == null
            ? null
            : () => widget.onTapDriverMarker!(coordinate),
        infoWindow: InfoWindow(
          onTap: widget.onTapDriverInfoWindow == null
              ? null
              : () => widget.onTapDriverInfoWindow!(coordinate),
          title: widget.driverName,
        ),
      );

      setState(() {});
    });
  }

  @override
  void initState() {
    _sourceLatLng = widget.sourceLatLng;
    _destinationLatLng = widget.destinationLatLng;

    _setSourceDestinationMarkers();
    _buildPolyLines();
    _listenToDriverCoordinates();

    super.initState();
  }

  @override
  void dispose() {
    _driverCoordinatesStreamSubscription?.cancel();

    if (_mapsControllerCompleter.isCompleted) {
      _mapsControllerCompleter.future.then(
        (controller) => controller.dispose(),
      );
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.defaultCameraLocation ?? _sourceLatLng,
        zoom: widget.defaultCameraZoom,
      ),
      markers: {..._markersMap.values, ...widget.markers},
      polylines: {..._polylines, ...widget.polylines},
      onMapCreated: (controller) {
        _mapsControllerCompleter.complete(controller);
        if (widget.onMapCreated != null) {
          return widget.onMapCreated!(controller);
        }
      },
      /////////////////////////////////////////////////
      // OTHER GOOGLE MAPS PARAMS
      /////////////////////////////////////////////////
      gestureRecognizers: widget.gestureRecognizers,
      compassEnabled: widget.compassEnabled,
      layoutDirection: widget.layoutDirection,
      mapToolbarEnabled: widget.mapToolbarEnabled,
      cameraTargetBounds: widget.cameraTargetBounds,
      mapType: widget.mapType,
      minMaxZoomPreference: widget.minMaxZoomPreference,
      rotateGesturesEnabled: widget.rotateGesturesEnabled,
      scrollGesturesEnabled: widget.scrollGesturesEnabled,
      zoomControlsEnabled: widget.zoomControlsEnabled,
      zoomGesturesEnabled: widget.zoomGesturesEnabled,
      liteModeEnabled: widget.liteModeEnabled,
      tiltGesturesEnabled: widget.tiltGesturesEnabled,
      myLocationEnabled: widget.myLocationEnabled,
      myLocationButtonEnabled: widget.myLocationButtonEnabled,
      padding: widget.padding,
      indoorViewEnabled: widget.indoorViewEnabled,
      trafficEnabled: widget.trafficEnabled,
      buildingsEnabled: widget.buildingsEnabled,
      polygons: widget.polygons,
      circles: widget.circles,
      onCameraMoveStarted: widget.onCameraMoveStarted,
      tileOverlays: widget.tileOverlays,
      onCameraMove: widget.onCameraMove,
      onCameraIdle: widget.onCameraIdle,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
    );
  }
}
