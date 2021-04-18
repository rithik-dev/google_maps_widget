import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_widget/src/models/direction.dart';
import 'package:google_maps_widget/src/models/marker_icon_info.dart';
import 'package:google_maps_widget/src/utils/constants.dart';
import 'package:google_maps_widget/src/main_widget.dart';

/// The underline class for [GoogleMapsWidget] which
/// contains all the implementations.
class MapsService {
  /// setState function
  late void Function(Function() fn) _setState;

  /// source [LatLng]
  late LatLng _sourceLatLng;

  /// destination [LatLng]
  late LatLng _destinationLatLng;

  /// Google maps controller
  GoogleMapController? _mapController;

  /// source marker info
  MarkerIconInfo? _sourceMarkerIconInfo;

  /// destination marker info
  MarkerIconInfo? _destinationMarkerIconInfo;

  /// driver marker info
  MarkerIconInfo? _driverMarkerIconInfo;

  /// A [Stream] of [LatLng] objects for the driver
  /// used to render [_driverMarkerIconInfo] on the map
  /// with the provided [LatLng] objects.
  ///
  /// See also:
  ///   * [_onTapDriverInfoWindow] parameter.
  ///   * [_onTapDriverMarker] parameter.
  ///   * [_driverName] parameter.
  ///
  /// If null, the [_driverMarkerIconInfo] is not rendered.
  StreamSubscription<LatLng>? _driverCoordinates;

  /// The initial location of the map's camera.
  LatLng? _defaultCameraLocation;

  /// The initial zoom of the map's camera.
  double? _defaultCameraZoom;

  /// Markers to be placed on the map.
  Set<Marker> _markers = {};

  /// Polylines to be placed on the map.
  Set<Polyline> _polylines = {};

  /// Displays source [Marker]'s [InfoWindow] displaying [_sourceName]
  /// when tapped on [_sourceMarkerIconInfo].
  String? _sourceName;

  /// Displays destination [Marker]'s [InfoWindow] displaying [_destinationName]
  /// when tapped on [_destinationMarkerIconInfo].
  String? _destinationName;

  /// Displays driver's [Marker]'s [InfoWindow] displaying [_driverName]
  /// when tapped on [_driverMarkerIconInfo].
  String? _driverName;

  /// Called every time source [Marker] is tapped.
  void Function(LatLng)? _onTapSourceMarker;

  /// Called every time destination [Marker] is tapped.
  void Function(LatLng)? _onTapDestinationMarker;

  /// Called every time driver [Marker] is tapped.
  void Function(LatLng)? _onTapDriverMarker;

  /// Called every time source [Marker]'s [InfoWindow] is tapped.
  void Function(LatLng)? _onTapSourceInfoWindow;

  /// Called every time destination [Marker]'s [InfoWindow] is tapped.
  void Function(LatLng)? _onTapDestinationInfoWindow;

  /// Called every time driver [Marker]'s [InfoWindow] is tapped.
  void Function(LatLng)? _onTapDriverInfoWindow;

  /// Called after polylines are created for the given
  /// [_sourceLatLng] and [_destinationLatLng] and
  /// totalDistance is initialized.
  void Function(String?)? _totalDistanceCallback;

  /// Called after polylines are created for the given
  /// [_sourceLatLng] and [_destinationLatLng] and
  /// totalTime is initialized.
  void Function(String?)? _totalTimeCallback;

  /// Color of the route made between [_sourceLatLng] and [_destinationLatLng].
  Color? _routeColor;

  /// Width of the route made between [_sourceLatLng] and [_destinationLatLng].
  int? _routeWidth;

  /// The total distance between the source and the destination.
  String? totalDistance;

  /// The total time between the source and the destination.
  String? totalTime;

  /// Google maps API Key
  static late String _apiKey;

  /// Returns the Google Maps API Key passed to the [GoogleMapsWidget].
  static String get apiKey => _apiKey;

  /// Returns the [_defaultCameraLocation].
  /// If [_defaultCameraLocation] is null, returns [_sourceLatLng].
  LatLng get defaultCameraLocation => _defaultCameraLocation ?? _sourceLatLng;

