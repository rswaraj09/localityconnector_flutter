import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' hide LocationAccuracy;
import 'package:geolocator/geolocator.dart' as geolocator show LocationAccuracy;
import 'package:flutter/foundation.dart' show kIsWeb;

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final Location _location = Location();

  // Cache for location data
  Position? _cachedPosition;
  DateTime? _lastLocationTime;

  // Cache for address data - key is "lat,lng", value is address
  final Map<String, String> _addressCache = {};

  // Maximum age of cached location data (5 minutes)
  static const Duration _maxLocationAge = Duration(minutes: 5);

  // Request location permissions and enable service
  Future<bool> requestPermission() async {
    if (kIsWeb) {
      // Web platform has different permission model
      return true;
    }

    try {
      bool serviceEnabled;
      PermissionStatus permissionGranted;

      // Check if location services are enabled
      serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return false;
        }
      }

      // Check if permission is granted
      permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return false;
        }
      }

      return true;
    } catch (e) {
      print("Location permission error: $e");
      return false;
    }
  }

  // Get current position using Geolocator with caching
  Future<Position> getCurrentLocation() async {
    // Check if we have a recent cached location
    if (_cachedPosition != null && _lastLocationTime != null) {
      final age = DateTime.now().difference(_lastLocationTime!);
      if (age < _maxLocationAge) {
        return _cachedPosition!;
      }
    }

    if (kIsWeb) {
      // Return a default position for web
      final position = Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );

      // Cache the position
      _cachedPosition = position;
      _lastLocationTime = DateTime.now();

      return position;
    }

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, request user to enable them
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      // Use a shorter timeout to avoid long delays (3 seconds)
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.high,
        timeLimit: const Duration(seconds: 3),
      );

      // Cache the position
      _cachedPosition = position;
      _lastLocationTime = DateTime.now();

      return position;
    } catch (e) {
      // If timeout occurs, try with lower accuracy
      print('Error getting high accuracy location: $e');

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.low,
        timeLimit: const Duration(seconds: 2),
      );

      // Cache the position
      _cachedPosition = position;
      _lastLocationTime = DateTime.now();

      return position;
    }
  }

  // Get current location using Location package (legacy method)
  Future<LocationData?> getLocationData() async {
    if (kIsWeb) {
      // Return a default location for web
      return LocationData.fromMap({
        'latitude': 37.7749,
        'longitude': -122.4194,
        'accuracy': 0.0,
        'altitude': 0.0,
        'speed': 0.0,
        'speed_accuracy': 0.0,
        'heading': 0.0,
        'time': DateTime.now().millisecondsSinceEpoch,
        'is_mocked': false,
      });
    }

    try {
      if (await requestPermission()) {
        return await _location.getLocation();
      }
      return null;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Get address from coordinates with caching
  Future<String?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    if (latitude == 0 || longitude == 0) {
      print('Error getting address: Invalid coordinates');
      return "Unknown location";
    }

    // Create a cache key
    final cacheKey = '$latitude,$longitude';

    // Check if we have this address cached
    if (_addressCache.containsKey(cacheKey)) {
      return _addressCache[cacheKey];
    }

    try {
      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        geocoding.Placemark place = placemarks[0];

        // Enhanced address formatting
        String formattedAddress = "";

        // If there's a meaningful street name (not "Unnamed Road"), use it
        if (place.street != null &&
            place.street!.isNotEmpty &&
            !place.street!.toLowerCase().contains("unnamed")) {
          formattedAddress += place.street!;
        }

        // Add sublocality if available
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          if (formattedAddress.isNotEmpty) formattedAddress += ", ";
          formattedAddress += place.subLocality!;
        }

        // Add locality (city/town) if available
        if (place.locality != null && place.locality!.isNotEmpty) {
          if (formattedAddress.isNotEmpty) formattedAddress += ", ";
          formattedAddress += place.locality!;
        }

        // Add administrative area (state/province) if available
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          if (formattedAddress.isNotEmpty) formattedAddress += ", ";
          formattedAddress += place.administrativeArea!;
        }

        // Add postal code if available
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          if (formattedAddress.isNotEmpty) formattedAddress += ", ";
          formattedAddress += place.postalCode!;
        }

        // Add country as the last component
        if (place.country != null && place.country!.isNotEmpty) {
          if (formattedAddress.isNotEmpty) formattedAddress += ", ";
          formattedAddress += place.country!;
        }

        // If we still don't have a meaningful address, fallback to something more useful
        if (formattedAddress.isEmpty ||
            formattedAddress.startsWith("Unnamed")) {
          formattedAddress = "Current Location";

          // Try to add at least city/state/country if available
          if (place.locality != null && place.locality!.isNotEmpty) {
            formattedAddress += " in ${place.locality}";

            if (place.administrativeArea != null &&
                place.administrativeArea!.isNotEmpty) {
              formattedAddress += ", ${place.administrativeArea}";
            }
          }
        }

        // Cache the result
        _addressCache[cacheKey] = formattedAddress;

        return formattedAddress;
      }
      return "Current Location";
    } catch (e) {
      print('Error getting address: $e');
      return "Current Location";
    }
  }

  // Get coordinates from address
  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    if (address.isEmpty) {
      print('Error getting coordinates: Address is empty');
      return const LatLng(0, 0);
    }

    try {
      List<geocoding.Location> locations =
          await geocoding.locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
      // Return a default location when address lookup fails
      return const LatLng(37.7749, -122.4194); // Default to San Francisco
    } catch (e) {
      print('Error getting coordinates: $e');
      // Return a default location for error cases
      return const LatLng(37.7749, -122.4194); // Default to San Francisco
    }
  }

  // Calculate distance between two coordinates in kilometers
  double calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    try {
      return Geolocator.distanceBetween(
              startLatitude, startLongitude, endLatitude, endLongitude) /
          1000; // Convert meters to kilometers
    } catch (e) {
      print('Error calculating distance: $e');
      return 0.0;
    }
  }
}
