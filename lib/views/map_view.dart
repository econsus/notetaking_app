import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatelessWidget {
  final double latitude;
  final double longitude;

  const MapView({required this.latitude, required this.longitude, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CameraPosition initialPosition = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 14.0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Note Location'),
      ),
      body: GoogleMap(
        initialCameraPosition: initialPosition,
        markers: {
          Marker(
            markerId: MarkerId('noteLocation'),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(title: 'Note Location'),
          ),
        },
      ),
    );
  }
}
