library google_maps_widget;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_widget/src/maps_service.dart';

class GoogleMapsWidget extends StatefulWidget {
  final String apiKey;
  final LatLng sourceLatLng;
  final LatLng destinationLatLng;
  final VoidCallback onTapSourceMarker;
  final VoidCallback onTapDestinationMarker;
  final Function(LatLng) onTapDriverMarker;
  final Stream<LatLng> driverCoordinatesStream;
  final LatLng defaultCameraLocation;
  final double defaultCameraZoom;
  final String sourceName;
  final String destinationName;
  final String driverName;
  final Color routeColor;
  final int routeWidth;

  const GoogleMapsWidget({
    @required this.apiKey,
    @required this.sourceLatLng,
    @required this.destinationLatLng,
    this.onTapSourceMarker,
    this.onTapDestinationMarker,
    this.onTapDriverMarker,
    this.driverCoordinatesStream,
    this.defaultCameraLocation,
    this.defaultCameraZoom = 15,
    this.sourceName = "Source",
    this.destinationName = "Destination",
    this.driverName = "Driver",
    this.routeColor = Colors.indigo,
    this.routeWidth = 5,
  });

  @override
  _GoogleMapsWidgetState createState() => _GoogleMapsWidgetState();
}

class _GoogleMapsWidgetState extends State<GoogleMapsWidget> {
  final _mapsService = MapsService();

  @override
  void initState() {
    _mapsService.initialize(
      setState: setState,
      apiKey: this.widget.apiKey,
      sourceLatLng: this.widget.sourceLatLng,
      destinationLatLng: this.widget.destinationLatLng,
      onTapSourceMarker: this.widget.onTapSourceMarker,
      onTapDestinationMarker: this.widget.onTapDestinationMarker,
      onTapDriverMarker: this.widget.onTapDriverMarker,
      driverCoordinatesStream: this.widget.driverCoordinatesStream,
      sourceName: this.widget.sourceName,
      destinationName: this.widget.destinationName,
      driverName: this.widget.driverName,
      routeColor: this.widget.routeColor,
      routeWidth: this.widget.routeWidth,
      defaultCameraLocation: this.widget.defaultCameraLocation,
      defaultCameraZoom: this.widget.defaultCameraZoom,
    );

    super.initState();
  }

  @override
  void dispose() {
    _mapsService.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _mapsService.defaultCameraLocation,
        zoom: _mapsService.defaultCameraZoom,
      ),
      myLocationEnabled: true,
      // compassEnabled: true,
      zoomControlsEnabled: false,
      mapType: MapType.normal,
      markers: _mapsService.markers,
      polylines: _mapsService.polyLines,
      onMapCreated: _mapsService.setController,
    );
  }
}
