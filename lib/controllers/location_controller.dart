import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationController with ChangeNotifier {
  Position? _currentPosition;

  Position? get currentPosition => _currentPosition;

  // Method to fetch the user's current location
  Future<Position?> fetchLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return null; // Location services are not enabled
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request location permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permission denied.");
        return null; // Permissions are denied
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Location permission denied forever.");
      return null; // Permissions are denied forever
    }

    // Fetch the current position and store it
    try {
      _currentPosition = await Geolocator.getCurrentPosition();
      print("Location fetched: Latitude: ${_currentPosition?.latitude}, Longitude: ${_currentPosition?.longitude}");
      notifyListeners();  // Notify listeners to update the UI
      return _currentPosition;
    } catch (e) {
      print("Error fetching location: $e");
      return null;
    }
  }
}
