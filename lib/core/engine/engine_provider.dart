import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sunnah_engine.dart';

/// Global provider for the Sunnah Engine.
/// This will be overridden in main.dart after asynchronous initialization.
final engineProvider = Provider<SunnahEngine>((ref) {
  throw UnimplementedError('engineProvider has not been initialized');
});
