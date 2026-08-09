# [GoogleMapsWidget](https://pub.dev/packages/google_maps_widget) For Flutter
[![pub package](https://img.shields.io/pub/v/google_maps_widget.svg)](https://pub.dev/packages/google_maps_widget)
[![likes](https://img.shields.io/pub/likes/google_maps_widget)](https://pub.dev/packages/google_maps_widget/score)
[![popularity](https://img.shields.io/pub/popularity/google_maps_widget)](https://pub.dev/packages/google_maps_widget/score)
[![pub points](https://img.shields.io/pub/points/google_maps_widget)](https://pub.dev/packages/google_maps_widget/score)
[![code size](https://img.shields.io/github/languages/code-size/rithik-dev/google_maps_widget)](https://github.com/rithik-dev/google_maps_widget)
[![license MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

---

A widget for flutter developers to easily integrate google maps in their apps. It can be used to make polylines from a source to a destination, and also handle a driver's realtime location (if any) on the map.

---

# 🗂️ Table of Contents

- **[📷 Screenshots](#-screenshots)**
- **[✨ Features](#-features)**
- **[🚀 Getting Started](#-getting-started)**
- **[🛠️ Platform-specific Setup](#%EF%B8%8F-platform-specific-setup)**  
  - [Android](#android)
  - [iOS](#ios)
  - [Web](#web)
- **[🔑 Supplying the API key](#-supplying-the-api-key)**
- **[❓ Usage](#-usage)**  
- **[🚚 Migrating](#-migrating)**
- **[🎯 Sample Usage](#-sample-usage)**
- **[👤 Collaborators](#-collaborators)**

---

# 📷 Screenshots

| With Source InfoWindow | With Rider Icon | With Rider Icon InfoWindow |
|-----------------------------------|-------------------------------------|-------------------------------------|
| <img src="https://user-images.githubusercontent.com/56810766/114386992-8fdadf00-9baf-11eb-84f2-22593024b533.png" height="500"> | <img src="https://user-images.githubusercontent.com/56810766/114386995-90737580-9baf-11eb-8cd7-056444554204.png" height="500"> | <img src="https://user-images.githubusercontent.com/56810766/114386985-8e111b80-9baf-11eb-9bfa-8e4d6d3364f5.png" height="500"> |

---

# ✨ Features

- **Route Creation:** Draw polylines (routes) between two locations by providing their latitude and longitude, using the Google Routes API.
- **Customizable Route Appearance:** Customize the route’s color and width.
- **Real-time Location Tracking:** Offers real-time location tracking for drivers, with an automatically updating marker on the map as the driver's location changes.
- **Marker Customization:** Fully customizable markers.
- **User Interaction Handling:** onTap callbacks for all markers and info windows to handle user interactions easily.
- **Full Google Maps Parameter Support:** Supports passing nearly all parameters from google_maps_flutter for the GoogleMap widget as arguments to the plugin.

---

# 🚀 Getting Started

## Step 1: Get an API Key
Visit [Google Cloud Maps Platform](https://cloud.google.com/maps-platform) and obtain an API key.

## Step 2: Enable Google Maps SDK for Each Platform and the Routes API
* Go to [Google Developers Console](https://console.cloud.google.com), select your project, and open the Google Maps section from the navigation menu. Under APIs, enable Maps SDK for Android, Maps SDK for iOS, and Maps JavaScript API for web under the "Additional APIs" section.

* To enable the Routes API, select "Routes API" in the "Additional APIs" section, then select "ENABLE". This is the service that builds the route. The older Directions API is in Legacy status and cannot be enabled on new Google Cloud projects, so it is not used.

> [!NOTE]
> Make sure the APIs you enabled are under the "Enabled APIs" section.

## Step 3: Refer the Documentation
For more details, see [Getting started with Google Maps Platform](https://developers.google.com/maps/gmp-get-started).

---

# 🛠️ Platform-Specific Setup

## Android
> [!NOTE]
> Refer to the platform specific setup for google maps [here](https://pub.dev/packages/google_maps_flutter#android)

Specify your API key in the application manifest `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...
  <application ...
    <meta-data android:name="com.google.android.geo.API_KEY"
               android:value="PASTE_GOOGLE_MAPS_API_KEY_HERE"/>
```

## iOS
> [!NOTE]
> Refer to the platform specific setup for google maps [here](https://pub.dev/packages/google_maps_flutter#ios)

Specify your API key in the application delegate `ios/Runner/AppDelegate.m`:

```objectivec
#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "GoogleMaps/GoogleMaps.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GMSServices provideAPIKey:@"PASTE_GOOGLE_MAPS_API_KEY_HERE"];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
@end
```

Or in your swift code, specify your API key in the application delegate `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("PASTE_GOOGLE_MAPS_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Web
> [!NOTE]
> Refer to the platform specific setup for google maps [here](https://pub.dev/packages/google_maps_flutter#web)

Modify web/index.html

Get an API Key for Google Maps JavaScript API. Get started [here](https://developers.google.com/maps/documentation/javascript/get-api-key).
Modify the `<head>` tag of your `web/index.html` to load the Google Maps JavaScript API, like so:
```html
<head>

  <!-- // Other stuff -->

  <script src="https://maps.googleapis.com/maps/api/js?key=PASTE_GOOGLE_MAPS_API_KEY_HERE"></script>
</head>
```

---

# 🔑 Supplying the API key

The key is needed in up to three places, because the map tiles and the route
come from different Google services:

| Where | What it is for |
| --- | --- |
| `apiKey:` on `GoogleMapsWidget` | The Routes API call that builds the route |
| `android/app/src/main/AndroidManifest.xml` | Rendering the map on Android |
| `ios/Runner/AppDelegate.swift` | Rendering the map on iOS |

Enable **Maps SDK for Android**, **Maps SDK for iOS** and the **Routes API** on
the key, and enable billing on the project. A key that renders the map but has
no Routes API produces a map with markers and no route.

> [!WARNING]
> An application restricted key (Android package name plus SHA-1, or iOS bundle
> id) **will not work for the route**. Those restrictions are enforced by the
> native Maps SDK, which attaches the app identity; the Routes API call is a
> plain HTTPS request from Dart and carries none. Google rejects it with:
>
> ```
> PERMISSION_DENIED: Requests from this Android client application <empty> are blocked.
> ```
>
> Map tiles keep working, so only the route disappears. Use two keys: one
> application restricted for the SDKs, and one restricted by **API** only
> (Routes API) for `apiKey:`. Cap its quota and set a billing alert, since a key
> without an application restriction is extractable from the app. For
> production, proxy the call through your own backend so the key never ships.

The example app keeps the key out of the repository. Put it in a gitignored
`example/.env`:

```
GOOGLE_MAPS_API_KEY=your_key_here
```

and let Flutter read it:

```sh
flutter run --dart-define-from-file=.env
```

iOS uses the same flag. Because `--dart-define` values arrive base64 encoded in
`DART_DEFINES`, which xcconfig cannot decode, the example adds an **Inject Google
Maps API key** build phase that decodes them into the built `Info.plist`. See
`example/ios/Runner/AppDelegate.swift`.

Without either, all three fall back to the literal
`PASTE_GOOGLE_MAPS_API_KEY_HERE`, which you can replace in place if you prefer.

# ❓ Usage

1. Add [`google_maps_widget`](https://pub.dev/packages/google_maps_widget) as a dependency in your pubspec.yaml file.
```yaml
dependencies:
  flutter:
    sdk: flutter
    
  google_maps_widget:
```

2. You can now add a [`GoogleMapsWidget`](https://github.com/rithik-dev/google_maps_widget/blob/master/lib/src/main_widget.dart) widget to your widget tree and pass all the required parameters to get started. This widget will create a route between the source and the destination LatLng's provided.
```dart
import 'package:google_maps_widget/google_maps_widget.dart';

GoogleMapsWidget(
  apiKey: "PASTE_GOOGLE_MAPS_API_KEY_HERE",
  sourceLatLng: LatLng(40.484000837597925, -3.369978368282318),
  destinationLatLng: LatLng(40.48017307700204, -3.3618026599287987),
),
```

3. One can create a controller and interact with the google maps controller, or update the source and destination LatLng's.
```dart
// can create a controller, and call methods to update source loc,
// destination loc, interact with the google maps controller to
// show/hide markers programmatically etc.
final mapsWidgetController = GlobalKey<GoogleMapsWidgetState>();

// Pass this controller to the "key" param in "GoogleMapsWidget" widget, and then
// call like this to update source or destination, this will also rebuild the route.
mapsWidgetController.currentState!.setSourceLatLng(
  LatLng(
    40.484000837597925 * (Random().nextDouble()),
    -3.369978368282318,
  ),
);

// or, can interact with the google maps controller directly to focus on a marker etc..

final googleMapsCon = await mapsWidgetController.currentState!.getGoogleMapsController();
googleMapsCon.showMarkerInfoWindow(MarkerIconInfo.sourceMarkerId);
```

4. The source and destination can also be updated declaratively, without a controller. Pass new values and rebuild, and the markers and the route follow.
```dart
GoogleMapsWidget(
  apiKey: "PASTE_GOOGLE_MAPS_API_KEY_HERE",
  // changing either of these and rebuilding recalculates the route
  sourceLatLng: _sourceLatLng,
  destinationLatLng: _destinationLatLng,
),
```

5. Pass a Google Maps style JSON to `style` to theme the map, for example to give it a dark mode. Generate one at [mapstyle.withgoogle.com](https://mapstyle.withgoogle.com).
```dart
GoogleMapsWidget(
  apiKey: "PASTE_GOOGLE_MAPS_API_KEY_HERE",
  sourceLatLng: ...,
  destinationLatLng: ...,
  style: Theme.of(context).brightness == Brightness.dark ? darkMapStyleJson : null,
),
```

6. Use `onError` to find out why a route failed to load. A key without the Routes API enabled, or a project without billing, otherwise just looks like a map with no route on it.
```dart
GoogleMapsWidget(
  apiKey: "PASTE_GOOGLE_MAPS_API_KEY_HERE",
  sourceLatLng: ...,
  destinationLatLng: ...,
  onError: (error, stackTrace) {
    // error is a RoutesApiException carrying the API's own message
    debugPrint('Could not load route: $error');
  },
),
```

---

# 🚚 Migrating

Upgrading from 1.0.x? See the [migration guide](MIGRATION.md). The short version: 2.0.0 needs Flutter 3.38.0 or newer, and `sourceLatLng`/`destinationLatLng` now update when you rebuild.

---

# 🎯 Sample Usage

See the [example](https://github.com/rithik-dev/google_maps_widget/blob/master/example) app for a complete app. Learn how to setup the example app for testing [here](https://github.com/rithik-dev/google_maps_widget/blob/master/example/README.md).

Check out the full API reference of the widget [here](https://pub.dev/documentation/google_maps_widget/latest/google_maps_widget/GoogleMapsWidget-class.html).

```dart
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
```

---

# 👤 Collaborators


| Name | GitHub | Linkedin |
|-----------------------------------|-------------------------------------|-------------------------------------|
| Rithik Bhandari | [github/rithik-dev](https://github.com/rithik-dev) | [linkedin/rithik-bhandari](https://www.linkedin.com/in/rithik-bhandari) |
