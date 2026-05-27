import 'dart:math';

/// Pure Dart — no dependencies on Flutter or external packages.
class QiblaCalculator {
  static const double _kaabaLat = 21.4225;
  static const double _kaabaLon = 39.8262;
  static const double _earthRadiusKm = 6371.0;

  /// Calculates the Qibla bearing from the user's location.
  /// Returns a value between 0 and 360 degrees (clockwise from North).
  static double calculateQiblaBearing(double userLat, double userLon) {
    final lat1 = _toRad(userLat);
    final lat2 = _toRad(_kaabaLat);
    final dLon = _toRad(_kaabaLon - userLon);

    final x = sin(dLon) * cos(lat2);
    final y =
        cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    final bearingRad = atan2(x, y);
    return (_toDeg(bearingRad) + 360) % 360;
  }

  /// Calculates the great-circle distance from user to Kaaba using Haversine.
  /// Returns distance in kilometers.
  static double calculateDistanceToKaaba(double userLat, double userLon) {
    final lat1 = _toRad(userLat);
    final lat2 = _toRad(_kaabaLat);
    final dLat = _toRad(_kaabaLat - userLat);
    final dLon = _toRad(_kaabaLon - userLon);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return _earthRadiusKm * c;
  }

  /// Computes the final needle angle relative to device heading.
  /// Result is normalized to [0, 360).
  static double computeFinalAngle(double qiblaBearing, double deviceHeading) {
    return (qiblaBearing - deviceHeading + 360) % 360;
  }

  static double _toRad(double deg) => deg * pi / 180;
  static double _toDeg(double rad) => rad * 180 / pi;
}
