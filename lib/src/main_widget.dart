import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_widget/src/models/route_details.dart';
import 'package:google_maps_widget/src/models/marker_icon_info.dart';
import 'package:google_maps_widget/src/utils/constants.dart';

/// A [GoogleMapsWidget] which can be used to make polylines(route)
/// from a source to a destination,
/// and also handle a driver's realtime location (if any) on the map.
class GoogleMapsWidget extends StatefulWidget {
  const GoogleMapsWidget({
    super.key,
    required this.apiKey,
    required this.sourceLatLng,
    required this.destinationLatLng,
    this.totalDistanceCallback,
    this.totalTimeCallback,
    this.onMapCreated,
    this.onError,
    this.sourceMarkerIconInfo = const MarkerIconInfo(),
    this.destinationMarkerIconInfo = const MarkerIconInfo(),
    this.driverMarkerIconInfo = const MarkerIconInfo(),
    this.driverCoordinatesStream,
    this.defaultCameraLocation,
    this.onPolylineUpdate,
    this.markers = const <Marker>{},
    this.polylines = const <Polyline>{},
    this.showPolyline = true,
    this.defaultCameraZoom = Constants.kDefaultCameraZoom,
    this.routeColor = Constants.kRouteColor,
    this.routeWidth = Constants.kRouteWidth,
    this.updatePolylinesOnDriverLocUpdate = true,
    this.routesConnectTimeout = Constants.kRoutesConnectTimeout,
    this.routesReceiveTimeout = Constants.kRoutesReceiveTimeout,

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
    this.padding = EdgeInsets.zero,
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
    this.style,
    this.colorScheme,
    this.clusterManagers = const <ClusterManager>{},
    this.groundOverlays = const <GroundOverlay>{},
    this.heatmaps = const <Heatmap>{},
    this.markerType = GoogleMapMarkerType.marker,
    this.fortyFiveDegreeImageryEnabled = false,
    this.fullscreenControlEnabled = false,
    this.mapTypeControlEnabled = false,
    this.streetViewControlEnabled = false,
    this.webCameraControlEnabled = true,
    this.webCameraControlPosition,
    this.webGestureHandling,
  });

  /// Google Maps API key used for the Routes API call that builds the route.
  ///
  /// This is separate from the key the native Maps SDKs use to render tiles,
  /// and it cannot carry an application restriction. Application restrictions
  /// are enforced by the native SDKs, which attach the package name or bundle
  /// id; this call is a plain HTTPS request and carries neither, so Google
  /// answers PERMISSION_DENIED, reporting the blocked client application
  /// as `<empty>`.
  ///
  /// Restrict this key by API instead, to the Routes API, and cap its quota.
  final String apiKey;

  /// The source [LatLng].
  ///
  /// Changing this and rebuilding the widget updates the source marker and
  /// recalculates the route.
  final LatLng sourceLatLng;

  /// The destination [LatLng].
  ///
  /// Changing this and rebuilding the widget updates the destination marker
  /// and recalculates the route.
  final LatLng destinationLatLng;

  /// If true, Updates the polylines everytime a new event is pushed to
  /// the driver stream, i.e. the driver location changes..
  ///
  /// Valid only if [GoogleMapsWidget.driverCoordinatesStream] is not null.
  final bool updatePolylinesOnDriverLocUpdate;

  /// Called with how long the route is expected to take, once it has been
  /// computed for [sourceLatLng] and [destinationLatLng].
  ///
  /// The Routes API reports duration numerically, so this is a [Duration]
  /// rather than the localized string the legacy Directions API returned.
  final void Function(Duration)? totalTimeCallback;

  /// Called with the length of the route in metres, once it has been computed
  /// for [sourceLatLng] and [destinationLatLng].
  ///
  /// The Routes API reports distance numerically, so format this for display
  /// yourself to match your app's locale.
  final void Function(int)? totalDistanceCallback;

  /// How long to wait to establish a connection to the Google Routes API
  /// before giving up.
  ///
  /// Defaults to [Constants.kRoutesConnectTimeout]. Worth lowering on a live
  /// driver stream, where a request that outlives the next location update is
  /// already stale.
  final Duration routesConnectTimeout;

  /// How long to wait for the Google Routes API response once connected.
  ///
  /// Defaults to [Constants.kRoutesReceiveTimeout].
  final Duration routesReceiveTimeout;

