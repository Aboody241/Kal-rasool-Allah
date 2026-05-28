import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kal_rasol_allah/features/qibla/data/services/compass_service.dart';
import 'package:kal_rasol_allah/features/qibla/data/services/location_service.dart';
import 'package:kal_rasol_allah/features/qibla/domain/calculator/qibla_calculator.dart';
import 'package:kal_rasol_allah/features/qibla/domain/usecases/get_qibla_direction.dart';
import 'package:kal_rasol_allah/features/qibla/presentation/controller/qibla_state.dart';

class QiblaController extends StateNotifier<QiblaState> {
  final GetQiblaDirection _getQiblaDirection;
  final CompassService _compassService;

  StreamSubscription<double>? _compassSubscription;

  QiblaController({
    required GetQiblaDirection getQiblaDirection,
    required CompassService compassService,
  })  : _getQiblaDirection = getQiblaDirection,
        _compassService = compassService,
        super(const QiblaState()) {
    initialize();
  }

  /// Entry point — called automatically on construction.
  Future<void> initialize() async {
    state = state.copyWith(status: QiblaStatus.loading);

    try {
      // 1. Get location + compute qibla
      final payload = await _getQiblaDirection.execute();

      state = state.copyWith(
        status: QiblaStatus.ready,
        userLocation: payload.location,
        qiblaBearing: payload.result.qiblaBearing,
        distanceToKaaba: payload.result.distanceToKaaba,
        finalAngle: QiblaCalculator.computeFinalAngle(
          payload.result.qiblaBearing,
          state.deviceHeading,
        ),
      );

      // 2. Subscribe to compass stream — minimal rebuilds via targeted updates
      _compassSubscription =
          _compassService.headingStream.listen(
        _onHeadingUpdate,
        onError: (e) {
          state = state.copyWith(
            status: QiblaStatus.error,
            errorMessage: 'حدث خطأ أثناء قراءة مستشعر البوصلة.',
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: QiblaStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void _onHeadingUpdate(double heading) {
    if (!mounted) return;

    final finalAngle =
        QiblaCalculator.computeFinalAngle(state.qiblaBearing, heading);

    // Only update heading-related fields — avoids full widget tree rebuild
    state = state.copyWith(
      deviceHeading: heading,
      finalAngle: finalAngle,
    );
  }

  /// Allows the user to retry after an error.
  Future<void> retry() => initialize();

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }
}

// ============================================================
// Providers
// ============================================================

final _locationServiceProvider = Provider<LocationService>(
  (_) => LocationService(),
);

final _compassServiceProvider = Provider<CompassService>(
  (_) => CompassService(),
);

final _getQiblaDirectionProvider = Provider<GetQiblaDirection>((ref) {
  return GetQiblaDirection(ref.read(_locationServiceProvider));
});

final qiblaControllerProvider =
    StateNotifierProvider.autoDispose<QiblaController, QiblaState>((ref) {
  return QiblaController(
    getQiblaDirection: ref.read(_getQiblaDirectionProvider),
    compassService: ref.read(_compassServiceProvider),
  );
});
