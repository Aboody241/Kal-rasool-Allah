class QiblaResult {
  /// Bearing from user to Kaaba (0–360 degrees, clockwise from North)
  final double qiblaBearing;

  /// Distance from user location to Kaaba in kilometers
  final double distanceToKaaba;

  const QiblaResult({
    required this.qiblaBearing,
    required this.distanceToKaaba,
  });
}
