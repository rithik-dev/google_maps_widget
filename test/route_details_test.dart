import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_widget/src/models/route_details.dart';

/// A structurally realistic `computeRoutes` response body.
Map<String, Object?> responseBody({
  Object? distanceMeters = 1204,
  Object? duration = '245s',
  Map<String, Object?>? viewport,
  Map<String, Object?>? polyline,
}) {
  return <String, Object?>{
    'routes': [
      <String, Object?>{
        'distanceMeters': distanceMeters,
        'duration': duration,
        'polyline':
            polyline ??
            <String, Object?>{
              'encodedPolyline': '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
            },
        'viewport':
            viewport ??
            <String, Object?>{
              'low': {'latitude': 40.4, 'longitude': -3.4},
              'high': {'latitude': 40.5, 'longitude': -3.3},
            },
      },
    ],
  };
}

void main() {
  group('decodePolyline', () {
    test('decodes the reference polyline from the Google encoding docs', () {
      final points = RouteDetails.decodePolyline('_p~iF~ps|U_ulLnnqC_mqNvxq`@');

      expect(points, hasLength(3));
      expect(points[0].latitude, closeTo(38.5, 1e-6));
      expect(points[0].longitude, closeTo(-120.2, 1e-6));
      expect(points[2].latitude, closeTo(43.252, 1e-6));
      expect(points[2].longitude, closeTo(-126.453, 1e-6));
    });

    test('returns an empty list for an empty string', () {
      expect(RouteDetails.decodePolyline(''), isEmpty);
    });
  });

  group('parseDuration', () {
    test('parses whole seconds with the protobuf trailing s', () {
      expect(RouteDetails.parseDuration('245s'), const Duration(seconds: 245));
    });

    test('parses a fractional duration', () {
      expect(
        RouteDetails.parseDuration('165.5s'),
        const Duration(milliseconds: 165500),
      );
    });

    test('tolerates a missing trailing s', () {
      expect(RouteDetails.parseDuration('90'), const Duration(seconds: 90));
    });

    test('falls back to zero for null, empty and unparseable values', () {
      expect(RouteDetails.parseDuration(null), Duration.zero);
      expect(RouteDetails.parseDuration(''), Duration.zero);
      expect(RouteDetails.parseDuration('not-a-duration'), Duration.zero);
      expect(RouteDetails.parseDuration(42), Duration.zero);
    });
  });

  group('RouteDetails.fromMap', () {
    test('parses viewport, distance, duration and points', () {
      final route = RouteDetails.fromMap(responseBody());

      // viewport.low is the south west corner, viewport.high the north east.
      expect(route.bounds.southwest.latitude, 40.4);
      expect(route.bounds.southwest.longitude, -3.4);
      expect(route.bounds.northeast.latitude, 40.5);
      expect(route.bounds.northeast.longitude, -3.3);
      expect(route.distance, 1204);
      expect(route.duration, const Duration(seconds: 245));
      expect(route.polylinePoints, hasLength(3));
    });

    // JSON numbers without a fractional part decode as int, which used to
    // throw a cast error on routes landing on a whole degree.
    test('accepts integer viewport coordinates', () {
      final route = RouteDetails.fromMap(
        responseBody(
          viewport: <String, Object?>{
            'low': {'latitude': 40, 'longitude': -4},
            'high': {'latitude': 41, 'longitude': -3},
          },
        ),
      );

      expect(route.bounds.southwest.latitude, 40.0);
      expect(route.bounds.northeast.longitude, -3.0);
    });

    test('falls back to zero distance when the field is absent', () {
      final route = RouteDetails.fromMap(responseBody(distanceMeters: null));

      expect(route.distance, 0);
    });

    test('tolerates a missing polyline', () {
      final route = RouteDetails.fromMap(
        responseBody(polyline: <String, Object?>{}),
      );

      expect(route.polylinePoints, isEmpty);
    });

    test('tolerates a missing viewport', () {
      final route = RouteDetails.fromMap(
        responseBody(viewport: <String, Object?>{}),
      );

      expect(route.bounds.southwest.latitude, 0.0);
      expect(route.bounds.northeast.latitude, 0.0);
    });
  });

  group('RoutesApiException', () {
    test('includes the API status when there is one', () {
      const exception = RoutesApiException(
        'Routes API has not been used in project 123 before or it is disabled.',
        status: 'PERMISSION_DENIED',
      );

      expect(
        exception.toString(),
        'RoutesApiException(PERMISSION_DENIED): '
        'Routes API has not been used in project 123 before or it is disabled.',
      );
    });

    test('omits the status when there is none', () {
      const exception = RoutesApiException('No network.');

      expect(exception.toString(), 'RoutesApiException: No network.');
    });
  });
}