  /// Called when the route could not be fetched from the Google Routes API,
  /// with a [RoutesApiException] describing why.
  ///
  /// The most common causes are an API key without the Routes API enabled,
  /// billing not being enabled on the Google Cloud project, or no network.
  /// Without this callback they are easy to mistake for the map simply not
  /// working.
  ///
  /// The map still renders when this fires; only the route is missing.
  /// Errors are also logged to the console in debug builds.
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// A [Stream] of [LatLng] objects for the driver
  /// used to render [driverMarkerIconInfo] on the map
  /// with the provided [LatLng] objects.
  ///
  /// See also:
  ///   * [driverMarkerIconInfo] parameter.
  ///
  /// If null, the [driverMarkerIconInfo] is not rendered.
  final Stream<LatLng>? driverCoordinatesStream;

  /// The initial location of the map's camera.
  /// If null, initial location is [sourceLatLng].
  final LatLng? defaultCameraLocation;

  /// The initial zoom of the map's camera.
  /// Defaults to [Constants.kDefaultCameraZoom].
  final double defaultCameraZoom;

  /// Color of the route made between [sourceLatLng] and [destinationLatLng].
  /// Defaults to [Constants.kRouteColor].
  final Color routeColor;

  /// Width of the route made between [sourceLatLng] and [destinationLatLng].
  /// Defaults to [Constants.kRouteWidth].
  final int routeWidth;

  /// Called when the polyline is updated i.e. route is updated.
  final void Function(Polyline)? onPolylineUpdate;

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

  /// The style to apply to the map, as a Google Maps style JSON string.
  ///
  /// This is how a dark (or otherwise themed) map is applied. Pass the JSON
  /// produced by https://mapstyle.withgoogle.com, switching the string when
  /// the app's theme changes:
  ///
  /// ```dart
  /// GoogleMapsWidget(
  ///   style: Theme.of(context).brightness == Brightness.dark
  ///       ? darkMapStyleJson
  ///       : null,
  ///   ...
  /// )
  /// ```
  ///
  /// See also:
  ///   * [colorScheme] parameter, for switching between Google's own light
  ///     and dark map styles without supplying a style JSON.
  final String? style;

  /// Whether the map should render in Google's light or dark color scheme,
  /// or follow the platform's setting.
  ///
  /// Unlike [style], this can only be applied when the map is first created;
  /// changing it later has no effect. Use [style] if the map has to follow a
  /// theme toggle at runtime.
  final MapColorScheme? colorScheme;

  /// Cluster managers to be initialized for the map.
  final Set<ClusterManager> clusterManagers;

  /// Ground overlays to be placed on the map.
  final Set<GroundOverlay> groundOverlays;

  /// Heatmaps to show on the map.
  final Set<Heatmap> heatmaps;

  /// The type of marker rendering to use for the map.
  final GoogleMapMarkerType markerType;

  /// Whether 45 degree imagery should be enabled. Web only.
  final bool fortyFiveDegreeImageryEnabled;

  /// Whether the fullscreen control should be enabled. Web only.
  final bool fullscreenControlEnabled;

  /// Whether the map type control should be enabled. Web only.
  final bool mapTypeControlEnabled;

  /// Whether the street view control should be enabled. Web only.
  final bool streetViewControlEnabled;

  /// Whether the camera (zoom) control should be enabled. Web only.
  final bool webCameraControlEnabled;

  /// The position of the camera (zoom) control. Web only.
  final WebCameraControlPosition? webCameraControlPosition;

  /// How the map handles gestures relative to the surrounding page. Web only.
  final WebGestureHandling? webGestureHandling;

  @override
  GoogleMapsWidgetState createState() => GoogleMapsWidgetState();
}

class GoogleMapsWidgetState extends State<GoogleMapsWidget> {
  /// The [PolylineId] of the route generated between the source and the
  /// destination.
  static const generatedPolylineId = PolylineId('default-polyline');

  /// Markers to be placed on the map, keyed by id so that an update replaces
  /// the previous marker rather than sitting alongside it.
  final _markersMap = <MarkerId, Marker>{};

