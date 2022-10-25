## [1.0.5] - 25/10/2022

* BREAKING: `MarkerIconInfo` inputs are now non-nullable
* BREAKING: Added properties `onTapMarker`, `onTapInfoWindow`, `infoWindowTitle` and `isVisible` to `MarkerIconInfo`, and removed corresponding params for source, destination, driver from `GoogleMapsWidget`
* Changed internal implementation of the widget
* Added `layoutDirection` property
* Exposed state class to allow updating source/destination lat lng, or interacting with google maps con directly
* Updated a dependency to the latest release
* Updated example app
* Updated README.md

## [1.0.4] - 15/06/2022

* Added updatePolylinesOnDriverLocUpdate to update directions based on current driver location
* Updated dependencies
* Updated example app
* Updated README.md

## [1.0.3] - 14/06/2022

* Added rotation and anchor to MarkerIconInfo
* Updated README.md

## [1.0.2] - 07/06/2022

* Updated dependencies
* Updated linter warnings

## [1.0.1] - 26/01/2022

* Updated license
* Updated README.md

## [1.0.0] - 26/01/2022

* Added linter and updated code accordingly
* Updated dependencies
* Removed unused dependencies
* Updated README.md

## [0.0.9] - 06/10/2021

* Fixed issue #2

## [0.0.8] - 12/05/2021

* Fixed key parameter

## [0.0.7] - 18/04/2021

* Set of markers can be passed to show on the map (apart from the source/destination/driver markers).
* Set of polylines can be passed to show on the map apart from the one created between source and destination.
* Added the option to not render the created markers and polylines.

## [0.0.6] - 14/04/2021

* Updated README.md

## [0.0.5] - 13/04/2021

* Added web support

## [0.0.4] - 12/04/2021

* Added dart doc comments
* Updated package description.
* Updated README.
* Updated example app

## [0.0.3] - 12/04/2021

* Updated package description.

## [0.0.2] - 12/04/2021

* Minor readme fixes.
* Added package description.

## [0.0.1] - 12/04/2021

* A Google Maps helper widget which can be used to draw route from a given source latitude and longitude. The route is customizable in terms of color and width.
* The plugin also offers realtime location tracking for a driver(if any) and shows a marker on the map which updates everytimes the driver's location changes.
* The markers are customizable and on tap callbacks are implemented that give the current location and a lot of parameters which can be explored.

