class LocationEntity {
  final double latitude;
  final double longitude;
  final double? accuracy;

  const LocationEntity({
    required this.latitude,
    required this.longitude,
    this.accuracy,
  });
}
