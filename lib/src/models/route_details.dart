import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_widget/src/utils/constants.dart';

/// Thrown when the Google Routes API could not be reached, or replied with
/// something other than a usable route.
///
/// Unlike the legacy Directions API, which answered HTTP 200 and put the
/// failure in the body, the Routes API returns a real HTTP error code together
/// with an `error` object, so both are surfaced here.
class RoutesApiException implements Exception {
  const RoutesApiException(this.message, {this.status});

  /// A human readable description of what went wrong.
  final String message;

  /// The `error.status` returned by the Routes API, when the request reached
  /// Google at all. e.g. `PERMISSION_DENIED`, `INVALID_ARGUMENT`.
  final String? status;

  @override
  String toString() => status == null ? 'RoutesApiException: $message' : 'RoutesApiException($status): $message';
}

/// A computed route, containing everything [GoogleMap] needs to draw it.
class RouteDetails {
  const RouteDetails._({
    required this.bounds,
    required this.polylinePoints,
    required this.distance,
    required this.duration,
  });

  /// A latitude/longitude aligned rectangle covering the whole route.
  ///
  /// Used to animate and position the camera so that both the source and the
  /// destination markers are visible.
  final LatLngBounds bounds;

  /// The points of the route, ready to hand to a [Polyline].
  final List<LatLng> polylinePoints;

  /// The length of the route, in metres.
  ///
  /// The Routes API reports distance numerically only. Format it for display
  /// yourself, with `intl` or otherwise, so it matches your app's locale.
  final int distance;

  /// How long the route is expected to take.
  final Duration duration;

  /// Routes API endpoint. The legacy Directions API is in Legacy status and
  /// cannot be enabled on new Google Cloud projects, so it is not used.
  static const String _baseUrl = 'https://routes.googleapis.com/directions/v2:computeRoutes';

  /// Only the fields below are returned. The Routes API requires a field mask
  /// and rejects the request without one; asking for less also costs less.
  static const String _fieldMask =
      'routes.distanceMeters,routes.duration,'
      'routes.polyline.encodedPolyline,routes.viewport';

  /// Reused across requests so the connection pool is shared, rather than
  /// rebuilt on every driver location update. Timeouts are applied per request
  /// so that callers can configure them without racing on shared state.
  static final Dio _dio = Dio(
    BaseOptions(
      // Non-2xx responses are handled below instead of being thrown by dio,
      // so the API's own error body can be read and reported.
      validateStatus: (_) => true,
    ),
  );

  /// Asks the Routes API for a route from [origin] to [destination].
  ///
  /// Returns null when Google finds no route between the two points, and
  /// throws a [RoutesApiException] when the request itself failed, so the
  /// caller can tell "nowhere to drive" apart from "your API key is wrong".
  static Future<RouteDetails?> getRoute({
    required String googleMapsApiKey,
    required LatLng origin,
    required LatLng destination,
    Duration connectTimeout = Constants.kRoutesConnectTimeout,
    Duration receiveTimeout = Constants.kRoutesReceiveTimeout,
  }) async {
    late final Response<Object?> response;

    try {
      response = await _dio.post<Object?>(
        _baseUrl,
        data: <String, Object?>{
          'origin': _waypoint(origin),
          'destination': _waypoint(destination),
          'travelMode': 'DRIVE',
          'polylineEncoding': 'ENCODED_POLYLINE',
        },
        options: Options(
          connectTimeout: connectTimeout,
          receiveTimeout: receiveTimeout,
          headers: <String, Object?>{
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': googleMapsApiKey,
            'X-Goog-FieldMask': _fieldMask,
          },
        ),
      );
    } on DioException catch (e) {
      throw RoutesApiException(
        'Could not reach the Google Routes API: ${e.message ?? e.type.name}',
      );
    }

    final Object? data = response.data;

    if (response.statusCode != 200) {
      throw _errorFrom(data, response.statusCode);
    }

    if (data is! Map<String, Object?>) {
      throw const RoutesApiException(
        'The Google Routes API returned an unexpected response body.',
      );
    }

    // A request that succeeds but finds nothing comes back as an empty object,
    // which is a legitimate "no route", not a failure.
    final Object? routes = data['routes'];
    if (routes is! List<Object?> || routes.isEmpty) return null;

    return RouteDetails.fromMap(data);
  }

