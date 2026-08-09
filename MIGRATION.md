# Migration Guide

## 1.0.x to 2.0.0

This release raises the minimum SDK and changes a few behaviours that were
previously bugs. Most apps need only the SDK bump.

### 1. Raise your Flutter and Dart SDK (required)

`google_maps_flutter` 2.18.0 requires a newer SDK, so this package does too:

```yaml
environment:
  sdk: ^3.10.0
  flutter: ">=3.38.0"
```

If you cannot move off an older Flutter yet, stay on `google_maps_widget: 1.0.8`.
There is no other way around this: the constraint comes from the underlying
plugin, not from this package.

### 1b. Raise your platform minimums (required)

The newer `google_maps_flutter` also raises the native floors. Existing projects
generated a few Flutter versions ago will fail to build until these are updated.

**Android.** `minSdk` is now 24, and the Flutter Gradle plugin requires
Gradle 8.7.0 or newer. If your build fails with "Your project's Gradle version
is lower than Flutter's minimum supported version", update
`android/gradle/wrapper/gradle-wrapper.properties` and the Android Gradle Plugin
and Kotlin versions in `android/settings.gradle`. The combination this package's
example uses, which is what `flutter create` generates on Flutter 3.44.8:

| Component | Version |
| --- | --- |
| Gradle | 9.1.0 |
| Android Gradle Plugin | 9.0.1 |
| Kotlin | 2.3.20 |
| Java source/target | 17 |

Gradle 9 also removed the mutable `buildDir` property. If your
`android/build.gradle` still assigns `rootProject.buildDir`, switch it to
`rootProject.layout.buildDirectory`.

**iOS.** The deployment target is now 14.0, above the Flutter template default
of 13.0. Set `platform :ios, '14.0'` in `ios/Podfile` and
`IPHONEOS_DEPLOYMENT_TARGET = 14.0` in `ios/Runner.xcodeproj/project.pbxproj`,
then run `pod install`.

### 2. `sourceLatLng` and `destinationLatLng` now react to rebuilds

Previously these were read once, in `initState`. Passing new values and
rebuilding did nothing, and the only way to move the route was the imperative
API on the state.

Both now work:

```dart
// Declarative: rebuild with a new value.
GoogleMapsWidget(
  sourceLatLng: _source,
  destinationLatLng: _destination,
  ...
)

// Imperative: still supported, unchanged.
mapsWidgetController.currentState?.setSourceLatLng(newSource);
```

The imperative API still wins while the widget's own value is unchanged, so
mixing the two is safe. A rebuild only overwrites the coordinates when the
value you pass actually differs from the previous one.

**What to check:** if you build the coordinates inline from a value that
changes often, every distinct value now triggers a Routes API request.
Hoist them into state, or memoize, if that matters for your quota.

### 2b. The route now comes from the Routes API

The legacy Directions API is in Legacy status, and Google does not allow it to
be enabled on new Cloud projects, so a fresh install of this package could not
fetch a route at all. Routes are now requested from the **Routes API**.

**Enable the Routes API** on your key, alongside the Maps SDKs. Existing
projects keep working once it is enabled; nothing else about the key changes.

The Routes API reports distance and duration numerically rather than as
localized text, so the two callbacks changed type:

```dart
// Before: localized strings from Google, for example "1.2 km" and "4 mins".
totalDistanceCallback: (String? distance) => print(distance),
totalTimeCallback: (String? time) => print(time),

// After: format them yourself, so they match your app's locale.
totalDistanceCallback: (int metres) => print('${(metres / 1000).toStringAsFixed(1)} km'),
totalTimeCallback: (Duration duration) => print('${duration.inMinutes} min'),
```

`DirectionsException` is now `RoutesApiException`, with the same `message` and
`status` fields. `status` now carries the Routes API's own codes, such as
`PERMISSION_DENIED`, rather than `REQUEST_DENIED`.

### 3. Route failures are reported instead of thrown

A failed route request used to surface as an uncaught async error. It is
now caught, and reported through the new `onError` callback.

If you relied on a zone or `FlutterError.onError` to notice these, add the
callback instead:

```dart
GoogleMapsWidget(
  onError: (error, stackTrace) {
    // error is a RoutesApiException
    debugPrint('$error');
  },
  ...
)
```

This is worth wiring up even if you never had an error handler. A key without
the Routes API enabled fails only on the route, so without this callback it
looks identical to a broken map.

### 4. Behaviour fixes you may have worked around

* Updating the source or destination no longer leaves the previous route drawn
  underneath the new one. If you were clearing polylines yourself to work
  around this, you can stop.
* Setting `isVisible: false` on a marker now removes it. Previously the last
  rendered marker stayed on the map.
* Toggling `showPolyline` to false now clears the generated route.

### 5. Theming

`style` takes a Google Maps style JSON and can be changed at any time, so the
map restyles with an in-app theme toggle. Which style to show is your decision:

```dart
GoogleMapsWidget(
  style: isDark ? darkMapStyleJson : lightMapStyleJson,
  ...
)
```

`colorScheme` is also exposed for Google's built-in light and dark schemes, but
it is only read when the map is created, so it cannot follow a runtime toggle.
Use `style` for that.

### 6. New pass-through parameters

`clusterManagers`, `groundOverlays`, `heatmaps`, `markerType`,
`fortyFiveDegreeImageryEnabled`, `fullscreenControlEnabled`,
`mapTypeControlEnabled`, `streetViewControlEnabled`, `webCameraControlEnabled`,
`webCameraControlPosition` and `webGestureHandling` are now forwarded to
`GoogleMap`. All are optional and default to the same values `GoogleMap` uses.
