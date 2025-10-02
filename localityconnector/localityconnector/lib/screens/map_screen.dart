import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import '../models/business.dart';
import '../models/database_helper.dart';
import '../services/location_service.dart';
import '../utils/geolocation_utils.dart';
import 'business_detail_screen.dart';

class MapScreen extends StatefulWidget {
  final int? categoryId;

  const MapScreen({super.key, this.categoryId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  LocationService _locationService = LocationService();
  LatLng _center = const LatLng(0, 0); // Default center
  bool _isLoading = true;
  Set<Marker> _markers = {};
  double _currentZoom = 13.0;
  double _radiusInKm = 1.0; // Default radius for filtering businesses (1km)

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _loadBusinesses();
  }

  // Get user's current location
  Future<void> _getUserLocation() async {
    try {
      Position locationData = await _locationService.getCurrentLocation();

      if (locationData != null) {
        setState(() {
          _center = LatLng(locationData.latitude, locationData.longitude);
          _isLoading = false;
        });

        _mapController.animateCamera(
          CameraUpdate.newLatLng(_center),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Calculate distance using Haversine formula with sin, cos, and tan
  double _calculatePreciseDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371.0; // Earth's radius in kilometers

    // Convert degrees to radians
    double lat1Rad = _degreesToRadians(lat1);
    double lon1Rad = _degreesToRadians(lon1);
    double lat2Rad = _degreesToRadians(lat2);
    double lon2Rad = _degreesToRadians(lon2);

    // Haversine formula using sin and cos
    double dLat = lat2Rad - lat1Rad;
    double dLon = lon2Rad - lon1Rad;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);

    // Use arc tangent (atan2) to calculate central angle
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    // Calculate distance
    double distance = earthRadius * c;

    return distance;
  }

  // Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  // Load businesses based on filter and distance
  Future<void> _loadBusinesses() async {
    try {
      List<Business> allBusinesses;

      if (widget.categoryId != null) {
        // Load businesses by category
        allBusinesses = await DatabaseHelper.instance
            .getBusinessesByCategory(widget.categoryId!);
      } else {
        // Load all businesses
        allBusinesses = await DatabaseHelper.instance.getAllBusinesses();
      }

      // Filter businesses by distance (1km radius)
      List<Business> filteredBusinesses = [];
      for (Business business in allBusinesses) {
        if (business.latitude != null && business.longitude != null) {
          // Calculate distance using custom trigonometric calculation
          double distance = _calculatePreciseDistance(_center.latitude,
              _center.longitude, business.latitude!, business.longitude!);

          // Only include businesses within specified radius
          if (distance <= _radiusInKm) {
            // Add distance information to the business
            Business businessWithDistance =
                business.copyWith(distance: distance);
            filteredBusinesses.add(businessWithDistance);
          }
        }
      }

      // Sort businesses by distance (closest first)
      filteredBusinesses.sort((a, b) {
        final distanceA = a.distance ?? double.infinity;
        final distanceB = b.distance ?? double.infinity;
        return distanceA.compareTo(distanceB);
      });

      Set<Marker> markers = {};

      for (Business business in filteredBusinesses) {
        if (business.latitude != null && business.longitude != null) {
          markers.add(
            Marker(
              markerId: MarkerId(business.id.toString()),
              position: LatLng(business.latitude!, business.longitude!),
              infoWindow: InfoWindow(
                title: business.businessName,
                snippet: business.businessType != null
                    ? '${business.businessType} • ${(business.distance! * 1000).round()}m away'
                    : '${(business.distance! * 1000).round()}m away',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BusinessDetailScreen(businessId: business.id!),
                    ),
                  );
                },
              ),
            ),
          );
        }
      }

      setState(() {
        _markers = markers;
      });
    } catch (e) {
      print('Error loading businesses: $e');
    }
  }

  // Change the radius and reload businesses
  void _updateRadius(double newRadius) {
    setState(() {
      _radiusInKm = newRadius;
    });
    _loadBusinesses();
  }

  // Calculate bearing angle between two coordinates
  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    // Convert to radians
    double lat1Rad = _degreesToRadians(lat1);
    double lon1Rad = _degreesToRadians(lon1);
    double lat2Rad = _degreesToRadians(lat2);
    double lon2Rad = _degreesToRadians(lon2);

    // Calculate delta longitude
    double dLon = lon2Rad - lon1Rad;

    // Calculate bearing using trigonometric functions
    double y = sin(dLon) * cos(lat2Rad);
    double x =
        cos(lat1Rad) * sin(lat2Rad) - sin(lat1Rad) * cos(lat2Rad) * cos(dLon);

    // Convert to degrees and normalize to 0-360
    double bearingRad = atan2(y, x);
    double bearingDeg = _radiansToDegrees(bearingRad);

    return (bearingDeg + 360) % 360;
  }

  // Convert radians to degrees
  double _radiansToDegrees(double radians) {
    return radians * (180.0 / pi);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryId != null
            ? 'Category Businesses'
            : 'All Businesses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _getUserLocation();
              _loadBusinesses();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: _currentZoom,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  onCameraMove: (CameraPosition position) {
                    _currentZoom = position.zoom;
                  },
                  circles: {
                    Circle(
                      circleId: const CircleId('1kmRadius'),
                      center: _center,
                      radius: _radiusInKm * 1000, // Convert km to meters
                      fillColor: Colors.blue.withOpacity(0.1),
                      strokeColor: Colors.blue,
                      strokeWidth: 1,
                    ),
                  },
                ),
                Positioned(
                  bottom: 100,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _getUserLocation,
                    child: const Icon(Icons.my_location),
                  ),
                ),
                Positioned(
                  bottom: 160,
                  right: 16,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Set Radius'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                  'Current radius: ${_radiusInKm.toStringAsFixed(1)} km'),
                              Slider(
                                value: _radiusInKm,
                                min: 0.1,
                                max: 5.0,
                                divisions: 49,
                                label: _radiusInKm.toStringAsFixed(1) + ' km',
                                onChanged: (value) {
                                  setState(() {
                                    _radiusInKm = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                _updateRadius(_radiusInKm);
                                Navigator.pop(context);
                              },
                              child: const Text('Apply'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.radar),
                    label: Text('${_radiusInKm.toStringAsFixed(1)} km'),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
