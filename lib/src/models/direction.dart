import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_widget/src/services/maps_service.dart';

/// A class containing information required by [GoogleMap] to
/// draw polylines on the map widget.
class Direction {
  const Direction._({
    required this.bounds,
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
  });

  /// A latitude/longitude aligned rectangle.
  /// Used to animate and position the camera in such a
  /// way that both the source and the destinations markers are visible.
  final LatLngBounds bounds;

  /// A [List] of [LatLng] objects required by [GoogleMap]
  /// to display the route.
  final List<LatLng> polylinePoints;

  /// The total distance between the source and the destination.
  final String totalDistance;

  /// The total time between the source and the destination.
  final String totalDuration;

  /// Google Maps API base url.
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';

  /// Receives [origin] and [destination] coordinates and calls
  /// the Google Maps API.
  static Future<Direction?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final response = await Dio().get(
      _baseUrl,
      queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key': MapsService.apiKey,
      },
    );

    if (response.statusCode == 200) {
      // no routes
      if ((response.data['routes'] as List).isEmpty) {
        return null;
      } else {
        return Direction._fromMap(response.data);
      }
    } else {
      return null;
    }
  }

  /// Takes in an [encoded] polyline string from the
  /// api response and parses the given string in a [List] of [LatLng].
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

  /// Private constructor for [Direction] which receives a map from the
  /// api request and maps the response to the class variables.
  factory Direction._fromMap(Map<String, dynamic> map) {
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

    return Direction._(
      bounds: bounds,
      polylinePoints: _decodePolyline(data['overview_polyline']['points']),
      totalDistance: distance,
      totalDuration: duration,
    );
  }
}
