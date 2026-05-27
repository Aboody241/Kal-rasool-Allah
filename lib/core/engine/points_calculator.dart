import 'storage_interface.dart';

class PointsCalculator {
  final Storage _storage;

  static const String _kTotalPoints = 'engine_total_points';
  static const String _kDailyPoints = 'engine_daily_points';

  int _totalPoints = 0;
  int _dailyPoints = 0;

  PointsCalculator(this._storage);

  Future<void> init() async {
    _totalPoints = await _storage.read(_kTotalPoints) ?? 0;
    _dailyPoints = await _storage.read(_kDailyPoints) ?? 0;
  }

  void addPoints(int amount) {
    _totalPoints += amount;
    _dailyPoints += amount;
    
    _saveData(_kTotalPoints, _totalPoints);
    _saveData(_kDailyPoints, _dailyPoints);
  }

  void resetDailyPoints() {
    _dailyPoints = 0;
    _saveData(_kDailyPoints, _dailyPoints);
  }

  int get totalPoints => _totalPoints;
  int get dailyPoints => _dailyPoints;

  /// Returns Level info:
  /// Level 1: 0-100
  /// Level 2: 101-300
  /// Level 3: 301-700
  /// Level 4: 700+
  Map<String, dynamic> getLevelInfo() {
    int level = 1;
    double progress = 0.0;
    
    if (_totalPoints <= 100) {
      level = 1;
      progress = _totalPoints / 100.0;
    } else if (_totalPoints <= 300) {
      level = 2;
      progress = (_totalPoints - 100) / 200.0;
    } else if (_totalPoints <= 700) {
      level = 3;
      progress = (_totalPoints - 300) / 400.0;
    } else {
      level = 4;
      progress = 1.0;
    }

    return {
      'level': level,
      'progress': progress.clamp(0.0, 1.0),
    };
  }

  Future<void> _saveData(String key, dynamic value) async {
    await _storage.save(key, value);
  }
}
