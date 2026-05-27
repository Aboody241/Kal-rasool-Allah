import 'package:geolocator/geolocator.dart';
import 'package:kal_rasol_allah/features/qibla/domain/entities/location_entity.dart';

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

class LocationService {
  /// Requests location permission and returns the current status.
  Future<LocationPermissionStatus> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationPermissionStatus.serviceDisabled;

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermissionStatus.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }

    return LocationPermissionStatus.granted;
  }

  /// Returns the user's location.
  /// First tries the last known cached position (instant).
  /// Falls back to a fresh position with medium accuracy for a faster GPS fix.
  Future<LocationEntity> getCurrentLocation() async {
    // ✅ 1. جرب الموقع الأخير المخزن أولاً — فوري بدون انتظار
    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        // قبول آخر موقع لو عمره أقل من 10 دقايق
        final age = DateTime.now().difference(lastKnown.timestamp);
        if (age.inMinutes < 10) {
          return LocationEntity(
            latitude: lastKnown.latitude,
            longitude: lastKnown.longitude,
            accuracy: lastKnown.accuracy,
          );
        }
      }
    } catch (_) {
      // نكمل لو فشل
    }

    // ✅ 2. اجلب موقع جديد بـ medium accuracy عشان يكون أسرع
    // بدون timeLimit عشان مانعطيش timeout على المستخدم
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );

    return LocationEntity(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
    );
  }
}
