import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsService {
  LatLng _sourceLatLng;
  LatLng _destinationLatLng;

  GoogleMapController _mapController;

  void setController(GoogleMapController _controller) {
    _mapController = _controller;
  }

  static String _apiKey;
  StreamSubscription<LatLng> _driverCoordinates;
  void Function(Function() fn) _setState;

  LatLng get defaultCameraLocation => _defaultCameraLocation ?? _sourceLatLng;

  double get defaultCameraZoom => _defaultCameraZoom;

  double _defaultCameraZoom;
  LatLng _defaultCameraLocation;
  Set<Marker> _markers = {};

  Set<Marker> get markers => _markers;
  Set<Polyline> _polyLines = {};

  Set<Polyline> get polyLines => _polyLines;
  String _sourceName;
  String _destinationName;
  String _driverName;
  VoidCallback _onTapSourceMarker;
  VoidCallback _onTapDestinationMarker;
  void Function(LatLng coordinate) _onTapDriverMarker;

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  //   Future<BitmapDescriptor> _getMarkerFromMaterialIcon(Icon icon) async {
  //   final _iconData = icon.icon;
  //   final _pictureRecorder = PictureRecorder();
  //   final _canvas = Canvas(_pictureRecorder);
  //   final _textPainter = TextPainter(textDirection: TextDirection.ltr);
  //   final _iconStr = String.fromCharCode(_iconData.codePoint);
  //
  //   _textPainter.text = TextSpan(
  //       text: _iconStr,
  //       style: TextStyle(
  //         letterSpacing: 0.0,
  //         fontSize: 48.0,
  //         fontFamily: _iconData.fontFamily,
  //         color: Colors.red,
  //       ));
  //   _textPainter.layout();
  //   _textPainter.paint(_canvas, Offset(0.0, 0.0));
  //
  //   final _picture = _pictureRecorder.endRecording();
  //   final _image = await _picture.toImage(48, 48);
  //   final _bytes = await _image.toByteData(format: ImageByteFormat.png);
  //
  //   return BitmapDescriptor.fromBytes(_bytes.buffer.asUint8List());
  // }

  void _setSourceDestinationMarkers() async {
    final sourceMarker = await _getBytesFromAsset(
      "assets/images/restaurant-marker-icon.png",
      150,
    );

    final destinationMarker = await _getBytesFromAsset(
      "assets/images/house-marker-icon.png",
      150,
    );

    // setting source and destination markers
    _markers.addAll([
      Marker(
        markerId: MarkerId("source"),
        position: _sourceLatLng,
        icon: BitmapDescriptor.fromBytes(sourceMarker),
        infoWindow: InfoWindow(
          onTap: _onTapSourceMarker,
          title: _sourceName,
        ),
      ),
      Marker(
        markerId: MarkerId("destination"),
        position: _destinationLatLng,
        icon: BitmapDescriptor.fromBytes(destinationMarker),
        infoWindow: InfoWindow(
          onTap: _onTapDestinationMarker,
          title: _destinationName,
        ),
      )
    ]);

    _setState(() {});
  }

  Color _routeColor;
  int _routeWidth;

  String totalDistance;
  String totalTime;

  Future<void> _buildPolyLines() async {
    // final result = await DirectionsRepository(
    //   dio: Dio()..interceptors.add(PrettyDioLogger()),
    // ).getDirections(
    //   origin: _sourceLatLng,
    //   destination: _destinationLatLng,
    //   apiKey: _apiKey,
    // );

    final result = await _Direction.getDirections(
      origin: _sourceLatLng,
      destination: _destinationLatLng,
    );

    final _polylineCoordinates = <LatLng>[];

    if (result != null && result.polylinePoints.isNotEmpty) {
      _polylineCoordinates.addAll(result.polylinePoints);
    }

    final polyline = Polyline(
      polylineId: PolylineId("poly_line"),
      color: _routeColor,
      width: _routeWidth,
      points: _polylineCoordinates,
    );

    _polyLines.add(polyline);

    // setting map such as both source and
    // destinations markers can be seen
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(result?.bounds, 32),
    );

    totalDistance = result?.totalDistance;
    totalTime = result?.totalDuration;

    _setState(() {});
  }

  /// This function takes in a [Stream] of [coordinates]
  /// to show driver's location in realtime.
  Future<void> _listenToDriverCoordinates(Stream<LatLng> coordinates) async {
    final markerBytes = await _getBytesFromAsset(
      "assets/images/driver-marker-icon.png",
      150,
    );

    _driverCoordinates = coordinates.listen((coordinate) {
      _markers.removeWhere(
            (element) => element.markerId == MarkerId('driver'),
      );

      _markers.add(
        Marker(
          markerId: MarkerId('driver'),
          position: coordinate,
          icon: BitmapDescriptor.fromBytes(markerBytes),
          infoWindow: InfoWindow(
            onTap: () => _onTapDriverMarker(coordinate),
            title: _driverName,
          ),
        ),
      );

      _setState(() {});
    });
  }

  void initialize({
    @required void setState(void Function() fn),
    @required String apiKey,
    @required LatLng sourceLatLng,
    @required LatLng destinationLatLng,
    VoidCallback onTapSourceMarker,
    VoidCallback onTapDestinationMarker,
    void Function(LatLng) onTapDriverMarker,
    Stream<LatLng> driverCoordinatesStream,
    LatLng defaultCameraLocation,
    double defaultCameraZoom,
    String sourceName,
    String destinationName,
    String driverName,
    Color routeColor,
    int routeWidth,
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
    _routeColor = routeColor;
    _routeWidth = routeWidth;

    _setState(() {
      _setSourceDestinationMarkers();
      _buildPolyLines();

      if (driverCoordinatesStream != null)
        _listenToDriverCoordinates(driverCoordinatesStream);
    });
  }

  void clear() {
    _sourceLatLng = null;
    _destinationLatLng = null;
    _defaultCameraLocation = null;
    _defaultCameraZoom = null;
    _apiKey = null;
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

class _Direction {
  final LatLngBounds bounds;
  final List<LatLng> polylinePoints;
  final String totalDistance;
  final String totalDuration;

  const _Direction._({
    @required this.bounds,
    @required this.polylinePoints,
    @required this.totalDistance,
    @required this.totalDuration,
  });

  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';

  static Future<_Direction> getDirections({
    @required LatLng origin,
    @required LatLng destination,
  }) async {
    final response = await Dio().get(
      _baseUrl,
      queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key': MapsService._apiKey,
      },
    );

    if (response.statusCode == 200) return _Direction._fromMap(response.data);
    return null;
  }

  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> _polyLines = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dLat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dLng;
      final p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      _polyLines.add(p);
    }
    return _polyLines;
  }

  factory _Direction._fromMap(Map<String, dynamic> map) {
    // Check if route is not available
    if ((map['routes'] as List).isEmpty) return null;

    // Get route information
    final data = Map<String, dynamic>.from(map['routes'][0]);

    // Bounds
    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];
    final bounds = LatLngBounds(
      northeast: LatLng(northeast['lat'], northeast['lng']),
      southwest: LatLng(southwest['lat'], southwest['lng']),
    );

    // Distance & Duration
    String distance = '';
    String duration = '';
    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      distance = leg['distance']['text'];
      duration = leg['duration']['text'];
    }

    return _Direction._(
      bounds: bounds,
      polylinePoints: _decodePolyline(data['overview_polyline']['points']),
      totalDistance: distance,
      totalDuration: duration,
    );
  }
}
