import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_widget/src/models/direction.dart';
import 'package:google_maps_widget/src/models/marker_info.dart';
import 'package:google_maps_widget/src/utils/constants.dart';

class MapsService {
  late LatLng _sourceLatLng;
  late LatLng _destinationLatLng;

  GoogleMapController? _mapController;

  void setController(GoogleMapController _controller) {
    _mapController = _controller;
  }

  static late String _apiKey;

  static String get apiKey => _apiKey;
  StreamSubscription<LatLng>? _driverCoordinates;
  late void Function(Function() fn) _setState;

  LatLng get defaultCameraLocation => _defaultCameraLocation ?? _sourceLatLng;

  double get defaultCameraZoom =>
      _defaultCameraZoom ?? Constants.DEFAULT_CAMERA_ZOOM;

  double? _defaultCameraZoom;
  LatLng? _defaultCameraLocation;
  Set<Marker> _markers = {};

  Set<Marker> get markers => _markers;
  Set<Polyline> _polyLines = {};

  Set<Polyline> get polyLines => _polyLines;
  String? _sourceName;
  String? _destinationName;
  String? _driverName;
  void Function(LatLng)? _onTapSourceMarker;
  void Function(LatLng)? _onTapDestinationMarker;
  void Function(LatLng)? _onTapDriverMarker;
  void Function(LatLng)? _onTapSourceInfoWindow;
  void Function(LatLng)? _onTapDestinationInfoWindow;
  void Function(LatLng)? _onTapDriverInfoWindow;

  void _setSourceDestinationMarkers() async {
    // setting source and destination markers
    _markers.addAll([
      Marker(
        markerId: MarkerId("source"),
        position: _sourceLatLng,
        icon: (await _sourceMarkerIconInfo?.bitmapDescriptor) ??
            BitmapDescriptor.defaultMarker,
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
      Marker(
        markerId: MarkerId("destination"),
        position: _destinationLatLng,
        icon: (await _destinationMarkerIconInfo?.bitmapDescriptor) ??
            BitmapDescriptor.defaultMarker,
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

  Color? _routeColor;
  int? _routeWidth;

  String? totalDistance;
  String? totalTime;

  Future<void> _buildPolyLines() async {
    // final result = await DirectionsRepository(
    //   dio: Dio()..interceptors.add(PrettyDioLogger()),
    // ).getDirections(
    //   origin: _sourceLatLng,
    //   destination: _destinationLatLng,
    //   apiKey: _apiKey,
    // );

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

    _polyLines.add(polyline);

    // setting map such as both source and
    // destinations markers can be seen
    if (result != null) {
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(result.bounds, 32),
      );

      totalDistance = result.totalDistance;
      totalTime = result.totalDuration;
    }

    _setState(() {});
  }

  /// This function takes in a [Stream] of [coordinates]
  /// to show driver's location in realtime.
  Future<void> _listenToDriverCoordinates(Stream<LatLng> coordinates) async {
    final driverMarker = (await _driverMarkerIconInfo?.bitmapDescriptor) ??
        BitmapDescriptor.defaultMarker;

    _driverCoordinates = coordinates.listen((coordinate) {
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

  MarkerIconInfo? _sourceMarkerIconInfo;
  MarkerIconInfo? _destinationMarkerIconInfo;
  MarkerIconInfo? _driverMarkerIconInfo;

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
    _routeColor = routeColor;
    _routeWidth = routeWidth;
    _sourceMarkerIconInfo = sourceMarkerIconInfo;
    _destinationMarkerIconInfo = destinationMarkerIconInfo;
    _driverMarkerIconInfo = driverMarkerIconInfo;

    _setState(() {
      _setSourceDestinationMarkers();
      _buildPolyLines();

      if (driverCoordinatesStream != null)
        _listenToDriverCoordinates(driverCoordinatesStream);
    });
  }

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
    _polyLines.clear();

    _setState(() {});
  }
}