  /// Polylines to be placed on the map.
  ///
  /// Keyed by [PolylineId] for the same reason as [_markersMap]: a [Set] would
  /// hold two polylines sharing an id, and google_maps_flutter keeps whichever
  /// one it happens to see last, so a stale route could win.
  final _polylines = <PolylineId, Polyline>{};

  final _mapsControllerCompleter = Completer<GoogleMapController>();

  Future<GoogleMapController> getGoogleMapsController() => _mapsControllerCompleter.future;

  Future<void> setSourceLatLng(LatLng sourceLatLng) async {
    if (_sourceLatLng == sourceLatLng) return;

    _sourceLatLng = sourceLatLng;
    await Future.wait([_buildPolyLines(), _setSourceDestinationMarkers()]);
  }

  Future<void> setDestinationLatLng(LatLng destinationLatLng) async {
    if (_destinationLatLng == destinationLatLng) return;

    _destinationLatLng = destinationLatLng;
    await Future.wait([_buildPolyLines(), _setSourceDestinationMarkers()]);
  }

  StreamSubscription<LatLng>? _driverCoordinatesStreamSubscription;

  late LatLng _sourceLatLng;
  late LatLng _destinationLatLng;

  /// Builds a [Marker] from [info], or null when it should not be rendered.
  ///
  /// [icon] can be passed to reuse an already resolved [BitmapDescriptor],
  /// which matters on the driver stream where a new location can arrive many
  /// times a second and decoding the asset each time would be wasteful.
  Future<Marker?> _buildMarker({
    required MarkerId markerId,
    required MarkerIconInfo info,
    required LatLng position,
    BitmapDescriptor? icon,
  }) async {
    if (!info.isVisible) return null;

    // Copied into locals so the null checks below promote, which keeps these
    // callbacks free of null assertions.
    final void Function(LatLng)? onTapMarker = info.onTapMarker;
    final void Function(LatLng)? onTapInfoWindow = info.onTapInfoWindow;

    return Marker(
      markerId: markerId,
      position: position,
      anchor: info.anchor,
      rotation: info.rotation,
      icon: icon ?? await info.bitmapDescriptor,
      onTap: onTapMarker == null ? null : () => onTapMarker(position),
      infoWindow: InfoWindow(
        onTap: onTapInfoWindow == null ? null : () => onTapInfoWindow(position),
        title: info.infoWindowTitle,
      ),
    );
  }

  /// Adds [marker] under [markerId], or removes any existing marker when
  /// [marker] is null. Returns whether anything actually changed.
  bool _setOrRemoveMarker(MarkerId markerId, Marker? marker) {
    if (marker == null) return _markersMap.remove(markerId) != null;

    final previous = _markersMap[markerId];
    _markersMap[markerId] = marker;
    return previous != marker;
  }

  /// setting source and destination markers
  Future<void> _setSourceDestinationMarkers() async {
    final source = await _buildMarker(
      markerId: MarkerIconInfo.sourceMarkerId,
      info: widget.sourceMarkerIconInfo,
      position: _sourceLatLng,
    );

    final destination = await _buildMarker(
      markerId: MarkerIconInfo.destinationMarkerId,
      info: widget.destinationMarkerIconInfo,
      position: _destinationLatLng,
    );

    // The bitmaps above are decoded asynchronously, so the widget can be gone
    // by the time they resolve.
    if (!mounted) return;

    setState(() {
      _setOrRemoveMarker(MarkerIconInfo.sourceMarkerId, source);
      _setOrRemoveMarker(MarkerIconInfo.destinationMarkerId, destination);
    });
  }

