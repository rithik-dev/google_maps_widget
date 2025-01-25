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
- **[❓ Usage](#-usage)**  
- **[🎯 Sample Usage](#-sample-usage)**
- **[👤 Collaborators](#-collaborators)**

---

# 📷 Screenshots

| With Source InfoWindow | With Rider Icon | With Rider Icon InfoWindow |
|-----------------------------------|-------------------------------------|-------------------------------------|
| <img src="https://user-images.githubusercontent.com/56810766/114386992-8fdadf00-9baf-11eb-84f2-22593024b533.png" height="500"> | <img src="https://user-images.githubusercontent.com/56810766/114386995-90737580-9baf-11eb-8cd7-056444554204.png" height="500"> | <img src="https://user-images.githubusercontent.com/56810766/114386985-8e111b80-9baf-11eb-9bfa-8e4d6d3364f5.png" height="500"> |

---

# ✨ Features

- **Route Creation:** Draw polylines (routes) between two locations by providing their latitude and longitude.
- **Customizable Route Appearance:** Customize the route’s color and width.
- **Real-time Location Tracking:** Offers real-time location tracking for drivers, with an automatically updating marker on the map as the driver's location changes.
- **Marker Customization:** Fully customizable markers.
- **User Interaction Handling:** onTap callbacks for all markers and info windows to handle user interactions easily.
- **Full Google Maps Parameter Support:** Supports passing nearly all parameters from google_maps_flutter for the GoogleMap widget as arguments to the plugin.

---

# 🚀 Getting Started

## Step 1: Get an API Key
Visit [Google Cloud Maps Platform](https://cloud.google.com/maps-platform) and obtain an API key.

## Step 2: Enable Google Maps SDK for Each Platform and Directions API
* Go to [Google Developers Console](https://console.cloud.google.com), select your project, and open the Google Maps section from the navigation menu. Under APIs, enable Maps SDK for Android, Maps SDK for iOS, and Maps JavaScript API for web under the "Additional APIs" section.

* To enable Directions API, select "Directions API" in the "Additional APIs" section, then select "ENABLE".

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
               android:value="YOUR KEY HERE"/>
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

## Web
> [!NOTE]
> Refer to the platform specific setup for google maps [here](https://pub.dev/packages/google_maps_flutter#web)

Modify web/index.html

Get an API Key for Google Maps JavaScript API. Get started [here](https://developers.google.com/maps/documentation/javascript/get-api-key).
Modify the `<head>` tag of your `web/index.html` to load the Google Maps JavaScript API, like so:
```html
<head>

  <!-- // Other stuff -->

  <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_KEY_HERE"></script>
</head>
```

---

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
  apiKey: "YOUR KEY HERE",
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

---

# 🎯 Sample Usage

# FIXME

See the [example](https://github.com/rithik-dev/google_maps_widget/blob/master/example) app for a complete app. Learn how to setup the example app for testing [here](https://github.com/rithik-dev/google_maps_widget/blob/master/example/README.md).

Check out the full API reference of the widget [here](https://pub.dev/documentation/google_maps_widget/latest/google_maps_widget/GoogleMapsWidget-class.html).

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

---

# 👤 Collaborators


| Name | GitHub | Linkedin |
|-----------------------------------|-------------------------------------|-------------------------------------|
| Rithik Bhandari | [github/rithik-dev](https://github.com/rithik-dev) | [linkedin/rithik-bhandari](https://www.linkedin.com/in/rithik-bhandari) |
