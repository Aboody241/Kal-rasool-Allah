import 'package:kal_rasol_allah/features/qibla/domain/entities/location_entity.dart';

enum QiblaStatus { initial, loading, ready, error }

class QiblaState {
  final QiblaStatus status;
  final String? errorMessage;
  final LocationEntity? userLocation;

  /// Bearing from user to Kaaba (0–360)
  final double qiblaBearing;

  /// Current device compass heading (0–360)
  final double deviceHeading;

  /// The angle to rotate the needle on screen (qiblaBearing - deviceHeading)
  final double finalAngle;

  /// Distance to Kaaba in kilometers
  final double? distanceToKaaba;

  const QiblaState({
    this.status = QiblaStatus.initial,
    this.errorMessage,
    this.userLocation,
    this.qiblaBearing = 0,
    this.deviceHeading = 0,
    this.finalAngle = 0,
    this.distanceToKaaba,
  });

  QiblaState copyWith({
    QiblaStatus? status,
    String? errorMessage,
    LocationEntity? userLocation,
    double? qiblaBearing,
    double? deviceHeading,
    double? finalAngle,
    double? distanceToKaaba,
  }) {
    return QiblaState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      userLocation: userLocation ?? this.userLocation,
      qiblaBearing: qiblaBearing ?? this.qiblaBearing,
      deviceHeading: deviceHeading ?? this.deviceHeading,
      finalAngle: finalAngle ?? this.finalAngle,
      distanceToKaaba: distanceToKaaba ?? this.distanceToKaaba,
    );
  }
}