  /// Build polylines from [_sourceLatLng] to [_destinationLatLng].
  Future<void> _buildPolyLines({LatLng? driverLoc}) async {
    if (!widget.showPolyline) return;

    final RouteDetails? result;
    try {
      result = await RouteDetails.getRoute(
        googleMapsApiKey: widget.apiKey,
        origin: driverLoc ?? _sourceLatLng,
        destination: _destinationLatLng,
        connectTimeout: widget.routesConnectTimeout,
        receiveTimeout: widget.routesReceiveTimeout,
      );
    } catch (error, stackTrace) {
      // A failed route must not take the map down with it, but it must also
      // not disappear silently. Silent failure is what makes a blank map so
      // hard to diagnose.
      debugLogRouteError(error, stackTrace);
      widget.onError?.call(error, stackTrace);
      return;
    }

    if (!mounted) return;

    final polylineCoordinates = <LatLng>[];

    if (result != null && result.polylinePoints.isNotEmpty) {
      polylineCoordinates.addAll(result.polylinePoints);
    }

    final polyline = Polyline(
      polylineId: generatedPolylineId,
      color: widget.routeColor,
      width: widget.routeWidth,
      points: polylineCoordinates,
    );

    widget.onPolylineUpdate?.call(polyline);

    setState(() => _polylines[generatedPolylineId] = polyline);

    // setting map such as both source and
    // destinations markers can be seen
    if (result != null) {
      final controller = await getGoogleMapsController();
      if (!mounted) return;

      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(result.bounds, 32),
      );

      widget.totalTimeCallback?.call(result.duration);
      widget.totalDistanceCallback?.call(result.distance);
    }
  }

  /// This function uses [GoogleMapsWidget.driverCoordinatesStream] which
  /// is a [Stream] of [LatLng]-[coordinates] and renders
  /// [GoogleMapsWidget.driverMarkerIconInfo] marker to show
  /// driver's location in realtime.
  Future<void> _listenToDriverCoordinates() async {
    final driverStream = widget.driverCoordinatesStream;
    if (driverStream == null) return;

    final driverMarkerBitmapDescriptor = await widget.driverMarkerIconInfo.bitmapDescriptor;
    if (!mounted) return;

    _driverCoordinatesStreamSubscription = driverStream.listen((coordinate) async {
      if (!mounted) return;

      if (widget.updatePolylinesOnDriverLocUpdate) {
        unawaited(_buildPolyLines(driverLoc: coordinate));
      }

      final marker = await _buildMarker(
        markerId: MarkerIconInfo.driverMarkerId,
        info: widget.driverMarkerIconInfo,
        position: coordinate,
        icon: driverMarkerBitmapDescriptor,
      );

      if (!mounted) return;

      if (_setOrRemoveMarker(MarkerIconInfo.driverMarkerId, marker)) {
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _sourceLatLng = widget.sourceLatLng;
    _destinationLatLng = widget.destinationLatLng;

    _setSourceDestinationMarkers();
    _buildPolyLines();
    _listenToDriverCoordinates();
  }

  @override
  void didUpdateWidget(covariant GoogleMapsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final sourceChanged = widget.sourceLatLng != oldWidget.sourceLatLng;
    final destinationChanged = widget.destinationLatLng != oldWidget.destinationLatLng;

    if (sourceChanged) _sourceLatLng = widget.sourceLatLng;
    if (destinationChanged) _destinationLatLng = widget.destinationLatLng;

    if (sourceChanged || destinationChanged) {
      _setSourceDestinationMarkers();
      _buildPolyLines();
    } else if (widget.showPolyline != oldWidget.showPolyline) {
      if (widget.showPolyline) {
        _buildPolyLines();
      } else {
        setState(_polylines.clear);
      }
    }

    if (widget.driverCoordinatesStream != oldWidget.driverCoordinatesStream) {
      _driverCoordinatesStreamSubscription?.cancel();
      _driverCoordinatesStreamSubscription = null;
      _listenToDriverCoordinates();
    }
  }

  @override
  void dispose() {
    _driverCoordinatesStreamSubscription?.cancel();
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
      polylines: {..._polylines.values, ...widget.polylines},
      onMapCreated: (controller) {
        if (!_mapsControllerCompleter.isCompleted) {
          _mapsControllerCompleter.complete(controller);
        }

        widget.onMapCreated?.call(controller);
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
      style: widget.style,
      colorScheme: widget.colorScheme,
      clusterManagers: widget.clusterManagers,
      groundOverlays: widget.groundOverlays,
      heatmaps: widget.heatmaps,
      markerType: widget.markerType,
      fortyFiveDegreeImageryEnabled: widget.fortyFiveDegreeImageryEnabled,
      fullscreenControlEnabled: widget.fullscreenControlEnabled,
      mapTypeControlEnabled: widget.mapTypeControlEnabled,
      streetViewControlEnabled: widget.streetViewControlEnabled,
      webCameraControlEnabled: widget.webCameraControlEnabled,
      webCameraControlPosition: widget.webCameraControlPosition,
      webGestureHandling: widget.webGestureHandling,
    );
  }
}