  /// Returns the [_defaultCameraZoom].
  /// If [_defaultCameraZoom] is null, returns [Constants.DEFAULT_CAMERA_ZOOM].
  double get defaultCameraZoom =>
      _defaultCameraZoom ?? Constants.DEFAULT_CAMERA_ZOOM;

  /// Returns markers to be placed on the map.
  Set<Marker> get markers => _markers;

  /// Returns polylines to be placed on the map.
  Set<Polyline> get polylines => _polylines;

  /// Sets [GoogleMapController] from [GoogleMap] callback to [_mapController].
  void setController(GoogleMapController _controller) {
    _mapController = _controller;
  }

  /// Whether to show the source marker at [_sourceLatLng].
  ///
  /// Defaults to true.
  late bool _showSourceMarker;

  /// Whether to show the destination marker at [_destinationLatLng].
  ///
  /// Defaults to true.
  late bool _showDestinationMarker;

  /// Whether to show the driver marker.
  ///
  /// Defaults to true.
  late bool _showDriverMarker;

  /// Whether to show the generated polyline from [_sourceLatLng]
  /// to [_destinationLatLng].
  ///
  /// Defaults to true.
  late bool _showPolyline;

  /// setting source and destination markers
  void _setSourceDestinationMarkers() async {
    _markers.addAll([
      if (_showSourceMarker)
        Marker(
          markerId: MarkerId("source"),
          position: _sourceLatLng,
          icon: (await _sourceMarkerIconInfo?.bitmapDescriptor)!,
          onTap: _onTapSourceMarker == null
              ? null
              : () => _onTapSourceMarker!(_sourceLatLng),
          infoWindow: InfoWindow(
            onTap: _onTapSourceInfoWindow == null
                ? null
                : () => _onTapSourceInfoWindow!(_sourceLatLng),
            title: _sourceName,
          ),
        ),
      if (_showDestinationMarker)
        Marker(
          markerId: MarkerId("destination"),
          position: _destinationLatLng,
          icon: (await _destinationMarkerIconInfo?.bitmapDescriptor)!,
          onTap: _onTapDestinationMarker == null
              ? null
              : () => _onTapDestinationMarker!(_destinationLatLng),
          infoWindow: InfoWindow(
            onTap: _onTapDestinationInfoWindow == null
                ? null
                : () => _onTapDestinationInfoWindow!(_destinationLatLng),
            title: _destinationName,
          ),
        )
    ]);

    _setState(() {});
  }

  /// Build polylines from [_sourceLatLng] to [_destinationLatLng].
  Future<void> _buildPolyLines() async {
    final result = await Direction.getDirections(
      origin: _sourceLatLng,
      destination: _destinationLatLng,
    );

    final _polylineCoordinates = <LatLng>[];

    if (result != null && result.polylinePoints.isNotEmpty) {
      _polylineCoordinates.addAll(result.polylinePoints);
    }

    final polyline = Polyline(
      polylineId: PolylineId("poly_line"),
      color: _routeColor ?? Constants.ROUTE_COLOR,
      width: _routeWidth ?? Constants.ROUTE_WIDTH,
      points: _polylineCoordinates,
    );

    _polylines.add(polyline);

    // setting map such as both source and
    // destinations markers can be seen
    if (result != null) {
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(result.bounds, 32),
      );

      totalDistance = result.totalDistance;
      totalTime = result.totalDuration;

      if (_totalDistanceCallback != null)
        _totalDistanceCallback!(totalDistance);

      if (_totalTimeCallback != null) _totalTimeCallback!(totalTime);
    }

