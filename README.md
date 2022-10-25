# [GoogleMapsWidget](https://pub.dev/packages/google_maps_widget) For Flutter
[![pub package](https://img.shields.io/pub/v/google_maps_widget.svg)](https://pub.dev/packages/google_maps_widget)
[![likes](https://badges.bar/google_maps_widget/likes)](https://pub.dev/packages/google_maps_widget/score)
[![popularity](https://badges.bar/google_maps_widget/popularity)](https://pub.dev/packages/google_maps_widget/score)
[![pub points](https://badges.bar/google_maps_widget/pub%20points)](https://pub.dev/packages/google_maps_widget/score)

*A widget for flutter developers to easily integrate google maps in their apps. It can be used to make polylines from a source to a destination, and also handle a driver's realtime location (if any) on the map.*

## Features
  * Make polylines (route) between two locations by providing the latitude and longitude for both the locations.
  * The route is customizable in terms of color and width.
  * The plugin also offers realtime location tracking for a driver(if any) and shows a marker on the map which updates everytimes the driver's location changes.
  * All the markers are customizable.
  * onTap callbacks are implemented for all the markers and their info windows to easily handle user interaction.
  * Almost all the parameters defined in [`google_maps_flutter`](https://pub.dev/packages/google_maps_flutter) for the [`GoogleMap`](https://github.com/flutter/plugins/blob/master/packages/google_maps_flutter/google_maps_flutter/lib/src/google_map.dart) widget can be passed as arguments to the widget.

### Screenshots
<img src="https://user-images.githubusercontent.com/56810766/114386990-8f424880-9baf-11eb-94bb-512abfdee36c.png" height=600/>&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/56810766/114386992-8fdadf00-9baf-11eb-84f2-22593024b533.png" height=600/>&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/56810766/114386995-90737580-9baf-11eb-8cd7-056444554204.png" height=600/>&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/56810766/114386985-8e111b80-9baf-11eb-9bfa-8e4d6d3364f5.png" height=600/>


## Getting Started

* Get an API key at <https://cloud.google.com/maps-platform/>.

* Enable Google Map SDK for each platform.
  * Go to [Google Developers Console](https://console.cloud.google.com/).
  * Choose the project that you want to enable Google Maps on.
  * Select the navigation menu and then select "Google Maps".
  * Select "APIs" under the Google Maps menu.
  * To enable Google Maps for Android, select "Maps SDK for Android" in the "Additional APIs" section, then select "ENABLE".
  * To enable Google Maps for iOS, select "Maps SDK for iOS" in the "Additional APIs" section, then select "ENABLE".
  * To enable Directions API, select "Directions API" in the "Additional APIs" section, then select "ENABLE".
  * Make sure the APIs you enabled are under the "Enabled APIs" section.

For more details, see [Getting started with Google Maps Platform](https://developers.google.com/maps/gmp-get-started).

### Android

Specify your API key in the application manifest `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...
  <application ...
    <meta-data android:name="com.google.android.geo.API_KEY"
               android:value="YOUR KEY HERE"/>
```

### iOS

Specify your API key in the application delegate `ios/Runner/AppDelegate.m`:

```objectivec
#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "GoogleMaps/GoogleMaps.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GMSServices provideAPIKey:@"YOUR KEY HERE"];
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
    GMSServices.provideAPIKey("YOUR KEY HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```
### Web (This package is a wrapper around the `google_maps_flutter` package. If that package supports web, this package will also support web.)

Modify web/index.html

Get an API Key for Google Maps JavaScript API. Get started [here](https://developers.google.com/maps/documentation/javascript/get-api-key).
Modify the `<head>` tag of your `web/index.html` to load the Google Maps JavaScript API, like so:
```html
<head>

  <!-- // Other stuff -->

  <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_KEY_HERE"></script>
</head>
```

## Usage

To use this plugin, add [`google_maps_widget`](https://pub.dev/packages/google_maps_widget) as a dependency in your pubspec.yaml file.

```yaml
  dependencies:
    flutter:
      sdk: flutter
    google_maps_widget:
```

First and foremost, import the widget.
```dart
import 'package:google_maps_widget/google_maps_widget.dart';
```

You can now add a [`GoogleMapsWidget`](https://github.com/rithik-dev/google_maps_widget/blob/master/lib/src/main_widget.dart) widget to your widget tree and pass all the required parameters to get started.
This widget will create a route between the source and the destination LatLng's provided.
```dart
GoogleMapsWidget(
    apiKey: "YOUR KEY HERE",
    sourceLatLng: LatLng(40.484000837597925, -3.369978368282318),
    destinationLatLng: LatLng(40.48017307700204, -3.3618026599287987),
),
```

One can create a controller and interact with the google maps controller, or update the source and destination LatLng's.
```dart
// can create a controller, and call methods to update source loc,
// destination loc, interact with the google maps controller to
// show/hide markers programmatically etc.
final mapsWidgetController = GlobalKey<GoogleMapsWidgetState>();
```
Pass this controller to the `key` param in `GoogleMapsWidget` widget, and then
```dart

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

Sample Usage
```dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_widget/google_maps_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // can create a controller, and call methods to update source loc,
  // destination loc, interact with the google maps controller to
  // show/hide markers programmatically etc.
  final mapsWidgetController = GlobalKey<GoogleMapsWidgetState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: GoogleMapsWidget(
                  apiKey: "YOUR GOOGLE MAPS API KEY HERE",
                  key: mapsWidgetController,
                  sourceLatLng: LatLng(
                    40.484000837597925,
                    -3.369978368282318,
                  ),
                  destinationLatLng: LatLng(
                    40.48017307700204,
                    -3.3618026599287987,
                  ),

                  ///////////////////////////////////////////////////////
                  //////////////    OPTIONAL PARAMETERS    //////////////
                  ///////////////////////////////////////////////////////

                  routeWidth: 2,
                  sourceMarkerIconInfo: MarkerIconInfo(
                    infoWindowTitle: "This is source name",
                    onTapInfoWindow: (_) {
                      print("Tapped on source info window");
                    },
                    assetPath: "assets/images/house-marker-icon.png",
                  ),
                  destinationMarkerIconInfo: MarkerIconInfo(
                    assetPath: "assets/images/restaurant-marker-icon.png",
                  ),
                  driverMarkerIconInfo: MarkerIconInfo(
                    infoWindowTitle: "Alex",
                    assetPath: "assets/images/driver-marker-icon.png",
                    onTapMarker: (currentLocation) {
                      print("Driver is currently at $currentLocation");
                    },
                    assetMarkerSize: Size.square(125),
                    rotation: 90,
                  ),
                  updatePolylinesOnDriverLocUpdate: true,
                  onPolylineUpdate: (_) {
                    print("Polyline updated");
                  },
                  // mock stream
                  driverCoordinatesStream: Stream.periodic(
                    Duration(milliseconds: 500),
                    (i) => LatLng(
                      40.47747872288886 + i / 10000,
                      -3.368043154478073 - i / 10000,
                    ),
                  ),
                  totalTimeCallback: (time) => print(time),
                  totalDistanceCallback: (distance) => print(distance),
                ),
              ),
              // demonstrates how to interact with the controller
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          mapsWidgetController.currentState!.setSourceLatLng(
                            LatLng(
                              40.484000837597925 * (Random().nextDouble()),
                              -3.369978368282318,
                            ),
                          );
                        },
                        child: Text('Update source'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final googleMapsCon = await mapsWidgetController
                              .currentState!
                              .getGoogleMapsController();
                          googleMapsCon.showMarkerInfoWindow(
                            MarkerIconInfo.sourceMarkerId,
                          );
                        },
                        child: Text('Show source info'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

See the [`example`](https://github.com/rithik-dev/google_maps_widget/blob/master/example) directory for a complete sample app.

### Created & Maintained By `Rithik Bhandari`

* GitHub: [@rithik-dev](https://github.com/rithik-dev)
* LinkedIn: [@rithik-bhandari](https://www.linkedin.com/in/rithik-bhandari/)

