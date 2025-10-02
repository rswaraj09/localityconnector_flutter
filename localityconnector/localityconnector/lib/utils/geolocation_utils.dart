import 'dart:math';

/// Utility class for geolocation operations, particularly optimizing Firestore
/// geolocation queries
class GeolocationUtils {
  /// Calculates approximate distance between two coordinates using the Haversine formula
  /// Returns distance in kilometers
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    final double latDiff = _degreesToRadians(lat2 - lat1);
    final double lonDiff = _degreesToRadians(lon2 - lon1);

    final double a = sin(latDiff / 2) * sin(latDiff / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(lonDiff / 2) *
            sin(lonDiff / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Creates a bounding box for geographical search
  /// Returns a map with the coordinates of the bounding box corners
  static Map<String, double> getBoundingBox(
    double latitude,
    double longitude,
    double radiusInKm,
  ) {
    // Earth's radius in kilometers
    const double earthRadius = 6371;

    // Angular distance in radians on a great circle
    double radDist = radiusInKm / earthRadius;

    // Convert latitude and longitude to radians
    double radLat = _degreesToRadians(latitude);
    double radLon = _degreesToRadians(longitude);

    // Calculate min and max latitudes (North/South bounds)
    double minLat = radLat - radDist;
    double maxLat = radLat + radDist;

    // Calculate min and max longitudes (East/West bounds)
    // This will be dependent on latitude
    double minLon, maxLon;

    // If the latitude goes outside of the poles
    if (minLat > -pi / 2 && maxLat < pi / 2) {
      double deltaLon = asin(sin(radDist) / cos(radLat));
      minLon = radLon - deltaLon;
      maxLon = radLon + deltaLon;

      // Adjust for the poles - this is to avoid wrapping around
      if (minLon < -pi) minLon += 2 * pi;
      if (maxLon > pi) maxLon -= 2 * pi;
    } else {
      // Near the poles, all longitudes may be included
      minLat = max(minLat, -pi / 2);
      maxLat = min(maxLat, pi / 2);
      minLon = -pi;
      maxLon = pi;
    }

    // Convert back to degrees
    return {
      'minLat': _radiansToDegrees(minLat),
      'maxLat': _radiansToDegrees(maxLat),
      'minLon': _radiansToDegrees(minLon),
      'maxLon': _radiansToDegrees(maxLon),
    };
  }

  /// Convert radians to degrees
  static double _radiansToDegrees(double radians) {
    return radians * (180 / pi);
  }
}