    _setState(() {});
  }

  /// This function takes in a [Stream] of [LatLng]-[coordinates]
  /// and renders [_driverMarkerIconInfo] marker to show
  /// driver's location in realtime.
  Future<void> _listenToDriverCoordinates(Stream<LatLng> coordinates) async {
    final driverMarker = (await _driverMarkerIconInfo?.bitmapDescriptor)!;

    _driverCoordinates = coordinates.listen((coordinate) {
      if (!_showDriverMarker) return;

      _markers.removeWhere(
        (element) => element.markerId == MarkerId('driver'),
      );

      _markers.add(
        Marker(
          markerId: MarkerId('driver'),
          position: coordinate,
          icon: driverMarker,
          onTap: _onTapDriverMarker == null
              ? null
              : () => _onTapDriverMarker!(coordinate),
          infoWindow: InfoWindow(
            onTap: _onTapDriverInfoWindow == null
                ? null
                : () => _onTapDriverInfoWindow!(coordinate),
            title: _driverName,
          ),
        ),
      );

      _setState(() {});
    });
  }

  /// Initialize all the parameters.
  void initialize({
    required void setState(void Function() fn),
    required String apiKey,
    required LatLng sourceLatLng,
    required LatLng destinationLatLng,
    void Function(LatLng)? onTapSourceInfoWindow,
    void Function(LatLng)? onTapDestinationInfoWindow,
    void Function(LatLng)? onTapDriverInfoWindow,
    void Function(LatLng)? onTapSourceMarker,
    void Function(LatLng)? onTapDestinationMarker,
    void Function(LatLng)? onTapDriverMarker,
    void Function(String?)? totalTimeCallback,
    void Function(String?)? totalDistanceCallback,
    Stream<LatLng>? driverCoordinatesStream,
    LatLng? defaultCameraLocation,
    double? defaultCameraZoom,
    String? sourceName,
    String? destinationName,
    String? driverName,
    Color? routeColor,
    int? routeWidth,
    MarkerIconInfo? sourceMarkerIconInfo,
    MarkerIconInfo? destinationMarkerIconInfo,
    MarkerIconInfo? driverMarkerIconInfo,
    bool showSourceMarker = true,
    bool showDestinationMarker = true,
    bool showDriverMarker = true,
    bool showPolyline = true,
  }) {
    _defaultCameraLocation = defaultCameraLocation;
    _sourceLatLng = sourceLatLng;
    _destinationLatLng = destinationLatLng;
    _apiKey = apiKey;
    _setState = setState;
    _defaultCameraZoom = defaultCameraZoom;
    _sourceName = sourceName;
    _destinationName = destinationName;
    _driverName = driverName;
    _onTapSourceMarker = onTapSourceMarker;
    _onTapDestinationMarker = onTapDestinationMarker;
    _onTapDriverMarker = onTapDriverMarker;
    _onTapSourceInfoWindow = onTapSourceInfoWindow;
    _onTapDestinationInfoWindow = onTapDestinationInfoWindow;
    _onTapDriverInfoWindow = onTapDriverInfoWindow;
    _totalTimeCallback = totalTimeCallback;
    _totalDistanceCallback = totalDistanceCallback;
    _routeColor = routeColor;
    _routeWidth = routeWidth;
    _sourceMarkerIconInfo = sourceMarkerIconInfo;
    _destinationMarkerIconInfo = destinationMarkerIconInfo;
    _driverMarkerIconInfo = driverMarkerIconInfo;
    _showSourceMarker = showSourceMarker;
    _showDestinationMarker = showDestinationMarker;
    _showDriverMarker = showDriverMarker;
    _showPolyline = showPolyline;

    _setState(() {
      _setSourceDestinationMarkers();

      if (_showPolyline) _buildPolyLines();

      if (driverCoordinatesStream != null)
        _listenToDriverCoordinates(driverCoordinatesStream);
    });
  }

  /// Clear all the fields.
  /// Dispose off controllers.
  void clear() {
    // _apiKey = null;
    // _sourceLatLng = null;
    // _destinationLatLng = null;
    _sourceMarkerIconInfo = null;
    _destinationMarkerIconInfo = null;
    _driverMarkerIconInfo = null;
    _defaultCameraLocation = null;
    _defaultCameraZoom = null;
    _mapController = null;
    _sourceName = null;
    _destinationName = null;
    _driverName = null;
    _onTapSourceMarker = null;
    _onTapDestinationMarker = null;
    _onTapDriverMarker = null;
    _routeColor = null;
    _routeWidth = null;
    totalDistance = null;
    totalTime = null;

    _mapController?.dispose();
    _driverCoordinates?.cancel();
    _markers.clear();
    _polylines.clear();

    _setState(() {});
  }
}
