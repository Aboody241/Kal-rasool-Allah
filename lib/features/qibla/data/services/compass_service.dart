
import 'package:flutter_compass/flutter_compass.dart';

class CompassService {
  /// Returns a stream of device heading values (0–360 degrees).
  /// Emits null if the device has no compass sensor.
  Stream<double> get headingStream {
    if (FlutterCompass.events == null) {
      throw Exception('هذا الجهاز لا يحتوي على مستشعر بوصلة (Magnetometer) للأسف.');
    }
    return FlutterCompass.events!
        .where((event) => event.heading != null)
        .map((event) => event.heading!);
  }
}
