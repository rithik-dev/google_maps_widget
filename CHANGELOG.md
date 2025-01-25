# [1.0.6]

* FIX: Bug where `assetMarkerSize` in `MarkerIconInfo`  does not apply if `icon` is passed. 
* Fix Dart static analysis warnings
* Updated README.md
* Updated example app
* Updated dependencies

# [1.0.5+1]

* Updated README.md

# [1.0.5]

* BREAKING: `MarkerIconInfo` inputs are now non-nullable
* BREAKING: Added properties `onTapMarker`, `onTapInfoWindow`, `infoWindowTitle` and `isVisible` to `MarkerIconInfo`, and removed corresponding params for source, destination, driver from `GoogleMapsWidget`
* Changed internal implementation of the widget
* Added `layoutDirection` property
* Added `onPolylineUpdate` callback
* Exposed state class to allow updating source/destination lat lng, or interacting with google maps con directly
* Updated a dependency to the latest release
* Updated example app
* Updated README.md

# [1.0.4]

* Added updatePolylinesOnDriverLocUpdate to update directions based on current driver location
* Updated dependencies
* Updated example app
* Updated README.md

# [1.0.3]

* Added rotation and anchor to MarkerIconInfo
* Updated README.md

# [1.0.2]

* Updated dependencies
* Updated linter warnings

# [1.0.1]

* Updated license
* Updated README.md

# [1.0.0]

* Added linter and updated code accordingly
* Updated dependencies
* Removed unused dependencies
* Updated README.md

# [0.0.9]

* Fixed issue #2

# [0.0.8]

* Fixed key parameter

# [0.0.7]

* Set of markers can be passed to show on the map (apart from the source/destination/driver markers).
* Set of polylines can be passed to show on the map apart from the one created between source and destination.
* Added the option to not render the created markers and polylines.

# [0.0.6]

* Updated README.md

# [0.0.5]

* Added web support

# [0.0.4]

* Added dart doc comments
* Updated package description.
* Updated README.
* Updated example app

# [0.0.3]

* Updated package description.

# [0.0.2]

* Minor readme fixes.
* Added package description.

# [0.0.1]

* A Google Maps helper widget which can be used to draw route from a given source latitude and longitude. The route is customizable in terms of color and width.
* The plugin also offers realtime location tracking for a driver(if any) and shows a marker on the map which updates everytimes the driver's location changes.
* The markers are customizable and on tap callbacks are implemented that give the current location and a lot of parameters which can be explored.