  /// Builds the error thrown for a non-200 response.
  static RoutesApiException _errorFrom(Object? data, int? statusCode) {
    if (data is Map<String, Object?>) {
      final Object? error = data['error'];
      if (error is Map<String, Object?>) {
        final String? message = error['message'] as String?;
        final String? status = error['status'] as String?;
        if (message != null) {
          return RoutesApiException(message, status: status);
        }
      }
    }
    return RoutesApiException(
      'The Google Routes API responded with HTTP $statusCode.',
    );
  }

  static Map<String, Object?> _waypoint(LatLng point) => <String, Object?>{
    'location': <String, Object?>{
      'latLng': <String, Object?>{
        'latitude': point.latitude,
        'longitude': point.longitude,
      },
    },
  };

  /// Decodes an encoded polyline string into a list of [LatLng].
  ///
  /// The Routes API uses the same encoding as the legacy Directions API when
  /// `polylineEncoding` is `ENCODED_POLYLINE`.
  @visibleForTesting
  static List<LatLng> decodePolyline(String encoded) {
    List<LatLng> polyLines = [];
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
      polyLines.add(p);
    }
    return polyLines;
  }

  /// JSON numbers arrive as [int] when they have no fractional part, so
  /// coordinates cannot be cast to [double] directly.
  static double _toDouble(Object? value) => value is num ? value.toDouble() : 0.0;

  /// Reads a nested JSON object, or null when absent or not an object.
  static Map<String, Object?>? _object(Map<String, Object?> parent, String key) {
    final Object? value = parent[key];
    return value is Map<String, Object?> ? value : null;
  }

  /// Parses a protobuf duration, which is seconds with a trailing `s` and an
  /// optional fractional part, such as `165s` or `165.5s`.
  @visibleForTesting
  static Duration parseDuration(Object? value) {
    if (value is! String || value.isEmpty) return Duration.zero;
    final String seconds = value.endsWith('s') ? value.substring(0, value.length - 1) : value;
    final double? parsed = double.tryParse(seconds);
    if (parsed == null) return Duration.zero;
    return Duration(milliseconds: (parsed * 1000).round());
  }

  /// Builds a [RouteDetails] from a full `computeRoutes` response body.
  @visibleForTesting
  factory RouteDetails.fromMap(Map<String, Object?> map) {
    final List<Object?> routes = map['routes'] as List<Object?>;
    final Map<String, Object?> route = routes.first as Map<String, Object?>;

    // The viewport is expressed as two opposite corners rather than as named
    // compass points: low is the south west corner, high the north east.
    final Map<String, Object?> viewport = _object(route, 'viewport') ?? const {};
    final Map<String, Object?> low = _object(viewport, 'low') ?? const {};
    final Map<String, Object?> high = _object(viewport, 'high') ?? const {};

    final LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        _toDouble(low['latitude']),
        _toDouble(low['longitude']),
      ),
      northeast: LatLng(
        _toDouble(high['latitude']),
        _toDouble(high['longitude']),
      ),
    );

    final Map<String, Object?> polyline = _object(route, 'polyline') ?? const {};

    return RouteDetails._(
      bounds: bounds,
      polylinePoints: decodePolyline(
        polyline['encodedPolyline'] as String? ?? '',
      ),
      distance: (route['distanceMeters'] as num?)?.toInt() ?? 0,
      duration: parseDuration(route['duration']),
    );
  }
}

/// Logs [error] to the console in debug builds only.
///
/// Failures here are non-fatal (the map still renders without a route), so
/// they must not crash the app, but swallowing them silently is what makes a
/// blank map impossible to diagnose.
void debugLogRouteError(Object error, StackTrace stackTrace) {
  assert(() {
    debugPrint('[google_maps_widget] $error');
    return true;
  }());
}
