import 'package:kal_rasol_allah/features/qibla/domain/entities/location_entity.dart';
import 'package:kal_rasol_allah/features/qibla/domain/entities/qibla_result.dart';
import 'package:kal_rasol_allah/features/qibla/data/services/location_service.dart';
import 'package:kal_rasol_allah/features/qibla/domain/calculator/qibla_calculator.dart';

class GetQiblaDirection {
  final LocationService _locationService;

  GetQiblaDirection(this._locationService);

  /// Requests permission, gets location, then computes QiblaResult.
  /// Throws a descriptive [Exception] on any failure.
  Future<({LocationEntity location, QiblaResult result})> execute() async {
    // 1. Handle permissions
    final permStatus = await _locationService.requestPermission();

    switch (permStatus) {
      case LocationPermissionStatus.serviceDisabled:
        throw Exception('خدمة الموقع معطلة. يرجى تفعيلها من الإعدادات.');
      case LocationPermissionStatus.denied:
        throw Exception('تم رفض إذن الموقع.');
      case LocationPermissionStatus.deniedForever:
        throw Exception(
            'تم رفض إذن الموقع بشكل دائم. يرجى السماح له من إعدادات التطبيق.');
      case LocationPermissionStatus.granted:
        break;
    }

    // 2. Get location
    final location = await _locationService.getCurrentLocation();

    // 3. Calculate
    final bearing = QiblaCalculator.calculateQiblaBearing(
      location.latitude,
      location.longitude,
    );
    final distance = QiblaCalculator.calculateDistanceToKaaba(
      location.latitude,
      location.longitude,
    );

    return (
      location: location,
      result: QiblaResult(qiblaBearing: bearing, distanceToKaaba: distance),
    );
  }
}
