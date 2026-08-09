import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_widget/google_maps_widget.dart';

void main() {
  runApp(const MyApp());
}

/// The Google Maps API key.
///
/// Pass it with `--dart-define-from-file=.env`, or replace the fallback below.
/// See README.md.
const _googleMapsApiKey = String.fromEnvironment(
  'GOOGLE_MAPS_API_KEY',
  defaultValue: 'PASTE_GOOGLE_MAPS_API_KEY_HERE',
);

/// A trimmed down dark map style. Generate your own at
/// https://mapstyle.withgoogle.com and paste the JSON here.
const _darkMapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#242f3e"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#746855"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#242f3e"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#38414e"}]},
  {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#212a37"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#17263c"}]}
]
''';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDark) {
    setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: MapDemo(
        isDark: _themeMode == ThemeMode.dark,
        onThemeChanged: _toggleTheme,
      ),
    );
  }
}

class MapDemo extends StatefulWidget {
  const MapDemo({super.key, required this.isDark, required this.onThemeChanged});

  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<MapDemo> createState() => _MapDemoState();
}

class _MapDemoState extends State<MapDemo> {
  // Can create a controller, and call methods to update source loc,
  // destination loc, interact with the google maps controller to
  // show/hide markers programmatically etc.
  final mapsWidgetController = GlobalKey<GoogleMapsWidgetState>();

  // Source is held in state so it can also be changed declaratively, by
  // rebuilding with a new value, instead of going through the controller.
  LatLng _sourceLatLng = const LatLng(40.484000837597925, -3.369978368282318);

  // mock stream
  final Stream<LatLng> _driverCoordinates = Stream<LatLng>.periodic(
    const Duration(milliseconds: 500),
    (i) => LatLng(
      40.47747872288886 + i / 10000,
      -3.368043154478073 - i / 10000,
    ),
  ).asBroadcastStream();

  final ValueNotifier<String?> _error = ValueNotifier<String?>(null);
  final ValueNotifier<Duration?> _duration = ValueNotifier<Duration?>(null);
  final ValueNotifier<int?> _distanceMetres = ValueNotifier<int?>(null);

  @override
  void dispose() {
    _error.dispose();
    _duration.dispose();
    _distanceMetres.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            ValueListenableBuilder<String?>(
              valueListenable: _error,
              builder: (context, error, _) {
                if (error == null) return const SizedBox.shrink();

                return Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.errorContainer,
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    error,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: GoogleMapsWidget(
                apiKey: _googleMapsApiKey,
                key: mapsWidgetController,
                sourceLatLng: _sourceLatLng,
                destinationLatLng: const LatLng(
                  40.48017307700204,
                  -3.3618026599287987,
                ),

                ///////////////////////////////////////////////////////
                //////////////    OPTIONAL PARAMETERS    //////////////
                ///////////////////////////////////////////////////////

                // Surfaces why a route failed to load. An API key without
                // the Routes API enabled is the usual cause, and it
                // otherwise looks like the map is simply broken.
                onError: (error, _) => _error.value = error.toString(),
                // The app decides which style to show. Anything can drive it:
                // the theme, a user preference, time of day. Passing a new
                // value restyles the live map.
                style: widget.isDark ? _darkMapStyle : null,
                routeWidth: 2,
                sourceMarkerIconInfo: const MarkerIconInfo(
                  infoWindowTitle: "This is source name",
                  assetPath: "assets/images/house-marker-icon.png",
                  assetMarkerSize: Size.square(50),
                ),
                destinationMarkerIconInfo: const MarkerIconInfo(
                  assetPath: "assets/images/restaurant-marker-icon.png",
                  assetMarkerSize: Size.square(50),
                ),
                driverMarkerIconInfo: MarkerIconInfo(
                  infoWindowTitle: "Alex",
                  assetPath: "assets/images/driver-marker-icon.png",
                  onTapMarker: (currentLocation) {
                    debugPrint("Driver is currently at $currentLocation");
                  },
                  assetMarkerSize: const Size.square(50),
                  rotation: 90,
                ),
                onPolylineUpdate: (p) {
                  debugPrint("Polyline updated: ${p.points}");
                },
                updatePolylinesOnDriverLocUpdate: true,
                driverCoordinatesStream: _driverCoordinates,
                totalTimeCallback: (duration) => _duration.value = duration,
                totalDistanceCallback: (metres) => _distanceMetres.value = metres,
              ),
            ),
            ListenableBuilder(
              listenable: Listenable.merge([_duration, _distanceMetres]),
              builder: (context, _) => _RouteSummary(
                duration: _duration.value,
                distanceMetres: _distanceMetres.value,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                spacing: 10,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      // Declarative update: rebuild with a new sourceLatLng
                      // and the marker and route follow.
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _sourceLatLng = LatLng(
                                40.47747872288886 + Random().nextInt(1000) / 10000,
                                -3.369978368282318,
                              );
                            });
                          },
                          child: const Text('Update source'),
                        ),
                      ),
                      // Imperative update through the state, for cases where
                      // you do not want to rebuild.
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final GoogleMapsWidgetState? state = mapsWidgetController.currentState;
                            if (state == null) return;

                            final GoogleMapController googleMapsCon = await state.getGoogleMapsController();
                            await googleMapsCon.showMarkerInfoWindow(
                              MarkerIconInfo.sourceMarkerId,
                            );
                          },
                          child: const Text('Show source info'),
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Dark theme'),
                    value: widget.isDark,
                    onChanged: widget.onThemeChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the total distance and time for the current route.
///
/// The package hands these over as an [int] of metres and a [Duration], so
/// turning them into text is the app's job. Use `intl` in a real app; the
/// formatting below is deliberately minimal.
class _RouteSummary extends StatelessWidget {
  const _RouteSummary({required this.duration, required this.distanceMetres});

  final Duration? duration;
  final int? distanceMetres;

  static String _formatDistance(int metres) {
    if (metres < 1000) return '$metres m';
    return '${(metres / 1000).toStringAsFixed(1)} km';
  }

  static String _formatDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '$hours h $minutes min';
    if (duration.inMinutes > 0) return '$minutes min';
    return '${duration.inSeconds} s';
  }

  @override
  Widget build(BuildContext context) {
    final Duration? duration = this.duration;
    final int? distanceMetres = this.distanceMetres;
    final ThemeData theme = Theme.of(context);

    // Nothing to show until the first route comes back.
    if (duration == null && distanceMetres == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (distanceMetres != null)
            _Metric(
              icon: Icons.straighten,
              label: 'Distance',
              value: _formatDistance(distanceMetres),
            ),
          if (duration != null)
            _Metric(
              icon: Icons.schedule,
              label: 'Time',
              value: _formatDuration(duration),
            ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: theme.textTheme.labelSmall),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
